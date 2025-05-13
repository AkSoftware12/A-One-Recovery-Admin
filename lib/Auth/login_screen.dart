
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../BottomNavigation/Bottom2/bottom2.dart';
import '../../strings.dart';
import '../constants.dart';
import '../textSize.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Dio _dio = Dio(); // Initialize Dio
  bool _isLoading = false;
  bool _rememberMe = false;
  bool _isPasswordVisible = false;

  List loginStudent = []; // Declare a list to hold API data



  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // AnimationController setup
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true); // auto reverse karega

    // Tween animation for scaling
    _animation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }


  Future<void> _login() async {
    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
    String? deviceToken = await _firebaseMessaging.getToken();
    print('Device id: $deviceToken');
    print('Email id: ${_emailController.text}');
    print('password id: ${ _passwordController.text}');
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });



    try {
      final response = await _dio.post(
        ApiRoutes.login,
        data: {
          'email': _emailController.text,
          'password': _passwordController.text,
          'device_id': deviceToken,
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true) {
          // Save token in SharedPreferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', responseData['token']);
          print('${AppStrings.tokenSaved}${responseData['token']}'); // Debug: Print the saved token

          // Retrieve the token
          String? token = prefs.getString('token');
          print('${AppStrings.tokenRetrieved}$token');
          PersistentNavBarNavigator.pushNewScreen(
            context,
            screen: ProvidedStylesExample(
              menuScreenContext: context,
            ),
          );

          // Debug: Print retrieved token

          // Navigate to the BottomNavBarScreen with the token

        } else {
          print('${AppStrings.loginFailedDebug}${responseData['message']}'); // Debug: Print failure message
          _showErrorDialog(responseData['message']);
        }
      } else {
        print('${AppStrings.loginFailedMessage} ${response.statusCode}'); // Debug: Unexpected status code
        _showErrorDialog(AppStrings.loginFailedMessage);
      }


    } on DioException catch (e) {
      String errorMessage = AppStrings.unexpectedError;
      if (e.response != null && e.response?.data is Map<String, dynamic>) {
        errorMessage = e.response?.data['message'] ?? errorMessage;
      } else if (e.response?.data is String) {
        errorMessage = e.response?.data;
      }

      _showErrorDialog(errorMessage);
    } catch (e) {
      print('${AppStrings.generalErrorDebug}$e');
      _showErrorDialog(AppStrings.unexpectedError);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.loginFailedTitle),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white,
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.topBg,   // top
              AppColors.bottomBg,  // middle
            ],
            // stops: [
            //   0.0,   // top
            //   0.0,   // top
            //   0.7,   // 50% pe yellow
            //   1.0,   // bottom pe black
            // ],
          ),
        ),

        child: Center(
          child: SafeArea(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.all(TextSizes.padding16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: TextSizes.padding20),
                    // extra spacing at top if needed

                    AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _animation.value,
                          child:Stack(
                            children: [
                              SizedBox(
                                height: 110.sp,
                                width: 110.sp,
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white.withOpacity(0.3),
                                        spreadRadius: 5,
                                        blurRadius: 15,
                                        offset: Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(90),
                                    child: Container(
                                      color: AppColors.bottomBg,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(TextSizes.padding8),
                                child: SizedBox(
                                  height: 95.sp,
                                  width: 95.sp,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(90),
                                    child: Image.asset(
                                      'assets/aonelogo.png',
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),




                    SizedBox(height: TextSizes.padding20),

                    Container(
                      padding: EdgeInsets.all(TextSizes.padding12),
                      decoration: BoxDecoration(
                        color: AppColors.bgLoginCard,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Column(
                              children: [
                                Text(
                                  AppStrings.welcomeBack,
                                  style: GoogleFonts.poppins(
                                    fontSize: TextSizes.text18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textBlack,
                                  ),
                                ),
                                Text(
                                  AppStrings.welcomebottomtext,
                                  style: GoogleFonts.poppins(
                                    fontSize: TextSizes.text12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textBlack,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: TextSizes.text15),

                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  CupertinoIcons.person,
                                  color: AppColors.bgYellow,
                                ),
                                hintText: AppStrings.employeeId,
                                hintStyle: TextStyle(
                                  color: AppColors.textHint,
                                  fontSize: TextSizes.text13,
                                ),
                                filled: true,
                                fillColor: AppColors.bottomBg,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      TextSizes.padding11),
                                  borderSide: BorderSide(
                                      color: AppColors.bgYellow),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      TextSizes.padding11),
                                  borderSide: BorderSide(
                                      color: AppColors.bgYellow, width: 2),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      TextSizes.padding11),
                                  borderSide: BorderSide(
                                      color: Colors.grey.shade400),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 12),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return AppStrings.invalidEmail;
                                }
                                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(
                                    value)) {
                                  return AppStrings.invalidEmail;
                                }
                                return null;
                              },
                              style: TextStyle(
                                fontSize: TextSizes.text13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textBlack,
                              ),
                            ),

                            const SizedBox(height: 15),

                            TextFormField(
                              controller: _passwordController,
                              obscureText: !_isPasswordVisible,
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  CupertinoIcons.padlock_solid,
                                  color: AppColors.bgYellow,
                                ),
                                hintText: AppStrings.password,
                                hintStyle: TextStyle(
                                  color: AppColors.textHint,
                                  fontSize: TextSizes.text13,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible
                                        ? CupertinoIcons.eye_slash_fill
                                        : CupertinoIcons.eye_solid,
                                    color: AppColors.bgYellow,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                ),
                                filled: true,
                                fillColor: AppColors.bottomBg,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: AppColors.bgYellow),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: AppColors.bgYellow, width: 2),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: Colors.grey.shade400),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 12),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return AppStrings.passwordRequired;
                                }
                                return null;
                              },
                              style: TextStyle(
                                fontSize: TextSizes.text13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textBlack,
                              ),
                            ),

                            const SizedBox(height: 10),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    print("Forgot Password clicked");
                                  },
                                  child: Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                      color: AppColors.bgYellow,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            Row(
                              children: [
                                Checkbox(
                                  value: _rememberMe,
                                  onChanged: (value) {
                                    setState(() {
                                      _rememberMe = value!;
                                    });
                                  },
                                  activeColor: AppColors.bgYellow,
                                  fillColor: MaterialStateProperty.resolveWith<Color>((states) {
                                    if (states.contains(MaterialState.selected)) {
                                      return AppColors.bgYellow;  // active color
                                    }
                                    return AppColors.bottomBg;          // inactive color
                                  }),
                                ),


                                // CupertinoSwitch(
                                //   value: _rememberMe,
                                //   onChanged: (value) {
                                //     setState(() {
                                //       _rememberMe = value;
                                //     });
                                //   },
                                //   activeColor: AppColors.bgYellow,
                                // ),
                                Text(
                                  AppStrings.rememberMe,
                                  style: GoogleFonts.poppins(
                                    fontSize: TextSizes.text12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textBlack,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: TextSizes.padding20),

                            if (_isLoading)
                              const CircularProgressIndicator()
                            else
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: TextSizes.padding18),
                                child: CustomLoginButton(
                                  onPressed: () {

                                    _login();

                                  },
                                  title: AppStrings.signIn,
                                ),
                              ),

                            SizedBox(height: TextSizes.padding20),

                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: TextSizes.padding20),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: TextSizes.padding11),
                                child: Text(
                                  AppStrings.signBottomText,
                                  style: GoogleFonts.poppins(
                                    fontSize: TextSizes.text12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textBlack,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: TextSizes.padding20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}




class CustomLoginButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String title;
  const CustomLoginButton({super.key, required this.onPressed, required this.title});

  @override
  _CustomLoginButtonState createState() => _CustomLoginButtonState();
}

class _CustomLoginButtonState extends State<CustomLoginButton> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => isPressed = true),
      onTapUp: (_) {
        Future.delayed(Duration(milliseconds: 100), () {
          setState(() => isPressed = false);
        });
        widget.onPressed();
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        width: double.infinity,
        height: 40.sp,
        decoration: BoxDecoration(
          color: AppColors.bgYellow,

          borderRadius: BorderRadius.circular(10),

          boxShadow: isPressed
              ? []
              : [
            BoxShadow(
              color: AppColors.bgYellow.withOpacity(0.5),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.login_outlined,color: AppColors.textWhite,size: TextSizes.text20,),
              SizedBox(width: TextSizes.padding5,),
              Text(
                '${widget.title}',
                style: GoogleFonts.poppins(
                    fontSize: TextSizes.text15,
                    fontWeight: FontWeight.w500,
                    color:AppColors.textWhite
                ),
              ).animate().fade(duration: 500.ms),
            ],
          ),
        ),
      ),
    );
  }
}

// Usage Example:
// CustomLoginButton(onPressed: () {
//   print("Login Clicked!");
// });
