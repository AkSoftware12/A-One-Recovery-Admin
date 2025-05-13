import 'dart:io';
import 'package:aoneadmin/BottomNavigation/Bottom2/screens.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Auth/login_screen.dart';
import '../../HexColorCode/HexColor.dart';
import '../../bottomScreen/Home/AllList/expenses_list.dart';
import '../../bottomScreen/Home/AllList/sallery_list.dart';
import '../../bottomScreen/Home/home.dart';
import '../../bottomScreen/Profile/profile.dart';
import '../../constants.dart';
import '../../textSize.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

BuildContext? testContext;

class ProvidedStylesExample extends StatefulWidget {
  const ProvidedStylesExample({
    required this.menuScreenContext,
    final Key? key,
  }) : super(key: key);
  final BuildContext menuScreenContext;

  @override
  _ProvidedStylesExampleState createState() => _ProvidedStylesExampleState();
}

class _ProvidedStylesExampleState extends State<ProvidedStylesExample> {
  late PersistentTabController _controller;
  late bool _hideNavBar;
  final List<ScrollController> _scrollControllers = [
    ScrollController(),
    ScrollController(),
  ];
  String? username;
  NavBarStyle _navBarStyle = NavBarStyle.style6;

  @override
  void initState() {
    super.initState();
    getName();
    _controller = PersistentTabController(initialIndex: 0);
    _hideNavBar = false;
  }

