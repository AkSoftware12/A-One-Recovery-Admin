
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import 'Auth/login_screen.dart';
import 'Auth/register.dart';
import 'BottomNavigation/Bottom2/bottom2.dart';



class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();



  }

  Future<void> _checkConnectivity() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        _isConnected = false;
      });
      // Show the dialog if there is no internet
      _showNoInternetDialog();
    } else {
      setState(() {
        _isConnected = true;
      });
      // Save the token in shared preferences
      // await _setTokenInSharedPreferences();
      // Navigate to BottomNavBarScreen after 5 seconds if connected

      await Future.delayed(const Duration(seconds: 4)); // splash delay

      if (token != null && token.isNotEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProvidedStylesExample( menuScreenContext: context,)),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      }
    }
  }

  void _showNoInternetDialog() {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('No Internet Connection'),
        content: const Text('Please check your internet connection and try again.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Reload'),
            onPressed: () {
              Navigator.of(ctx).pop();
              _checkConnectivity(); // Retry connectivity check
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgYellow,
      body:  Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo image
            Container(
              height: 80.sp,
              width: 80.sp,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(20))
              ),
              child: Padding(
                padding:  EdgeInsets.all(0.sp),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.sp),
                  child: Image.asset(
                    'assets/aonelogo.png',
                    width: 100.sp,
                    height: 100.sp,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10.sp), // Spacing between logo and app name
            // App name
            Text(
              'A One Recovery', // Replace with your app name
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white, // White text for contrast
              ),
            ),

            SizedBox(height: 20.sp), // Spacing before loader
            const CupertinoActivityIndicator(
              radius: 10,
              color: Colors.white,
            ),
          ],
        ),
      ),



    );
  }
}
