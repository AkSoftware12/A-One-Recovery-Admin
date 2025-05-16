import 'dart:async';
import 'package:aoneadmin/constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../textSize.dart';



class AddEmployee extends StatefulWidget {
  final VoidCallback onReturn;

  const AddEmployee({super.key, required BuildContext menuScreenContext, required this.onReturn});

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<AddEmployee> with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  final _personalFormKey = GlobalKey<FormState>();
  final _bankFormKey = GlobalKey<FormState>();
  final _purposeFormKey = GlobalKey<FormState>();
  AnimationController? _animationController;
  Animation<double>? _animation;
  bool _isLoading = false;

  String? _selectedOption; // Holds the selected dropdown value ("Permanent" or "Contract")
  int? _selectedValue;

  String? _selectedOption2; // Holds the selected dropdown value ("Permanent" or "Contract")
  int? _selectedValue2;

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
  final TextEditingController joiningDateController = TextEditingController();
  final TextEditingController ifscController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController pinController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController branchNameController = TextEditingController();
  final TextEditingController bankNameController = TextEditingController();
  final TextEditingController bankCityController = TextEditingController();
  final TextEditingController bankStateController = TextEditingController();
  final TextEditingController bankAccountNoController = TextEditingController();
  final TextEditingController basicPayController = TextEditingController();

  List<Map<String, dynamic>> documents = [];
  final TextEditingController _documentNameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  String? contractType;
  String? bloodGroup;
  String? gender;
  String? religion;
  String? employeetype;
  String? socialCategory;
  double _opacity = 0.0;


  // Phone info
  final _phoneController = TextEditingController();
  String _selectedPhoneOption = "";

  // Purpose info
  String _callingPurpose = "";
  String _callingAction = "";
  String city = '';
  String stateName = '';

  String? branch, bankCity, state, bank;
  Timer? _debounce;


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

    // ifscController.addListener(() {
    //   if (ifscController.text.length == 11) {
    //     _onIFSCChanged(ifscController.text);
    //   }
    // });


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

  // Fetch bank details from API
  Future<void> getDetails(String ifscCode) async {
    final url = Uri.parse('https://ifsc.razorpay.com/$ifscCode');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      setState(() {
        branchNameController.text = data['BRANCH'];
        bankCityController.text  = data['CITY'];
        bankStateController.text = data['STATE'];
        bankNameController.text  = data['BANK'];
      });
    } else {
      setState(() {
        branch = bankCity = state = bank = null;
        branchNameController.clear();  // <-- ye line add karo agar textfield bhi empty karni ho
        bankStateController.clear();  // <-- ye line add karo agar textfield bhi empty karni ho
        bankCityController.clear();  // <-- ye line add karo agar textfield bhi empty karni ho
        bankNameController.clear();  // <-- ye line add karo agar textfield bhi empty karni ho

      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid IFSC Code")),
      );
    }
  }

