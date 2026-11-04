import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const LoanEligibilityApp());
}

class LoanEligibilityApp extends StatelessWidget {
  const LoanEligibilityApp({super.key});

  static const Color navy = Color(0xFF143B66);
  static const Color blue = Color(0xFF246BCE);
  static const Color paleBlue = Color(0xFFEAF2FC);
  static const Color background = Color(0xFFF5F8FC);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Loan Eligibility Checker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: blue,
          primary: blue,
          surface: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF9FBFE),
          labelStyle: const TextStyle(color: Color(0xFF64748B)),
          prefixIconColor: blue,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 17,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFDCE5F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFDCE5F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: blue, width: 1.6),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.redAccent),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.6),
          ),
        ),
      ),
      home: const CustomerDetailsScreen(),
    );
  }
}

class CustomerDetails {
  const CustomerDetails({
    required this.name,
    required this.age,
    required this.monthlySalary,
    required this.existingEmi,
    required this.requestedLoan,
  });

  final String name;
  final int age;
  final double monthlySalary;
  final double existingEmi;
  final double requestedLoan;
}

class EligibilityResult {
  EligibilityResult.fromCustomer(CustomerDetails customer)
    : dti = customer.existingEmi / customer.monthlySalary * 100,
      rejectionReasons = _getRejectionReasons(customer);

  final double dti;
  final List<String> rejectionReasons;

  bool get isEligible => rejectionReasons.isEmpty;

  double monthlyEmiFor(double principal) {
    // Apply the standard reducing-balance EMI formula for 60 monthly payments.
    const monthlyRate = 0.10 / 12;
    const installments = 60;
    final rateFactor = math.pow(1 + monthlyRate, installments);
    return principal * monthlyRate * rateFactor / (rateFactor - 1);
  }

  static List<String> _getRejectionReasons(CustomerDetails customer) {
    final reasons = <String>[];
    // Check each rule independently so the result can explain every failure.
    final dti = customer.existingEmi / customer.monthlySalary * 100;

    if (dti > 60) {
      reasons.add(
        'Your debt-to-income ratio is ${dti.toStringAsFixed(2)}%, above the 60% limit.',
      );
    }
    if (customer.age < 21 || customer.age > 60) {
      reasons.add('Applicants must be between 21 and 60 years old.');
    }
    final maximumLoan = customer.monthlySalary * 10;
    if (customer.requestedLoan > maximumLoan) {
      reasons.add(
        'The requested amount exceeds your maximum permitted loan of ${formatRupees(maximumLoan)}.',
      );
    }
    return reasons;
  }
}

class CustomerDetailsScreen extends StatefulWidget {
  const CustomerDetailsScreen({super.key});

  @override
  State<CustomerDetailsScreen> createState() => _CustomerDetailsScreenState();
}

