import 'dart:convert';
import 'package:aoneadmin/HexColorCode/HexColor.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../DialogClass/ExpensesDialog/addExpenseDialog.dart'; // Adjust path as needed
import '../../../constants.dart'; // Adjust path as needed
import '../../../textSize.dart';
import '../DialogClass/AllowanceDialog/addAllowanceDialog.dart';
import '../DialogClass/AllowanceDialog/editallowanceDialog.dart'; // Adjust path as needed

class AllowanceScreen extends StatefulWidget {
  const AllowanceScreen({super.key});

  @override
  State<AllowanceScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<AllowanceScreen>
    with SingleTickerProviderStateMixin {
  final EditAllowanceDialog editExpenseDialog = EditAllowanceDialog();
  final AllowanceDialog _allowanceDialog = AllowanceDialog();

  bool isLoading = false;
  List ALLOWANCE = [];
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
    filteredExpenses = ALLOWANCE;
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
      Uri.parse(ApiRoutes.getAllowanceList),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        ALLOWANCE = data['data'];
        filteredExpenses = ALLOWANCE;
        isLoading = false;
      });
      _animationController.forward(from: 0);
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load ALLOWANCE')),
      );
    }
  }

  // New: Delete Allowance
  Future<void> deleteAllowance(String allowanceId, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print('$password');

    final response = await http.post(
      Uri.parse('${ApiRoutes.deleteAllowanceList}/$allowanceId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'password': password, // ✅ send password in body
      }),
    );

    if (response.statusCode == 200) {
      Fluttertoast.showToast(
        msg: "Allowance deleted successfully!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 14.0,
      );
      fetchExpenseData(); // ✅ refresh data
    } else {
      await showInvalidPasswordDialog(context);

      // Fluttertoast.showToast(
      //   msg: "Failed to delete allowance (${response.statusCode})",
      //   toastLength: Toast.LENGTH_LONG,
      //   gravity: ToastGravity.CENTER,
      //   backgroundColor: Colors.redAccent,
      //   textColor: Colors.white,
      //   fontSize: 16.0,
      // );
    }
  }


  /// Call this function when password is invalid:
  /// await showInvalidPasswordDialog(context);
  Future<void> showInvalidPasswordDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // tap outside to dismiss
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 10,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 22.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top red icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.lock_outline, size: 36, color: Colors.red.shade700),
                ),
                const SizedBox(height: 16),

                // Title
                Text(
                  'Invalid Password',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.red.shade800,
                  ),
                ),
                const SizedBox(height: 8),

                // Message
                const Text(
                  'The password you entered is incorrect. Please try again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 18),

                // Buttons row
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // just close
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // close and let caller handle retry
                          // Optionally you could navigate to the retry screen here
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade700,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Try Again',style: TextStyle(color: Colors.white),),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),


              ],
            ),
          ),
        );
      },
    );
  }


  // New: Edit Allowance
  Future<void> editAllowance(Map allowance) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.put(
      Uri.parse('${ApiRoutes.updateAllowanceList}/${allowance['id']}'), // Adjust endpoint
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'name': allowance['name'],
        'type': allowance['type'],
        'amount': allowance['amount'],
        'percentange': allowance['percentange'],
        'status': allowance['status'],
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Allowance updated successfully')),
      );
      fetchExpenseData(); // Refresh data
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update allowance')),
      );
    }
  }

  void _filterExpenses() {
    String query = searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredExpenses = ALLOWANCE;
      } else {
        filteredExpenses = ALLOWANCE.where((Allowance) {
          return Allowance['amount'].toString().toLowerCase().contains(query) ||
              Allowance['name'].toLowerCase().contains(query) ||
              Allowance['percentange'].toString().toLowerCase().contains(query) ||
              Allowance['expance_date'].toString().toLowerCase().contains(query);
        }).toList();
      }
      _animationController.forward(from: 0);
    });
  }



  // New: Show Delete Confirmation Dialog
  void _showDeleteConfirmation(String allowanceId) {
    bool isDeleting = false;


    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissal by tapping outside
      builder: (context) {
        TextEditingController controller = TextEditingController();
        bool isPasswordVisible = false;
        String enteredPassword = '';
        bool isLoading = false; // For delete button loading state
        bool isDeleteEnabled = false; // Enable delete only after valid password entry

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 8,
              backgroundColor: Colors.white,
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.redAccent,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Text(
                          "Delete Allowance",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                        Text(
                          "This action is permanent",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.withOpacity(0.1)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.redAccent, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: const Text(
                            "Are you sure you want to delete this item? This action cannot be undone and will remove it from your list forever.",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Secure Confirmation",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: controller,
                    obscureText: !isPasswordVisible,
                    style: const TextStyle(fontSize: 18),
                    decoration: InputDecoration(
                      labelText: 'Enter your secure password',
                      labelStyle: TextStyle(color: Colors.grey.shade600),
                      prefixIcon: Icon(Icons.lock_outline, color: Colors.red),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          setState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.purple.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.redAccent, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    onChanged: (value) {
                      enteredPassword = value;
                      setState(() {
                        isDeleteEnabled = value.length >= 6;
                      });
                    },
                  ),
                  if (!isDeleteEnabled)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        "Password must be at least 6 characters",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                ],
              ),
              actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  child:  Text(
                    "Cancel",
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: isDeleteEnabled && !isLoading
                      ? () async {
                    setState(() {
                      isLoading = true;
                    });

                    await Future.delayed(const Duration(milliseconds: 800));

                    if (enteredPassword.isNotEmpty) {
                      try {
                        // ✅ Call your delete API here
                        await deleteAllowance(allowanceId,enteredPassword);

                        Navigator.pop(context);
                        // Fluttertoast.showToast(
                        //   msg: "Allowance deleted successfully!",
                        //   toastLength: Toast.LENGTH_SHORT,
                        //   gravity: ToastGravity.BOTTOM,
                        //   backgroundColor: Colors.green,
                        //   textColor: Colors.white,
                        //   fontSize: 14.0,
                        // );
                      } catch (e) {
                        Fluttertoast.showToast(
                          msg: "Failed to delete allowance: $e",
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.CENTER,
                          backgroundColor: Colors.redAccent,
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                      } finally {
                        setState(() {
                          isLoading = false;
                        });
                      }
                    } else {
                      setState(() {
                        isLoading = false;
                      });
                      Fluttertoast.showToast(
                        msg: "Invalid password. Please try again.",
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.CENTER,
                        backgroundColor: Colors.redAccent,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                    }
                  }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: isDeleteEnabled ? 3 : 0,
                  ),
                  child: isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.delete, color: Colors.white, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'Delete',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    // showDialog(
    //   context: context,
    //   builder: (context) => StatefulBuilder(
    //     builder: (context, setState) => AlertDialog(
    //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    //       backgroundColor: Colors.white,
    //       elevation: 8,
    //       title: Row(
    //         children: [
    //           Icon(
    //             Icons.delete_forever,
    //             color: Colors.red,
    //             size: 28,
    //           ),
    //           SizedBox(width: 8),
    //           Text(
    //             'Delete Allowance',
    //             style: GoogleFonts.poppins(
    //               fontWeight: FontWeight.w600,
    //               fontSize: 18,
    //               color: Colors.black87,
    //             ),
    //           ),
    //         ],
    //       ),
    //       content: Padding(
    //         padding: const EdgeInsets.symmetric(vertical: 12.0),
    //         child: Text(
    //           'Are you sure you want to delete this allowance? This action cannot be undone.',
    //           style: GoogleFonts.poppins(
    //             fontSize: 14,
    //             color: Colors.black54,
    //           ),
    //         ),
    //       ),
    //       actions: [
    //         TextButton(
    //           onPressed: isDeleting ? null : () => Navigator.pop(context),
    //           child: Text(
    //             'Cancel',
    //             style: GoogleFonts.poppins(
    //               color: Colors.grey[600],
    //               fontWeight: FontWeight.w500,
    //             ),
    //           ),
    //         ),
    //         ElevatedButton(
    //           onPressed: isDeleting
    //               ? null
    //               : () async {
    //             setState(() => isDeleting = true);
    //             try {
    //               await deleteAllowance(allowanceId);
    //               Navigator.pop(context);
    //               // ScaffoldMessenger.of(context).showSnackBar(
    //               //   SnackBar(
    //               //     content: Text('Allowance deleted successfully'),
    //               //     backgroundColor: Colors.green,
    //               //   ),
    //               // );
    //             } catch (e) {
    //               ScaffoldMessenger.of(context).showSnackBar(
    //                 SnackBar(
    //                   content: Text('Failed to delete allowance: $e'),
    //                   backgroundColor: Colors.red,
    //                 ),
    //               );
    //             } finally {
    //               setState(() => isDeleting = false);
    //             }
    //           },
    //           style: ElevatedButton.styleFrom(
    //             backgroundColor: Colors.red,
    //             shape: RoundedRectangleBorder(
    //               borderRadius: BorderRadius.circular(10),
    //             ),
    //             padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    //           ),
    //           child: isDeleting
    //               ? SizedBox(
    //             width: 20,
    //             height: 20,
    //             child: CircularProgressIndicator(
    //               color: Colors.white,
    //               strokeWidth: 2,
    //             ),
    //           )
    //               : Row(
    //             mainAxisSize: MainAxisSize.min,
    //             children: [
    //               Icon(Icons.delete, color: Colors.white, size: 18),
    //               SizedBox(width: 4),
    //               Text(
    //                 'Delete',
    //                 style: GoogleFonts.poppins(
    //                   color: Colors.white,
    //                   fontWeight: FontWeight.w500,
    //                 ),
    //               ),
    //             ],
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }


  @override
  void dispose() {
    _animationController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bottomBg,
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 65.sp),
        child: ElevatedButton(
          onPressed: () async {

            final allowanceDialog = AllowanceDialog();
            final result = await allowanceDialog.show(context); // Show dialog and wait for result
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
                FontAwesomeIcons.plus,
                size: 18.sp,
                color: Colors.white,
              ),
              SizedBox(width: 5.sp),
              Text(
                'Add Allowance',
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
          padding: EdgeInsets.symmetric(horizontal: 0.sp, vertical: 20.sp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: EdgeInsets.all(8.sp),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ALLOWANCE LIST (${filteredExpenses.length})',
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
                            (states) => Colors.grey[100]!),
                    dataRowColor: MaterialStateColor.resolveWith(
                            (states) => states.contains(MaterialState.selected)
                            ? Colors.grey[50]!
                            : Colors.white),
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
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: HexColor('#4B5563'),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Name',
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: HexColor('#4B5563'),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Type',
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: HexColor('#4B5563'),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Amount',
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: HexColor('#4B5563'),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Percentange',
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: HexColor('#4B5563'),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Status',
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: HexColor('#4B5563'),
                          ),
                        ),
                      ),
                      // New: Action Column
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
                      final Allowance = filteredExpenses[index];
                      return DataRow(
                        color: MaterialStateColor.resolveWith(
                                (states) => index % 2 == 0
                                ? Colors.white
                                : Colors.grey[50]!),
                        cells: [
                          DataCell(
                            Center(
                              child: Text(
                                '${(index + 1).toString()}.',
                                style: GoogleFonts.poppins(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: HexColor('#1F2937'),
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              '${Allowance['name'].toString()}',
                              style: GoogleFonts.poppins(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: HexColor('#1F2937'),
                              ),
                            ),
                          ),
                          DataCell(
                            Center(
                              child: Text(
                                Allowance['type'] == 'amount' ? '₹ ' : '%',
                                style: GoogleFonts.poppins(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: HexColor('#1F2937'),
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Center(
                              child: Text(
                                (Allowance['amount'] ?? '--').toString(),
                                style: GoogleFonts.poppins(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: HexColor('#1F2937'),
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ),
                          DataCell(
                            Center(
                              child: Text(
                                Allowance['percentange'] != null
                                    ? '${Allowance['percentange']} %'
                                    : '--',
                                style: GoogleFonts.poppins(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: HexColor('#1F2937'),
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Center(
                              child: Chip(
                                label: Text(
                                  Allowance['status'] == 1
                                      ? 'Active'
                                      : 'Inactive',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Allowance['status'] == 1
                                        ? HexColor('#069c06')
                                        : Colors.red.shade600,
                                  ),
                                ),
                                backgroundColor: Allowance['status'] == 1
                                    ? HexColor('#E6F7E6')
                                    : Colors.red.shade50,
                                padding: EdgeInsets.zero,
                                labelPadding: EdgeInsets.symmetric(
                                    horizontal: 10.sp),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          // New: Action Cell
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit,
                                      size: 20.sp, color: Colors.blue),
                                  onPressed: () =>
                                      showDialog(
                                        context: context,
                                        builder: (context) => CustomConfirmationDialog(
                                          title: "Edit Allowance",
                                          message: "Are you sure you want to save the changes?",
                                          onConfirm: () async {
                                            Navigator.pop(context);
                                            final editExpenseDialog = EditAllowanceDialog();
                                            final result = await editExpenseDialog.show(context, Allowance['name'].toString(),
                                              Allowance['type'].toString(),
                                              Allowance['amount'].toString(),
                                              Allowance['percentange'].toString(),
                                              Allowance['id'].toString(),
                                            ); // Show dialog and wait for result
                                            if (result) {
                                            // Refresh the list if allowance was added successfully
                                            await fetchExpenseData();
                                            }

                                          },
                                          onYes: () {
                                            Navigator.pop(context);


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
                                  onPressed: () => _showDeleteConfirmation(Allowance['id'].toString()),
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
        color: AppColors.bgYellow,
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
  _CustomConfirmationDialogState createState() => _CustomConfirmationDialogState();
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
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.redAccent, Colors.redAccent.shade100],
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
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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