import 'dart:convert';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../Auth/login_screen.dart';
import '../../../constants.dart'; // Adjust path as needed
import '../../../demo.dart';
import '../../../textSize.dart'; // Adjust path as needed
import 'package:url_launcher/url_launcher.dart';

import '../../Attendance/mark_attendance.dart';
import 'employee_list.dart';
import 'expenses_list.dart';
import 'fund_list.dart';

class SalaryScreen extends StatefulWidget {
  final String appBar;
  const SalaryScreen({super.key, required this.appBar});

  @override
  State<SalaryScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<SalaryScreen>
    with SingleTickerProviderStateMixin {
  bool isLoading = false;
  List Salary = [];
  List filteredExpenses = [];
  TextEditingController searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    fetchExpenseData();
    filteredExpenses = Salary;
    searchController.addListener(_filterExpenses);
    _animationController.forward();
  }

  Future<void> fetchExpenseData() async {
    setState(() {
      isLoading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse(ApiRoutes.getSalaryList),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        Salary = data['payrolls'];
        filteredExpenses = Salary;
        isLoading = false;
      });
      _animationController.forward(from: 0);
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load Salary')),
      );
    }
  }

  void _filterExpenses() {
    String query = searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredExpenses = Salary;
      } else {
        filteredExpenses = Salary.where((Salary) {
          return Salary['month'].toString().toLowerCase().contains(query) ||
              Salary['month'].toLowerCase().contains(query) ||
              Salary['net_salary'].toString().toLowerCase().contains(query) ||
              Salary['entry_date'].toString().toLowerCase().contains(query);
        }).toList();
      }
      _animationController.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    searchController.dispose();
    super.dispose();
  }

  void _refresh() {
    setState(() {
      fetchExpenseData();
    });
  }
  // Widget _buildAppBar() {
  //   return Padding(
  //     padding: EdgeInsets.only(top: 30.sp),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       crossAxisAlignment: CrossAxisAlignment.center,
  //       children: [
  //         // Left side with menu and user info
  //         Row(
  //           children: [
  //             // Menu Button
  //             Builder(
  //               builder: (context) => GestureDetector(
  //                 onTap: (){
  //                   Navigator.of(context).pop();
  //
  //   },
  //                 child: Container(
  //                   width: 40.sp,
  //                   // Equal width and height for perfect circle
  //                   height: 40.sp,
  //                   decoration: BoxDecoration(
  //                     shape: BoxShape.circle,
  //                     color: Colors.white.withOpacity(0.2),
  //                     boxShadow: [
  //                       BoxShadow(
  //                         color: Colors.black12,
  //                         blurRadius: 6.sp,
  //                         offset: Offset(0, 3.sp),
  //                       ),
  //                     ],
  //                   ),
  //                   child: Center(
  //                     // Center the icon for better alignment
  //                     child: Icon(
  //                       Icons.arrow_back,
  //                       size: 20.sp,
  //                       color: AppColors.textWhite,
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             ),
  //             SizedBox(width: 12.sp),
  //             // User Info
  //             Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: [
  //                 Text(
  //                   'Salary', // Ensure username is defined
  //                   style: GoogleFonts.poppins(
  //                     fontSize: 14.sp,
  //                     fontWeight: FontWeight.w600,
  //                     color: AppColors.textWhite,
  //                   ),
  //                 ),
  //                 SizedBox(height: 2.sp),
  //                 // Text(
  //                 //   'Admin ID: 2100101',
  //                 //   style: GoogleFonts.poppins(
  //                 //     fontSize: 10.sp,
  //                 //     fontWeight: FontWeight.w400,
  //                 //     color: AppColors.subTitlewhite.withOpacity(0.8),
  //                 //   ),
  //                 // ),
  //               ],
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Future<void> logoutApi(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent user from dismissing dialog
      builder: (BuildContext context) {
        return Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: Colors.orangeAccent,
              ),
              // SizedBox(width: 16.0),
              // Text("Logging in..."),
            ],
          ),
        );
      },
    );

    try {
      // Replace 'your_token_here' with your actual token
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');
      final Uri uri = Uri.parse(ApiRoutes.logout);
      final Map<String, String> headers = {'Authorization': 'Bearer $token'};
      print('Token: $token');

      final response = await http.post(uri, headers: headers);

      if (response.statusCode == 200) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.remove(
          'isLoggedIn',
        );

        // If the server returns a 200 OK response, parse the data
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              return LoginPage();
            },
          ),
        );
      } else {
        // If the server did not return a 200 OK response,
        // throw an exception.
        throw Exception('Failed to load data');
      }
    } catch (e) {
      Navigator.pop(context); // Close the progress dialog
      // Handle errors appropriately
      print('Error during logout: $e');
      // Show a snackbar or display an error message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to log out. Please try again.'),
      ));
    }
  }
  Widget _buildAppBar() {
    return Padding(
      padding: EdgeInsets.only(top: 30.sp),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left side with menu and user info
          Row(
            children: [
              // Menu Button
              Builder(
                builder: (context) => GestureDetector(
                  onTap: () => Scaffold.of(context).openDrawer(),
                  child: Container(
                    width: 40.sp,
                    // Equal width and height for perfect circle
                    height: 40.sp,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6.sp,
                          offset: Offset(0, 3.sp),
                        ),
                      ],
                    ),
                    child: Center(
                      // Center the icon for better alignment
                      child: Icon(
                        Icons.menu_rounded,
                        size: 20.sp,
                        color: AppColors.textWhite,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.sp),
              // User Info
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.appBar, // Ensure username is defined
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textWhite,
                    ),
                  ),
                  SizedBox(height: 2.sp),
                  // Text(
                  //   'Admin ID: 2100101',
                  //   style: GoogleFonts.poppins(
                  //     fontSize: 10.sp,
                  //     fontWeight: FontWeight.w400,
                  //     color: AppColors.subTitlewhite.withOpacity(0.8),
                  //   ),
                  // ),
                ],
              ),
            ],
          ),
          // Notification Button
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return LoanPage();
                  },
                ),
              );
            },
            child: Container(
              width: 40.sp, // Equal width and height for perfect circle
              height: 40.sp,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.2),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.notifications_none_rounded,
                    size: 22.sp,
                    color: AppColors.textWhite,
                  ),
                  Positioned(
                    right: 8.sp,
                    top: 8.sp,
                    child: Container(
                      width: 16.sp,
                      height: 16.sp,
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1.5.sp,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '3',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildDrawerHeader() {
    return SizedBox(
      height: 50.sp,
      child: Card(
        elevation: 5,
        color: AppColors.bottomBg,
        margin: EdgeInsets.all(0.sp),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        // height: 80.sp,
        // decoration:  BoxDecoration(
        //   color: AppColors.bottomBg,
        // ),
        child: Padding(
          padding: EdgeInsets.all(5.sp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: AssetImage('assets/aonelogo.png'),
                    // your logo here
                    radius: 20.sp,
                  ),
                  SizedBox(
                    width: 5.sp,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'A ONE RECOVERY',
                        style: GoogleFonts.poppins(
                          fontSize: TextSizes.text14,
                          fontWeight: FontWeight.w800,
                          fontStyle: FontStyle.normal,
                          color: AppColors.textblack,
                        ),
                      ),
                      Text(
                        'DASHBOARD',
                        style: GoogleFonts.poppins(
                          fontSize: TextSizes.text12,
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.normal,
                          color: AppColors.subTitleBlack,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bottomBg,
      drawer: Drawer(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        width: MediaQuery.sizeOf(context).width * .65,
        backgroundColor: AppColors.bottomBg,
        child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        _buildDrawerHeader(),
                        Padding(
                          padding: EdgeInsets.only(
                            left: TextSizes.padding11,
                            right: TextSizes.padding15,
                            top: 25.sp,
                          ),
                          child: GestureDetector(
                            onTap: (){

                              Navigator.pop(context); // Close the progress dialog


                            },
                            child: Row(
                              children: [
                                FaIcon(FontAwesomeIcons.home, size: 16.sp),
                                SizedBox(
                                  width: 10.sp,
                                ),
                                Text(
                                  'Dashboard',
                                  style: GoogleFonts.poppins(
                                    fontSize: TextSizes.text16,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FontStyle.normal,
                                    color: AppColors.textblack,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              left: TextSizes.padding11,
                              right: TextSizes.padding15,
                              top: TextSizes.padding15),
                          child: GestureDetector(
                            onTap: (){
                              PersistentNavBarNavigator.pushNewScreen(
                                context,
                                screen: EmployeeScreen(
                                  menuScreenContext: context, appBar: 'app',
                                ),
                              );
                            },
                            child: Row(
                              children: [
                                FaIcon(FontAwesomeIcons.users, size: 16.sp),
                                SizedBox(
                                  width: 10.sp,
                                ),
                                Text(
                                  'Employee',
                                  style: GoogleFonts.poppins(
                                    fontSize: TextSizes.text15,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FontStyle.normal,
                                    color: AppColors.textblack,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 8.sp,
                        ),

                        Padding(
                          padding: EdgeInsets.only(
                              left: TextSizes.padding11,
                              right: TextSizes.padding15,
                              top: TextSizes.padding15),
                          child: GestureDetector(
                            onTap: (){
                              PersistentNavBarNavigator.pushNewScreen(
                                context,
                                screen: AttendanceScreen(
                                  appBar: 'app',
                                ),
                              );
                            },
                            child: Row(
                              children: [
                                FaIcon(FontAwesomeIcons.calendar, size: 16.sp),
                                SizedBox(
                                  width: 10.sp,
                                ),
                                Text(
                                  'Attendance',
                                  style: GoogleFonts.poppins(
                                    fontSize: TextSizes.text15,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FontStyle.normal,
                                    color: AppColors.textblack,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 8.sp,
                        ),

                        Padding(
                          padding: EdgeInsets.only(
                              left: TextSizes.padding11,
                              right: TextSizes.padding15,
                              top: TextSizes.padding15),
                          child: GestureDetector(
                            onTap: (){
                              PersistentNavBarNavigator.pushNewScreen(
                                context,
                                screen: EmployeeFundScreen(appBar: 'appbar',),
                              );
                            },
                            child: Row(
                              children: [
                                FaIcon(FontAwesomeIcons.wallet, size: 16.sp),
                                SizedBox(
                                  width: 10.sp,
                                ),
                                Text(
                                  'Fund Manager',
                                  style: GoogleFonts.poppins(
                                    fontSize: TextSizes.text15,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FontStyle.normal,
                                    color: AppColors.textblack,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 8.sp,
                        ),


                        Padding(
                          padding: EdgeInsets.only(
                              left: TextSizes.padding11,
                              right: TextSizes.padding15,
                              top: TextSizes.padding15),
                          child: GestureDetector(
                            onTap: (){
                              PersistentNavBarNavigator.pushNewScreen(
                                context,
                                screen: ExpensesScreen(appBar: 'appBar',),
                              );
                            },
                            child: Row(
                              children: [
                                FaIcon(FontAwesomeIcons.fileInvoiceDollar, size: 16.sp),
                                SizedBox(
                                  width: 10.sp,
                                ),
                                Text(
                                  'Expense Manager',
                                  style: GoogleFonts.poppins(
                                    fontSize: TextSizes.text15,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FontStyle.normal,
                                    color: AppColors.textblack,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 8.sp,
                        ),

                        Padding(
                          padding: EdgeInsets.only(
                              left: TextSizes.padding11,
                              right: TextSizes.padding15,
                              top: TextSizes.padding15),
                          child: GestureDetector(
                            onTap: (){

                              PersistentNavBarNavigator.pushNewScreen(
                                context,
                                screen: SalaryScreen(appBar: 'appBar',),
                              );
                            },
                            child: Row(
                              children: [
                                FaIcon(FontAwesomeIcons.moneyBill1Wave, size: 16.sp),
                                SizedBox(
                                  width: 10.sp,
                                ),
                                Text(
                                  'Salary',
                                  style: GoogleFonts.poppins(
                                    fontSize: TextSizes.text15,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FontStyle.normal,
                                    color: AppColors.textblack,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(
                          height: 8.sp,
                        ),

                        Padding(
                          padding: EdgeInsets.only(
                              left: TextSizes.padding11,
                              right: TextSizes.padding15,
                              top: TextSizes.padding15),
                          child: GestureDetector(
                            onTap: (){
                              Navigator.pop(context); // Close the progress dialog

                              logoutApi(context);
                            },
                            child: Row(
                              children: [
                                Icon(Icons.logout, color: Colors.black, size: 16.sp),
                                SizedBox(
                                  width: 10.sp,
                                ),
                                Text(
                                  'Logout',
                                  style: GoogleFonts.poppins(
                                    fontSize: TextSizes.text15,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FontStyle.normal,
                                    color: AppColors.textblack,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(12.sp),
                  child: Text(
                    'App Version 1.0.0',
                    style: GoogleFonts.poppins(
                      fontSize: TextSizes.text14,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.normal,
                      color: AppColors.textblack,
                    ),
                  ),
                ),
              ],
            )),
      ),


      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 50.sp),
        child: ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => SalaryDialog(
                onReturn: _refresh,
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0066CC),
            padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 8.sp),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 6,
            shadowColor: Colors.black26,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(
                FontAwesomeIcons.plus,
                size: 18.sp,
                color: Colors.white,
              ),
              SizedBox(width: 5.sp),
              Text(
                'Add Salary',
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 0.sp, vertical: 0.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.appBar != ''
                ? Container(
              height: 80.sp,
              decoration: BoxDecoration(
                color: AppColors.bgYellow,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20.sp),
                ),
                // border: Border.all(
                //   color: Colors.purple.shade100, // Or any color you want
                //   width: 1.sp,
                // ),
              ),
              padding: EdgeInsets.all(8.sp),
              alignment: Alignment.center,
              child: _buildAppBar(),
            ):SizedBox(),
            // Search Bar
            Padding(
              padding: EdgeInsets.all(5.sp),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search by amount, category, remark, or date...',
                  hintStyle: GoogleFonts.poppins(
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w400,
                    fontSize: 14.sp,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey[600],
                    size: 24.sp,
                  ),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear,
                              color: Colors.grey[600], size: 22.sp),
                          onPressed: () {
                            searchController.clear();
                            _filterExpenses();
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide:
                        BorderSide(color: Colors.grey[300]!, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: AppColors.bgYellow,
                      // Replace with AppColors.bgYellow
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 14.sp, horizontal: 16.sp),
                ),
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: Colors.black87,
                ),
              ),
            ),
            // SizedBox(height: 24.sp),
            // Table Title
            FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: EdgeInsets.all(8.sp),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Salary List (${filteredExpenses.length})',
                      style: GoogleFonts.poppins(
                        fontSize: TextSizes.text14,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.refresh,
                          size: 24.sp, color: Colors.grey[700]),
                      onPressed: fetchExpenseData,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 0.sp),
            // Data Table
            Expanded(
              child: isLoading
                  ? const Center(child: AnimatedLoader())
                  : ListView.builder(
                      padding: const EdgeInsets.all(12.0),
                      itemCount: filteredExpenses.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        final salary = filteredExpenses[index];
                        return FadeInUp(
                          duration: Duration(milliseconds: 300 + (index * 100)),
                          child: _buildSalaryCard(
                            context,
                            salary['unique_id'].toString(),
                            salary['month'].toString(),
                            salary['basic_salary'].toString(),
                            salary['total_allowance'].toString(),
                            salary['total_deduction'].toString(),
                            salary['net_salary'].toString(),
                          ),
                        );
                      },
                    ),
            ),
            // SizedBox(height: 50.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildSalaryCard(
    BuildContext context,
    String name,
    String month,
    String basic,
    String allowance,
    String deduction,
    String netSalary,
  ) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Selected ${name}',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.teal[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Card(
        elevation: 6.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            gradient: LinearGradient(
              colors: [Colors.white, Colors.teal[50]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.teal.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                ZoomIn(
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.teal[600],
                    child: Text(
                      name[0].toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10.0),
                // Salary Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MediaQuery(
                        data: MediaQuery.of(context).copyWith(
                          textScaler: TextScaler.noScaling,
                        ),
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      MediaQuery(
                        data: MediaQuery.of(context).copyWith(
                          textScaler: TextScaler.noScaling,
                        ),
                        child: Text(
                          'Month: ${month}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildDetailColumn(
                            'Basic',
                            '₹${basic}',
                            Colors.green[400]!,
                          ),
                          _buildDetailColumn(
                            'Allow.',
                            '₹${allowance}',
                            Colors.blue[400]!,
                          ),
                          _buildDetailColumn(
                            'Deduct.',
                            '₹${deduction}',
                            Colors.red[400]!,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4.0),
                      MediaQuery(
                        data: MediaQuery.of(context).copyWith(
                          textScaler: TextScaler.noScaling,
                        ),
                        child: Text(
                          'Net: ₹${netSalary}',
                          style: GoogleFonts.poppins(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                            color: Colors.teal[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Print Button
                ZoomIn(
                  child: IconButton(
                    icon: Icon(
                      Icons.print_rounded,
                      color: Colors.teal[600],
                      size: 22,
                    ),

                    onPressed: () async {
                      final Uri uri = Uri.parse(ApiRoutes.genrateSlip);
                      try {
                        if (!await launchUrl(uri,
                            mode: LaunchMode.externalApplication)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Could not open URL')),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    },
                    // onPressed: () {
                    //   print('Printing salary details for ${name}');
                    //   ScaffoldMessenger.of(context).showSnackBar(
                    //     SnackBar(
                    //       content: Text(
                    //         'Printing salary for ${name}',
                    //         style: GoogleFonts.poppins(
                    //           fontSize: 14,
                    //           color: Colors.white,
                    //         ),
                    //       ),
                    //       backgroundColor: Colors.teal[600],
                    //       behavior: SnackBarBehavior.floating,
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(10.0),
                    //       ),
                    //       duration: const Duration(seconds: 2),
                    //     ),
                    //   );
                    // },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailColumn(String label, String value, Color valueColor) {
    return MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.noScaling,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: valueColor,
              ),
            ),
          ],
        ));
  }
}

// Animated Loader
class AnimatedLoader extends StatefulWidget {
  const AnimatedLoader({super.key});

  @override
  _AnimatedLoaderState createState() => _AnimatedLoaderState();
}

class _AnimatedLoaderState extends State<AnimatedLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: Icon(
        Icons.refresh,
        size: 40.sp,
        color: AppColors.bgYellow, // Replace with AppColors.bgYellow
      ),
    );
  }
}

class SalaryDialog extends StatefulWidget {
  final VoidCallback onReturn;

  const SalaryDialog({super.key, required this.onReturn});

  @override
  State<SalaryDialog> createState() => _SalaryDialogState();
}

class _SalaryDialogState extends State<SalaryDialog> {
  String? selectedYear;
  String? selectedMonth;
  String generatedSalary = '';
  bool _isLoading = false; // State to track loading

  final List<String> years =
      List.generate(10, (index) => (DateTime.now().year - index).toString());
  final List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedYear = now.year.toString();
    selectedMonth = months[now.month - 1];
  }

  void generateSalary() async {
    setState(() {
      _isLoading = true; // Show progress bar
    });

    if (selectedYear != null && selectedMonth != null) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');

        final response = await http.post(
          Uri.parse(ApiRoutes.genrateSalary),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'year': selectedYear,
            'month': selectedMonth,
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final salary = data['salary']; // Adjust based on your API response
          setState(() {
            widget.onReturn();
            Navigator.of(context).pop();
            generatedSalary =
                'Salary for $selectedMonth $selectedYear: ₹$salary';
            _isLoading = false; // Hide progress bar
          });
        } else {
          setState(() {
            generatedSalary = 'Error fetching salary: ${response.statusCode}';
            _isLoading = false; // Hide progress bar
          });
        }
      } catch (e) {
        setState(() {
          generatedSalary = 'Error: $e';
          _isLoading = false; // Hide progress bar
        });
      }
    } else {
      setState(() {
        generatedSalary = 'Please select both year and month';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      elevation: 10,
      contentPadding: const EdgeInsets.all(20),
      title: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.blueAccent, Colors.indigo],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'Generate Salary',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: DropdownButton<String>(
                hint: const Text('Select Year'),
                value: selectedYear,
                isExpanded: true,
                underline: const SizedBox(),
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                ),
                icon:
                    const Icon(Icons.arrow_drop_down, color: Colors.blueAccent),
                items: years.map((String year) {
                  return DropdownMenuItem<String>(
                    value: year,
                    child: Text(year),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedYear = newValue;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: DropdownButton<String>(
                hint: const Text('Select Month'),
                value: selectedMonth,
                isExpanded: true,
                underline: const SizedBox(),
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                ),
                icon:
                    const Icon(Icons.arrow_drop_down, color: Colors.blueAccent),
                items: months.map((String month) {
                  return DropdownMenuItem<String>(
                    value: month,
                    child: Text(month),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedMonth = newValue;
                  });
                },
              ),
            ),
            const SizedBox(height: 20),
            Text(
              generatedSalary,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: generatedSalary.startsWith('Please')
                    ? Colors.red
                    : Colors.green,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey[600],
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          child: const Text(
            'Close',
            style: TextStyle(fontSize: 16),
          ),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : generateSalary,
          // Disable button while loading
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 5,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'Generate',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
        )
      ],
    );
  }
}
