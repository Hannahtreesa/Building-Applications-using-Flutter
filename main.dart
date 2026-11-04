import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart'
    show databaseFactoryFfi, sqfliteFfiInit;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.macOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  runApp(const BankAccountApp());
}

class BankAccountApp extends StatelessWidget {
  const BankAccountApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Bank Account Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1769AA),
          surface: const Color(0xFFF5F7FA),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1769AA),
          foregroundColor: Colors.white,
          centerTitle: false,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFDCE3EB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFDCE3EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF1769AA), width: 2),
          ),
        ),
        useMaterial3: true,
      ),
      home: const AccountsPage(),
    );
  }
}

class AccountsPage extends StatefulWidget {
  const AccountsPage({super.key});

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  final _formKey = GlobalKey<FormState>();
  final _accountHolderController = TextEditingController();
  final _initialBalanceController = TextEditingController();

  List<Map<String, Object?>> _accounts = [];
  double _totalBalance = 0;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _refreshAccounts();
  }

  @override
  void dispose() {
    _accountHolderController.dispose();
    _initialBalanceController.dispose();
    super.dispose();
  }

  Future<void> _refreshAccounts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final accounts = await AccountDatabase.instance.getAccounts();
      final totalBalance = await AccountDatabase.instance.getTotalBalance();
      if (!mounted) return;
      setState(() {
        _accounts = accounts;
        _totalBalance = totalBalance;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Could not load accounts: $error';
      });
    }
  }

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _accountHolderController.text.trim();
    final balance = double.parse(_initialBalanceController.text.trim());

    setState(() => _isSaving = true);
    try {
      await AccountDatabase.instance.insertAccount(name, balance);
      _accountHolderController.clear();
      _initialBalanceController.clear();
      await _refreshAccounts();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not create account: $error')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bank Accounts',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTotalBalance(),
              const SizedBox(height: 18),
              _buildAccountForm(),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Accounts',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ),
                  Text(
                    '${_accounts.length} ${_accounts.length == 1 ? 'account' : 'accounts'}',
                    style: const TextStyle(color: Color(0xFF6B7280)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Color(0xFFB42318)),
                  ),
                ),
              Expanded(child: _buildAccountList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTotalBalance() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF7EF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD3EEDB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.account_balance, color: Color(0xFF21854A), size: 20),
              SizedBox(width: 8),
              Text(
                'TOTAL MONEY IN BANK',
                style: TextStyle(
                  color: Color(0xFF37734C),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '₹ ${_totalBalance.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Color(0xFF18743B),
              fontSize: 30,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _accountHolderController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Account Holder Name',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Enter an account holder name';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _initialBalanceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            decoration: const InputDecoration(
              labelText: 'Initial Balance',
              prefixText: '₹ ',
              prefixIcon: Icon(Icons.currency_rupee),
            ),
            validator: (value) {
              final balance = double.tryParse(value?.trim() ?? '');
              if (balance == null || !balance.isFinite || balance < 0) {
                return 'Enter a valid non-negative balance';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 50,
            child: FilledButton.icon(
              onPressed: _isSaving ? null : _createAccount,
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.add),
              label: Text(_isSaving ? 'Creating...' : 'Create Account'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF1769AA),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountList() {
    if (_isLoading && _accounts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_accounts.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 44,
              color: Color(0xFF9AA4B2),
            ),
            SizedBox(height: 10),
            Text(
              'No accounts yet',
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Create your first account above.',
              style: TextStyle(color: Color(0xFF8993A1)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _accounts.length,
      padding: const EdgeInsets.only(bottom: 8),
      itemBuilder: (context, index) {
        final account = _accounts[index];
        final balance = (account['balance'] as num).toDouble();
        final isLowBalance = balance == 0;

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          color: isLowBalance ? const Color(0xFFFFEEEE) : Colors.white,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: isLowBalance
                  ? const Color(0xFFF2B8B5)
                  : const Color(0xFFE7EBF0),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: isLowBalance
                      ? const Color(0xFFFAD1CF)
                      : const Color(0xFFE8F1FA),
                  foregroundColor: isLowBalance
                      ? const Color(0xFFB42318)
                      : const Color(0xFF1769AA),
                  child: Icon(
                    isLowBalance ? Icons.warning_amber_rounded : Icons.person,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        account['accountHolder'] as String,
                        style: const TextStyle(
                          color: Color(0xFF1F2937),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Account ID: ${account['id']}',
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 13,
                        ),
                      ),
                      if (isLowBalance) ...[
                        const SizedBox(height: 5),
                        const Text(
                          'Low Balance!',
                          style: TextStyle(
                            color: Color(0xFFB42318),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '₹ ${balance.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: isLowBalance
                        ? const Color(0xFFB42318)
                        : const Color(0xFF18743B),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class AccountDatabase {
  AccountDatabase._();

  static final AccountDatabase instance = AccountDatabase._();
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    final databasePath = path.join(
      await getDatabasesPath(),
      'bank_accounts.db',
    );
    _database = await openDatabase(
      databasePath,
      version: 1,
      onCreate: (database, version) async {
        await database.execute('''
          CREATE TABLE accounts (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            accountHolder TEXT NOT NULL,
            balance REAL NOT NULL
          )
        ''');
      },
    );
    return _database!;
  }

  Future<int> insertAccount(String accountHolder, double balance) async {
    final db = await database;
    return db.insert('accounts', {
      'accountHolder': accountHolder,
      'balance': balance,
    });
  }

  Future<List<Map<String, Object?>>> getAccounts() async {
    final db = await database;
    return db.query('accounts', orderBy: 'id DESC');
  }

  Future<double> getTotalBalance() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(balance), 0) AS total FROM accounts',
    );
    return (result.first['total'] as num).toDouble();
  }
}
