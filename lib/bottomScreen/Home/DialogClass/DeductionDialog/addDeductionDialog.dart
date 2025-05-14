
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../constants.dart';
import '../../../../textSize.dart';

class AddDeductionDialog {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _shortController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<bool> show(
      BuildContext context,
      ) async {

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
                                'Add Deduction',
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
                                    _buildShorCodeField(context),
                                    SizedBox(height: 24.sp),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          _buildUpdateButton(context),
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
          'name',
          style: GoogleFonts.poppins(
            fontSize: TextSizes.text14,
            fontWeight: FontWeight.w500,
            color: AppColors.subTitleBlack,
          ),
        ),
        SizedBox(height: 10.sp),
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: 'Enter Allowance name',
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
              return 'Please enter a name';
            }
            return null;
          },
        ),
      ],
    );
  }
  Widget _buildShorCodeField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Short Code',
          style: GoogleFonts.poppins(
            fontSize: TextSizes.text14,
            fontWeight: FontWeight.w500,
            color: AppColors.subTitleBlack,
          ),
        ),
        SizedBox(height: 10.sp),
        TextFormField(
          controller: _shortController,
          decoration: InputDecoration(
            hintText: 'Enter Short Code',
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
              return 'Please enter a short code';
            }
            return null;
          },
        ),
      ],
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
            bool success = await updateAllowance();
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
            'Add  Deduction',
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
    _nameController.clear();
    _shortController.clear();

  }

  Future<bool> updateAllowance() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    var url =  Uri.parse(ApiRoutes.createDeduction);
    // Adjust endpoint

    Map<String, String> params = {
      'title': _nameController.text.trim(),
      'short_title': _shortController.text.trim(),
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

      if (response.statusCode == 201) {
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
    _nameController.dispose();
    _shortController.dispose();
  }
}

// Extension to capitalize the first letter of a string
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}