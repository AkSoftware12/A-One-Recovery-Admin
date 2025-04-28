import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../constants.dart';
import '../../../textSize.dart';

class CreateSalleryDialog {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _remarkController = TextEditingController();
  String? _selectedYear;
  String? _selectedMonth;
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
              height: MediaQuery.of(context).size.height * 0.40, // 60% of screen height
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Create Salary',
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
                          _selectedYear=null;
                          _selectedMonth=null;
                          Navigator.pop(context);
                        }
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
                                Text(
                                  'Year',
                                  style: GoogleFonts.poppins(
                                    textStyle: Theme.of(context).textTheme.displayLarge,
                                    fontSize: TextSizes.text14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.subTitleBlack,
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
                              height: 10.sp,
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
                                'Select year',
                                style: GoogleFonts.poppins(
                                  textStyle: Theme.of(context).textTheme.displayLarge,
                                  fontSize: TextSizes.text15,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.subTitleBlack.withOpacity(0.6),
                                ),
                              ),
                              value: _selectedYear,
                              dropdownColor: Colors.white, // <-- this line sets dropdown dialog background to white
                              items: <String>['2020', '2021', '2022', '2024','2025']
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
                                _selectedYear = newValue;
                              },
                              validator: (value) =>
                              value == null ? 'Please select a category' : null,
                            ),
                            SizedBox(height: 16),



                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Month',
                                  style: GoogleFonts.poppins(
                                    textStyle: Theme.of(context).textTheme.displayLarge,
                                    fontSize: TextSizes.text14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.subTitleBlack,
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
                              height: 10.sp,
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
                                'Select month',
                                style: GoogleFonts.poppins(
                                  textStyle: Theme.of(context).textTheme.displayLarge,
                                  fontSize: TextSizes.text15,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.subTitleBlack.withOpacity(0.6),
                                ),
                              ),
                              value: _selectedMonth,
                              dropdownColor: Colors.white, // <-- this line sets dropdown dialog background to white
                              items: <String>['Jun', 'Feb', 'Mar', 'Apr']
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
                                _selectedMonth = newValue;
                              },
                              validator: (value) =>
                              value == null ? 'Please select a category' : null,
                            ),
                            SizedBox(height: 16),
                            // Date Field

                            SizedBox(height: 24),
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
                          'type': _selectedYear,
                          'type': _selectedMonth,

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
                          ' Generate Salary',
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
    _titleController.dispose();
    _dateController.dispose();
    _remarkController.dispose();
  }
}