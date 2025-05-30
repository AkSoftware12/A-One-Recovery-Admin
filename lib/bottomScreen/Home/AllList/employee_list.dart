import 'dart:convert';
import 'package:aoneadmin/HexColorCode/HexColor.dart';
import 'package:aoneadmin/bottomScreen/Home/AllList/sallery_list.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../Auth/login_screen.dart';
import '../../../Employee/Add/add_employee.dart';
import '../../../Widget/AppBar/appBar.dart';
import '../../../constants.dart';
import '../../../demo.dart';
import '../../../strings.dart';
import '../../../textSize.dart';
import '../../Attendance/mark_attendance.dart';
import 'expenses_list.dart';
import 'fund_list.dart';

class EmployeeScreen extends StatefulWidget {
  final String appBar;
   EmployeeScreen({super.key, required BuildContext menuScreenContext, required this.appBar});

  @override
  State<EmployeeScreen> createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen>
    with SingleTickerProviderStateMixin {
  bool isLoading = false;
  int? activeCount;
  int? inactiveCount;
  List fees = [];
  List filteredFees = [];
  TextEditingController searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // List of colors for CircleAvatar
  final List<Color> avatarColors = [
    Colors.blue,
    Colors.purple,
    Colors.orange,
    Colors.teal,
    Colors.pink,
    Colors.amber,
    Colors.cyan,
    Colors.lime,
  ];

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
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    fetchEmployeeData();
    filteredFees = fees;
    searchController.addListener(_filterEmployees);
    _animationController.forward();
  }

