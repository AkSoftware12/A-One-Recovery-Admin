
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../constants.dart';
import '../../../../textSize.dart';

class AllotRecoveryDialog {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _remarkController = TextEditingController();
  Map<String, dynamic>? _selectedCategory; // Store the entire category object
  final _formKey = GlobalKey<FormState>();
  String? _selectedTransactionType; // Add this to your state class
  // List to hold categories passed as parameter
  List _categoryExpenses = [];
  List _recovery = [];
  bool _isLoadingCategories = false;

  Future<bool> show(
      BuildContext context,
      List categoryExpenses,
      List recoverList,
      ) async {
    // Initialize controllers with provided values


    // Set the passed categoryExpenses list
    _categoryExpenses = categoryExpenses;
    _recovery = recoverList;

    // Find the category object that matches the provided categoryName
    // _selectedCategory = _categoryExpenses.firstWhere(
    //       (category) => category['title'] == categoryName,
    //   orElse: () => null,
    // );

    return await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      transitionDuration: Duration(milliseconds: 300),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          ),
          child: child,
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.sp),
          child: Dialog(
            elevation: 8,
            backgroundColor: Colors.white,
            insetPadding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
                maxWidth: MediaQuery.of(context).size.width * 0.9,
              ),
              child: IntrinsicHeight(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.99,
                  padding: EdgeInsets.all(16.sp),
                  child: StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                      return Column(
                        children: [
                          // Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Allot Recovery',
                                style: GoogleFonts.poppins(
                                  textStyle: Theme.of(context).textTheme.displayLarge,
                                  fontSize: TextSizes.text17,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textblack,
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.close, color: Colors.grey[600], size: 24.sp),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                          // Form
                          Expanded(
                            child: SingleChildScrollView(
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    SizedBox(height: 20.sp),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(left: 8.sp),
                                          child: Text(
                                            'Select Employee',
                                            style: GoogleFonts.poppins(
                                              textStyle: Theme.of(context).textTheme.displayLarge,
                                              fontSize: TextSizes.text14,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.textblack,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '',
                                          style: GoogleFonts.poppins(
                                            textStyle: Theme.of(context).textTheme.displayLarge,
                                            fontSize: TextSizes.text17,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.textblack,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 5.sp),
                                    // Category Dropdown
                                    _buildCategoryDropdown(context, setState),


                                    SizedBox(height: 25.sp),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Submit Button
                          _buildUpdateButton(context,),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ) ?? false;
  }

  Widget _buildCategoryDropdown(BuildContext context, StateSetter setState) {
    if (_isLoadingCategories) {
      return Center(child: CircularProgressIndicator());
    }

    if (_categoryExpenses.isEmpty) {
      return Text(
        'No categories available',
        style: GoogleFonts.poppins(
          fontSize: TextSizes.text14,
          color: Colors.red,
        ),
      );
    }

    return DropdownButtonFormField<Map<String, dynamic>>(
      icon: Icon(
        Icons.keyboard_arrow_down,
        size: 20.sp,
        color: AppColors.subTitleBlack,
      ),
      decoration: InputDecoration(
        labelStyle: GoogleFonts.poppins(
          textStyle: Theme.of(context).textTheme.displayLarge,
          fontSize: TextSizes.text15,
          fontWeight: FontWeight.w600,
          color: AppColors.subTitleBlack,
        ),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 12.h,
        ),
      ),
      hint: Text(
        'Select Employee',
        style: GoogleFonts.poppins(
          textStyle: Theme.of(context).textTheme.displayLarge,
          fontSize: TextSizes.text15,
          fontWeight: FontWeight.w500,
          color: AppColors.subTitleBlack.withOpacity(0.6),
        ),
      ),
      value: _selectedCategory,
      dropdownColor: Colors.white,
      items: _categoryExpenses.map<DropdownMenuItem<Map<String, dynamic>>>((category) {
        String title = category['name'].toString();
        return DropdownMenuItem<Map<String, dynamic>>(
          value: category, // Store the entire category object
          child: SizedBox(
            height: 30.sp,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  textStyle: Theme.of(context).textTheme.displayLarge,
                  fontSize: TextSizes.text15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.subTitleBlack,
                ),
              ),
            ),
          ),
        );
      }).toList(),
      onChanged: (Map<String, dynamic>? newValue) {
        setState(() {
          _selectedCategory = newValue;
        });
      },
      validator: (value) => value == null ? 'Please select a category' : null,
    );
  }
  Widget _buildUpdateButton(BuildContext context,) {
    return GestureDetector(
      onTap: () async {
        if (_formKey.currentState!.validate()) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.bgYellow),
              ),
            ),
          );

          try {
            bool success = await addFund();
            Navigator.pop(context); // Close progress dialog

            if (success) {
              Navigator.pop(context, true); // Return true on success
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to update allowance'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          } catch (e) {
            Navigator.pop(context); // Close progress dialog
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('An error occurred: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
      child: Container(
        width: 150.sp,
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.bgYellow,
              AppColors.bgYellow.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: AppColors.bgYellow.withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'Allot Recovery',
            style: GoogleFonts.poppins(
              fontSize: TextSizes.text15,
              fontWeight: FontWeight.w600,
              color: AppColors.textWhite,
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> addFund() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    var url = Uri.parse(ApiRoutes.assignAllot); // Adjust endpoint
    print(_selectedCategory);

    try {
      // Ensure _selectedCategory and _recovery are not null
      if (_selectedCategory == null || _recovery == null) {
        print('Error: _selectedCategory or _recovery is null');
        return false;
      }

      // Prepare the JSON payload
      final payload = {
        'employee_id': _selectedCategory!['id'].toString(),
        'loan_ids': _recovery
      };

      var response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        _clearControllers();
        print('Response Data: $data');
        return true;
      } else {
        print('Failed: ${response.statusCode}');
        print('Body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  void dispose() {
    _amountController.dispose();
    _dateController.dispose();
    _remarkController.dispose();
    _selectedCategory = null;
  }

  void _clearControllers() {
    _amountController.clear();
    _dateController.clear();
    _remarkController.clear();
    _selectedCategory = null;
  }
}

// Extension to capitalize the first letter of a string
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}