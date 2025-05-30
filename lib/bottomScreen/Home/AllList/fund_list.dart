import 'dart:convert';
import 'package:animate_do/animate_do.dart';
import 'package:aoneadmin/HexColorCode/HexColor.dart';
import 'package:aoneadmin/bottomScreen/Home/AllList/sallery_list.dart';
import 'package:aoneadmin/strings.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../Auth/login_screen.dart';
import '../../../demo.dart';
import '../DialogClass/ExpensesDialog/addExpenseDialog.dart'; // Adjust path as needed
import '../../../constants.dart'; // Adjust path as needed
import '../../../textSize.dart';
import '../DialogClass/ExpensesDialog/editExpensesDialog.dart';
import '../DialogClass/FundDialog/addFundDialog.dart';
import '../DialogClass/FundDialog/editFundDialog.dart'; // Adjust path as needed
import '../../Attendance/mark_attendance.dart';
import 'employee_list.dart';
import 'expenses_list.dart';
import 'fund_list.dart';


class EmployeeFundScreen extends StatefulWidget {
  final String appBar;
  const EmployeeFundScreen({super.key, required this.appBar});

  @override
  State<EmployeeFundScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<EmployeeFundScreen>
    with SingleTickerProviderStateMixin {
  final AddFundDialog _addFundDialog = AddFundDialog();
  bool isLoading = false;
  List expenses = [];
  List categoryExpenses = [];
  List filteredExpenses = [];

  TextEditingController searchController = TextEditingController();
  TextEditingController title = TextEditingController();
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
    filteredExpenses = expenses;
    searchController.addListener(_filterExpenses);
    _animationController.forward();
    fetchExpenseCategoryData();
  }