  Future<void> fetchEmployeeData() async {
    setState(() {
      isLoading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse(ApiRoutes.getEmployeeList),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        fees = data['employees'];
        activeCount = fees.where((employee) => employee['status'] == 1).length;
        inactiveCount = fees.where((employee) => employee['status'] == 2).length;
        filteredFees = fees;
        isLoading = false;
      });
      _animationController.forward(from: 0);
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _filterEmployees() {
    String query = searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredFees = fees;
      } else {
        filteredFees = fees.where((employee) {
          return employee['name'].toLowerCase().contains(query);
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
      fetchEmployeeData();

    });
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
    return


      Scaffold(
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
                                    appBar: 'Attendance',
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
                                  screen: EmployeeFundScreen(appBar: 'Fund Manager',),
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
                                  screen: ExpensesScreen(appBar: 'Expense Manager',),
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

        floatingActionButton: AnimatedScale(
        scale: isLoading ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 300),
        child: Padding(
          padding: EdgeInsets.only(bottom: 65.sp),
          child: ElevatedButton(
            onPressed: () {
              PersistentNavBarNavigator.pushNewScreen(
                context,
                screen: AddEmployee(menuScreenContext: context, onReturn: _refresh,),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: HexColor('#0066cc'),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedRotation(
                  turns: isLoading ? 0.5 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: FaIcon(
                    FontAwesomeIcons.userPlus,
                    size: 20.sp,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Add Employee',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(0.sp),
          child: Column(
            children: [
              widget.appBar != ''
                  ?
              Container(
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
              )
                  :SizedBox(),
              Padding(
                padding:  EdgeInsets.all(5.sp),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Card(
                          color: HexColor('#fefefe'),
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(10.sp),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Employee'.toUpperCase(),
                                  style: GoogleFonts.poppins(
                                    fontSize: MediaQuery.of(context).size.width * 0.045,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textblack,
                                  ),
                                ),
                                SizedBox(height: 5.sp),
                                Row(
                                  children: [
                                    Expanded(
                                      child: SummaryCard(
                                        title: "Active Employee",
                                        value: activeCount?.toString() ?? '0',
                                        isActive: true,
                                        animationDelay: 100,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10.sp,
                                    ),
                                    Expanded(
                                      child: SummaryCard(
                                        title: "Inactive Employee",
                                        value: inactiveCount?.toString() ?? '0',
                                        isActive: false,
                                        animationDelay: 200,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.sp),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      transform: Matrix4.identity()
                        ..scale(searchController.text.isNotEmpty ? 1.02 : 1.0),
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: 'Search employees by name...',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontWeight: FontWeight.w400,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey[700],
                            size: 22,
                          ),
                          suffixIcon: searchController.text.isNotEmpty
                              ? IconButton(
                            icon: Icon(Icons.clear,
                                color: Colors.grey[700], size: 20),
                            onPressed: () {
                              searchController.clear();
                              _filterEmployees();
                            },
                          )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: AppColors.bgYellow,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          isDense: true,
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                        ),
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          fontFamily: 'Roboto',
                        ),
                        cursorColor: AppColors.bgYellow,
                      ),
                    ),
                    SizedBox(height: 20.sp),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,

                        children: [
                          Text(
                            'EMPLOYEE LIST (${filteredFees.length})',
                            style: GoogleFonts.poppins(
                              fontSize: TextSizes.text12,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textblack,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.refresh,
                                size: 24.sp, color: Colors.grey[700]),
                            onPressed: fetchEmployeeData,
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 10.sp),
                    isLoading
                        ? Center(child: AnimatedLoader())
                        : Card(
                      color: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: List.generate(filteredFees.length, (index) {
                            final employee = filteredFees[index];
                            return FadeTransition(
                              opacity: _fadeAnimation,
                              child: SlideTransition(
                                position: _slideAnimation,
                                child: EmployeeCard(
                                  initials: employee['name']
                                      .split(' ')
                                      .map((e) => e[0])
                                      .join(),
                                  name: employee['name']??'',
                                  base: employee['email']??'',
                                  incentive: employee['joining_date']??'',
                                  total: employee['joining_date']??'',
                                  status: employee['status'].toString(),
                                  avatarColor:
                                  avatarColors[index % avatarColors.length],
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                    Center(
                      child: TextButton(
                        onPressed: () {},
                        child: AnimatedOpacity(
                          opacity: filteredFees.isNotEmpty ? 1.0 : 0.5,
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            'VIEW ALL EMPLOYEES (${filteredFees.length})',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AnimatedLoader extends StatefulWidget {
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
        color: AppColors.bgYellow,
      ),
    );
  }
}

class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final bool isActive;
  final int animationDelay;

  const SummaryCard({
    required this.title,
    required this.value,
    this.isActive = true,
    this.animationDelay = 0,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.delayed(Duration(milliseconds: animationDelay)),
      builder: (context, snapshot) {
        return AnimatedOpacity(
          opacity: snapshot.connectionState == ConnectionState.done ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 500),
          child:Container(
            decoration: BoxDecoration(
              color: AppColors.bottomBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        FaIcon(
                          FontAwesomeIcons.userPlus,
                          size: 15.sp,
                          color: isActive ? Colors.green : Colors.red,
                        ),
                        SizedBox(
                          width: 5.sp,
                        ),
                        Text(
                          title,
                          style: GoogleFonts.poppins(
                            textStyle:
                            Theme.of(context)
                                .textTheme
                                .displayLarge,
                            fontSize: 13.sp,
                            fontWeight:
                            FontWeight.w600,
                            fontStyle:
                            FontStyle.normal,
                            color:  isActive ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.sp),
                    Text(
                      '($value)',
                      style: GoogleFonts.poppins(
                        textStyle: Theme.of(context)
                            .textTheme
                            .displayLarge,
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.normal,
                        color:  isActive ? Colors.green : Colors.red,
                      ),
                    ),
                    SizedBox(height: 8.sp),
                  ],
                ),
              ),
            ),
          ),



        );
      },
    );
  }
}

class EmployeeCard extends StatelessWidget {
  final String initials;
  final String name;
  final String base;
  final String incentive;
  final String total;
  final String status;
  final Color avatarColor; // New parameter for avatar color

  EmployeeCard({
    required this.initials,
    required this.name,
    required this.base,
    required this.incentive,
    required this.total,
    required this.status,
    required this.avatarColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(5.sp),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: avatarColor, // Use dynamic color from list
                child: Text(
                  initials.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white, // Darker text for better contrast
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.poppins(
                        fontSize: TextSizes.text14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textblack,
                      ),
                    ),
                    Text(
                      base,
                      style: GoogleFonts.poppins(
                        fontSize: TextSizes.text12,
                        fontWeight: FontWeight.w500,
                        color: HexColor('#1f2937'),
                      ),
                    ),
                  ],
                ),
              ),
              Chip(
                label: Text(
                  status == '1' ? 'Active' : 'Inactive',
                  style: GoogleFonts.poppins(
                    fontSize: TextSizes.text13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textWhite,
                  ),
                ),
                backgroundColor: status == '1' ? Colors.green : Colors.red,
              ),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          height: 1.sp,
          color: Colors.grey.shade100,
        ),
      ],
    );
  }
}