import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(const MyMoneyApp());
}

class MyMoneyApp extends StatelessWidget {
  const MyMoneyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "MyMoney",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Arial'),
      home: const RegistrationLoginPage(),
    );
  }
}

// =================== REGISTRATION / LOGIN ===================
class RegistrationLoginPage extends StatefulWidget {
  const RegistrationLoginPage({super.key});

  @override
  State<RegistrationLoginPage> createState() => _RegistrationLoginPageState();
}

class _RegistrationLoginPageState extends State<RegistrationLoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  String? savedUsername;
  String? savedPassword;
  bool isRegistered = false;

  @override
  void initState() {
    super.initState();
    _loadCredentials();
  }

  Future<void> _loadCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      savedUsername = prefs.getString("username");
      savedPassword = prefs.getString("password");
      isRegistered = savedUsername != null && savedPassword != null;
    });
  }

  Future<void> _register() async {
    if (usernameController.text.isNotEmpty &&
        passwordController.text.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("username", usernameController.text);
      await prefs.setString("password", passwordController.text);
      await prefs.setString("transactions", jsonEncode([]));
      await prefs.setString(
          "rates", jsonEncode({"USD": 1.0, "BDT": 110.0, "EUR": 0.9}));
      _loadCredentials();
    }
  }

  Future<void> _login() async {
    if (usernameController.text == savedUsername &&
        passwordController.text == savedPassword) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                MainNavigation(username: usernameController.text)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid credentials")),
      );
    }
  }

  Future<void> _resetApp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    setState(() {
      savedUsername = null;
      savedPassword = null;
      isRegistered = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFc2ccd9),
      body: Center(
        child: _neuCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isRegistered ? "Login to MyMoney" : "Register MyMoney",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              _neuTextField(usernameController, "Username"),
              const SizedBox(height: 12),
              _neuTextField(passwordController, "Password", obscure: true),
              const SizedBox(height: 20),
              _neuButton(
                text: isRegistered ? "Login" : "Register",
                onTap: isRegistered ? _login : _register,
              ),
              if (isRegistered) ...[
                const SizedBox(height: 10),
                TextButton(
                  onPressed: _resetApp,
                  child: const Text("Forgot Password? Reset App",
                      style: TextStyle(color: Colors.blueGrey)),
                )
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _neuCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFc2ccd9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.white, offset: Offset(-4, -4), blurRadius: 8),
          BoxShadow(color: Colors.black26, offset: Offset(4, 4), blurRadius: 8),
        ],
      ),
      child: child,
    );
  }

  Widget _neuTextField(TextEditingController c, String hint,
      {bool obscure = false, TextInputType keyboard = TextInputType.text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFc2ccd9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.white, offset: Offset(-3, -3), blurRadius: 6),
          BoxShadow(color: Colors.black26, offset: Offset(3, 3), blurRadius: 6),
        ],
      ),
      child: TextField(
        controller: c,
        obscureText: obscure,
        keyboardType: keyboard,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _neuButton({required String text, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFc2ccd9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: Colors.white, offset: Offset(-4, -4), blurRadius: 8),
            BoxShadow(color: Colors.black26, offset: Offset(4, 4), blurRadius: 8),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ),
      ),
    );
  }
}

// =================== MAIN NAVIGATION ===================
class MainNavigation extends StatefulWidget {
  final String username;
  const MainNavigation({super.key, required this.username});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardPage(username: widget.username),
      const TransactionHistoryPage(),
      const AnalyticsPage(),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFc2ccd9),
          boxShadow: const [
            BoxShadow(color: Colors.white, offset: Offset(-3, -3), blurRadius: 6),
            BoxShadow(color: Colors.black26, offset: Offset(3, 3), blurRadius: 6),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          backgroundColor: const Color(0xFFc2ccd9),
          selectedItemColor: Colors.black87,
          unselectedItemColor: Colors.black54,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
            BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Analytics"),
          ],
        ),
      ),
    );
  }
}

// =================== DASHBOARD ===================
class DashboardPage extends StatefulWidget {
  final String username;
  const DashboardPage({super.key, required this.username});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<Map<String, dynamic>> transactions = [];
  Map<String, double> rates = {};
  double balance = 0.0;

  final amountController = TextEditingController();
  final noteController = TextEditingController();
  String type = "income";

