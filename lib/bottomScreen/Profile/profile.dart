import 'dart:convert';

import 'package:aoneadmin/Auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../HexColorCode/HexColor.dart';
import '../../constants.dart';
import '../../textSize.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..forward();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.4, 0.9, curve: Curves.easeOutCubic),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.6, 1.0, curve: Curves.elasticOut),
      ),
    );

    _colorAnimation = ColorTween(
      begin: Colors.teal.withOpacity(0.2),
      end: Colors.teal.withOpacity(0.4),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    fetchProfileData();
  }

  Future<void> fetchProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse(ApiRoutes.getProfile),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        userData = data['user'];
        isLoading = false;
        _controller.forward();
      });
    } else {
      // Handle error (e.g., show login dialog)
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _logout(context),
        tooltip: 'Logout',
        backgroundColor: Colors.red.shade300,
        child: Icon(Icons.logout,color: Colors.white,), // Optional: Customize FAB color
      ),
      body: Stack(
        children: [
          // Gradient Background
          // Main Content
          Column(
            children: [
              // Profile Header Card
              Container(
                margin: EdgeInsets.only(top: 0.h,bottom: 0.h),
                color: Colors.white,
                child: Card(
                  elevation: 10,

                  margin: EdgeInsets.symmetric(horizontal: 0.w),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  color: Colors.white,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child:_buildProfileHeader(
                        fadeAnimation: _fadeAnimation,
                        slideAnimation: _slideAnimation,
                        userData: userData,
                        onEditPressed: () {
                          // Handle edit profile action here
                          // Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfileScreen()));
                        },
                      )
                    ),
                  ),
                ),
              ),
              // Scrollable Content
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 0.w,vertical: 0.w),
                        child: Column(
                          children: [

                            _buildProfileDetailsCard(),
                            SizedBox(height: 30.h),

                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  void _logout(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true, // Allow dismissing by tapping outside
      barrierColor: Colors.black.withOpacity(0.7), // Darker, sleek overlay
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24), // Softer rounded corners
        ),
        elevation: 0, // Remove default elevation for a modern look
        backgroundColor: Colors.transparent, // Transparent for glassmorphism
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Colors.white.withOpacity(0.95), // Subtle glassmorphism effect
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 5,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Hug content
            children: [
              // Animated Icon
              AnimatedScale(
                scale: 1.0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.redAccent.withOpacity(0.1),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    size: 48,
                    color: Colors.redAccent,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Title
              Text(
                "Logout Confirmation",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              // Message
              Text(
                "Are you sure you want to log out of your account?",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[800],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Cancel Button
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Colors.grey[100],
                    ),
                    child: Text(
                      "Cancel",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                  // Logout Button
                  ElevatedButton(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      prefs.clear();
                      Navigator.pop(context); // Close dialog
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      elevation: 0,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.redAccent, Colors.red],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      child: Text(
                        "Logout",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
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
  Widget _buildProfileHeader({
    required Animation<double> fadeAnimation,
    required Animation<Offset> slideAnimation,
    required Map<String, dynamic>? userData,
    required VoidCallback onEditPressed, // Add this callback parameter
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Avatar
              FadeTransition(
                opacity: fadeAnimation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.7, end: 1.0).animate(
                    CurvedAnimation(
                      parent: fadeAnimation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      // Handle avatar tap
                    },
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            gradient: LinearGradient(
                              colors: [AppColors.bgYellow, Colors.teal.shade400],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(
                              color: Colors.white,
                              width: 3.w,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 12.r,
                                spreadRadius: 2.r,
                                offset: Offset(0, 4.h),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 35.sp,
                            backgroundColor: Colors.white,
                            child: ClipOval(
                              child: Image.network(
                                userData?['picture_data'] ?? 'https://via.placeholder.com/150',
                                fit: BoxFit.cover,
                                width: 90.sp,
                                height: 90.sp,
                                errorBuilder: (context, error, stackTrace) => Icon(
                                  Icons.person_rounded,
                                  size: 45.sp,
                                  color: AppColors.bgYellow,
                                ),
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                          : null,
                                      strokeWidth: 3.w,
                                      color: AppColors.bgYellow,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        // Verification Badge

                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              // User Info
              Expanded(
                child: SlideTransition(
                  position: slideAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userData?['name']?.toString().toUpperCase() ?? 'UNKNOWN',
                        style: GoogleFonts.poppins(
                          fontSize: TextSizes.text18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textblack,
                          letterSpacing: 0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 0.h),
                      Text(
                        userData?['email'] ?? 'No email provided',
                        style: GoogleFonts.poppins(
                          fontSize: TextSizes.text14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.subTitleBlack,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 5.h),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.bgYellow.withOpacity(0.2), Colors.teal.shade100],
                            ),
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(color: AppColors.bgYellow.withOpacity(0.5)),
                          ),
                          child:  Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.edit_rounded, size: 15.sp),
                              SizedBox(width: 8.w),
                              Text(
                                'Edit Profile',
                                style: GoogleFonts.poppins(
                                  fontSize: TextSizes.text13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textblack,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),

        ],
      ),
    );
  }

  Widget _buildProfileDetailsCard() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Card(
        elevation: 6,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Column(
            children: [
              _buildSectionHeader('Personal Information'),
              _buildDivider(),
              _buildDetailItem(
                icon: Icons.person_outline_rounded,
                title: 'Full Name',
                value: userData?['name'] ?? 'Not provided',
              ),
              _buildDivider(),
              _buildDetailItem(
                icon: Icons.cake_rounded,
                title: 'Date of Birth',
                value: userData?['dob'] != null
                    ? _formatDate(userData?['dob'])
                    : 'Not provided',
              ),
              _buildDivider(),
              _buildDetailItem(
                icon: Icons.transgender_rounded,
                title: 'Gender',
                value: _getGender(userData?['gender']),
              ),
              _buildDivider(),
              _buildDetailItem(
                icon: Icons.category_rounded,
                title: 'Social Category',
                value: _getSocialCategory(userData?['social_category']),
              ),
              _buildDivider(),
              _buildDetailItem(
                icon: Icons.h_mobiledata,
                title: 'Religion',
                value: userData?['religion'] ?? 'Not provided',
              ),

              SizedBox(height: 24.h),
              _buildSectionHeader('Contact Details'),
              _buildDivider(),
              _buildDetailItem(
                icon: Icons.phone_rounded,
                title: 'Contact Number',
                value: userData?['contact'] ?? 'Not provided',
              ),
              _buildDivider(),
              _buildDetailItem(
                icon: Icons.email_rounded,
                title: 'Email Address',
                value: userData?['email'] ?? 'Not provided',
                isImportant: true,
              ),
              _buildDivider(),
              _buildDetailItem(
                icon: Icons.location_on_rounded,
                title: 'Address',
                value: userData?['address'] ?? 'Not provided',
              ),
              _buildDivider(),
              _buildDetailItem(
                icon: Icons.location_city_rounded,
                title: 'State/District',
                value: '${userData?['state'] ?? 'N/A'} / ${userData?['district'] ?? 'N/A'}',
              ),
              _buildDivider(),
              _buildDetailItem(
                icon: Icons.pin_drop_rounded,
                title: 'PIN Code',
                value: userData?['pin']?.toString() ?? 'Not provided',
              ),

              SizedBox(height: 24.h),
              _buildSectionHeader('Official Information'),
              _buildDivider(),
              _buildDetailItem(
                icon: Icons.work_rounded,
                title: 'Employee Type',
                value: _getEmployeeType(userData?['employee_type']),
              ),
              _buildDivider(),
              _buildDetailItem(
                icon: Icons.assignment_rounded,
                title: 'Contract Type',
                value: _getContractType(userData?['contract_type']),
              ),
              _buildDivider(),
              _buildDetailItem(
                icon: Icons.money_rounded,
                title: 'Basic Pay',
                value: userData?['basic_pay']?.toString() ?? 'Not provided',
              ),
              _buildDivider(),
              _buildDetailItem(
                icon: Icons.calendar_today_rounded,
                title: 'Joining Date',
                value: userData?['joining_date'] != null
                    ? _formatDate(userData?['joining_date'])
                    : 'Not provided',
              ),
              _buildDivider(),
              _buildDetailItem(
                icon: Icons.calendar_month_rounded,
                title: 'Entry Date',
                value: userData?['entry_date'] != null
                    ? _formatDate(userData?['entry_date'])
                    : 'Not provided',
              ),

              SizedBox(height: 24.h),
              _buildSectionHeader('Identification'),
              _buildDivider(),
              _buildDetailItem(
                icon: Icons.credit_card_rounded,
                title: 'Aadhaar Number',
                value: userData?['adhar_card_no']?.isNotEmpty == true
                    ? '•••• •••• •••• ${userData?['adhar_card_no'].substring(8)}'
                    : 'Not provided',
              ),
              _buildDivider(),
              _buildDetailItem(
                icon: Icons.badge_rounded,
                title: 'PAN Card',
                value: userData?['pan_card']?.isNotEmpty == true
                    ? '•••••${userData?['pan_card'].substring(5)}'
                    : 'Not provided',
              ),
              _buildDivider(),
              _buildDetailItem(
                icon: Icons.card_membership_rounded,
                title: 'Voter ID',
                value: userData?['voter_id'] ?? 'Not provided',
              ),
              _buildDivider(),
              _buildDetailItem(
                icon: Icons.directions_car_rounded,
                title: 'Driving License',
                value: userData?['driving_licence'] ?? 'Not provided',
              ),
              _buildDivider(),
              _buildDetailItem(
                icon: Icons.account_balance_wallet_rounded,
                title: 'UAN Number',
                value: userData?['uan_no'] ?? 'Not provided',
              ),

              SizedBox(height: 24.h),
              _buildSectionHeader('Bank Details'),
              _buildDivider(),
              _buildDetailItem(
                icon: Icons.account_balance_rounded,
                title: 'Bank Account',
                value: userData?['bank_account_no'] ?? 'Not provided',
              ),
              _buildDivider(),
              _buildDetailItem(
                icon: Icons.code_rounded,
                title: 'IFSC Code',
                value: userData?['ifsc_code'] ?? 'Not provided',
              ),

              SizedBox(height: 24.h),
              _buildSectionHeader('System Information'),
              _buildDivider(),
              _buildDetailItem(
                icon: Icons.login_rounded,
                title: 'Last Login',
                value: _formatDateTime(userData?['last_login']),
              ),
              _buildDivider(),
              _buildDetailItem(
                icon: Icons.update_rounded,
                title: 'Last Updated',
                value: _formatDateTime(userData?['updated_at']),
              ),
              _buildDivider(),
              _buildDetailItem(
                icon: Icons.notifications_active_rounded,
                title: 'Notifications',
                value: userData?['is_notifiable'] == 1 ? 'Enabled' : 'Disabled',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        children: [
          Container(
            height: 28.h,
            width: 5.w,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.bgYellow, Colors.teal.shade400],
              ),
              borderRadius: BorderRadius.circular(3.r),
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: TextSizes.text17,
              fontWeight: FontWeight.w700,
              color: AppColors.textblack,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String title,
    required String value,
    bool isImportant = false,
  }) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 14.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: isImportant ? Colors.red.shade50 : AppColors.bgYellow.withOpacity(0.15),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6.r,
                      offset: Offset(0, 2.h),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: isImportant ? Colors.red.shade400 : AppColors.bgYellow,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: TextSizes.text14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.subTitleBlack,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      value,
                      style: GoogleFonts.poppins(
                        fontSize: TextSizes.text15,
                        fontWeight: isImportant ? FontWeight.w600 : FontWeight.w500,
                        color: isImportant ? Colors.red.shade700 : AppColors.textblack,
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

  Widget _buildDivider() {
    return Divider(
      height: 1.h,
      thickness: 1,
      color: Colors.grey.shade200,
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildNeumorphicButton(
          icon: Icons.edit_rounded,
          text: 'Edit',
          color: Colors.teal.shade600,
          onPressed: () {
            _controller.reset();
            _controller.forward();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Edit Profile Clicked!'),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                backgroundColor: Colors.teal.shade700,
              ),
            );
          },
        ),
        _buildNeumorphicButton(
          icon: Icons.file_copy_rounded,
          text: 'Documents',
          color: Colors.blue.shade600,
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Documents View Clicked!'),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                backgroundColor: Colors.blue.shade700,
              ),
            );
          },
        ),
        _buildNeumorphicButton(
          icon: Icons.share_rounded,
          text: 'Share',
          color: Colors.purple.shade600,
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Share Profile Clicked!'),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                backgroundColor: Colors.purple.shade700,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildNeumorphicButton({
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: Offset(4.w, 4.h),
                blurRadius: 8.r,
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.7),
                offset: Offset(-4.w, -4.h),
                blurRadius: 8.r,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                text,
                style: GoogleFonts.poppins(
                  fontSize: TextSizes.text14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(String? dateTime) {
    if (dateTime == null) return 'Unknown';
    try {
      final dt = DateTime.parse(dateTime);
      return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    } catch (e) {
      return dateTime;
    }
  }

  String _formatDate(String? date) {
    if (date == null) return 'Not provided';
    try {
      final dt = DateTime.parse(date);
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (e) {
      return date;
    }
  }

  String _getGender(String? genderCode) {
    switch (genderCode) {
      case '1':
        return 'Male';
      case '2':
        return 'Female';
      case '3':
        return 'Other';
      default:
        return 'Not specified';
    }
  }

  String _getSocialCategory(String? categoryCode) {
    switch (categoryCode) {
      case '1':
        return 'General';
      case '2':
        return 'OBC';
      case '3':
        return 'SC';
      case '4':
        return 'ST';
      default:
        return 'Not specified';
    }
  }

  String _getEmployeeType(int? typeCode) {
    switch (typeCode) {
      case 1:
        return 'Permanent';
      case 2:
        return 'Contract';
      case 3:
        return 'Temporary';
      default:
        return 'Not specified';
    }
  }

  String _getContractType(int? typeCode) {
    switch (typeCode) {
      case 1:
        return 'Full-time';
      case 2:
        return 'Part-time';
      case 3:
        return 'Consultant';
      default:
        return 'Not specified';
    }
  }
}