  Future<void> fetchExpenseData() async {
    setState(() {
      isLoading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print('Token: $token');

    final response = await http.get(
      Uri.parse(ApiRoutes.getFundList),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        expenses = data['data'];
        filteredExpenses = expenses;
        isLoading = false;
      });
      _animationController.forward(from: 0);
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load expenses')),
      );
    }
  }

  Future<void> fetchExpenseCategoryData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print('Token: $token');

    final response = await http.get(
      Uri.parse(ApiRoutes.getEmployeeList),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        categoryExpenses = data['employees'];
        isLoading = false;
        print(categoryExpenses);
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load expenses')),
      );
    }
  }

  void _filterExpenses() {
    String query = searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredExpenses = expenses;
      } else {
        filteredExpenses = expenses.where((expense) {
          return expense['amount'].toString().toLowerCase().contains(query) ||
              expense['user']['name'].toLowerCase().contains(query) ||
              expense['description'].toString().toLowerCase().contains(query) ||
              expense['type'].toString().toLowerCase().contains(query) ||
              expense['issue_date'].toString().toLowerCase().contains(query);
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
                                screen: SalaryScreen(appBar: 'Salary',),
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
        padding: EdgeInsets.only(bottom: 65.sp),
        child: ElevatedButton(
          onPressed: () async {
            final _addFundDialog = AddFundDialog();
            final result = await _addFundDialog.show(context,categoryExpenses);
            // Show dialog and wait for result
            if (result) {
              // Refresh the list if allowance was added successfully
              await fetchExpenseData();
            }
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
                FontAwesomeIcons.plusCircle,
                size: 18.sp,
                color: Colors.white,
              ),
              SizedBox(width: 5.sp),
              Text(
                'Add',
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
      body: SingleChildScrollView(
        child: Padding(
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
                    contentPadding: EdgeInsets.symmetric(
                        vertical: 14.sp, horizontal: 16.sp),
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
                        'FUND LIST (${filteredExpenses.length})',
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
              isLoading
                  ? const Center(child: AnimatedLoader())
                  : Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columnSpacing: 20.sp,
                          headingRowHeight: 56.sp,
                          dataRowHeight: 40.sp,
                          headingRowColor: MaterialStateColor.resolveWith(
                            (states) => Colors.grey[100]!,
                          ),
                          dataRowColor: MaterialStateColor.resolveWith(
                            (states) => states.contains(MaterialState.selected)
                                ? Colors.grey[50]!
                                : Colors.white,
                          ),
                          dividerThickness: 0.5,
                          border: TableBorder(
                            horizontalInside: BorderSide(
                              color: Colors.grey[400]!,
                              width: 0.5,
                            ),
                            verticalInside: BorderSide(
                              color: Colors.grey[200]!,
                              width: 0.5,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          columns: [
                            DataColumn(
                              label: Text(
                                'Sr. No.',
                                style: GoogleFonts.poppins(
                                  textStyle:
                                      Theme.of(context).textTheme.displayLarge,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  fontStyle: FontStyle.normal,
                                  color: HexColor('#4B5563'),
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Employee Name',
                                style: GoogleFonts.poppins(
                                  textStyle:
                                      Theme.of(context).textTheme.displayLarge,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  fontStyle: FontStyle.normal,
                                  color: HexColor('#4B5563'),
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Amount',
                                style: GoogleFonts.poppins(
                                  textStyle:
                                      Theme.of(context).textTheme.displayLarge,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  fontStyle: FontStyle.normal,
                                  color: HexColor('#4B5563'),
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Type',
                                style: GoogleFonts.poppins(
                                  textStyle:
                                      Theme.of(context).textTheme.displayLarge,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  fontStyle: FontStyle.normal,
                                  color: HexColor('#4B5563'),
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Description',
                                style: GoogleFonts.poppins(
                                  textStyle:
                                      Theme.of(context).textTheme.displayLarge,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  fontStyle: FontStyle.normal,
                                  color: HexColor('#4B5563'),
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Date',
                                style: GoogleFonts.poppins(
                                  textStyle:
                                      Theme.of(context).textTheme.displayLarge,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  fontStyle: FontStyle.normal,
                                  color: HexColor('#4B5563'),
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Actions',
                                style: GoogleFonts.poppins(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  color: HexColor('#4B5563'),
                                ),
                              ),
                            ),
                          ],
                          rows: List.generate(filteredExpenses.length, (index) {
                            final expense = filteredExpenses[index];
                            return DataRow(
                              color: MaterialStateColor.resolveWith(
                                (states) => index % 2 == 0
                                    ? Colors.white
                                    : Colors.grey[50]!,
                              ),
                              cells: [
                                DataCell(
                                  Text(
                                    '${(index + 1).toString()}.',
                                    style: GoogleFonts.poppins(
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .displayLarge,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FontStyle.normal,
                                      color: HexColor('#1F2937'),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    filteredExpenses[index]['user']['name']
                                        .toString(),
                                    style: GoogleFonts.poppins(
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .displayLarge,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FontStyle.normal,
                                      color: HexColor('#1F2937'),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    '₹ ${expense['amount'].toString()}',
                                    style: GoogleFonts.poppins(
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .displayLarge,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FontStyle.normal,
                                      color: HexColor('#1F2937'),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    expense['type'].toString(),
                                    style: GoogleFonts.poppins(
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .displayLarge,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FontStyle.normal,
                                      color: HexColor('#1F2937'),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    expense['description'].toString(),
                                    style: GoogleFonts.poppins(
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .displayLarge,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FontStyle.normal,
                                      color: HexColor('#1F2937'),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    expense['issue_date'].toString(),
                                    style: GoogleFonts.poppins(
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .displayLarge,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FontStyle.normal,
                                      color: HexColor('#1F2937'),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit,
                                            size: 20.sp, color: Colors.blue),
                                        onPressed: () => showDialog(
                                          context: context,
                                          builder: (context) =>
                                              CustomConfirmationDialog(
                                            title: "Edit Fund",
                                            message:
                                                "Are you sure you want to save the changes?",
                                            onConfirm: () async {
                                              Navigator.pop(context);
                                              final editFundDialog = EditFundDialog();
                                              final result = await editFundDialog.show(
                                                context,
                                                filteredExpenses[index]['user']['name'].toString(),
                                                expense['type'].toString(),
                                                expense['entry_date'].toString(),
                                                expense['amount'].toString(),
                                                expense['description'].toString(),
                                                expense['id'].toString(),
                                                categoryExpenses,
                                              ); // Show dialog and wait for result
                                              if (result) {
                                                // Refresh the list if allowance was added successfully
                                                await fetchExpenseData();
                                              }
                                            },
                                            onYes: () async {
                                              Navigator.pop(context);
                                              final editFundDialog = EditFundDialog();
                                              final result = await editFundDialog.show(
                                                context,
                                                filteredExpenses[index]['user']['name'].toString(),
                                                expense['type'].toString(),
                                                expense['entry_date']
                                                    .toString(),
                                                expense['amount'].toString(),
                                                expense['remark'].toString(),
                                                expense['id'].toString(),
                                                categoryExpenses,
                                              ); // Show dialog and wait for result
                                              if (result) {
                                                // Refresh the list if allowance was added successfully
                                                await fetchExpenseData();
                                              }
                                            },
                                            onCancel: () {
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete,
                                            size: 20.sp, color: Colors.red),
                                        onPressed: () =>
                                            _showDeleteConfirmation(
                                                expense['id'].toString()),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                    ),
              SizedBox(height: 50.sp),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(String allowanceId) {
    bool isDeleting = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Colors.white,
          elevation: 8,
          title: Row(
            children: [
              Icon(
                Icons.delete_forever,
                color: Colors.red,
                size: 28,
              ),
              SizedBox(width: 8),
              Text(
                'Delete Expenses',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Text(
              'Are you sure you want to delete this Expenses? This action cannot be undone.',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isDeleting ? null : () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: isDeleting
                  ? null
                  : () async {
                      setState(() => isDeleting = true);
                      try {
                        await deleteFund(allowanceId);
                        Navigator.pop(context);
                        // ScaffoldMessenger.of(context).showSnackBar(
                        //   SnackBar(
                        //     content: Text('Allowance deleted successfully'),
                        //     backgroundColor: Colors.green,
                        //   ),
                        // );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to delete Expenses: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } finally {
                        setState(() => isDeleting = false);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              child: isDeleting
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.delete, color: Colors.white, size: 18),
                        SizedBox(width: 4),
                        Text(
                          'Delete',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> deleteFund(String allowanceId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.post(
      Uri.parse('${ApiRoutes.deleteFund}/$allowanceId'), // Adjust endpoint
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('Allowance deleted successfully')),
      // );
      fetchExpenseData(); // Refresh data
    } else {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('Failed to delete allowance')),
      // );
    }
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

class CustomConfirmationDialog extends StatefulWidget {
  final String title;
  final String message;
  final VoidCallback onConfirm;
  final VoidCallback onYes;
  final VoidCallback onCancel;

  CustomConfirmationDialog({
    required this.title,
    required this.message,
    required this.onConfirm,
    required this.onYes,
    required this.onCancel,
  });

  @override
  _CustomConfirmationDialogState createState() =>
      _CustomConfirmationDialogState();
}

class _CustomConfirmationDialogState extends State<CustomConfirmationDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 10),
              // Message
              Text(
                widget.message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 20),
              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: widget.onCancel,
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 4),
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.redAccent,
                              Colors.redAccent.shade100
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.greenAccent.withOpacity(0.3),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          "Cancel",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Confirm Button
                  Expanded(
                    child: GestureDetector(
                      onTap: widget.onConfirm,
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 4),
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blueAccent, Colors.blue],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blueAccent.withOpacity(0.3),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          "YES",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
