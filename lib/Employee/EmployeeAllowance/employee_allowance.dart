import 'dart:convert';
import 'package:animate_do/animate_do.dart';
import 'package:aoneadmin/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:searchable_paginated_dropdown/searchable_paginated_dropdown.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import '../../HexColorCode/HexColor.dart';
import '../../app_colors.dart';
import '../../textSize.dart';

class EmployeeAllowanceListScreen extends StatefulWidget {
  const EmployeeAllowanceListScreen({
    super.key,
  });

  @override
  State<EmployeeAllowanceListScreen> createState() =>
      _AllIndiaRankScreenState();
}

class _AllIndiaRankScreenState extends State<EmployeeAllowanceListScreen> {
  String? selectedCourse;
  String? selectedCategory;
  bool isLoading = false;
  List<dynamic> counseling = [];
  List<dynamic> courseList = [];
  List categoryExpenses = [];
  List deducation = [];
  List employeeDeductions = [];
  List<int> _selectedDeduction = [];
  Map<String, dynamic>? _selectedCategory; // Store the entire category object
  bool isLoading2 = false;
  bool isLoading3 = false;

  @override
  void initState() {
    super.initState();
    fetchExpenseCategoryData();
    fetchDeductionListData();
    fetchDeductionList();
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

  Future<void> fetchDeductionListData() async {
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
        deducation = data['data'];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load deducation')),
      );
    }
  }

  Future<void> fetchDeductionList() async {
    setState(() {
      isLoading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse(ApiRoutes.employeeAllowanceList),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        employeeDeductions = data['employees'];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load deducation')),
      );
    }
  }

  Future<bool> deductionStore() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    var url = Uri.parse(ApiRoutes.employeeDeductionStore); // Adjust endpoint
    print(_selectedCategory);

    try {
      // Ensure _selectedCategory and _recovery are not null
      if (_selectedCategory == null || _selectedDeduction == null) {
        print('Error: _selectedCategory or _recovery is null');
        return false;
      }

      // Prepare the JSON payload
      final payload = {
        'employee_id': _selectedCategory!['id'].toString(),
        'deductions': _selectedDeduction
      };

      var response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        print('Response Data: $data');

        setState(() {
          _selectedDeduction = []; // Clear the selected items
        });

        fetchDeductionList();

        return true;
      } else {
        print('Failed: ${response.statusCode}');
        print('Body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = screenWidth * 0.04;

    return Theme(
      data: ThemeData(
        primaryColor: Color(0xFF124559),
        colorScheme: ColorScheme.light(
          primary: Color(0xFF124559),
          secondary: Color(0xFF124559),
        ),
        textTheme: TextTheme(
          bodyMedium: TextStyle(fontSize: fontSize, color: Colors.black87),
          labelLarge:
          TextStyle(fontSize: fontSize + 2, fontWeight: FontWeight.w600),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFF124559), width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          errorStyle:
          TextStyle(color: Colors.redAccent, fontSize: fontSize - 2),
        ),
      ),
      child: Scaffold(
          backgroundColor: AppColors.bottomBg,
          body:Column(
            children: [
              Container(
                margin: EdgeInsets.all(10.sp),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Padding(
                  padding: EdgeInsets.all(10.sp),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCategoryDropdown(context, setState),
                      SizedBox(height: 10.sp),
                      _buildCategoryDropdown2(context, setState),
                      SizedBox(height: 10.sp),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Card(
                              elevation: 5,
                              color: HexColor('#124559'),
                              child: InkWell(
                                onTap: () async {
                                  setState(() {
                                    isLoading2 = true;
                                  });
                                  try {
                                    await deductionStore();
                                  } finally {
                                    setState(() {
                                      isLoading2 = false;
                                    });
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (isLoading2)
                                        CircularProgressIndicator(
                                          valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                              Colors.white),
                                          strokeWidth: 3,
                                        )
                                      else
                                        Text(
                                          'Set Allowance'.toUpperCase(),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                    ],
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
              Padding(
                padding: const EdgeInsets.only(top: 0, bottom: 10,left: 10),
                child: Row(
                  children: [
                    FaIcon(
                      FontAwesomeIcons.list,
                      color: Colors.black,
                      size: 17.sp,
                    ),
                    SizedBox(width: 5.sp),
                    Text(
                      'Allowance List',
                      style: TextStyle(
                        fontSize: fontSize + 3,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: isLoading
                    ? Center(
                  child: CircularProgressIndicator(
                    color: primaryColor,
                  ), // Show progress bar here
                )
                    : Padding(
                  padding:  EdgeInsets.only(bottom: 50.sp),
                  child: ListView.builder(
                    itemCount: employeeDeductions.length,
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) {
                      var college = employeeDeductions[index];
                      return GestureDetector(
                          onTap: () {},
                          child: Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 5),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white,
                                  Colors.grey[50]!
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  offset: Offset(4, 4),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                                BoxShadow(
                                  color:
                                  Colors.white.withOpacity(0.7),
                                  offset: Offset(-4, -4),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                              // border: Border(
                              //   left: BorderSide(color: color[colorIndex], width: 4),
                              // ),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 0),
                              leading: AnimatedContainer(
                                duration: Duration(milliseconds: 300),
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color:
                                  Colors.purple.withOpacity(0.15),
                                  borderRadius:
                                  BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.purple
                                          .withOpacity(0.2),
                                      blurRadius: 4,
                                      offset: Offset(2, 2),
                                    ),
                                  ],
                                ),
                                child: FaIcon(FontAwesomeIcons.wallet,
                                  color: Colors.purple,

                                ),
                              ),
                              title: Text(
                                college['name'] ??
                                    'Unknown Institute',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                  color: Colors.black87,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  // SizedBox(height: 6),
                                  Text(
                                    college["deduction"] != null
                                        ? college["deduction"]
                                    ['name'] ??
                                        ''
                                        : '',
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ), // SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.green[100],
                                          borderRadius:
                                          BorderRadius.circular(
                                              4),
                                        ),
                                        child: Text(
                                          '₹ ${college["amount"]?.toStringAsFixed(2) ?? '0.00'}',
                                          style: TextStyle(
                                            color: Colors.green[800],
                                            fontSize: 12,
                                            fontWeight:
                                            FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.edit,
                                    color: Colors.blue[600],
                                    size: 24),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      final nameController =
                                      TextEditingController(
                                        text: college['name'] ??
                                            'Unknown Institute',
                                      );
                                      final deductionController =
                                      TextEditingController(
                                        text: college["allowances"]['name'] ??
                                            'Unknown Course',
                                      );
                                      final priceController =
                                      TextEditingController(
                                        text: college["amount"]
                                            ?.toString() ??
                                            '0',
                                      );
                                      return Dialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(
                                              16),
                                        ),
                                        elevation: 0,
                                        backgroundColor:
                                        Colors.transparent,
                                        child: Stack(
                                          children: [
                                            Container(
                                              padding:
                                              EdgeInsets.all(20),
                                              margin: EdgeInsets.only(
                                                  top: 20),
                                              decoration:
                                              BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                BorderRadius
                                                    .circular(16),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors
                                                        .black
                                                        .withOpacity(
                                                        0.1),
                                                    blurRadius: 10,
                                                    offset:
                                                    Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                              child:
                                              SingleChildScrollView(
                                                child: Column(
                                                  mainAxisSize:
                                                  MainAxisSize
                                                      .min,
                                                  children: [
                                                    Text(
                                                      'Edit College Details',
                                                      style:
                                                      TextStyle(
                                                        fontWeight:
                                                        FontWeight
                                                            .w700,
                                                        fontSize: 18,
                                                        color: Colors
                                                            .black87,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                        height: 16),
                                                    TextField(
                                                      controller:
                                                      nameController,
                                                      decoration:
                                                      InputDecoration(
                                                        labelText:
                                                        'College Name',
                                                        border:
                                                        OutlineInputBorder(
                                                          borderRadius:
                                                          BorderRadius
                                                              .circular(8),
                                                        ),
                                                        filled: true,
                                                        fillColor:
                                                        Colors.grey[
                                                        50],
                                                      ),
                                                    ),
                                                    SizedBox(
                                                        height: 12),
                                                    TextField(
                                                      controller:
                                                      deductionController,
                                                      decoration:
                                                      InputDecoration(
                                                        labelText:
                                                        'Deduction Name',
                                                        border:
                                                        OutlineInputBorder(
                                                          borderRadius:
                                                          BorderRadius
                                                              .circular(8),
                                                        ),
                                                        filled: true,
                                                        fillColor:
                                                        Colors.grey[
                                                        50],
                                                      ),
                                                    ),
                                                    SizedBox(
                                                        height: 12),
                                                    TextField(
                                                      controller:
                                                      priceController,
                                                      decoration:
                                                      InputDecoration(
                                                        labelText:
                                                        'Price',
                                                        border:
                                                        OutlineInputBorder(
                                                          borderRadius:
                                                          BorderRadius
                                                              .circular(8),
                                                        ),
                                                        prefixText:
                                                        '₹ ',
                                                        filled: true,
                                                        fillColor:
                                                        Colors.grey[
                                                        50],
                                                      ),
                                                      keyboardType:
                                                      TextInputType
                                                          .number,
                                                    ),
                                                    SizedBox(
                                                        height: 20),
                                                    Row(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .end,
                                                      children: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                  context),
                                                          child: Text(
                                                            'Cancel',
                                                            style: TextStyle(
                                                                color:
                                                                Colors.grey[600]),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                            width: 8),
                                                        ElevatedButton(
                                                          onPressed: isLoading3
                                                              ? null  // Disable button when loading
                                                              : () async {
                                                            college['name'] = nameController.text;
                                                            college["deduction"]['name'] = deductionController.text;
                                                            college["price"] = double.tryParse(priceController.text) ?? 0.0;

                                                            setState(() {
                                                              isLoading3 = true;
                                                            });

                                                            try {
                                                              final prefs = await SharedPreferences.getInstance();
                                                              final token = prefs.getString('token');
                                                              final requestBody = {
                                                                'amount': college["price"],
                                                              };

                                                              final response = await http.post(
                                                                Uri.parse('${ApiRoutes.employeeDeductionUpdate}/${college["id"].toString()}'),
                                                                headers: {
                                                                  'Content-Type': 'application/json',
                                                                  'Authorization': 'Bearer $token',
                                                                },
                                                                body: jsonEncode(requestBody),
                                                              );

                                                              if (response.statusCode == 200) {
                                                                Navigator.pop(context);
                                                                (context as Element).markNeedsBuild();
                                                                fetchDeductionList();
                                                              } else {
                                                                ScaffoldMessenger.of(context).showSnackBar(
                                                                  SnackBar(content: Text('Failed to update: ${response.body}')),
                                                                );
                                                              }
                                                            } finally {
                                                              setState(() {
                                                                isLoading3 = false;
                                                              });
                                                            }
                                                          },
                                                          style: ElevatedButton.styleFrom(
                                                            backgroundColor: Colors.blue[600],
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(8),
                                                            ),
                                                            padding: EdgeInsets.symmetric(horizontal: 16),
                                                          ),
                                                          child: isLoading3
                                                              ? SizedBox(
                                                            height: 20,  // Match your text height
                                                            width: 20,   // Match your text height
                                                            child: CircularProgressIndicator(
                                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                              strokeWidth: 3,
                                                            ),
                                                          )
                                                              : Text(
                                                            'Update'.toUpperCase(),
                                                            style: TextStyle(color: Colors.white),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              top: 0,
                                              left: 20,
                                              right: 20,
                                              child: CircleAvatar(
                                                backgroundColor:
                                                Colors.blue[100],
                                                radius: 24,
                                                child: Icon(
                                                  Icons.edit,
                                                  color: Colors
                                                      .blue[600],
                                                  size: 24,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ));
                    },
                  ),
                ),
              ),
            ],
          )





        // Stack(
        //   children: [
        //     CustomScrollView(
        //       slivers: [
        //         SliverPadding(
        //           padding: EdgeInsets.symmetric(vertical: 5.sp),
        //         ),
        //         SliverPadding(
        //           padding: EdgeInsets.symmetric(horizontal: 5.sp),
        //           sliver: SliverList(
        //             delegate: SliverChildListDelegate([
        //               Container(
        //                 decoration: BoxDecoration(
        //                   color: Colors.white,
        //                   borderRadius: BorderRadius.circular(25),
        //                 ),
        //                 child: Padding(
        //                   padding: EdgeInsets.all(10.sp),
        //                   child: Column(
        //                     crossAxisAlignment: CrossAxisAlignment.start,
        //                     children: [
        //                       _buildCategoryDropdown(context, setState),
        //                       SizedBox(height: 10.sp),
        //                       _buildCategoryDropdown2(context, setState),
        //                       SizedBox(height: 10.sp),
        //                       Row(
        //                         mainAxisAlignment:
        //                             MainAxisAlignment.spaceBetween,
        //                         children: [
        //                           Expanded(
        //                             child: Card(
        //                               elevation: 5,
        //                               color: HexColor('#124559'),
        //                               child: InkWell(
        //                                 onTap: () async {
        //                                   setState(() {
        //                                     isLoading2 = true;
        //                                   });
        //                                   try {
        //                                     await deductionStore();
        //                                   } finally {
        //                                     setState(() {
        //                                       isLoading2 = false;
        //                                     });
        //                                   }
        //                                 },
        //                                 child: Padding(
        //                                   padding: const EdgeInsets.all(12.0),
        //                                   child: Row(
        //                                     mainAxisAlignment:
        //                                         MainAxisAlignment.center,
        //                                     children: [
        //                                       if (isLoading2)
        //                                         CircularProgressIndicator(
        //                                           valueColor:
        //                                               AlwaysStoppedAnimation<
        //                                                   Color>(Colors.white),
        //                                           strokeWidth: 3,
        //                                         )
        //                                       else
        //                                         Text(
        //                                           'Set Deduction'.toUpperCase(),
        //                                           style: TextStyle(
        //                                             color: Colors.white,
        //                                             fontSize: 16.sp,
        //                                             fontWeight: FontWeight.bold,
        //                                           ),
        //                                         ),
        //                                     ],
        //                                   ),
        //                                 ),
        //                               ),
        //                             ),
        //                           ),
        //                         ],
        //                       ),
        //                     ],
        //                   ),
        //                 ),
        //               ),
        //               Padding(
        //                 padding: const EdgeInsets.only(top: 16, bottom: 0),
        //                 child: Row(
        //                   children: [
        //                     FaIcon(
        //                       FontAwesomeIcons.list,
        //                       color: Colors.black,
        //                       size: 17.sp,
        //                     ),
        //                     SizedBox(width: 5.sp),
        //                     Text(
        //                       'Deduction List',
        //                       style: TextStyle(
        //                         fontSize: fontSize + 3,
        //                         fontWeight: FontWeight.w800,
        //                         color: Colors.black,
        //                       ),
        //                     ),
        //                   ],
        //                 ),
        //               ),
        //               isLoading
        //                   ? Center(
        //                       child: CircularProgressIndicator(
        //                         color: primaryColor,
        //                       ), // Show progress bar here
        //                     )
        //                   : ListView.builder(
        //                       itemCount: employeeDeductions.length,
        //                       shrinkWrap: true,
        //                       physics: NeverScrollableScrollPhysics(),
        //                       padding: EdgeInsets.zero,
        //                       itemBuilder: (context, index) {
        //                         var college = employeeDeductions[index];
        //                         return GestureDetector(
        //                             onTap: () {},
        //                             child: Container(
        //                               margin: EdgeInsets.symmetric(
        //                                   horizontal: 8, vertical: 5),
        //                               decoration: BoxDecoration(
        //                                 gradient: LinearGradient(
        //                                   colors: [
        //                                     Colors.white,
        //                                     Colors.grey[50]!
        //                                   ],
        //                                   begin: Alignment.topLeft,
        //                                   end: Alignment.bottomRight,
        //                                 ),
        //                                 borderRadius: BorderRadius.circular(12),
        //                                 boxShadow: [
        //                                   BoxShadow(
        //                                     color: Colors.grey.withOpacity(0.2),
        //                                     offset: Offset(4, 4),
        //                                     blurRadius: 8,
        //                                     spreadRadius: 1,
        //                                   ),
        //                                   BoxShadow(
        //                                     color:
        //                                         Colors.white.withOpacity(0.7),
        //                                     offset: Offset(-4, -4),
        //                                     blurRadius: 8,
        //                                     spreadRadius: 1,
        //                                   ),
        //                                 ],
        //                                 // border: Border(
        //                                 //   left: BorderSide(color: color[colorIndex], width: 4),
        //                                 // ),
        //                               ),
        //                               child: ListTile(
        //                                 contentPadding: EdgeInsets.symmetric(
        //                                     horizontal: 5, vertical: 0),
        //                                 leading: AnimatedContainer(
        //                                   duration: Duration(milliseconds: 300),
        //                                   padding: EdgeInsets.all(10),
        //                                   decoration: BoxDecoration(
        //                                     color:
        //                                         Colors.purple.withOpacity(0.15),
        //                                     borderRadius:
        //                                         BorderRadius.circular(8),
        //                                     boxShadow: [
        //                                       BoxShadow(
        //                                         color: Colors.purple
        //                                             .withOpacity(0.2),
        //                                         blurRadius: 4,
        //                                         offset: Offset(2, 2),
        //                                       ),
        //                                     ],
        //                                   ),
        //                                   child: Icon(
        //                                     CupertinoIcons.scissors_alt,
        //                                     color: Colors.purple,
        //                                     size: 24,
        //                                   ),
        //                                 ),
        //                                 title: Text(
        //                                   college["user"]['name'] ??
        //                                       'Unknown Institute',
        //                                   style: TextStyle(
        //                                     fontWeight: FontWeight.w800,
        //                                     fontSize: 16,
        //                                     color: Colors.black87,
        //                                     letterSpacing: 0.5,
        //                                   ),
        //                                 ),
        //                                 subtitle: Column(
        //                                   crossAxisAlignment:
        //                                       CrossAxisAlignment.start,
        //                                   children: [
        //                                     // SizedBox(height: 6),
        //                                     Text(
        //                                       college["deduction"] != null
        //                                           ? college["deduction"]
        //                                                   ['name'] ??
        //                                               ''
        //                                           : '',
        //                                       style: TextStyle(
        //                                         color: Colors.grey[700],
        //                                         fontSize: 13,
        //                                         fontWeight: FontWeight.w500,
        //                                       ),
        //                                     ), // SizedBox(height: 4),
        //                                     Row(
        //                                       children: [
        //                                         Container(
        //                                           padding: EdgeInsets.symmetric(
        //                                               horizontal: 6,
        //                                               vertical: 2),
        //                                           decoration: BoxDecoration(
        //                                             color: Colors.green[100],
        //                                             borderRadius:
        //                                                 BorderRadius.circular(
        //                                                     4),
        //                                           ),
        //                                           child: Text(
        //                                             '₹ ${college["amount"]?.toStringAsFixed(2) ?? '0.00'}',
        //                                             style: TextStyle(
        //                                               color: Colors.green[800],
        //                                               fontSize: 12,
        //                                               fontWeight:
        //                                                   FontWeight.w600,
        //                                             ),
        //                                           ),
        //                                         ),
        //                                       ],
        //                                     ),
        //                                   ],
        //                                 ),
        //                                 trailing: IconButton(
        //                                   icon: Icon(Icons.edit,
        //                                       color: Colors.blue[600],
        //                                       size: 24),
        //                                   onPressed: () {
        //                                     showDialog(
        //                                       context: context,
        //                                       builder: (context) {
        //                                         final nameController =
        //                                             TextEditingController(
        //                                           text: college["user"]
        //                                                   ['name'] ??
        //                                               'Unknown Institute',
        //                                         );
        //                                         final deductionController =
        //                                             TextEditingController(
        //                                           text: college["deduction"]
        //                                                   ['name'] ??
        //                                               'Unknown Course',
        //                                         );
        //                                         final priceController =
        //                                             TextEditingController(
        //                                           text: college["amount"]
        //                                                   ?.toString() ??
        //                                               '0',
        //                                         );
        //                                         return Dialog(
        //                                           shape: RoundedRectangleBorder(
        //                                             borderRadius:
        //                                                 BorderRadius.circular(
        //                                                     16),
        //                                           ),
        //                                           elevation: 0,
        //                                           backgroundColor:
        //                                               Colors.transparent,
        //                                           child: Stack(
        //                                             children: [
        //                                               Container(
        //                                                 padding:
        //                                                     EdgeInsets.all(20),
        //                                                 margin: EdgeInsets.only(
        //                                                     top: 20),
        //                                                 decoration:
        //                                                     BoxDecoration(
        //                                                   color: Colors.white,
        //                                                   borderRadius:
        //                                                       BorderRadius
        //                                                           .circular(16),
        //                                                   boxShadow: [
        //                                                     BoxShadow(
        //                                                       color: Colors
        //                                                           .black
        //                                                           .withOpacity(
        //                                                               0.1),
        //                                                       blurRadius: 10,
        //                                                       offset:
        //                                                           Offset(0, 4),
        //                                                     ),
        //                                                   ],
        //                                                 ),
        //                                                 child:
        //                                                     SingleChildScrollView(
        //                                                   child: Column(
        //                                                     mainAxisSize:
        //                                                         MainAxisSize
        //                                                             .min,
        //                                                     children: [
        //                                                       Text(
        //                                                         'Edit College Details',
        //                                                         style:
        //                                                             TextStyle(
        //                                                           fontWeight:
        //                                                               FontWeight
        //                                                                   .w700,
        //                                                           fontSize: 18,
        //                                                           color: Colors
        //                                                               .black87,
        //                                                         ),
        //                                                       ),
        //                                                       SizedBox(
        //                                                           height: 16),
        //                                                       TextField(
        //                                                         controller:
        //                                                             nameController,
        //                                                         decoration:
        //                                                             InputDecoration(
        //                                                           labelText:
        //                                                               'College Name',
        //                                                           border:
        //                                                               OutlineInputBorder(
        //                                                             borderRadius:
        //                                                                 BorderRadius
        //                                                                     .circular(8),
        //                                                           ),
        //                                                           filled: true,
        //                                                           fillColor:
        //                                                               Colors.grey[
        //                                                                   50],
        //                                                         ),
        //                                                       ),
        //                                                       SizedBox(
        //                                                           height: 12),
        //                                                       TextField(
        //                                                         controller:
        //                                                             deductionController,
        //                                                         decoration:
        //                                                             InputDecoration(
        //                                                           labelText:
        //                                                               'Deduction Name',
        //                                                           border:
        //                                                               OutlineInputBorder(
        //                                                             borderRadius:
        //                                                                 BorderRadius
        //                                                                     .circular(8),
        //                                                           ),
        //                                                           filled: true,
        //                                                           fillColor:
        //                                                               Colors.grey[
        //                                                                   50],
        //                                                         ),
        //                                                       ),
        //                                                       SizedBox(
        //                                                           height: 12),
        //                                                       TextField(
        //                                                         controller:
        //                                                             priceController,
        //                                                         decoration:
        //                                                             InputDecoration(
        //                                                           labelText:
        //                                                               'Price',
        //                                                           border:
        //                                                               OutlineInputBorder(
        //                                                             borderRadius:
        //                                                                 BorderRadius
        //                                                                     .circular(8),
        //                                                           ),
        //                                                           prefixText:
        //                                                               '₹ ',
        //                                                           filled: true,
        //                                                           fillColor:
        //                                                               Colors.grey[
        //                                                                   50],
        //                                                         ),
        //                                                         keyboardType:
        //                                                             TextInputType
        //                                                                 .number,
        //                                                       ),
        //                                                       SizedBox(
        //                                                           height: 20),
        //                                                       Row(
        //                                                         mainAxisAlignment:
        //                                                             MainAxisAlignment
        //                                                                 .end,
        //                                                         children: [
        //                                                           TextButton(
        //                                                             onPressed: () =>
        //                                                                 Navigator.pop(
        //                                                                     context),
        //                                                             child: Text(
        //                                                               'Cancel',
        //                                                               style: TextStyle(
        //                                                                   color:
        //                                                                       Colors.grey[600]),
        //                                                             ),
        //                                                           ),
        //                                                           SizedBox(
        //                                                               width: 8),
        //                                                           ElevatedButton(
        //                                                             onPressed: isLoading3
        //                                                                 ? null  // Disable button when loading
        //                                                                 : () async {
        //                                                               college["user"]['name'] = nameController.text;
        //                                                               college["deduction"]['name'] = deductionController.text;
        //                                                               college["price"] = double.tryParse(priceController.text) ?? 0.0;
        //
        //                                                               setState(() {
        //                                                                 isLoading3 = true;
        //                                                               });
        //
        //                                                               try {
        //                                                                 final prefs = await SharedPreferences.getInstance();
        //                                                                 final token = prefs.getString('token');
        //                                                                 final requestBody = {
        //                                                                   'amount': college["price"],
        //                                                                 };
        //
        //                                                                 final response = await http.post(
        //                                                                   Uri.parse('${ApiRoutes.employeeDeductionUpdate}/${college["id"].toString()}'),
        //                                                                   headers: {
        //                                                                     'Content-Type': 'application/json',
        //                                                                     'Authorization': 'Bearer $token',
        //                                                                   },
        //                                                                   body: jsonEncode(requestBody),
        //                                                                 );
        //
        //                                                                 if (response.statusCode == 200) {
        //                                                                   Navigator.pop(context);
        //                                                                   (context as Element).markNeedsBuild();
        //                                                                   fetchDeductionList();
        //                                                                 } else {
        //                                                                   ScaffoldMessenger.of(context).showSnackBar(
        //                                                                     SnackBar(content: Text('Failed to update: ${response.body}')),
        //                                                                   );
        //                                                                 }
        //                                                               } finally {
        //                                                                 setState(() {
        //                                                                   isLoading3 = false;
        //                                                                 });
        //                                                               }
        //                                                             },
        //                                                             style: ElevatedButton.styleFrom(
        //                                                               backgroundColor: Colors.blue[600],
        //                                                               shape: RoundedRectangleBorder(
        //                                                                 borderRadius: BorderRadius.circular(8),
        //                                                               ),
        //                                                               padding: EdgeInsets.symmetric(horizontal: 16),
        //                                                             ),
        //                                                             child: isLoading3
        //                                                                 ? SizedBox(
        //                                                               height: 20,  // Match your text height
        //                                                               width: 20,   // Match your text height
        //                                                               child: CircularProgressIndicator(
        //                                                                 valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        //                                                                 strokeWidth: 3,
        //                                                               ),
        //                                                             )
        //                                                                 : Text(
        //                                                               'Update'.toUpperCase(),
        //                                                               style: TextStyle(color: Colors.white),
        //                                                             ),
        //                                                           ),
        //                                                         ],
        //                                                       ),
        //                                                     ],
        //                                                   ),
        //                                                 ),
        //                                               ),
        //                                               Positioned(
        //                                                 top: 0,
        //                                                 left: 20,
        //                                                 right: 20,
        //                                                 child: CircleAvatar(
        //                                                   backgroundColor:
        //                                                       Colors.blue[100],
        //                                                   radius: 24,
        //                                                   child: Icon(
        //                                                     Icons.edit,
        //                                                     color: Colors
        //                                                         .blue[600],
        //                                                     size: 24,
        //                                                   ),
        //                                                 ),
        //                                               ),
        //                                             ],
        //                                           ),
        //                                         );
        //                                       },
        //                                     );
        //                                   },
        //                                 ),
        //                               ),
        //                             ));
        //                       },
        //                     ),
        //             ]),
        //           ),
        //         ),
        //       ],
        //     ),
        //   ],
        // ),
      ),
    );
  }

  Widget _buildCategoryDropdown(BuildContext context, StateSetter setState) {
    // if (_isLoadingCategories) {
    //   return Center(child: CircularProgressIndicator());
    // }
    //
    // if (categoryExpenses.isEmpty) {
    //   return Text(
    //     'No categories available',
    //     style: GoogleFonts.poppins(
    //       fontSize: TextSizes.text14,
    //       color: Colors.red,
    //     ),
    //   );
    // }

    return DropdownButtonFormField<Map<String, dynamic>>(
      icon: Icon(
        Icons.keyboard_arrow_down,
        size: 20.sp,
        color: AppColors.subTitleBlack,
      ),
      decoration: InputDecoration(
        labelStyle: GoogleFonts.poppins(
          textStyle: Theme.of(context).textTheme.displayLarge,
          fontSize: TextSizes.text15,
          fontWeight: FontWeight.w600,
          color: AppColors.subTitleBlack,
        ),
        filled: true,
        fillColor: AppColors.bottomBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 14.h,
        ),
      ),
      hint: Text(
        'Select Employee',
        style: GoogleFonts.poppins(
          textStyle: Theme.of(context).textTheme.displayLarge,
          fontSize: TextSizes.text15,
          fontWeight: FontWeight.w500,
          color: AppColors.subTitleBlack.withOpacity(0.6),
        ),
      ),
      value: _selectedCategory,
      dropdownColor: Colors.white,
      items: categoryExpenses
          .map<DropdownMenuItem<Map<String, dynamic>>>((category) {
        String title = category['name'].toString();
        return DropdownMenuItem<Map<String, dynamic>>(
          value: category, // Store the entire category object
          child: SizedBox(
            height: 30.sp,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  textStyle: Theme.of(context).textTheme.displayLarge,
                  fontSize: TextSizes.text15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.subTitleBlack,
                ),
              ),
            ),
          ),
        );
      }).toList(),
      onChanged: (Map<String, dynamic>? newValue) {
        setState(() {
          _selectedCategory = newValue;
        });
      },
      validator: (value) => value == null ? 'Please select a category' : null,
    );
  }

  Widget _buildCategoryDropdown2(BuildContext context, StateSetter setState) {
    return Stack(
      children: [
        Card(
          color: AppColors.bottomBg,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: MultiSelectDialogField<int>(
              items: deducation
                  .map(
                    (category) => MultiSelectItem<int>(
                  category['id'],
                  category['name'].toString(),
                ),
              )
                  .toList(),
              initialValue: _selectedDeduction,
              onConfirm: (List<int> values) {
                setState(() {
                  _selectedDeduction = values;
                });
              },
              listType: MultiSelectListType.LIST,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(0),
              ),
              chipDisplay: MultiSelectChipDisplay.none(),
              buttonText: Text(
                _selectedDeduction.isEmpty
                    ? 'Select Allowance'
                    : deducation
                    .where((category) =>
                    _selectedDeduction.contains(category['id']))
                    .map((category) => category['name'].toString())
                    .join(', '),
                style: GoogleFonts.poppins(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.subTitleBlack.withOpacity(0.7),
                ),
                overflow: TextOverflow.ellipsis,
              ),
              buttonIcon: const Icon(
                Icons.keyboard_arrow_down,
                size: 0,
                color: Colors.transparent, // Hide icon
              ),
              dialogWidth: MediaQuery.of(context).size.width * 0.85,
              dialogHeight: MediaQuery.of(context).size.height * 0.5,
              title: Text(
                "Choose Deductions",
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.bgYellow,
                ),
              ),
              selectedColor: AppColors.bgYellow.withOpacity(0.2),
            ),
          ),
        ),
        if (_selectedDeduction.isNotEmpty)
          Positioned(
            right: 10,
            top: 10,
            child: IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.redAccent),
              onPressed: () {
                setState(() => _selectedDeduction = []);
              },
            ),
          ),
        if (_selectedDeduction.isEmpty)
          Positioned(
            right: 20,
            top: 25,
            child: Icon(
              Icons.keyboard_arrow_down,
              size: 20.sp,
              color: AppColors.subTitleBlack,
            ),
          ),
      ],
    );
  }
}
