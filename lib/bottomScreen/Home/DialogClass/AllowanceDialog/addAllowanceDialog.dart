import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../../../constants.dart';
import '../../../../textSize.dart';

class AllowanceDialog {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _percentageController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _remarkController = TextEditingController();
  String? _selectedType;
  final _formKey = GlobalKey<FormState>();

  Future<bool> show(BuildContext context) async { // Changed to return Future<bool>
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
                  padding: EdgeInsets.all(16.sp),
                  child: StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Add Allowance',
                                style: GoogleFonts.poppins(
                                  textStyle: Theme.of(context).textTheme.displayLarge,
                                  fontSize: TextSizes.text17,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textblack,
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.close, color: Colors.grey[600], size: 24.sp),
                                onPressed: () {
                                  _titleController.clear();
                                  _amountController.clear();
                                  _percentageController.clear();
                                  _selectedType = null;
                                  Navigator.pop(context, false); // Return false on cancel
                                },
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
                                        Text(
                                          'Title',
                                          style: GoogleFonts.poppins(
                                            textStyle: Theme.of(context).textTheme.displayLarge,
                                            fontSize: TextSizes.text14,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.subTitleBlack,
                                          ),
                                        ),
                                        Text(''),
                                      ],
                                    ),
                                    SizedBox(height: 10.sp),
                                    // Title Field
                                    TextFormField(
                                      controller: _titleController,
                                      decoration: InputDecoration(
                                        hintText: 'Enter Allowance Title',
                                        labelStyle: GoogleFonts.poppins(
                                          textStyle: Theme.of(context).textTheme.displayLarge,
                                          fontSize: TextSizes.text15,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.subTitleBlack,
                                        ),
                                        hintStyle: GoogleFonts.poppins(
                                          textStyle: Theme.of(context).textTheme.displayLarge,
                                          fontSize: TextSizes.text15,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.subTitleBlack.withOpacity(0.6),
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
                                      keyboardType: TextInputType.text,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter a title';
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: 16.sp),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Type',
                                          style: GoogleFonts.poppins(
                                            textStyle: Theme.of(context).textTheme.displayLarge,
                                            fontSize: TextSizes.text14,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.subTitleBlack,
                                          ),
                                        ),
                                        Text(''),
                                      ],
                                    ),
                                    SizedBox(height: 10.sp),
                                    // Type Dropdown
                                    DropdownButtonFormField<String>(
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
                                        'Select Type',
                                        style: GoogleFonts.poppins(
                                          textStyle: Theme.of(context).textTheme.displayLarge,
                                          fontSize: TextSizes.text15,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.subTitleBlack.withOpacity(0.6),
                                        ),
                                      ),
                                      value: _selectedType,
                                      dropdownColor: Colors.white,
                                      items: <String>['Amount', 'Percentage']
                                          .map<DropdownMenuItem<String>>((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(
                                            value,
                                            style: GoogleFonts.poppins(
                                              textStyle: Theme.of(context).textTheme.displayLarge,
                                              fontSize: TextSizes.text15,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.subTitleBlack,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          _selectedType = newValue;
                                          _amountController.clear();
                                          _percentageController.clear();
                                        });
                                      },
                                      validator: (value) =>
                                      value == null ? 'Please select a type' : null,
                                    ),
                                    if (_selectedType != null) ...[
                                      SizedBox(height: 16.sp),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            _selectedType == 'Percentage' ? 'Percentage' : 'Amount',
                                            style: GoogleFonts.poppins(
                                              textStyle: Theme.of(context).textTheme.displayLarge,
                                              fontSize: TextSizes.text14,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.subTitleBlack,
                                            ),
                                          ),
                                          Text(''),
                                        ],
                                      ),
                                      SizedBox(height: 10.sp),
                                      // Amount or Percentage Field
                                      if (_selectedType == 'Amount')
                                        TextFormField(
                                          controller: _amountController,
                                          decoration: InputDecoration(
                                            hintText: 'Enter Amount',
                                            labelStyle: GoogleFonts.poppins(
                                              textStyle: Theme.of(context).textTheme.displayLarge,
                                              fontSize: TextSizes.text15,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.subTitleBlack,
                                            ),
                                            hintStyle: GoogleFonts.poppins(
                                              textStyle: Theme.of(context).textTheme.displayLarge,
                                              fontSize: TextSizes.text15,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.subTitleBlack.withOpacity(0.6),
                                            ),
                                            filled: true,
                                            fillColor: Colors.grey[100],
                                            prefixIcon: Icon(Icons.currency_rupee, size: 20.sp),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(15),
                                              borderSide: BorderSide.none,
                                            ),
                                            contentPadding: EdgeInsets.symmetric(
                                              horizontal: 16.w,
                                              vertical: 12.h,
                                            ),
                                          ),
                                          keyboardType: TextInputType.number,
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Please enter an amount';
                                            }
                                            final double? number = double.tryParse(value);
                                            if (number == null || number <= 0) {
                                              return 'Please enter a valid amount';
                                            }
                                            return null;
                                          },
                                        ),
                                      if (_selectedType == 'Percentage')
                                        TextFormField(
                                          controller: _percentageController,
                                          decoration: InputDecoration(
                                            hintText: 'Enter Percentage',
                                            labelStyle: GoogleFonts.poppins(
                                              textStyle: Theme.of(context).textTheme.displayLarge,
                                              fontSize: TextSizes.text15,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.subTitleBlack,
                                            ),
                                            hintStyle: GoogleFonts.poppins(
                                              textStyle: Theme.of(context).textTheme.displayLarge,
                                              fontSize: TextSizes.text15,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.subTitleBlack.withOpacity(0.6),
                                            ),
                                            filled: true,
                                            fillColor: Colors.grey[100],
                                            prefixIcon: Icon(Icons.percent, size: 20.sp),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(15),
                                              borderSide: BorderSide.none,
                                            ),
                                            contentPadding: EdgeInsets.symmetric(
                                              horizontal: 16.w,
                                              vertical: 12.h,
                                            ),
                                          ),
                                          keyboardType: TextInputType.number,
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Please enter a percentage';
                                            }
                                            final double? number = double.tryParse(value);
                                            if (number == null || number <= 0) {
                                              return 'Please enter a valid percentage';
                                            }
                                            if (number > 100) {
                                              return 'Percentage cannot exceed 100';
                                            }
                                            return null;
                                          },
                                        ),
                                    ],
                                    SizedBox(height: 24.sp),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Submit Button
                          GestureDetector(
                            onTap: () async {
                              if (_formKey.currentState!.validate()) {
                                // Show progress bar
                                showDialog(
                                  context: context,
                                  barrierDismissible: false, // Prevent dismissing dialog by tapping outside
                                  builder: (context) => Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.bgYellow),
                                    ),
                                  ),
                                );

                                try {
                                  // Call the API
                                  bool success = await createAllowance();

                                  // Close progress bar
                                  Navigator.pop(context); // Close the dialog
                                  // Show success or failure message
                                  if (success) {
                                    Navigator.pop(context, true); // Return true on success
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Failed to add allowance'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  // Close progress bar on error
                                  Navigator.pop(context); // Close the dialog

                                  // Show error message
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
                                  'Add Allowance',
                                  style: GoogleFonts.poppins(
                                    textStyle: Theme.of(context).textTheme.displayLarge,
                                    fontSize: TextSizes.text15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textWhite,
                                  ),
                                ),
                              ),
                            ),
                          ),
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
    ) ?? false; // Return false if dialog is dismissed without a result
  }

  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _percentageController.dispose();
    _dateController.dispose();
    _remarkController.dispose();
  }

  Future<bool> createAllowance() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    var url = Uri.parse(ApiRoutes.createAllowance);

    // Parameters
    Map<String, String> params = {
      'title': _titleController.text.trim(),
      'type': _selectedType.toString(),
      'amount': _selectedType == 'Amount' ? _amountController.text.trim() : '',
      'percentage': _selectedType == 'Percentage' ? _percentageController.text.trim() : '',
    };

    try {
      var response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: params,
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        _titleController.clear();
        _amountController.clear();
        _percentageController.clear();
        _selectedType = null;
        print('Response Data: $data');
        return true; // Indicate success
      } else {
        print('Failed: ${response.statusCode}');
        print('Body: ${response.body}');
        return false; // Indicate failure
      }
    } catch (e) {
      print('Error: $e');
      return false; // Indicate failure
    }
  }
}