class _CustomerDetailsScreenState extends State<CustomerDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _salaryController = TextEditingController();
  final _emiController = TextEditingController();
  final _loanController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _salaryController.dispose();
    _emiController.dispose();
    _loanController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _nameController.clear();
    _ageController.clear();
    _salaryController.clear();
    _emiController.clear();
    _loanController.clear();
    FocusScope.of(context).unfocus();
  }

  Future<void> _checkEligibility() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final customer = CustomerDetails(
      name: _nameController.text.trim(),
      age: int.parse(_ageController.text.trim()),
      monthlySalary: double.parse(_salaryController.text.trim()),
      existingEmi: double.parse(_emiController.text.trim()),
      requestedLoan: double.parse(_loanController.text.trim()),
    );

    final shouldReset = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (_) => LoanResultScreen(customer: customer),
      ),
    );
    if (shouldReset == true && mounted) {
      _resetForm();
    }
  }

  String? _requiredText(String? value) {
    if (value == null || value.trim().isEmpty) return 'This field is required.';
    return null;
  }

  String? _validateName(String? value) {
    final requiredError = _requiredText(value);
    if (requiredError != null) return requiredError;
    if (!RegExp(r'^[A-Za-z]+(?: [A-Za-z]+)*$').hasMatch(value!.trim())) {
      return 'Enter a name using letters and spaces only.';
    }
    return null;
  }

  String? _validateAge(String? value) {
    final requiredError = _requiredText(value);
    if (requiredError != null) return requiredError;
    final age = int.tryParse(value!.trim());
    if (age == null || age < 1 || age > 120) {
      return 'Enter a whole number between 1 and 120.';
    }
    return null;
  }

  String? _validateAmount(String? value, {required bool allowZero}) {
    final requiredError = _requiredText(value);
    if (requiredError != null) return requiredError;
    final amount = double.tryParse(value!.trim());
    if (amount == null || !amount.isFinite) {
      return 'Enter a valid amount.';
    }
    if (allowZero ? amount < 0 : amount <= 0) {
      return allowZero
          ? 'Amount cannot be negative.'
          : 'Amount must be greater than zero.';
    }
    return null;
  }

  Widget _textField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? prefixText,
    TextInputAction textInputAction = TextInputAction.next,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 21),
        prefixText: prefixText,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth > 600 ? 32.0 : 20.0;
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    18,
                    horizontalPadding,
                    28,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 22),
                      Card(
                        color: Colors.white,
                        elevation: 1,
                        shadowColor: const Color(0x14143B66),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                          side: const BorderSide(color: Color(0xFFE7EDF5)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Text(
                                  'Your details',
                                  style: TextStyle(
                                    color: LoanEligibilityApp.navy,
                                    fontSize: 19,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                const Text(
                                  'Tell us a little about your finances.',
                                  style: TextStyle(
                                    color: Color(0xFF718096),
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                _textField(
                                  label: 'Full name',
                                  icon: Icons.person_outline_rounded,
                                  controller: _nameController,
                                  validator: _validateName,
                                  textInputAction: TextInputAction.next,
                                ),
                                const SizedBox(height: 15),
                                _textField(
                                  label: 'Age',
                                  icon: Icons.cake_outlined,
                                  controller: _ageController,
                                  validator: _validateAge,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                ),
                                const SizedBox(height: 15),
                                _textField(
                                  label: 'Monthly salary',
                                  icon: Icons.account_balance_wallet_outlined,
                                  controller: _salaryController,
                                  validator: (value) =>
                                      _validateAmount(value, allowZero: false),
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d*\.?\d{0,2}'),
                                    ),
                                  ],
                                  prefixText: '₹ ',
                                ),
                                const SizedBox(height: 15),
                                _textField(
                                  label: 'Existing EMI / debts',
                                  icon: Icons.credit_card_outlined,
                                  controller: _emiController,
                                  validator: (value) =>
                                      _validateAmount(value, allowZero: true),
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d*\.?\d{0,2}'),
                                    ),
                                  ],
                                  prefixText: '₹ ',
                                ),
                                const SizedBox(height: 15),
                                _textField(
                                  label: 'Loan amount requested',
                                  icon: Icons.request_quote_outlined,
                                  controller: _loanController,
                                  validator: (value) =>
                                      _validateAmount(value, allowZero: false),
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d*\.?\d{0,2}'),
                                    ),
                                  ],
                                  prefixText: '₹ ',
                                ),
                                const SizedBox(height: 22),
                                SizedBox(
                                  height: 54,
                                  child: ElevatedButton.icon(
                                    onPressed: _checkEligibility,
                                    icon: const Icon(
                                      Icons.verified_user_outlined,
                                      size: 20,
                                    ),
                                    label: const Text('Check Eligibility'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: LoanEligibilityApp.blue,
                                      foregroundColor: Colors.white,
                                      textStyle: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                TextButton(
                                  onPressed: _resetForm,
                                  child: const Text('Reset'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'Your information is used only to estimate eligibility.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF8190A5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF236CCB), Color(0xFF174478)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x29246BCE),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Loan Eligibility\nChecker',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    height: 1.18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 9),
                Text(
                  'Check your loan eligibility in seconds.',
                  style: TextStyle(color: Color(0xFFDCEAFF), fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(19),
            ),
            child: const Icon(
              Icons.account_balance_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
        ],
      ),
    );
  }
}

class LoanResultScreen extends StatelessWidget {
  const LoanResultScreen({required this.customer, super.key});

  final CustomerDetails customer;

  @override
  Widget build(BuildContext context) {
    final result = EligibilityResult.fromCustomer(customer);
    final resultColor = result.isEligible
        ? const Color(0xFF16834A)
        : const Color(0xFFD13E45);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Eligibility result',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: LoanEligibilityApp.background,
        foregroundColor: LoanEligibilityApp.navy,
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth > 600 ? 32.0 : 20.0;
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    12,
                    horizontalPadding,
                    28,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildCustomerCard(result),
                      const SizedBox(height: 18),
                      _buildDecision(result, resultColor),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 54,
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.pop(context, true),
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Calculate Again'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: LoanEligibilityApp.blue,
                            foregroundColor: Colors.white,
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCustomerCard(EligibilityResult result) {
    return Card(
      color: Colors.white,
      elevation: 1,
      shadowColor: const Color(0x14143B66),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: Color(0xFFE7EDF5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Applicant summary',
              style: TextStyle(
                color: LoanEligibilityApp.navy,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            _detailRow('Customer name', customer.name),
            _detailRow('Age', '${customer.age} years'),
            _detailRow('Monthly salary', formatRupees(customer.monthlySalary)),
            _detailRow(
              'Existing EMI / debts',
              formatRupees(customer.existingEmi),
            ),
            _detailRow('Loan requested', formatRupees(customer.requestedLoan)),
            const Divider(height: 22),
            _detailRow(
              'Debt-to-income ratio',
              '${result.dti.toStringAsFixed(2)}%',
              emphasize: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, {bool emphasize = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: emphasize
                    ? LoanEligibilityApp.navy
                    : const Color(0xFF718096),
                fontSize: 13,
                fontWeight: emphasize ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: LoanEligibilityApp.navy,
                fontSize: 14,
                fontWeight: emphasize ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecision(EligibilityResult result, Color resultColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: resultColor.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: resultColor.withValues(alpha: 0.18)),
      ),
      child: Column(
        children: [
          Icon(
            result.isEligible
                ? Icons.check_circle_rounded
                : Icons.cancel_rounded,
            color: resultColor,
            size: 54,
          ),
          const SizedBox(height: 10),
          Text(
            result.isEligible ? 'LOAN APPROVED' : 'LOAN NOT APPROVED',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: resultColor,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 12),
          if (result.isEligible) ...[
            const Text(
              'Approved loan amount',
              style: TextStyle(color: Color(0xFF62748A), fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              formatRupees(customer.requestedLoan),
              style: TextStyle(
                color: resultColor,
                fontSize: 25,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  const Text(
                    'Estimated monthly EMI',
                    style: TextStyle(color: Color(0xFF62748A), fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatRupees(result.monthlyEmiFor(customer.requestedLoan)),
                    style: const TextStyle(
                      color: LoanEligibilityApp.navy,
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'At 10% annual interest for 5 years',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF8290A2), fontSize: 11),
                  ),
                ],
              ),
            ),
          ] else ...[
            const Text(
              'We found the following criteria that were not met:',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF62748A), fontSize: 13),
            ),
            const SizedBox(height: 12),
            ...result.rejectionReasons.map(
              (reason) => Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.error_outline, color: resultColor, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        reason,
                        style: const TextStyle(
                          color: Color(0xFF4D5B6E),
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

String formatRupees(double amount) {
  final parts = amount.toStringAsFixed(2).split('.');
  final digits = parts.first;
  final lastThree = digits.length > 3
      ? digits.substring(digits.length - 3)
      : digits;
  final preceding = digits.length > 3
      ? digits.substring(0, digits.length - 3)
      : '';
  final indianGrouped = preceding.isEmpty
      ? lastThree
      : '${preceding.replaceAllMapped(RegExp(r'(\d)(?=(\d{2})+$)'), (match) => '${match[1]},')},$lastThree';
  return '₹$indianGrouped.${parts.last}';
}
