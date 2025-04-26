import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primarySwatch: Colors.indigo,
//         inputDecorationTheme: InputDecorationTheme(
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(color: Colors.indigo, width: 2),
//           ),
//           contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
//         ),
//         elevatedButtonTheme: ElevatedButtonThemeData(
//           style: ElevatedButton.styleFrom(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             elevation: 2,
//           ),
//         ),
//       ),
//       home: RegistrationPage(),
//     );
//   }
// }

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key, required BuildContext menuScreenContext});

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  final _personalFormKey = GlobalKey<FormState>();
  final _phoneFormKey = GlobalKey<FormState>();
  final _purposeFormKey = GlobalKey<FormState>();
  AnimationController? _animationController;
  Animation<double>? _animation;

  // Personal info controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedCountry = "United States";

  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController districtController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController ifscController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController pinController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  String? contractType;
  String? bloodGroup;
  String? gender;
  double _opacity = 0.0;
  // Phone info
  final _phoneController = TextEditingController();
  String _selectedPhoneOption = "";

  // Purpose info
  String _callingPurpose = "";
  String _callingAction = "";
  String city = '';
  String stateName = '';


  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeInOut,
    );
    _animationController!.forward();

    pinController.addListener(() {
      if (pinController.text.length == 6) {
        fetchCityState(pinController.text);
      }
    });

  }


  void fetchCityState(String pincode) async {
    final response = await http.get(
        Uri.parse('https://api.postalpincode.in/pincode/$pincode'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data[0]['Status'] == 'Success') {
        setState(() {
          districtController.text = data[0]['PostOffice'][0]['District'];
          stateController.text = data[0]['PostOffice'][0]['State'];
          // city = data[0]['PostOffice'][0]['District'];
          // stateName = data[0]['PostOffice'][0]['State'];
        });
      } else {
        setState(() {
          city = 'Not found';
          stateName = 'Not found';
        });
      }
    } else {
      setState(() {
        city = 'Error';
        stateName = 'Error';
      });
    }
  }
  @override
  void dispose() {
    _animationController?.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _navigateToStep(int step) {
    _animationController!.reverse().then((_) {
      setState(() {
        _currentStep = step;
      });
      _animationController!.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data:  ThemeData(
        primarySwatch: Colors.indigo,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.indigo, width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
        ),
      ),

      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.indigo.shade50, Colors.white],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 24.0,right: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Icon(Icons.app_registration, size: 25, color: Colors.indigo),
                    SizedBox(width: 12),
                    Text(
                      "Add Employee",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo.shade800
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 3),
                Text(
                  "Complete the steps to create your account",
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600
                  ),
                ),
                SizedBox(height: 10),

                // Progress indicators
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      _buildProgressIndicator(0, "Personal Info"),
                      Expanded(
                        child: Container(
                          height: 3,
                          color: _currentStep > 0 ? Colors.indigo : Colors.grey.shade300,
                        ),
                      ),
                      _buildProgressIndicator(1, "Phone"),
                      Expanded(
                        child: Container(
                          height: 3,
                          color: _currentStep > 1 ? Colors.indigo : Colors.grey.shade300,
                        ),
                      ),
                      _buildProgressIndicator(2, "Purpose"),
                      Expanded(
                        child: Container(
                          height: 3,
                          color: _currentStep > 1 ? Colors.indigo : Colors.grey.shade300,
                        ),
                      ),
                      _buildProgressIndicator(3, "Bank"),

                    ],
                  ),
                ),

                SizedBox(height: 32),

                // Form steps
                Expanded(
                  child: FadeTransition(
                    opacity: _animation!,
                    child: _buildCurrentStep(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(int step, String label) {
    bool isActive = _currentStep >= step;
    bool isCurrent = _currentStep == step;

    return Column(
      children: [
        GestureDetector(
          onTap: _currentStep > step ? () => _navigateToStep(step) : null,
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: isActive ? Colors.indigo : Colors.grey.shade300,
              shape: BoxShape.circle,
              boxShadow: isCurrent ? [
                BoxShadow(
                  color: Colors.indigo.withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                )
              ] : null,
            ),
            child: Center(
              child: isActive
                  ? Icon(Icons.check, color: Colors.white, size: 22)
                  : Text(
                "${step + 1}",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: isCurrent ? Colors.indigo : Colors.grey.shade700,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildPersonalInfoStep();
      case 1:
        return _buildPhoneVerificationStep();
      case 2:
        return _buildPurposeStep();
      default:
        return Container();
    }
  }

  Widget _buildPersonalInfoStep() {
    double screenWidth = MediaQuery.of(context).size.width;
    double horizontalPadding = screenWidth * 0.0;
    double fontSize = screenWidth * 0.04;
    return Form(
      key: _personalFormKey,
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Personal Information"),
            SizedBox(height: 16),

            buildLabel("Name", fontSize),
            buildTextField(
              hint: "Enter Name",
              controller: nameController,
              fontSize: fontSize,
              icon: Icons.person_outline,
            ),



            buildLabel("Date of Birth", fontSize),
            TextFormField(
              controller: dobController,
              style: TextStyle(fontSize: fontSize),
              decoration: InputDecoration(
                hintText: "dd-mm-yyyy",
                hintStyle: TextStyle(fontSize: fontSize, color: Colors.grey[400]),
                suffixIcon: Icon(Icons.calendar_today, color: Colors.indigo),
              ),
              readOnly: true,
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime(1990),
                  firstDate: DateTime(1950),
                  lastDate: DateTime.now(),
                  builder: (context, child) {
                    return Theme(
                      data: ThemeData.light().copyWith(
                        colorScheme: ColorScheme.light(
                          primary: Colors.indigo,
                          onPrimary: Colors.white,
                          surface: Colors.white,
                        ),
                        dialogBackgroundColor: Colors.white,
                      ),
                      child: child!,
                    );
                  },
                );
                if (pickedDate != null) {
                  setState(() {
                    dobController.text = DateFormat('dd-MM-yyyy').format(pickedDate);
                  });
                }
              },
              validator: (value) => value!.isEmpty ? "Required field" : null,
            ),

            buildLabel("IFSC Code", fontSize),
            buildTextField(
              hint: "Enter IFSC Code",
              controller: ifscController,
              fontSize: fontSize,
              icon: Icons.account_balance,
            ),

            buildLabel("Contract Type", fontSize),
            buildDropdown(
              items: ["Permanent", "Contract"],
              onChanged: (value) => setState(() => contractType = value),
              value: contractType,
              fontSize: fontSize,
              icon: Icons.work_outline,
            ),

            buildLabel("Blood Group", fontSize),
            buildDropdown(
              items: ["A+", "A-", "B+", "B-", "O+", "O-", "AB+", "AB-"],
              onChanged: (value) => setState(() => bloodGroup = value),
              value: bloodGroup,
              fontSize: fontSize,
              icon: Icons.bloodtype_outlined,
            ),

            buildLabel("Gender", fontSize),
            buildDropdown(
              items: ["Male", "Female", "Other"],
              onChanged: (value) => setState(() => gender = value),
              value: gender,
              fontSize: fontSize,
              icon: Icons.person,
            ),

            buildLabel("Email", fontSize),
            buildTextField(
              hint: "Enter Email",
              controller: emailController,
              fontSize: fontSize,
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),

            buildLabel("PIN", fontSize),
            buildTextField(
              hint: "Enter PIN",
              controller: pinController,
              fontSize: fontSize,
              icon: Icons.lock_outline,
              keyboardType: TextInputType.number,
            ),

            buildLabel("Address", fontSize),
            buildTextField(
              hint: "Enter Address",
              controller: addressController,
              fontSize: fontSize,
              icon: Icons.book,
              keyboardType: TextInputType.streetAddress,
            ),



            buildLabel("District", fontSize),
            buildTextField(
              hint: "Enter District",
              controller: districtController,
              fontSize: fontSize,
              icon: Icons.location_city,
            ),

            buildLabel("State", fontSize),

            buildTextField(
              hint: "Enter State",
              controller: stateController,
              fontSize: fontSize,
              icon: Icons.language,
            ),

            // TextFormField(
            //   controller: _firstNameController,
            //   decoration: InputDecoration(
            //     labelText: "First Name",
            //     prefixIcon: Icon(Icons.person_outline),
            //   ),
            //   validator: (value) => value!.isEmpty ? "Required field" : null,
            // ),
            // SizedBox(height: 20),
            // TextFormField(
            //   controller: _lastNameController,
            //   decoration: InputDecoration(
            //     labelText: "Last Name",
            //     prefixIcon: Icon(Icons.person_outline),
            //   ),
            //   validator: (value) => value!.isEmpty ? "Required field" : null,
            // ),
            // SizedBox(height: 20),
            // TextFormField(
            //   controller: _emailController,
            //   decoration: InputDecoration(
            //     labelText: "Your email",
            //     prefixIcon: Icon(Icons.email_outlined),
            //   ),
            //   validator: (value) => value!.isEmpty || !value.contains('@')
            //       ? "Enter a valid email" : null,
            // ),
            // SizedBox(height: 20),
            // TextFormField(
            //   controller: _passwordController,
            //   obscureText: true,
            //   decoration: InputDecoration(
            //     labelText: "Password",
            //     prefixIcon: Icon(Icons.lock_outline),
            //   ),
            //   validator: (value) => value!.length < 6
            //       ? "Password must be at least 6 characters" : null,
            // ),
            // SizedBox(height: 20),
            // DropdownButtonFormField<String>(
            //   value: _selectedCountry,
            //   decoration: InputDecoration(
            //     labelText: "Country",
            //     prefixIcon: Icon(Icons.public),
            //   ),
            //   items: ["United States", "Canada", "United Kingdom", "Australia"]
            //       .map((country) => DropdownMenuItem(
            //     value: country,
            //     child: Text(country),
            //   ))
            //       .toList(),
            //   onChanged: (value) {
            //     setState(() {
            //       _selectedCountry = value!;
            //     });
            //   },
            // ),
            SizedBox(height: 40),
            _buildNextButton(() {
              if (_personalFormKey.currentState!.validate()) {
                _navigateToStep(1);
              }
            }),
            SizedBox(height: 80),

          ],
        ),
      ),
    );
  }

  Widget _buildPhoneVerificationStep() {
    return Form(
      key: _phoneFormKey,
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Verify Your Phone"),
            SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: "Phone Number",
                prefixIcon: Icon(Icons.phone_android),
                hintText: "(xxx) xxx-xxxx",
              ),
              keyboardType: TextInputType.phone,
              validator: (value) => value!.isEmpty ? "Required field" : null,
            ),
            SizedBox(height: 24),

            Text(
              "Select your preferred number",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.indigo.shade800
              ),
            ),
            SizedBox(height: 8),

            _buildPhoneOption("(385) 121-4567", "(385) 121-4567"),
            _buildPhoneOption("(385) 555-2200", "(385) 555-2200", selected: true),
            _buildPhoneOption("(385) 121-4567", "(385) 121-4567_2"),
            _buildPhoneOption("(385) 555-2200", "(385) 555-2200_2"),

            SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  child: _buildBackButton(() => _navigateToStep(0)),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildNextButton(() {
                    if (_phoneFormKey.currentState!.validate() &&
                        _selectedPhoneOption.isNotEmpty) {
                      _navigateToStep(2);
                    }
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneOption(String title, String value, {bool selected = false}) {
    return Card(
      elevation: _selectedPhoneOption == value ? 3 : 1,
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _selectedPhoneOption == value ? Colors.indigo : Colors.transparent,
          width: 2,
        ),
      ),
      child: RadioListTile(
        title: Text(
          title,
          style: TextStyle(
            fontWeight: _selectedPhoneOption == value ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        value: value,
        groupValue: _selectedPhoneOption,
        onChanged: (value) {
          setState(() {
            _selectedPhoneOption = value.toString();
          });
        },
        activeColor: Colors.indigo,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildPurposeStep() {
    return Form(
      key: _purposeFormKey,
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Setup Purpose"),
            SizedBox(height: 16),

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.help_outline, color: Colors.indigo),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Thank you for calling XYZ Company. How can I help you?",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),

            _buildPurposeExpansionTile(
              "1. If they are calling",
              [
                {"title": "Cancel an appointment", "value": "Cancel an appointment"},
              ],
            ),

            SizedBox(height: 16),

            _buildPurposeExpansionTile(
              "2. If they are calling",
              [
                {"title": "Ask about a product", "value": "Ask about a product"},
                {"title": "Ask for their information", "value": "Ask for their information"},
              ],
            ),

            SizedBox(height: 24),

            if (_callingPurpose.isNotEmpty && _callingAction.isNotEmpty)
              _buildSummarySection(),

            SizedBox(height: 40),

            Row(
              children: [
                Expanded(
                  child: _buildBackButton(() => _navigateToStep(1)),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {
                      if (_callingPurpose.isNotEmpty && _callingAction.isNotEmpty) {
                        // Submit the form
                        _showSuccessDialog();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Please select an option")),
                        );
                      }
                    },
                    icon: Icon(Icons.check_circle, color: Colors.white),
                    label: Text(
                      "Submit",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Center(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: Colors.indigo.shade300),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onPressed: () {
                  // Add another option
                },
                icon: Icon(Icons.add, size: 20),
                label: Text("Add another option"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPurposeExpansionTile(String title, List<Map<String, String>> options) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.indigo.shade800,
          ),
        ),
        children: options.map((option) =>
            RadioListTile(
              title: Text(option["title"]!),
              value: option["value"]!,
              groupValue: _callingAction,
              onChanged: (value) {
                setState(() {
                  _callingPurpose = title;
                  _callingAction = value.toString();
                });
              },
              activeColor: Colors.indigo,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            ),
        ).toList(),
      ),
    );
  }

  Widget _buildSummarySection() {
    return Card(
      elevation: 3,
      color: Colors.indigo.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.indigo.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Registration Summary",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.indigo.shade800,
              ),
            ),
            Divider(color: Colors.indigo.shade200),
            _buildSummaryItem("Name", "${_firstNameController.text} ${_lastNameController.text}"),
            _buildSummaryItem("Email", _emailController.text),
            _buildSummaryItem("Country", _selectedCountry),
            _buildSummaryItem("Phone", _selectedPhoneOption.split('_').first),
            _buildSummaryItem("Purpose", _callingAction),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.indigo.shade800,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.indigo.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.indigo.shade800,
      ),
    );
  }

  Widget _buildNextButton(VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.indigo,
        ),
        onPressed: onPressed,
        icon: Icon(Icons.arrow_forward, color: Colors.white),
        label: Text(
          "Next",
          style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildBackButton(VoidCallback onPressed) {
    return SizedBox(
      height: 54,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.indigo),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
        icon: Icon(Icons.arrow_back, color: Colors.indigo),
        label: Text(
          "Previous",
          style: TextStyle(fontSize: 16, color: Colors.indigo, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 8),
            Text("Success!"),
          ],
        ),
        content: Text(
          "Your registration is complete! Welcome to our platform.",
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              "OK",
              style: TextStyle(fontSize: 16, color: Colors.indigo),
            ),
          ),
        ],
      ),
    );
  }


  Widget buildLabel(String text, double fontSize) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize + 1,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget buildTextField({
    required String hint,
    required TextEditingController controller,
    required double fontSize,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      style: TextStyle(fontSize: fontSize),
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: fontSize, color: Colors.grey[400]),
        prefixIcon: Icon(icon, color: Colors.indigo),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.redAccent, width: 2),
        ),
      ),
      validator: (value) => value!.isEmpty ? "Required field" : null,
    );
  }
  Widget buildText({
    required String hint,
    required TextEditingController controller,
    required double fontSize,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Text(
      controller.text,
      style: TextStyle(fontSize: fontSize),
    );
  }
  Widget buildDropdown({
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required String? value,
    required double fontSize,
    required IconData icon,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.indigo),
        hintStyle: TextStyle(fontSize: fontSize, color: Colors.grey[400]),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.redAccent, width: 2),
        ),
      ),
      hint: Text("Select", style: TextStyle(fontSize: fontSize)),
      onChanged: onChanged,
      items: items
          .map((item) => DropdownMenuItem(
        value: item,
        child: Text(item, style: TextStyle(fontSize: fontSize)),
      ))
          .toList(),
      validator: (value) => value == null ? "Please select an option" : null,
    );
  }
}