  final convertAmountController = TextEditingController();
  String fromCurrency = "USD";
  String toCurrency = "BDT";
  double converted = 0.0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final storedTx = jsonDecode(prefs.getString("transactions") ?? "[]");
    final storedRates = jsonDecode(prefs.getString("rates") ?? "{}");
    setState(() {
      transactions = List<Map<String, dynamic>>.from(storedTx);
      rates = Map<String, double>.from(
          storedRates.map((k, v) => MapEntry(k as String, (v as num).toDouble())));
      balance = transactions.fold(
          0.0,
              (sum, item) =>
          sum + (item["type"] == "income" ? item["amount"] : -item["amount"]));
    });
  }

  Future<void> _addTransaction() async {
    if (amountController.text.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final tx = {
      "type": type,
      "amount": double.parse(amountController.text),
      "note": noteController.text,
      "date": DateTime.now().toIso8601String(),
    };
    transactions.add(tx);
    await prefs.setString("transactions", jsonEncode(transactions));
    amountController.clear();
    noteController.clear();
    _loadData();
  }

  void _convertCurrency() {
    if (convertAmountController.text.isEmpty) return;
    final amount = double.parse(convertAmountController.text);
    final usd = amount / rates[fromCurrency]!;
    setState(() {
      converted = usd * rates[toCurrency]!;
    });
  }

  void _goToAnalytics() {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => const AnalyticsPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFc2ccd9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Center(
                child: Text("Hi, ${widget.username}!",
                    style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87)),
              ),
              const SizedBox(height: 20),
              _neuCard(
                  child: Text("Balance: ${balance.toStringAsFixed(2)} Taka",
                      style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 20,
                          fontWeight: FontWeight.bold))),
              const SizedBox(height: 10),
              _neuCard(
                child: Column(
                  children: [
                    const Text("Add Transaction",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 10),
                    DropdownButton<String>(
                      value: type,
                      items: const [
                        DropdownMenuItem(
                            value: "income",
                            child: Text("Income",
                                style: TextStyle(color: Colors.black87))),
                        DropdownMenuItem(
                            value: "expense",
                            child: Text("Expense",
                                style: TextStyle(color: Colors.black87))),
                      ],
                      onChanged: (val) => setState(() => type = val!),
                    ),
                    _neuTextField(amountController, "Amount",
                        keyboard: TextInputType.number),
                    const SizedBox(height: 10),
                    _neuTextField(noteController, "Note"),
                    const SizedBox(height: 10),
                    _neuButton(text: "Save Transaction", onTap: _addTransaction),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              _neuCard(
                child: Column(
                  children: [
                    const Text("Currency Converter",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 10),
                    _neuTextField(convertAmountController, "Amount",
                        keyboard: TextInputType.number),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        DropdownButton<String>(
                          value: fromCurrency,
                          items: rates.keys
                              .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(c,
                                style: const TextStyle(
                                    color: Colors.black87)),
                          ))
                              .toList(),
                          onChanged: (v) => setState(() => fromCurrency = v!),
                        ),
                        const Icon(Icons.swap_horiz, color: Colors.black87),
                        DropdownButton<String>(
                          value: toCurrency,
                          items: rates.keys
                              .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(c,
                                style: const TextStyle(
                                    color: Colors.black87)),
                          ))
                              .toList(),
                          onChanged: (v) => setState(() => toCurrency = v!),
                        ),
                      ],
                    ),
                    _neuButton(text: "Convert", onTap: _convertCurrency),
                    if (converted > 0)
                      Text("$fromCurrency → $toCurrency = ${converted.toStringAsFixed(2)}",
                          style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              _neuButton(text: "View Analytics", onTap: _goToAnalytics),
            ],
          ),
        ),
      ),
    );
  }

  Widget _neuCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFc2ccd9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.white, offset: Offset(-4, -4), blurRadius: 8),
          BoxShadow(color: Colors.black26, offset: Offset(4, 4), blurRadius: 8),
        ],
      ),
      child: child,
    );
  }

  Widget _neuTextField(TextEditingController c, String hint,
      {TextInputType keyboard = TextInputType.text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFc2ccd9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.white, offset: Offset(-3, -3), blurRadius: 6),
          BoxShadow(color: Colors.black26, offset: Offset(3, 3), blurRadius: 6),
        ],
      ),
      child: TextField(
        controller: c,
        keyboardType: keyboard,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _neuButton({required String text, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFc2ccd9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: Colors.white, offset: Offset(-4, -4), blurRadius: 8),
            BoxShadow(color: Colors.black26, offset: Offset(4, 4), blurRadius: 8),
          ],
        ),
        child: Center(
          child: Text(text,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black87)),
        ),
      ),
    );
  }
}

