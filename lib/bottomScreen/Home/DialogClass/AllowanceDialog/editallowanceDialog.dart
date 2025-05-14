import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../constants.dart';
import '../../../../textSize.dart';

class EditAllowanceDialog {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _percentageController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _remarkController = TextEditingController();
  String? _selectedType;
  final _formKey = GlobalKey<FormState>();

  Future<bool> show(
      BuildContext context,
      String title,
      String type,
      String amount,
      String percentage,
      String allowanceId,
      ) async {
    // Initialize controllers with provided values
    _titleController.text = title;
    _amountController.text = amount;
    _percentageController.text = percentage;
    _selectedType = ['amount', 'percentage'].contains(type.toLowerCase()) ? type.toLowerCase() : null;

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
                    builder: (BuildContext context, StateSetter dialogSetState) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Edit Allowance',
                                style: GoogleFonts.poppins(
                                  fontSize: TextSizes.text17,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textblack,
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.close, color: Colors.grey[600], size: 24.sp),
                                onPressed: () {
                                  _clearControllers();
                                  Navigator.pop(context, false);
                                },
                              ),
                            ],
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    SizedBox(height: 20.sp),
                                    _buildTitleField(context),
                                    SizedBox(height: 16.sp),
                                    _buildTypeField(context, dialogSetState),
                                    if (_selectedType != null) ...[
                                      SizedBox(height: 16.sp),
                                      _buildAmountOrPercentageField(context),
                                    ],
                                    SizedBox(height: 24.sp),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          _buildUpdateButton(context,allowanceId),
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

  Widget _buildTitleField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Title',
          style: GoogleFonts.poppins(
            fontSize: TextSizes.text14,
            fontWeight: FontWeight.w500,
            color: AppColors.subTitleBlack,
          ),
        ),
        SizedBox(height: 10.sp),
        TextFormField(
          controller: _titleController,
          decoration: InputDecoration(
            hintText: 'Enter Allowance Title',
            labelStyle: GoogleFonts.poppins(
              fontSize: TextSizes.text15,
              fontWeight: FontWeight.w500,
              color: AppColors.subTitleBlack,
            ),
            hintStyle: GoogleFonts.poppins(
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
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          ),
          keyboardType: TextInputType.text,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a title';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTypeField(BuildContext context, StateSetter dialogSetState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Type',
          style: GoogleFonts.poppins(
            fontSize: TextSizes.text14,
            fontWeight: FontWeight.w500,
            color: AppColors.subTitleBlack,
          ),
        ),
        SizedBox(height: 10.sp),
        DropdownButtonFormField<String>(
          icon: Icon(
            Icons.keyboard_arrow_down,
            size: 20.sp,
            color: AppColors.subTitleBlack,
          ),
          decoration: InputDecoration(
            labelStyle: GoogleFonts.poppins(
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
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          ),
          hint: Text(
            'Select Type',
            style: GoogleFonts.poppins(
              fontSize: TextSizes.text15,
              fontWeight: FontWeight.w500,
              color: AppColors.subTitleBlack.withOpacity(0.6),
            ),
          ),
          value: _selectedType,
          dropdownColor: Colors.white,
          items: <String>['amount', 'percentage'].map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value.capitalize(),
                style: GoogleFonts.poppins(
                  fontSize: TextSizes.text15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.subTitleBlack,
                ),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            dialogSetState(() {
              _selectedType = newValue;
              // _amountController.clear();
              // _percentageController.clear();
              print('Selected Type: $_selectedType'); // Debug print
            });
          },
          validator: (value) => value == null ? 'Please select a type' : null,
        ),
      ],
    );
  }

  Widget _buildAmountOrPercentageField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _selectedType == 'percentage' ? 'Percentage' : 'Amount',
          style: GoogleFonts.poppins(
            fontSize: TextSizes.text14,
            fontWeight: FontWeight.w500,
            color: AppColors.subTitleBlack,
          ),
        ),
        SizedBox(height: 10.sp),
        TextFormField(
          controller: _selectedType == 'amount' ? _amountController : _percentageController,
          decoration: InputDecoration(
            hintText: _selectedType == 'amount' ? 'Enter Amount' : 'Enter Percentage',
            labelStyle: GoogleFonts.poppins(
              fontSize: TextSizes.text15,
              fontWeight: FontWeight.w500,
              color: AppColors.subTitleBlack,
            ),
            hintStyle: GoogleFonts.poppins(
              fontSize: TextSizes.text15,
              fontWeight: FontWeight.w500,
              color: AppColors.subTitleBlack.withOpacity(0.6),
            ),
            filled: true,
            fillColor: Colors.grey[100],
            prefixIcon: Icon(
              _selectedType == 'amount' ? Icons.currency_rupee : Icons.percent,
              size: 20.sp,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return _selectedType == 'amount' ? 'Please enter an amount' : 'Please enter a percentage';
            }
            final double? number = double.tryParse(value);
            if (number == null || number <= 0) {
              return _selectedType == 'amount' ? 'Please enter a valid amount' : 'Please enter a valid percentage';
            }
            if (_selectedType == 'percentage' && number > 100) {
              return 'Percentage cannot exceed 100';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildUpdateButton(BuildContext context,String allownaceId) {
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
            bool success = await updateAllowance(allownaceId);
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
            'Update Allowance',
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

  void _clearControllers() {
    _titleController.clear();
    _amountController.clear();
    _percentageController.clear();
    _selectedType = null;
  }

  Future<bool> updateAllowance(String allowance) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    var url =  Uri.parse('${ApiRoutes.updateAllowanceList}/$allowance}');
    // Adjust endpoint

    Map<String, String> params = {
      'title': _titleController.text.trim(),
      'type': _selectedType.toString(),
      'amount': _amountController.text.trim(),
      'percentage':_percentageController.text.trim(),
    };
    print('params :$params');

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
    _titleController.dispose();
    _amountController.dispose();
    _percentageController.dispose();
    _dateController.dispose();
    _remarkController.dispose();
  }
}

// Extension to capitalize the first letter of a string
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}