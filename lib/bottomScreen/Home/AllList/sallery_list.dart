import 'dart:convert';
import 'package:aoneadmin/HexColorCode/HexColor.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../DialogClass/addExpenseDialog.dart'; // Adjust path as needed
import '../../../constants.dart'; // Adjust path as needed
import '../../../textSize.dart'; // Adjust path as needed

class SalaryScreen extends StatefulWidget {
  const SalaryScreen({super.key});

  @override
  State<SalaryScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<SalaryScreen>
    with SingleTickerProviderStateMixin {
  final AddExpenseDialog _addExpenseDialog = AddExpenseDialog();
  bool isLoading = false;
  List Salary = [];
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
    filteredExpenses = Salary;
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
      Uri.parse(ApiRoutes.getSalaryList),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        Salary = data['payrolls'];
        filteredExpenses = Salary;
        isLoading = false;
      });
      _animationController.forward(from: 0);
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load Salary')),
      );
    }
  }

  void _filterExpenses() {
    String query = searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredExpenses = Salary;
      } else {
        filteredExpenses = Salary.where((Salary) {
          return Salary['basic_salary'].toString().toLowerCase().contains(query) ||
              Salary['name'].toLowerCase().contains(query) ||
              Salary['net_salary'].toString().toLowerCase().contains(query) ||
              Salary['entry_date'].toString().toLowerCase().contains(query);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bottomBg,
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 65.sp),
        child: ElevatedButton(
          onPressed: () {
            // _addExpenseDialog.show(context).then((_) => fetchExpenseData());
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
                'Add Salary',
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
                padding:  EdgeInsets.all(5.sp),
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
                      borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: AppColors.bgYellow, // Replace with AppColors.bgYellow
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
              // SizedBox(height: 24.sp),
              // Table Title
              FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding:  EdgeInsets.all(8.sp),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Salary List (${filteredExpenses.length})',
                        style: GoogleFonts.poppins(
                          fontSize: TextSizes.text14,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.refresh, size: 24.sp, color: Colors.grey[700]),
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
                            textStyle: Theme.of(context)
                                .textTheme
                                .displayLarge,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            fontStyle: FontStyle.normal,
                            color:HexColor('#4B5563'),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Name',
                          style: GoogleFonts.poppins(
                            textStyle: Theme.of(context)
                                .textTheme
                                .displayLarge,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            fontStyle: FontStyle.normal,
                            color:HexColor('#4B5563'),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Basic Salary',
                          style: GoogleFonts.poppins(
                            textStyle: Theme.of(context)
                                .textTheme
                                .displayLarge,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            fontStyle: FontStyle.normal,
                            color:HexColor('#4B5563'),
                          ),
                        ),
                      ),

                      DataColumn(
                        label: Text(
                          'Date',
                          style: GoogleFonts.poppins(
                            textStyle: Theme.of(context)
                                .textTheme
                                .displayLarge,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            fontStyle: FontStyle.normal,
                            color:HexColor('#4B5563'),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Net Salary',
                          style: GoogleFonts.poppins(
                            textStyle: Theme.of(context)
                                .textTheme
                                .displayLarge,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            fontStyle: FontStyle.normal,
                            color:HexColor('#4B5563'),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Status',
                          style: GoogleFonts.poppins(
                            textStyle: Theme.of(context)
                                .textTheme
                                .displayLarge,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            fontStyle: FontStyle.normal,
                            color:HexColor('#4B5563'),
                          ),
                        ),
                      ),
                    ],
                    rows: List.generate(filteredExpenses.length, (index) {
                      final Salary = filteredExpenses[index];
                      return DataRow(
                        color: MaterialStateColor.resolveWith(
                              (states) => index % 2 == 0
                              ? Colors.white
                              : Colors.grey[50]!,
                        ),
                        cells: [
                          DataCell(
                            Center(
                              child: Text(
                                '${(index + 1).toString()}.',
                                style: GoogleFonts.poppins(
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .displayLarge,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FontStyle.normal,
                                  color:HexColor('#1F2937'),
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              '${Salary['name'].toString()}',
                              style: GoogleFonts.poppins(
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .displayLarge,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                fontStyle: FontStyle.normal,
                                color:HexColor('#1F2937'),
                              ),
                            ),
                          ),
                          DataCell(
                            Center(
                              child: Text(
                               '₹ ${Salary['basic_salary']}',
                                style: GoogleFonts.poppins(
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .displayLarge,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FontStyle.normal,
                                  color:HexColor('#1F2937'),
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                              Center(
                                child: Text(
                                  Salary['entry_date'],
                                  style: GoogleFonts.poppins(
                                    textStyle: Theme.of(context).textTheme.displayLarge,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FontStyle.normal,
                                    color: HexColor('#1F2937'),
                                  ),
                                ),
                              )

                          ),
                          DataCell(
                              Center(
                                child: Text(
                                  '₹ ${Salary['net_salary']}'.toString(),
                                  style: GoogleFonts.poppins(
                                    textStyle: Theme.of(context).textTheme.displayLarge,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FontStyle.normal,
                                    color: HexColor('#1F2937'),
                                  ),
                                ),
                              )

                          ),
                          DataCell(
                            Center(
                              child: Chip(
                                label: Text(
                                  Salary['status'] == 1 ? 'Active' : 'Inactive',
                                  style: GoogleFonts.poppins(
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .displayLarge,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FontStyle.normal,
                                    color:Salary['status'] == 1
                                        ? HexColor('#069c06')
                                        : Colors.red.shade600,
                                  ),
                                ),
                                backgroundColor: Salary['status'] == 1
                                    ? HexColor('#E6F7E6')
                                    : Colors.red.shade600,
                                padding: EdgeInsets.zero,
                                labelPadding:
                                EdgeInsets.symmetric(horizontal: 10.sp),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
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
        color: AppColors.bgYellow, // Replace with AppColors.bgYellow
      ),
    );
  }
}