// =================== ANALYTICS PAGE ===================
class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  List<Map<String, dynamic>> transactions = [];
  double totalIncome = 0.0;
  double totalExpense = 0.0;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final storedTx = jsonDecode(prefs.getString("transactions") ?? "[]");
    setState(() {
      transactions = List<Map<String, dynamic>>.from(storedTx);
      _calculateAnalytics();
    });
  }

  void _calculateAnalytics() {
    totalIncome = 0.0;
    totalExpense = 0.0;
    for (var tx in transactions) {
      if (tx["type"] == "income") {
        totalIncome += tx["amount"];
      } else {
        totalExpense += tx["amount"];
      }
    }
  }

  List<FlSpot> _generateBalanceSpots() {
    double running = 0.0;
    List<FlSpot> spots = [];
    for (int i = 0; i < transactions.length; i++) {
      running += transactions[i]["type"] == "income"
          ? transactions[i]["amount"]
          : -transactions[i]["amount"];
      spots.add(FlSpot(i.toDouble(), running));
    }
    return spots;
  }

  double get _finalBalance => totalIncome - totalExpense;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFc2ccd9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Analytics",
            style: TextStyle(
                color: Colors.black87, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: transactions.isEmpty
            ? Center(
          child: _neuCard(
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "No transactions yet.\nAdd some to see analytics!",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54, fontSize: 18),
              ),
            ),
          ),
        )
            : SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // SUMMARY CARD
              _neuCard(
                child: Column(
                  children: [
                    const Text("Monthly Summary",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            fontSize: 20)),
                    const SizedBox(height: 10),
                    Text("Income: ${totalIncome.toStringAsFixed(2)} Taka",
                        style: const TextStyle(
                            color: Colors.green, fontSize: 18)),
                    const SizedBox(height: 5),
                    Text("Expense: ${totalExpense.toStringAsFixed(2)} Taka",
                        style: const TextStyle(
                            color: Colors.red, fontSize: 18)),
                    const SizedBox(height: 5),
                    Text("Final Balance: ${_finalBalance.toStringAsFixed(2)} Taka",
                        style: const TextStyle(
                            color: Colors.blueGrey, fontSize: 18)),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // BALANCE TREND LINE CHART
              _neuCard(
                child: Column(
                  children: [
                    const Text("Balance Trend",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            fontSize: 20)),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 200,
                      child: LineChart(LineChartData(
                          gridData: FlGridData(show: false),
                          titlesData: FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: _generateBalanceSpots(),
                              isCurved: true,
                              color: Colors.blueGrey,
                              barWidth: 3,
                              dotData: FlDotData(show: false),
                            )
                          ])),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // BAR CHART (Income vs Expense)
              _neuCard(
                child: Column(
                  children: [
                    const Text("Income vs Expense",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            fontSize: 20)),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 200,
                      child: BarChart(BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        gridData: FlGridData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                switch (value.toInt()) {
                                  case 0:
                                    return const Text("Income");
                                  case 1:
                                    return const Text("Expense");
                                }
                                return const SizedBox();
                              },
                            ),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: [
                          BarChartGroupData(
                            x: 0,
                            barRods: [
                              BarChartRodData(
                                  toY: totalIncome,
                                  color: Colors.green,
                                  width: 30),
                            ],
                          ),
                          BarChartGroupData(
                            x: 1,
                            barRods: [
                              BarChartRodData(
                                  toY: totalExpense,
                                  color: Colors.red,
                                  width: 30),
                            ],
                          ),
                        ],
                      )),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // PIE CHART (Final Balance Breakdown)
              _neuCard(
                child: Column(
                  children: [
                    const Text("Balance Breakdown",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            fontSize: 20)),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 200,
                      child: PieChart(PieChartData(
                        sections: [
                          PieChartSectionData(
                            value: totalIncome,
                            color: Colors.green,
                            title: "Income",
                            radius: 60,
                            titleStyle: const TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
                          PieChartSectionData(
                            value: totalExpense,
                            color: Colors.red,
                            title: "Expense",
                            radius: 60,
                            titleStyle: const TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
                          PieChartSectionData(
                            value: _finalBalance > 0 ? _finalBalance : 0,
                            color: Colors.blueGrey,
                            title: "Balance",
                            radius: 60,
                            titleStyle: const TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
                        ],
                      )),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _neuCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFc2ccd9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.white, offset: Offset(-4, -4), blurRadius: 8),
          BoxShadow(color: Colors.black26, offset: Offset(4, 4), blurRadius: 8),
        ],
      ),
      child: child,
    );
  }
}

// =================== TRANSACTION HISTORY PAGE ===================
class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  List<Map<String, dynamic>> transactions = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final storedTx = jsonDecode(prefs.getString("transactions") ?? "[]");
    setState(() {
      transactions = List<Map<String, dynamic>>.from(storedTx);
    });
  }

  Future<void> _deleteTransaction(int index) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      transactions.removeAt(index);
    });
    await prefs.setString("transactions", jsonEncode(transactions));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFc2ccd9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Transaction History",
            style: TextStyle(
                color: Colors.black87, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: transactions.isEmpty
          ? const Center(
        child: Text("No transactions yet.",
            style: TextStyle(color: Colors.black54, fontSize: 18)),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: transactions.length,
        itemBuilder: (context, i) {
          final tx = transactions[i];
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFc2ccd9),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                    color: Colors.white,
                    offset: Offset(-3, -3),
                    blurRadius: 6),
                BoxShadow(
                    color: Colors.black26,
                    offset: Offset(3, 3),
                    blurRadius: 6),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tx["note"] ?? "No note",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87)),
                      Text(
                        DateTime.parse(tx["date"]).toString(),
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black54),
                      ),
                    ]),
                Row(
                  children: [
                    Text(
                      "${tx["type"] == "income" ? "+" : "-"} ${tx["amount"]}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: tx["type"] == "income"
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                    const SizedBox(width: 10),
                    PopupMenuButton<String>(
                      onSelected: (val) {
                        if (val == "delete") {
                          _deleteTransaction(i);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: "delete",
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text("Delete"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