  @override
  void dispose() {
    for (final element in _scrollControllers) {
      element.dispose();
    }
    super.dispose();
  }
  void getName() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      username = prefs.getString('username');

    });
    print(username);
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
        prefs.remove('isLoggedIn',);

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

  List<Widget> _buildScreens() => [
        HomeScreen(),

        MainScreen(
          menuScreenContext: widget.menuScreenContext,
          hideStatus: _hideNavBar,
          onScreenHideButtonPressed: () {
            setState(() {
              _hideNavBar = !_hideNavBar;
            });
          },
          onNavBarStyleChanged: (final value) =>
              setState(() => _navBarStyle = value),
        ),
    SalaryScreen(),
    ExpensesScreen(),
    ProfileScreen(),
      ];

  Color? _getSecondaryItemColorForSpecificStyles() =>
      _navBarStyle == NavBarStyle.style7 ||
              _navBarStyle == NavBarStyle.style10 ||
              _navBarStyle == NavBarStyle.style15 ||
              _navBarStyle == NavBarStyle.style16 ||
              _navBarStyle == NavBarStyle.style17 ||
              _navBarStyle == NavBarStyle.style18
          ? HexColor('#cbd5e0')
          : null;

  List<PersistentBottomNavBarItem> _navBarsItems() => [
        PersistentBottomNavBarItem(
          // icon:  Icon(Icons.home),
          icon: FaIcon(
            FontAwesomeIcons.home,
            size: 16.sp,
          ),
          title: "Home",
          textStyle: GoogleFonts.poppins(
            textStyle: Theme.of(context).textTheme.displayLarge,
            fontSize: TextSizes.text12,
            fontWeight: FontWeight.w500,
            fontStyle: FontStyle.normal,
            color: AppColors.textblack,
          ),
          opacity: 0.7,
          activeColorPrimary: AppColors.bottomBarBG,
          activeColorSecondary: _navBarStyle == NavBarStyle.style7 ||
                  _navBarStyle == NavBarStyle.style10
              ? Colors.white
              : null,
          inactiveColorPrimary: HexColor('#cbd5e0'),
          scrollController: _scrollControllers.first,
          routeAndNavigatorSettings: RouteAndNavigatorSettings(
            initialRoute: "/",
            routes: {
              "/first": (final context) => const MainScreen2(),
              "/second": (final context) => const MainScreen3(),
            },
          ),
        ),
        PersistentBottomNavBarItem(
          icon: FaIcon(
            FontAwesomeIcons.tasks,
            size: 16.sp,
          ),
          title: "Allotment",
          textStyle: GoogleFonts.poppins(
            textStyle: Theme.of(context).textTheme.displayLarge,
            fontSize: TextSizes.text12,
            fontWeight: FontWeight.w500,
            fontStyle: FontStyle.normal,
            color: AppColors.textblack,
          ),
          activeColorPrimary: AppColors.bottomBarBG,
          activeColorSecondary: _navBarStyle == NavBarStyle.style7 ||
                  _navBarStyle == NavBarStyle.style10
              ? Colors.white
              : null,
          inactiveColorPrimary: HexColor('#cbd5e0'),
        ),
        PersistentBottomNavBarItem(
          icon: FaIcon(
            FontAwesomeIcons.moneyBill1Wave,
            size: 16.sp,
          ),
          title: "Payroll",
          textStyle: GoogleFonts.poppins(
            textStyle: Theme.of(context).textTheme.displayLarge,
            fontSize: TextSizes.text12,
            fontWeight: FontWeight.w500,
            fontStyle: FontStyle.normal,
            color: AppColors.textblack,
          ),
          activeColorPrimary: AppColors.bottomBarBG,
          inactiveColorPrimary: HexColor('#cbd5e0'),
          activeColorSecondary: _getSecondaryItemColorForSpecificStyles(),
        ),
        PersistentBottomNavBarItem(
          icon: FaIcon(
            FontAwesomeIcons.fileInvoiceDollar,
            size: 16.sp,
          ),
          title: "Expenses",
          textStyle: GoogleFonts.poppins(
            textStyle: Theme.of(context).textTheme.displayLarge,
            fontSize: TextSizes.text12,
            fontWeight: FontWeight.w500,
            fontStyle: FontStyle.normal,
            color: AppColors.textblack,
          ),
          activeColorPrimary: AppColors.bottomBarBG,
          inactiveColorPrimary: HexColor('#cbd5e0'),
          activeColorSecondary: _navBarStyle == NavBarStyle.style7 ||
                  _navBarStyle == NavBarStyle.style10
              ? Colors.white
              : null,
          scrollController: _scrollControllers.last,
        ),
        PersistentBottomNavBarItem(
          icon: FaIcon(
            FontAwesomeIcons.user,
            size: 16.sp,
          ),
          title: "Profile",
          textStyle: GoogleFonts.poppins(
            textStyle: Theme.of(context).textTheme.displayLarge,
            fontSize: TextSizes.text12,
            fontWeight: FontWeight.w500,
            fontStyle: FontStyle.normal,
            color: AppColors.textblack,
          ),
          activeColorPrimary: AppColors.bottomBarBG,
          inactiveColorPrimary: HexColor('#cbd5e0'),
          activeColorSecondary: _navBarStyle == NavBarStyle.style7 ||
                  _navBarStyle == NavBarStyle.style10
              ? Colors.white
              : null,
          scrollController: _scrollControllers.last,
        ),
      ];

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
                    width: 40.sp, // Equal width and height for perfect circle
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
                    child: Center( // Center the icon for better alignment
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
                    username.toString(), // Ensure username is defined
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textWhite,
                    ),
                  ),
                  SizedBox(height: 2.sp),
                  Text(
                    'Admin ID: 2100101',
                    style: GoogleFonts.poppins(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.subTitlewhite.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Notification Button
          GestureDetector(
            onTap: () {
              // Handle notification tap
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
  @override
  Widget build(BuildContext context) {
    // final packageInfo = await PackageInfo.fromPlatform();
    // final version = packageInfo.version;

    return Scaffold(
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
                          top: 25.sp,),
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
                    Padding(
                      padding: EdgeInsets.only(
                          left: TextSizes.padding11,
                          right: TextSizes.padding15,
                          top: TextSizes.padding15),
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
                    SizedBox(
                      height: 8.sp,
                    ),
                    _buildExpansionItem(
                      icon: FaIcon(FontAwesomeIcons.calendarCheck, size: 16.sp),
                      text: 'Attendance',
                      children: [
                        _buildSubItem(
                            context, 'Mark Attendance', '/attendance/mark'),
                        _buildSubItem(
                            context, 'Attendance Report', '/attendance/report'),
                      ],
                    ),
                    _buildExpansionItem(
                      icon: FaIcon(FontAwesomeIcons.wallet, size: 16.sp),
                      text: 'Fund Manager',
                      children: [
                        _buildSubItem(context, 'Fund List', '/fund/list'),
                        _buildSubItem(context, 'Add Fund', '/fund/add'),
                      ],
                    ),
                    _buildExpansionItem(
                      icon: FaIcon(FontAwesomeIcons.fileInvoiceDollar,
                          size: 16.sp),
                      text: 'Expense Manager',
                      children: [
                        _buildSubItem(context, 'Expense List', '/expense/list'),
                        _buildSubItem(context, 'Add Expense', '/expense/add'),
                      ],
                    ),

                    Padding(
                      padding: EdgeInsets.only(
                          left: TextSizes.padding11,
                          right: TextSizes.padding15,
                          top: TextSizes.padding15),
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
                    ListTile(
                      leading: Icon(Icons.logout, color: Colors.black),
                      title: Text("Logout", style: TextStyle(color: Colors.black)),
                      onTap: () {
                        Navigator.pop(context); // Close the progress dialog

                        logoutApi(context);
                      },
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
      body: Column(
        children: [
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
          ),
          Expanded(
            child: PersistentTabView(
              context,
              // controller: _controller,
              screens: _buildScreens(),
              items: _navBarsItems(),
              handleAndroidBackButtonPress: true,
              resizeToAvoidBottomInset: false,
              stateManagement: true,
              hideNavigationBarWhenKeyboardAppears: true,
              popBehaviorOnSelectedNavBarItemPress: PopBehavior.once,
              // hideOnScrollSettings: HideOnScrollSettings(
              //   hideNavBarOnScroll: true,
              //   scrollControllers: _scrollControllers,
              // ),
              padding: EdgeInsets.only(top: 10.sp, bottom: 10.sp),
              onWillPop: (final context) async {
                await showDialog<bool>(
                  context: context ?? this.context,
                  barrierDismissible: false,
                  builder: (context) => AlertDialog(
                    title: const Text("Exit App?"),
                    content:
                        const Text("Are you sure you want to exit the app?"),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    actions: [
                      TextButton(
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                              color: AppColors.textblack, fontSize: 14.sp),
                        ),
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade300,
                        ),
                        icon: Icon(
                          Icons.exit_to_app,
                          color: AppColors.textWhite,
                        ),
                        label: Text(
                          "Exit",
                          style: TextStyle(
                              color: AppColors.textWhite, fontSize: 14.sp),
                        ),
                        onPressed: () => exit(0), // Close the app
                      ),
                    ],
                  ),
                );

                return false;
              },
              selectedTabScreenContext: (final context) {
                testContext = context;
              },
              backgroundColor: AppColors.bgYellow,
              isVisible: !_hideNavBar,
              animationSettings: const NavBarAnimationSettings(
                navBarItemAnimation: ItemAnimationSettings(
                  // Navigation Bar's items animation properties.
                  duration: Duration(milliseconds: 400),
                  curve: Curves.ease,
                ),
                screenTransitionAnimation: ScreenTransitionAnimationSettings(
                  // Screen transition animation on change of selected tab.
                  animateTabTransition: true,
                  duration: Duration(milliseconds: 300),
                  screenTransitionAnimationType:
                      ScreenTransitionAnimationType.fadeIn,
                ),
                onNavBarHideAnimation: OnHideAnimationSettings(
                  duration: Duration(milliseconds: 100),
                  curve: Curves.bounceInOut,
                ),
              ),
              confineToSafeArea: true,
              // navBarHeight: kBottomNavigationBarHeight,
              navBarHeight: 50.sp,
              navBarStyle: _navBarStyle,
            ),
          ),
        ],
      ),
    );
  }
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

Widget _buildDrawerItem({
  required FaIcon icon,
  required String text,
  GestureTapCallback? onTap,
}) {
  return ListTile(
    leading: icon,
    title: Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: TextSizes.text14,
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
        color: AppColors.textblack,
      ),
    ),
    onTap: onTap,
  );
}

Widget _buildExpansionItem({
  required FaIcon icon,
  required String text,
  required List<Widget> children,
}) {
  return ExpansionTile(
    leading: icon,
    title: Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: TextSizes.text15,
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
        color: AppColors.textblack,
      ),
    ),
    minTileHeight: 5,
    children: children,
  );
}

Widget _buildSubItem(BuildContext context, String title, String routeName) {
  return Padding(
    padding:  EdgeInsets.only(left: 16.sp,bottom: 15.sp),
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      splashColor: Colors.black.withOpacity(0.1),
      highlightColor: Colors.transparent,
      onTap: () {
        Navigator.pushNamed(context, routeName);
      },
      child: Row(
        children: [
          // const Icon(Icons.star_border, size: 24, color: Colors.blueAccent), // Example icon, replace if needed
          //  SizedBox(width: 50.sp),
          Expanded(
            child: SizedBox(
              height: 25.sp,
              child: Center(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: TextSizes.text13,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.normal,
                    color: AppColors.textblack,
                  ),
                ),
              ),
            ),
          ),
          // const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    ),
  );
}
