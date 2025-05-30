import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../Auth/login_screen.dart';
import '../../bottomScreen/Attendance/mark_attendance.dart';
import '../../bottomScreen/Home/AllList/employee_list.dart';
import '../../bottomScreen/Home/AllList/expenses_list.dart';
import '../../bottomScreen/Home/AllList/fund_list.dart';
import '../../bottomScreen/Home/AllList/sallery_list.dart';
import '../../constants.dart';
import '../../demo.dart';
import '../../textSize.dart';

class CustomScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final FloatingActionButton? floatingActionButton;

  const CustomScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(title,  style: GoogleFonts.poppins(
      //     fontSize: 14.sp,
      //     fontWeight: FontWeight.w600,
      //     color: AppColors.textWhite,
      //   ),),
      //   actions: actions,
      //   backgroundColor: Colors.transparent,
      //   elevation: 0,
      //   flexibleSpace: ClipRRect(
      //     borderRadius: BorderRadius.vertical(
      //       bottom: Radius.circular(20.sp),
      //     ),
      //     child: Container(
      //       color: AppColors.bgYellow,
      //     ),
      //   ),
      //   leading: Padding(
      //     padding: EdgeInsets.all(8.sp),
      //     child: Container(
      //       decoration: BoxDecoration(
      //         color: Colors.white, // background color of the circle
      //         shape: BoxShape.circle,
      //       ),
      //       child: IconButton(
      //         icon: Icon(Icons.menu, color: Colors.deepPurple),
      //         onPressed: () {
      //           Scaffold.of(context).openDrawer();
      //         },
      //       ),
      //     ),
      //   ),
      // ),


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
      body: body,
      floatingActionButton: floatingActionButton,
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
  Widget _buildAppBar(BuildContext context) {
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
                   '', // Ensure username is defined
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


}
