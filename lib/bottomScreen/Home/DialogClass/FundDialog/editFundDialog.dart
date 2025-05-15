import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../constants.dart';
import '../../../../textSize.dart';

class EditFundDialog {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _percentageController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _remarkController = TextEditingController();
  Map<String, dynamic>? _selectedCategory; // Store the entire category object
  final _formKey = GlobalKey<FormState>();

  // List to hold categories passed as parameter
  List _categoryExpenses = [];
  bool _isLoadingCategories = false;

  Future<bool> show(
      BuildContext context,
      String categoryName,
      String entryDate,
      String amount,
      String remark,
      String allowanceId,
      List categoryExpenses, // Parameter for categoryExpenses
      ) async {
    // Initialize controllers with provided values
    _amountController.text = amount;
    _dateController.text = entryDate;
    _remarkController.text = remark;

    // Set the passed categoryExpenses list
    _categoryExpenses = categoryExpenses;

    // Find the category object that matches the provided categoryName
    _selectedCategory = _categoryExpenses.firstWhere(
          (category) => category['title'] == categoryName,
      orElse: () => null,
    );

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
                  height: MediaQuery.of(context).size.height * 0.7,
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
                                'Edit Expense',
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
                                            'Expense Category',
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
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(left: 8.sp),
                                          child: Text(
                                            'Amount',
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
                                    // Amount Field
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
                                          fontWeight: FontWeight.w600,
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
                                        if (double.tryParse(value) == null ||
                                            double.parse(value) <= 0) {
                                          return 'Please enter a valid amount';
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: 25.sp),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(left: 8.sp),
                                          child: Text(
                                            'Issue Date',
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
                                    // Date Field
                                    TextFormField(
                                      controller: _dateController,
                                      decoration: InputDecoration(
                                        hintText: 'dd-mm-yyyy',
                                        labelStyle: GoogleFonts.poppins(
                                          textStyle: Theme.of(context).textTheme.displayLarge,
                                          fontSize: TextSizes.text15,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textblack,
                                        ),
                                        hintStyle: GoogleFonts.poppins(
                                          textStyle: Theme.of(context).textTheme.displayLarge,
                                          fontSize: TextSizes.text15,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.subTitleBlack.withOpacity(0.6),
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey[100],
                                        suffixIcon: Icon(Icons.calendar_today, size: 18.sp),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(15),
                                          borderSide: BorderSide.none,
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16.w,
                                          vertical: 12.h,
                                        ),
                                      ),
                                      readOnly: true,
                                      onTap: () async {
                                        DateTime? pickedDate = await showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime(2000),
                                          lastDate: DateTime(2100),
                                          builder: (context, child) {
                                            return Theme(
                                              data: Theme.of(context).copyWith(
                                                colorScheme: ColorScheme.light(
                                                  primary: AppColors.bgYellow,
                                                  onPrimary: Colors.white,
                                                  surface: Colors.white,
                                                  onSurface: AppColors.textblack,
                                                ),
                                                dialogBackgroundColor: Colors.white,
                                              ),
                                              child: child!,
                                            );
                                          },
                                        );
                                        if (pickedDate != null) {
                                          _dateController.text =
                                              DateFormat('dd-MM-yyyy').format(pickedDate);
                                        }
                                      },
                                      validator: (value) =>
                                      value!.isEmpty ? 'Please select a date' : null,
                                    ),
                                    SizedBox(height: 25.sp),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(left: 8.sp),
                                          child: Text(
                                            'Remark',
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
                                    // Remark Field
                                    TextFormField(
                                      controller: _remarkController,
                                      decoration: InputDecoration(
                                        hintText: 'Enter Remarks',
                                        labelStyle: GoogleFonts.poppins(
                                          textStyle: Theme.of(context).textTheme.displayLarge,
                                          fontSize: TextSizes.text15,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.subTitleBlack,
                                        ),
                                        hintStyle: GoogleFonts.poppins(
                                          textStyle: Theme.of(context).textTheme.displayLarge,
                                          fontSize: TextSizes.text15,
                                          fontWeight: FontWeight.w600,
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
                                      maxLines: 3,
                                    ),
                                    SizedBox(height: 25.sp),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Submit Button
                          _buildUpdateButton(context, allowanceId),
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
        'Select Category',
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
        String title = category['title'].toString();
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

  Widget _buildUpdateButton(BuildContext context, String allowanceId) {
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
            bool success = await updateAllowance(allowanceId);
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
            'Update Expenses',
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

  Future<bool> updateAllowance(String allowance) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    var url = Uri.parse('${ApiRoutes.updateExpenses}/$allowance'); // Adjust endpoint

    Map<String, String> body = {
      'category_id': _selectedCategory!['id'].toString(), // Use the ID from the selected category
      'amount': _amountController.text,
      'description': _remarkController.text,
      'issue_date': _dateController.text,
    };
    print('body: $body');

    try {
      var response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(body), // Encode the body as JSON
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