  // Debounce textfield changes
  void _onIFSCChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(Duration(milliseconds: 600), () {
      if (value.length == 11) {
        getDetails(value);
      } else {
        setState(() {
          branch = bankCity = state = bank = null;
          branchNameController.clear();  // <-- ye line add karo agar textfield bhi empty karni ho
          bankStateController.clear();  // <-- ye line add karo agar textfield bhi empty karni ho
          bankCityController.clear();  // <-- ye line add karo agar textfield bhi empty karni ho
          bankNameController.clear();  // <-- ye line add karo agar textfield bhi empty karni ho

        });
      }
    });
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        documents.add({
          'name': _documentNameController.text,
          'image': pickedFile.path,
        });
      });
      _documentNameController.clear();  // Clear the name field after adding the document
    }
  }

  // Function to add document
  void _addDocument() {
    if (_documentNameController.text.isNotEmpty) {
      _pickImage();
    } else {
      // Show warning if document name is empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a document name')),
      );
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

    ifscController.dispose();
    _debounce?.cancel();
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
                      _buildProgressIndicator(1, "Bank Details"),
                      Expanded(
                        child: Container(
                          height: 3,
                          color: _currentStep > 1 ? Colors.indigo : Colors.grey.shade300,
                        ),
                      ),
                      _buildProgressIndicator(2, "Document"),
                      Expanded(
                        child: Container(
                          height: 3,
                          color: _currentStep > 2 ? Colors.indigo : Colors.grey.shade300,
                        ),
                      ),
                      _buildProgressIndicator(3, "Other"),

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
        return _buildBankInfoStep();
      case 2:
        return _buildDocumentsStep();
      case 3:
        return _buildOtherStep();
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
            SizedBox(height: 0),

            buildLabel("Name", fontSize),
            buildTextField(
              hint: "Enter Name",
              controller: nameController,
              fontSize: fontSize,
              icon: Icons.person_outline,
              keyboardType: TextInputType.name
            ),





            buildLabel("Email", fontSize),
            buildTextField(
              hint: "Enter Email",
              controller: emailController,
              fontSize: fontSize,
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),

            buildLabel("Contact", fontSize),
            buildTextFieldContactNumber(
              hint: "Enter Contact Number",
              controller: contactController,
              fontSize: fontSize,
              icon: Icons.call,
              keyboardType: TextInputType.number,
            ),


            buildLabel("PIN", fontSize),
            buildTextFieldPinCode(
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


            buildLabel("Gender", fontSize),
            buildDropdown(
              items: ["Male", "Female", "Other"],
              onChanged: (value) => setState(() => gender = value),
              value: gender,
              fontSize: fontSize,
              icon: Icons.person,
            ),
            SizedBox(height: 40),
            _buildNextButton(() {

                if (nameController.text.isEmpty) {
                  // Show name validation error as toast
                  Fluttertoast.showToast(msg: "Please enter your name",backgroundColor: Colors.red,textColor: Colors.white,  gravity: ToastGravity.CENTER,
                  );
                }

               else if (contactController.text.isEmpty) {
                  // Show contact validation error as toast
                  Fluttertoast.showToast(msg: "Please enter your contact number",backgroundColor: Colors.red,textColor: Colors.white, gravity: ToastGravity.CENTER,);
                }

               else {
                  _navigateToStep(1);

                }
              }





              // if (_personalFormKey.currentState!.validate()) {
              //   _navigateToStep(1);
              // }
            ),
            SizedBox(height: 80),

          ],
        ),
      ),
    );
  }

  Widget _buildBankInfoStep() {
    double screenWidth = MediaQuery.of(context).size.width;
    double horizontalPadding = screenWidth * 0.0;
    double fontSize = screenWidth * 0.04;
    return Form(
      key: _bankFormKey,
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Bank Information"),

            buildLabel("Account Number", fontSize),
            buildTextField(
              hint: "Enter account number",
              keyboardType: TextInputType.number,
              controller: bankAccountNoController,
              fontSize: fontSize,
              icon: Icons.account_balance,

            ),

            buildLabel("IFSC Code", fontSize),
            buildTextField(
              hint: "Enter IFSC Code",
              controller: ifscController,
              fontSize: fontSize,
              icon: Icons.account_balance,
              onChanged: (text) {
                _onIFSCChanged(text);

              },
            ),

            buildLabel("Bank Name", fontSize),
            buildTextField(
              hint: "Enter Bank Name",
              controller: bankNameController,
              fontSize: fontSize,
              icon: Icons.person_outline,
            ),

            buildLabel("Branch Name", fontSize),
            buildTextField(
              hint: "Enter Branch Name",
              controller: branchNameController,
              fontSize: fontSize,
              icon: Icons.person_outline,
            ),


            buildLabel("Bank City", fontSize),
            buildTextField(
              hint: "Enter Bank City",
              controller: bankCityController,
              fontSize: fontSize,
              icon: Icons.location_city,
            ),

            buildLabel("Bank State", fontSize),

            buildTextField(
              hint: "Enter  Bank State",
              controller: bankStateController,
              fontSize: fontSize,
              icon: Icons.language,
            ),



            SizedBox(height: 40),

            Row(
              children: [
                Expanded(
                  child: _buildBackButton(() => _navigateToStep(0)),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildNextButton(() {
                    _navigateToStep(2);

                  }),
                ),
              ],
            ),

            // _buildNextButton(() {
            //   // if (_bankFormKey.currentState!.validate()) {
            //   //   _navigateToStep(2);
            //   // }
            //
            //   _navigateToStep(2);
            //
            // }),
            SizedBox(height: 80),

          ],
        ),
      ),
    );
  }

  Widget _buildOtherStep() {
    double screenWidth = MediaQuery.of(context).size.width;
    double horizontalPadding = screenWidth * 0.0;
    double fontSize = screenWidth * 0.04;
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Others"),
          buildLabel("Basic Pay ", fontSize),
          buildTextField(
            hint: "Enter amount ",
            controller: basicPayController,
            keyboardType: TextInputType.number,
            fontSize: fontSize,
            icon: Icons.currency_rupee,
          ),

          buildLabel("Joining Date", fontSize),
          TextFormField(
            controller: joiningDateController,
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
                  joiningDateController.text = DateFormat('dd-MM-yyyy').format(pickedDate);
                });
              }
            },
            validator: (value) => value!.isEmpty ? "Required field" : null,
          ),


          buildLabel("Contract Type", fontSize),
          buildDropdown2(
            items: ["Permanent", "Contract"], // Dropdown options
            onChanged: _handleDropdownChange, // Callback to handle selection
            value: _selectedOption, // Current selected option
            fontSize: 16.0, // Font size for dropdown
            icon: Icons.work, // Icon for dropdown
          ),

          buildLabel("Blood Group", fontSize),
          buildDropdown(
            items: ["A+", "A-", "B+", "B-", "O+", "O-", "AB+", "AB-"],
            onChanged: (value) => setState(() => bloodGroup = value),
            value: bloodGroup,
            fontSize: fontSize,
            icon: Icons.bloodtype_outlined,
          ),

          buildLabel("Religion", fontSize),
          buildDropdown(
              items: ["Christianity", "Islam", "Hinduism", "Buddhism", "Judaism", "Other"],
            onChanged: (value) => setState(() => religion = value),
            value: religion,
            fontSize: fontSize,
            icon: Icons.person,
          ),


          buildLabel("Employee Type", fontSize),
          buildDropdown2(
              items: ["Fos", "Office",],
            onChanged: _handleDropdownChange2, // Callback to handle selection
            // onChanged: (value) => setState(() => employeetype = value),
            value: _selectedOption2,
            fontSize: fontSize,
            icon: Icons.person,
          ),


          buildLabel("Social Category", fontSize),
          buildDropdown(
              items: ["General", "OBC", "SC", "ST", "EWS", "Other"],
            onChanged: (value) => setState(() => socialCategory = value),
            value: socialCategory,
            fontSize: fontSize,
            icon: Icons.person,
          ),

          SizedBox(height: 40),
          Row(
            children: [
              Expanded(
                child: _buildBackButton(() => _navigateToStep(2)),
              ),
              SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _isLoading
                      ? null
                      : () async {
                    if (_selectedValue == null) {
                      Fluttertoast.showToast(
                        msg: "Please enter Contract Type",
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        gravity: ToastGravity.CENTER,
                      );
                    } else if (_selectedValue2 == null) {
                      Fluttertoast.showToast(
                        msg: "Please enter your Employee type",
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        gravity: ToastGravity.CENTER,
                      );
                    } else {
                      setState(() {
                        _isLoading = true;
                      });

                      try {
                        final response = await hitApi();
                        if (mounted) {
                          setState(() {
                            _isLoading = false;
                          });
                        }

                        // if (response.statusCode == 200) {
                        //   // _navigateToStep(4);
                        //   Fluttertoast.showToast(
                        //     msg: "Success!",
                        //     backgroundColor: Colors.green,
                        //     textColor: Colors.white,
                        //     gravity: ToastGravity.CENTER,
                        //   );
                        // } else {
                        //   Fluttertoast.showToast(
                        //     msg: "API Error: ${response.statusCode}",
                        //     backgroundColor: Colors.red,
                        //     textColor: Colors.white,
                        //     gravity: ToastGravity.CENTER,
                        //   );
                        // }
                      } catch (e) {
                        if (mounted) {
                          setState(() {
                            _isLoading = false;
                          });
                        }
                        Fluttertoast.showToast(
                          msg: "Error: $e",
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          gravity: ToastGravity.CENTER,
                        );
                      }
                    }
                  },
                  icon: _isLoading
                      ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : Icon(Icons.check_circle, color: Colors.white),
                  label: Text(
                    _isLoading ? "Submitting..." : "Submit",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
                ],
          ),

          SizedBox(height: 80),

        ],
      ),
    );
  }
  Future<void> hitApi() async {
    setState(() {
      _isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    // Prepare data
    Map<String, dynamic> data = {
      'name': nameController.text,
      'email': emailController.text,
      'state': stateController.text,
      'district': districtController.text,
      'pin': pinController.text,
      'address': addressController.text,
      'contact': contactController.text,
      'dob': dobController.text,
      'bank_account_no': bankAccountNoController.text,
      'ifsc_code': ifscController.text,
      'joining_date': joiningDateController.text,
      'employee_type': _selectedValue2,
      'contract_type': _selectedValue,
      'religion': religion,
      'social_category': socialCategory,
      'blood_group': bloodGroup,
      'adhar_card_no': '7894531456',
      'pan_card_no': '456saf5656',
      'gender': gender,
      'basic_pay': basicPayController.text,
    };

    try {
      // Make API request
      final response = await http.post(
        Uri.parse(ApiRoutes.employeeCreate),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      setState(() {
        _isLoading = false;
      });

      // Handle response
      print('Response: ${response.body}');
      if (response.statusCode == 200) {
        widget.onReturn();
        Navigator.of(context).pop();
        print('API call successful');
        // _showSuccessDialog();
      } else {
        Fluttertoast.showToast(
            msg: "${response.statusCode}",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );
        print('API call failed with status: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      Fluttertoast.showToast(
          msg: "$e",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
      print('Error: $e');
    }
  }

  Widget _buildDocumentsStep() {
    double screenWidth = MediaQuery.of(context).size.width;
    double horizontalPadding = screenWidth * 0.0;
    double fontSize = screenWidth * 0.04;
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Documents"),

          // Document Name TextField
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: TextField(
              controller: _documentNameController,
              decoration: InputDecoration(
                labelText: 'Document Name',
                hintText: 'Enter the name of the document',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12), // Rounded corners
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20), // Adjust padding
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.blue, width: 2), // Blue border on focus
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey, width: 1), // Grey border when enabled
                ),
              ),
            ),
          ),

          SizedBox(height: 20),

          // Add More Button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.bgYellow, // Change to your desired color
              ),
              onPressed: _addDocument,
              child: Text('Add More',style: GoogleFonts.poppins(
                textStyle: Theme.of(context)
                    .textTheme
                    .displayLarge,
                fontSize: TextSizes.text12,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.normal,
                color: AppColors.textWhite,
              ),),
            ),
          ),
          SizedBox(height: 40),

          // Display added documents
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Number of items per row (you can adjust this)
                crossAxisSpacing: 10.0, // Space between columns
                mainAxisSpacing: 10.0, // Space between rows
              ),
              itemCount: documents.length,
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                var doc = documents[index];
                return Card(
                  elevation: 4,
                  color: AppColors.bgYellow,
                  child: Column(
                    children: [
                      Text(doc['name'], style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white)),
                      doc['image'] != null
                          ? SizedBox(
                        height: 150.0,
                        width: double.infinity,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0), // Optional: for rounded corners
                          child: Image.file(
                            File(doc['image']),
                            fit: BoxFit.cover, // This ensures the image covers the available space
                          ),
                        ),
                      )
                          : Container(),
                    ],
                  ),
                );

              },
            ),
          ),

          SizedBox(height: 40),

          Row(
            children: [
              Expanded(
                child: _buildBackButton(() => _navigateToStep(1)),
              ),
              SizedBox(width: 16),
              Expanded(
                child:  Expanded(
                  child: _buildNextButton(() {
                    _navigateToStep(3);

                  }),
                ),
              ),
            ],
          ),


          // Next Button
          // _buildNextButton(() {
          //   // Navigate to the next step
          //   _navigateToStep(3);
          // }),
          SizedBox(height: 80),
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
    void Function(String)? onChanged, // 👈 add this line
  }) {
    return TextFormField(
      controller: controller,
      style: TextStyle(fontSize: fontSize),
      keyboardType: keyboardType,
      textInputAction: TextInputAction.next, // This makes the "Next" button appear
      onEditingComplete: () {
        // You can handle what happens when the "Next" button is pressed here
        FocusScope.of(context).nextFocus(); // Move to the next field
      },
      onChanged: onChanged, // 👈 use it here
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

  Widget buildTextFieldPinCode({
    required String hint,
    required TextEditingController controller,
    required double fontSize,
    required IconData icon,
    TextInputType? keyboardType,
    void Function(String)? onChanged, // 👈 add this line
  }) {
    return TextFormField(
      controller: controller,
      style: TextStyle(fontSize: fontSize),
      keyboardType: keyboardType,
      maxLength: 6,  // Maximum length of 6 characters
      textInputAction: TextInputAction.next, // This makes the "Next" button appear
      onEditingComplete: () {
        // You can handle what happens when the "Next" button is pressed here
        FocusScope.of(context).nextFocus(); // Move to the next field
      },
      onChanged: onChanged, // 👈 use it here
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

  Widget buildTextFieldContactNumber({
    required String hint,
    required TextEditingController controller,
    required double fontSize,
    required IconData icon,
    TextInputType? keyboardType,
    void Function(String)? onChanged, // 👈 add this line
  }) {
    return TextFormField(
      controller: controller,
      style: TextStyle(fontSize: fontSize),
      keyboardType: keyboardType,
      maxLength: 10,  // Maximum length of 6 characters
      textInputAction: TextInputAction.next, // This makes the "Next" button appear
      onEditingComplete: () {
        // You can handle what happens when the "Next" button is pressed here
        FocusScope.of(context).nextFocus(); // Move to the next field
      },
      onChanged: onChanged, // 👈 use it here
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

  void _handleDropdownChange(String? newValue) {
    setState(() {
      _selectedOption = newValue;
      if (newValue == "Permanent") {
        _selectedValue = 1;
      } else if (newValue == "Contract") {
        _selectedValue = 2;
      } else {
        _selectedValue = null; // Handle null case if needed
      }
      print("Selected Option: $_selectedOption, Value: $_selectedValue");
    });
  }

  void _handleDropdownChange2(String? newValue) {
    setState(() {
      _selectedOption2 = newValue;
      if (newValue == "Fos") {
        _selectedValue2 = 1;
      } else if (newValue == "Office") {
        _selectedValue2 = 2;
      } else {
        _selectedValue2 = null; // Handle null case if needed
      }
      print("Selected Option: $_selectedOption2, Value: $_selectedValue2");
    });
  }

  // The provided buildDropdown2 widget
  Widget buildDropdown2({
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




class LoadingDialog {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  static void hide(BuildContext context) {
    Navigator.of(context).pop();
  }
}