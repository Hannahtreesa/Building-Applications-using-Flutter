import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF2457D6);

    return MaterialApp(
      title: 'Student Registration Portal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: blue,
          primary: blue,
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F7FC),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF8FAFD),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 15,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E7F1)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E7F1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: blue, width: 1.5),
          ),
        ),
      ),
      home: const RegistrationScreen(),
    );
  }
}

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _registerNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  DateTime? _dateOfBirth;
  String? _gender;
  String? _department;
  String? _year;
  bool _isVisible = false;

  static const _departments = [
    'CSE',
    'ECE',
    'EEE',
    'IT',
    'Mechanical',
    'Civil',
  ];
  static const _years = ['1st Year', '2nd Year', '3rd Year', '4th Year'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _isVisible = true);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _registerNumberController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';

  Future<void> _selectDate() async {
    final today = DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      initialDate:
          _dateOfBirth ?? DateTime(today.year - 18, today.month, today.day),
      firstDate: DateTime(1900),
      lastDate: today,
      helpText: 'Select date of birth',
    );
    if (selectedDate != null) {
      setState(() => _dateOfBirth = selectedDate);
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _nameController.clear();
    _registerNumberController.clear();
    _emailController.clear();
    _phoneController.clear();
    _addressController.clear();
    setState(() {
      _dateOfBirth = null;
      _gender = null;
      _department = null;
      _year = null;
    });
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final student = <String, String>{
      'Full Name': _nameController.text.trim(),
      'Register Number': _registerNumberController.text.trim(),
      'Email Address': _emailController.text.trim(),
      'Phone Number': _phoneController.text.trim(),
      'Date of Birth': _formatDate(_dateOfBirth!),
      'Gender': _gender!,
      'Department': _department!,
      'Year of Study': _year!,
      'Address': _addressController.text.trim(),
    };

    _resetForm();
    Navigator.push(
      context,
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (context, animation, secondaryAnimation) =>
            RegistrationSuccessScreen(student: student),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  String? _required(String? value, String label) {
    if (value == null || value.trim().isEmpty) return '$label is required';
    return null;
  }

  Widget _textField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        alignLabelWithHint: maxLines > 1,
      ),
    );
  }

  Widget _fieldLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(
        color: Color(0xFF26334A),
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        titleSpacing: 24,
        title: const Row(
          children: [
            Icon(Icons.school_rounded, color: Color(0xFF2457D6)),
            SizedBox(width: 10),
            Flexible(
              child: Text(
                'Student Registration Portal',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Color(0xFF18243A),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
      body: AnimatedOpacity(
        opacity: _isVisible ? 1 : 0,
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeOut,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: constraints.maxWidth < 600 ? 16 : 32,
                vertical: 28,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 4,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  right: 28,
                                  top: 26,
                                ),
                                child: _welcomePanel(),
                              ),
                            ),
                            Expanded(flex: 6, child: _formCard()),
                          ],
                        )
                      : Column(
                          children: [
                            _welcomePanel(compact: true),
                            const SizedBox(height: 22),
                            _formCard(),
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

  Widget _welcomePanel({bool compact = false}) {
    return Container(
      padding: EdgeInsets.all(compact ? 22 : 30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Color(0xFF2457D6), Color(0xFF4F83F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.auto_stories_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Welcome to your\nnext chapter.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              height: 1.15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Complete your student registration to get started with your academic journey.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.86),
              height: 1.5,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 26),
          const _EducationIllustration(),
        ],
      ),
    );
  }

  Widget _formCard() {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFE8EDF5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final twoColumns = constraints.maxWidth >= 520;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Student Registration',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF18243A),
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Enter your details below to complete registration.',
                    style: TextStyle(color: Color(0xFF758198), fontSize: 13),
                  ),
                  const SizedBox(height: 24),
                  if (twoColumns)
                    Row(
                      children: [
                        Expanded(child: _nameInput()),
                        const SizedBox(width: 14),
                        Expanded(child: _registerNumberInput()),
                      ],
                    )
                  else ...[
                    _nameInput(),
                    const SizedBox(height: 16),
                    _registerNumberInput(),
                  ],
                  const SizedBox(height: 16),
                  if (twoColumns)
                    Row(
                      children: [
                        Expanded(child: _emailInput()),
                        const SizedBox(width: 14),
                        Expanded(child: _phoneInput()),
                      ],
                    )
                  else ...[
                    _emailInput(),
                    const SizedBox(height: 16),
                    _phoneInput(),
                  ],
                  const SizedBox(height: 16),
                  _fieldLabel('Date of Birth'),
                  FormField<DateTime>(
                    initialValue: _dateOfBirth,
                    validator: (value) =>
                        value == null ? 'Date of birth is required' : null,
                    builder: (field) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () async {
                            await _selectDate();
                            field.didChange(_dateOfBirth);
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.calendar_month_outlined,
                                size: 20,
                              ),
                              hintText: 'Select your date of birth',
                              errorText: field.errorText,
                            ),
                            child: Text(
                              _dateOfBirth == null
                                  ? 'Select your date of birth'
                                  : _formatDate(_dateOfBirth!),
                              style: TextStyle(
                                color: _dateOfBirth == null
                                    ? const Color(0xFF8994A8)
                                    : const Color(0xFF26334A),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  _fieldLabel('Gender'),
                  FormField<String>(
                    initialValue: _gender,
                    validator: (value) =>
                        value == null ? 'Please select your gender' : null,
                    builder: (field) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RadioGroup<String>(
                          groupValue: field.value,
                          onChanged: (selected) {
                            field.didChange(selected);
                            setState(() => _gender = selected);
                          },
                          child: Wrap(
                            spacing: 4,
                            runSpacing: 0,
                            children: ['Male', 'Female', 'Other']
                                .map(
                                  (value) => SizedBox(
                                    width: twoColumns ? 132 : 112,
                                    child: RadioListTile<String>(
                                      contentPadding: EdgeInsets.zero,
                                      dense: true,
                                      visualDensity: VisualDensity.compact,
                                      title: Text(
                                        value,
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                      value: value,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        if (field.errorText != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 12, top: 2),
                            child: Text(
                              field.errorText!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (twoColumns)
                    Row(
                      children: [
                        Expanded(child: _departmentDropdown()),
                        const SizedBox(width: 14),
                        Expanded(child: _yearDropdown()),
                      ],
                    )
                  else ...[
                    _departmentDropdown(),
                    const SizedBox(height: 16),
                    _yearDropdown(),
                  ],
                  const SizedBox(height: 16),
                  _textField(
                    label: 'Address',
                    hint: 'Enter your full address',
                    controller: _addressController,
                    icon: Icons.location_on_outlined,
                    maxLines: 3,
                    validator: (value) => _required(value, 'Address'),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: ElevatedButton.icon(
                          onPressed: _submit,
                          icon: const Icon(Icons.how_to_reg_rounded, size: 19),
                          label: const Text('Submit Registration'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(0, 50),
                            backgroundColor: const Color(0xFF2457D6),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _resetForm,
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 50),
                            foregroundColor: const Color(0xFF46536A),
                            side: const BorderSide(color: Color(0xFFDCE3EF)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Reset'),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _nameInput() => _textField(
    label: 'Full Name',
    hint: 'Enter your full name',
    controller: _nameController,
    icon: Icons.person_outline_rounded,
    validator: (value) {
      final requiredError = _required(value, 'Full name');
      if (requiredError != null) return requiredError;
      if (!RegExp(r"^[A-Za-z][A-Za-z .'-]*$").hasMatch(value!.trim())) {
        return 'Enter a valid name';
      }
      return null;
    },
  );

  Widget _registerNumberInput() => _textField(
    label: 'Register Number',
    hint: 'e.g. 2024001',
    controller: _registerNumberController,
    icon: Icons.badge_outlined,
    validator: (value) => _required(value, 'Register number'),
  );

  Widget _emailInput() => _textField(
    label: 'Email Address',
    hint: 'name@example.com',
    controller: _emailController,
    icon: Icons.email_outlined,
    keyboardType: TextInputType.emailAddress,
    validator: (value) {
      final requiredError = _required(value, 'Email address');
      if (requiredError != null) return requiredError;
      if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value!.trim())) {
        return 'Enter a valid email address';
      }
      return null;
    },
  );

  Widget _phoneInput() => _textField(
    label: 'Phone Number',
    hint: '10-digit phone number',
    controller: _phoneController,
    icon: Icons.phone_outlined,
    keyboardType: TextInputType.number,
    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    validator: (value) {
      if (value == null || value.isEmpty) return 'Phone number is required';
      if (!RegExp(r'^\d{10}$').hasMatch(value)) {
        return 'Phone number must contain exactly 10 digits';
      }
      return null;
    },
  );

  Widget _departmentDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _department,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Department',
        prefixIcon: Icon(Icons.account_balance_outlined, size: 20),
      ),
      hint: const Text('Select department'),
      items: _departments
          .map((value) => DropdownMenuItem(value: value, child: Text(value)))
          .toList(),
      validator: (value) => value == null ? 'Please select a department' : null,
      onChanged: (value) => setState(() => _department = value),
    );
  }

  Widget _yearDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _year,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Year of Study',
        prefixIcon: Icon(Icons.calendar_today_outlined, size: 20),
      ),
      hint: const Text('Select year'),
      items: _years
          .map((value) => DropdownMenuItem(value: value, child: Text(value)))
          .toList(),
      validator: (value) => value == null ? 'Please select a year' : null,
      onChanged: (value) => setState(() => _year = value),
    );
  }
}

class _EducationIllustration extends StatelessWidget {
  const _EducationIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 8,
            child: Container(
              width: 220,
              height: 110,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          const Positioned(
            top: 10,
            left: 30,
            child: Icon(Icons.star_rounded, color: Color(0xFFFFD166), size: 25),
          ),
          const Positioned(
            top: 30,
            right: 36,
            child: Icon(
              Icons.auto_awesome_rounded,
              color: Color(0xFFFFD166),
              size: 22,
            ),
          ),
          Positioned(
            bottom: 20,
            child: Container(
              width: 170,
              height: 88,
              decoration: BoxDecoration(
                color: const Color(0xFFFFD166),
                borderRadius: BorderRadius.circular(13),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                color: Color(0xFF2457D6),
                size: 68,
              ),
            ),
          ),
          const Positioned(
            top: 43,
            child: CircleAvatar(
              radius: 25,
              backgroundColor: Color(0xFFFFE0BD),
              child: Icon(
                Icons.face_rounded,
                color: Color(0xFF6B4E3D),
                size: 34,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              width: 72,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFF162B58),
                borderRadius: BorderRadius.circular(30).copyWith(
                  bottomLeft: const Radius.circular(8),
                  bottomRight: const Radius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RegistrationSuccessScreen extends StatefulWidget {
  const RegistrationSuccessScreen({super.key, required this.student});

  final Map<String, String> student;

  @override
  State<RegistrationSuccessScreen> createState() =>
      _RegistrationSuccessScreenState();
}

class _RegistrationSuccessScreenState extends State<RegistrationSuccessScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..forward();
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text(
          'Student Registration Portal',
          style: TextStyle(
            color: Color(0xFF18243A),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          tooltip: 'Back to registration',
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
                side: const BorderSide(color: Color(0xFFE8EDF5)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  children: [
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: 82,
                        height: 82,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE8F7EF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Color(0xFF20A465),
                          size: 52,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Registration Successful!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF18243A),
                        fontSize: 25,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'The student details have been submitted successfully.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF758198)),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFD),
                        border: Border.all(color: const Color(0xFFE8EDF5)),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        children: widget.student.entries
                            .map(
                              (entry) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 145,
                                      child: Text(
                                        entry.key,
                                        style: const TextStyle(
                                          color: Color(0xFF758198),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        entry.value,
                                        style: const TextStyle(
                                          color: Color(0xFF26334A),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.person_add_alt_1_rounded),
                        label: const Text('Register Another Student'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 50),
                          backgroundColor: const Color(0xFF2457D6),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
