import 'package:aoneadmin/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


class AddEmployeePage1 extends StatefulWidget {
  const AddEmployeePage1({super.key, required BuildContext menuScreenContext});

  @override
  _AddEmployeePageState createState() => _AddEmployeePageState();
}

class _AddEmployeePageState extends State<AddEmployeePage1> {
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

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 100), () {
      setState(() => _opacity = 1.0);
    });
  }


  Future<void> getAddressFromPincode(String pincode) async {
    final response = await http.get(
      Uri.parse('https://api.postalpincode.in/pincode/$pincode'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data[0]['Status'] == 'Success') {
        final postOffices = data[0]['PostOffice'];
        if (postOffices != null && postOffices.isNotEmpty) {
          final office = postOffices[0];
          String district = office['District'];
          String state = office['State'];
          String country = office['Country'];
          String area = office['Name'];

          print('Area: $area');
          print('District: $district');
          print('State: $state');
          print('Country: $country');
        } else {
          print('No details found for this pincode.');
        }
      } else {
        print('Invalid pincode');
      }
    } else {
      print('Failed to fetch data');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double horizontalPadding = screenWidth * 0.0;
    double fontSize = screenWidth * 0.04;

    return Theme(
      data: ThemeData(
        primaryColor: Colors.indigo,
        colorScheme: ColorScheme.light(
          primary: Colors.indigo,
          secondary: Colors.indigoAccent,
        ),
        textTheme: TextTheme(
          bodyMedium: TextStyle(fontSize: fontSize, color: Colors.black87),
          labelLarge: TextStyle(fontSize: fontSize + 2, fontWeight: FontWeight.w600),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.indigo, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          errorStyle: TextStyle(color: Colors.redAccent, fontSize: fontSize - 2),
        ),
      ),
      child: Scaffold(
        backgroundColor: AppColors.bottomBg,
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 0),
          child: Center(
            child: AnimatedOpacity(
              opacity: _opacity,
              duration: Duration(milliseconds: 500),
              child:Container(
                constraints: BoxConstraints(maxWidth: 600),
                padding: EdgeInsets.only(left: 15.sp,right: 15.sp),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          "Add New Employee",
                          style: TextStyle(
                            fontSize: fontSize + 4,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo[800],
                          ),
                        ),
                      ),

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



                      SizedBox(height: 10),
                      Center(
                        child: GestureDetector(
                          onTapDown: (_) => setState(() => _opacity = 0.8),
                          onTapUp: (_) => setState(() => _opacity = 1.0),
                          child: AnimatedOpacity(
                            opacity: _opacity,
                            duration: Duration(milliseconds: 200),
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  // Submit action
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.15,
                                  vertical: 16,
                                ),
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.indigo, Colors.indigoAccent],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                child: Text(
                                  "Submit",
                                  style: TextStyle(
                                    fontSize: fontSize + 2,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 80.sp),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
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