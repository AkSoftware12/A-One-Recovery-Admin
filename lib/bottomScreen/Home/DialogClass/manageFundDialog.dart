import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // For date formatting

import '../../../constants.dart';
import '../../../textSize.dart';

class ManageFundDialog {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _remarkController = TextEditingController();
  String? _selectedCategory;
  final _formKey = GlobalKey<FormState>();


  void show(BuildContext context) {
    showGeneralDialog(
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
            insetPadding: EdgeInsets.zero, // <- yeh important line
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.99, // 90% of screen width
              height: MediaQuery.of(context).size.height * 0.8, // 60% of screen height
              padding: EdgeInsets.all(16.sp),
              child: Column(
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Manage Fund',
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
                            SizedBox(
                              height: 20.sp,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding:  EdgeInsets.only(left: 8.sp),
                                  child: Text(
                                    'Employee Name',
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
                            SizedBox(
                              height: 5.sp,
                            ),
                            // Category Dropdown
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
                              items: <String>['Food', 'Travel', 'Office', 'Other']
                                  .map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: SizedBox(
                                    height: 30.sp, // 👈 this makes each item box 30.sp high
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        value,
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
                              onChanged: (String? newValue) {
                                _selectedCategory = newValue;

                              },
                              validator: (value) =>
                              value == null ? 'Please select a category' : null,
                            ),
                            SizedBox(height: 25.sp),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding:  EdgeInsets.only(left: 8.sp),
                                  child: Text(
                                    'Type',
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
                            SizedBox(
                              height: 5.sp,
                            ),
                            // Category Dropdown
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
                              value: _selectedCategory,
                              dropdownColor: Colors.white,
                              items: <String>['Food', 'Travel', 'Office', 'Other']
                                  .map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: SizedBox(
                                    height: 30.sp, // 👈 this makes each item box 30.sp high
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        value,
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
                              onChanged: (String? newValue) {
                                _selectedCategory = newValue;

                              },
                              validator: (value) =>
                              value == null ? 'Please select a category' : null,
                            ),
                            SizedBox(height: 25.sp),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding:  EdgeInsets.only(left: 8.sp),
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
                            SizedBox(
                              height: 5.sp,
                            ),
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
                                  padding:  EdgeInsets.only(left: 8.sp),
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
                            SizedBox(
                              height: 5.sp,
                            ),
                            // Date Field
                            TextFormField(
                              controller: _dateController,
                              decoration: InputDecoration(
                                // labelText: 'Issue Date',
                                hintText: 'dd-mm-yyyy',
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
                                suffixIcon: Icon(Icons.calendar_today, size: 18.sp), // <- moved here

                                // prefixIcon: Icon(Icons.calendar_today, size: 20.sp),
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
                                  padding:  EdgeInsets.only(left: 8.sp),
                                  child: Text(
                                    'Description',
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
                            SizedBox(
                              height: 5.sp,
                            ),
                            // Remark Field
                            TextFormField(
                              controller: _remarkController,
                              decoration: InputDecoration(
                                hintText: 'Enter Description',
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
                  GestureDetector(
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Expense Added Successfully!'),
                            backgroundColor: AppColors.bgYellow,
                          ),
                        );
                        print({
                          'category': _selectedCategory,
                          'amount': _amountController.text,
                          'date': _dateController.text,
                          'remark': _remarkController.text,
                        });
                        Navigator.pop(context);
                      }
                    },
                    child: Container(
                      width: 150.sp,
                      // width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.bgYellow,
                            AppColors.bgYellow.withOpacity(0.8)
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
                          'Save Fund',
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
              ),
            ),
          ),
        );
      },
    );
  }

  void dispose() {
    _amountController.dispose();
    _dateController.dispose();
    _remarkController.dispose();
  }
}


