import 'dart:io';
import 'package:aoneadmin/BottomNavigation/Bottom2/screens.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import '../../HexColorCode/HexColor.dart';
import '../../bottomScreen/Home/home.dart';
import '../../constants.dart';
import '../../textSize.dart';

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

  NavBarStyle _navBarStyle = NavBarStyle.style6;

  @override
  void initState() {
    super.initState();
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


  List<Widget> _buildScreens() => [
    HomeScreen(),
    // MainScreen(
    //   menuScreenContext: widget.menuScreenContext,
    //   scrollController: _scrollControllers.first,
    //   hideStatus: _hideNavBar,
    //   onScreenHideButtonPressed: () {
    //     setState(() {
    //       _hideNavBar = !_hideNavBar;
    //     });
    //   },
    //   onNavBarStyleChanged: (final value) =>
    //       setState(() => _navBarStyle = value),
    // ),
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
    MainScreen(
      menuScreenContext: widget.menuScreenContext,
      scrollController: _scrollControllers.last,
      hideStatus: _hideNavBar,
      onScreenHideButtonPressed: () {
        setState(() {
          _hideNavBar = !_hideNavBar;
        });
      },
      onNavBarStyleChanged: (final value) =>
          setState(() => _navBarStyle = value),
    ),
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
      icon: FaIcon(FontAwesomeIcons.home,size: 16.sp,),
      title: "Home",
      textStyle:GoogleFonts.poppins(
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
      icon: FaIcon(FontAwesomeIcons.tasks,size: 16.sp,),
      title: "Allotment",
      textStyle:GoogleFonts.poppins(
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
      icon: FaIcon(FontAwesomeIcons.moneyBill1Wave,size: 16.sp,),
      title: "Payroll",
      textStyle:GoogleFonts.poppins(
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
      icon: FaIcon(FontAwesomeIcons.fileInvoiceDollar,size: 16.sp,),
      title: "Expenses",
      textStyle:GoogleFonts.poppins(
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
      icon: FaIcon(FontAwesomeIcons.user,size: 16.sp,),
      title: "Profile",
      textStyle:GoogleFonts.poppins(
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
      padding:  EdgeInsets.only(top: TextSizes.padding30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Builder(
                builder: (context) => Padding(
                  padding: EdgeInsets.all(0),
                  child: GestureDetector(
                    onTap: () {
                      Scaffold.of(context).openDrawer();
                    },
                    child: Container(
                      height: MediaQuery.of(context).size.width * 0.1,
                      width: MediaQuery.of(context).size.width * 0.1,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.shade200, // background color, change as needed
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/menu.png',
                          height: MediaQuery.of(context).size.width * 0.05,
                          width: MediaQuery.of(context).size.width * 0.05,
                          color: AppColors.textblack,
                        ),
                      ),
                    ),
                  ),
                ),
              ),



              SizedBox(width: 12.sp),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Admin!',
                    style: GoogleFonts.poppins(
                      textStyle: Theme.of(context).textTheme.displayLarge,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.normal,
                      color: AppColors.textWhite,
                    ),
                  ),
                  Text(
                    // studentData?['student_name'].toString()??'Student Name',
                    'Admin ID : ${'2100101'}',
                    style: GoogleFonts.poppins(
                      textStyle: Theme.of(context).textTheme.displayLarge,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.normal,
                      color: AppColors.subTitlewhite,
                    ),
                  ),



                ],
              ),

            ],
          ),
          Builder(
            builder: (context) => Padding(
              padding: EdgeInsets.all(0),
              child: GestureDetector(
                onTap: () {
                  // Notification icon tapped
                },
                child: Stack(
                  clipBehavior: Clip.none, // So badge can overflow outside stack
                  children: [
                    Icon(
                      Icons.notification_add,
                      color: AppColors.textWhite,
                      size: 23.sp,
                    ),


                    // Notification Count Badge
                    Positioned(
                      right: -4, // adjust as needed
                      top: -4,   // adjust as needed
                      child: Container(
                        padding: EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Center(
                          child: Text(
                            '3', // <-- your dynamic notification count here
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.sp,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )


        ],
      ),
    );
  }


  @override
  Widget build(final BuildContext context) => Scaffold(

    drawer: Drawer(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      width: MediaQuery.sizeOf(context).width * .65,
      backgroundColor: AppColors.primary,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 200.sp,
            padding: EdgeInsets.all(16.sp),
            child: Column(
              children: [
                SizedBox(height: 30.sp),
                CircleAvatar(
                  radius: 40.sp,
                  backgroundImage: NetworkImage(
                    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRjPy4QWtfglbm7rI4dSi6dvh4n8ZExI828MA&s',
                  ),
                  backgroundColor: Colors.white,
                ),
                SizedBox(width: 12.sp),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Ravikant',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'ravikant@example.com',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Divider(color: Colors.white30),

          // Drawer Items
          ListTile(
            leading: Icon(Icons.home, color: Colors.white),
            title: Text("Home", style: TextStyle(color: Colors.white)),
            onTap: () {
              // Navigate to Home
            },
          ),
          ListTile(
            leading: Icon(Icons.person, color: Colors.white),
            title: Text("Profile", style: TextStyle(color: Colors.white)),
            onTap: () {
              // Navigate to Profile
            },
          ),
          ListTile(
            leading: Icon(Icons.dashboard, color: Colors.white),
            title: Text("Dashboard", style: TextStyle(color: Colors.white)),
            onTap: () {
              // Navigate to Dashboard
            },
          ),


        ],
      ),
    ),
    body: Column(
      children: [

        Container(
          height: 80.sp,
          decoration: BoxDecoration(
            color: AppColors.bgYellow,
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(0.sp),
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
            padding:  EdgeInsets.only(top: 10.sp,bottom: 10.sp),
            onWillPop: (final context) async {
              await  showDialog<bool>(
                context: context ?? this.context,
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                  title: const Text("Exit App?"),
                  content: const Text("Are you sure you want to exit the app?"),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  actions: [
                    TextButton(
                      child:  Text("Cancel",style: TextStyle(color: AppColors.textblack,fontSize: 14.sp),),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade300,
                      ),
                      icon:  Icon(Icons.exit_to_app,color: AppColors.textWhite,),
                      label:  Text("Exit",style: TextStyle(color: AppColors.textWhite,fontSize: 14.sp),),
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
            backgroundColor:AppColors.bgYellow,
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
            navBarHeight: 55.sp,
            navBarStyle: _navBarStyle,
          ),
        ),
      ],
    ),
  );
}
