import 'package:flutter/material.dart';

import 'HexColorCode/HexColor.dart';

class AppColors {
  static  Color primary = HexColor('#3a1e0d'); // Example primary color (blue)
  static  Color secondary =HexColor('#3a1e0d'); // Secondary color (gray)
  static const Color bottomBarBG =Colors.orange; // Secondary color (gray)
  static const Color grey = Color(0xFFAAAEB2); // Secondary color (gray)
  static const Color background = Color(0xFFF8F9FA); // Light background color
  static const Color textblack = Color(0xFF212529); // Dark text color
  // static  Color textwhite = Color.fromARGB(45, 55, 72, 1);
  static const Color error = Color(0xFFDC3545); // Error color (red)
  static const Color success = Color(0xFF28A745);



  // Success color (green)
  // static  Color bgYellow = HexColor('#E8A84B'); // Success color (green)
  static  Color bgYellow = HexColor('#1935af'); // Success color (green)
  // static  Color bgBlack = HexColor('#181818'); // Success color (green)
  static  Color bgBlack = HexColor('#3d2314'); // Success color (green)
  static  Color bgLoginCard = HexColor('#fefefe'); // Success color (green)
  static  Color textFieldBg = HexColor('#434a56'); // Success color (green)
  static  Color textWhite  = HexColor('#ffffff'); // Success color (green)
  static  Color subTitlewhite  = HexColor('#cbd5e0'); // Success color (green)
  static  Color subTitleBlack  = HexColor('#666666'); // Success color (green)
  static  Color textBlack  = HexColor('#000000'); // Success color (green)
  static  Color textHint  = HexColor('#a1aab5'); // Success color (green)
  static  Color topBg  = HexColor('#c2e6ff'); // Success color (green)
  static  Color bottomBg  = HexColor('#eef1f6'); // Success color (green)
}

class AppAssets {
  static const String logo = 'assets/images/logo.png'; 
  static const String cjm = 'assets/cjm.png';
  static const String cjmlogo = 'assets/playstore.png';
  // static const String cjmlogo2 = 'assets/playstore2.png';
}

class ApiRoutes {


  // Main App Url
  static const String baseUrl = "https://aone.akdesire.com/api";


// Local  App Url


  // static const String baseUrl = "http://192.168.1.4/CJM/api";



  static const String login = "$baseUrl/login";
  static const String logout = "$baseUrl/logout";
  static const String clear = "$baseUrl/clear";
  static const String getProfile = "$baseUrl/get-profile";
  static const String employeeCreate = "$baseUrl/admin/employee-create";
  static const String dashboard = "$baseUrl/admin/dashboard";


  static const String getEmployeeList = "$baseUrl/admin/employee-list";
  static const String getExpensesList = "$baseUrl/admin/expance-list";

  static const String getAllowanceList = "$baseUrl/admin/allowance-list";
  static const String updateAllowanceList = "$baseUrl/admin/allowance-update";
  static const String createAllowance = "$baseUrl/admin/allowance-create";
  static const String detailAllowance = "$baseUrl/admin/allowance";
  static const String deleteAllowanceList = "$baseUrl/admin/allowance-delete";


  static const String getDeductionList = "$baseUrl/admin/deduction-list";
  static const String deleteDeductionList  = "$baseUrl/admin/deduction-delete";
  static const String updateDeductionList= "$baseUrl/admin/deduction-update";
  static const String createDeduction = "$baseUrl/admin/deduction-create";




  static const String employeeDeductionList = "$baseUrl/admin/employee-deduction";
  static const String employeeDeductionStore = "$baseUrl/admin/employee-deduction-store";
  static const String employeeDeductionUpdate = "$baseUrl/admin/employee-deduction-update";
  static const String employeeAllowanceList = "$baseUrl/admin/employee-allowance";




  static const String getSalaryList = "$baseUrl/admin/salary-list";
  static const String genrateSalary = "$baseUrl/admin/salary-genrate";
  static const String genrateSlip = "$baseUrl/admin/salary-slip/";



  static const String getCategoryListExpanse = "$baseUrl/admin/category-list";
  static const String createExpenses = "$baseUrl/admin/expance-create";
  static const String createCategoryExpenses = "$baseUrl/admin/category-create";
  static const String deleteExpenses = "$baseUrl/admin/expance-delete";
  static const String deleteCategory = "$baseUrl/admin/category-delete";
  static const String updateExpenses = "$baseUrl/admin/expance-update";
  static const String updateCategory = "$baseUrl/admin/category-update";


  static const String getFundList = "$baseUrl/admin/fund-list";
  static const String deleteFund = "$baseUrl/admin/fund-delete";
  static const String createFund = "$baseUrl/admin/fund-create";
  static const String updateFund = "$baseUrl/admin/fund-update";



  static const String getAllotmentList = "$baseUrl/admin/recovery-list";
  static const String assignAllot = "$baseUrl/admin/recovery-allotment";




  static const String attendanceCreate = "$baseUrl/admin/attandance-create";


  static const String notifications = "$baseUrl/notifications";
}
