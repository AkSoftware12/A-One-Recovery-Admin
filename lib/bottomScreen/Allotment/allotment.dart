import 'dart:convert';
import 'package:animate_do/animate_do.dart';
import 'package:aoneadmin/bottomScreen/Home/DialogClass/AllotmentDialog/allotRecoveryDialog.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../constants.dart'; // Adjust path as needed
import '../../../textSize.dart'; // Adjust path as needed
import 'package:url_launcher/url_launcher.dart';

import '../Home/DialogClass/AllotmentDialog/addRecoveryDialog.dart';

class AllotmentPage extends StatefulWidget {
  const AllotmentPage({super.key});

  @override
  State<AllotmentPage> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<AllotmentPage>
    with SingleTickerProviderStateMixin {
  bool isLoading = false;
  List allotmentlist = [];
  List filteredExpenses = [];
  TextEditingController searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final Map<int, bool> _expandedCards = {};
  final List<String> _selectedLoanNos = []; // List to store selected loan numbers
  List categoryExpenses = [];

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
    filteredExpenses = allotmentlist;
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

    final response = await http.get(
      Uri.parse(ApiRoutes.getAllotmentList),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        allotmentlist = data['recovery']['data'];
        filteredExpenses = allotmentlist;
        _selectedLoanNos.clear();


        isLoading = false;
      });
      _animationController.forward(from: 0);
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load allotmentlist')),
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
        filteredExpenses = allotmentlist;
      } else {
        filteredExpenses = allotmentlist.where((allotmentlist) {
          return allotmentlist['month']
                  .toString()
                  .toLowerCase()
                  .contains(query) ||
              allotmentlist['month'].toLowerCase().contains(query) ||
              allotmentlist['net_salary']
                  .toString()
                  .toLowerCase()
                  .contains(query) ||
              allotmentlist['entry_date']
                  .toString()
                  .toLowerCase()
                  .contains(query);
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
    final isRecoveryMode = _selectedLoanNos.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.bottomBg,
      floatingActionButton:Padding(
        padding: EdgeInsets.only(bottom: 50.sp),
        child: isRecoveryMode ?
        ElevatedButton(
          onPressed: () async {
            final allotRecoveryDialog = AllotRecoveryDialog();
            final result = await allotRecoveryDialog.show(context,categoryExpenses,_selectedLoanNos);
            // Show dialog and wait for result
            if (result) {
              // Refresh the list if allowance was added successfully
              await fetchExpenseData();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor:  isRecoveryMode ? AppColors.secondary : AppColors.bgYellow,
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
                'Allot Recovery',
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ): ElevatedButton(
          onPressed: () async {
            final addRecoveryDialog = AddRecoveryDialog();
            final result = await addRecoveryDialog.show(context,);
            // Show dialog and wait for result
            if (result) {
              // Refresh the list if allowance was added successfully
              await fetchExpenseData();
            }

          },
          style: ElevatedButton.styleFrom(
            backgroundColor:  isRecoveryMode ? AppColors.secondary : AppColors.bgYellow,
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
                'Add Recovery',
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        )
      ),
      body: Padding(
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
                      // Replace with AppColors.bgYellow
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
                padding: EdgeInsets.all(8.sp),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Allotment List (${filteredExpenses.length})',
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
            Padding(
              padding:  EdgeInsets.only(left: 10.sp,),
              child: Text(
                'Selected Item (${_selectedLoanNos.length})',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.teal,
                ),
              ),
            ),

            // Data Table
            Expanded(
                child: isLoading
                    ? const Center(child: AnimatedLoader())
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        itemCount: filteredExpenses.length,
                        itemBuilder: (context, index) {
                          final allotmentlist = filteredExpenses[index];
                          final isExpanded = _expandedCards[index] ?? false;
                          final loanId = allotmentlist['id'].toString();
                          final loanNo = allotmentlist['Loan_no'].toString();
                          final isSelected = _selectedLoanNos.contains(loanId);

                          return FadeInUp(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _expandedCards[index] = !isExpanded;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 10.0, vertical: 8.0),
                                padding: const EdgeInsets.all(12.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      spreadRadius: 2,
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Checkbox(
                                              value: isSelected,
                                              onChanged: (bool? value) {
                                                setState(() {
                                                  if (value == true) {
                                                    if (_selectedLoanNos.length < 15) {
                                                      _selectedLoanNos.add(loanId);
                                                      print(_selectedLoanNos);
                                                    } else {
                                                      // Optional: Show a message to the user indicating max limit reached
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(content: Text('Maximum 15 items can be selected'),backgroundColor: Colors.red,),
                                                      );
                                                    }
                                                  } else {
                                                    _selectedLoanNos.remove(loanId);
                                                    print(_selectedLoanNos);
                                                  }
                                                });
                                              },
                                              activeColor: Colors.teal,
                                            ),
                                            Text(
                                              "Loan #${loanNo}",
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.teal,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Icon(
                                          isExpanded
                                              ? Icons.expand_less
                                              : Icons.expand_more,
                                          color: Colors.teal,
                                        ),
                                      ],
                                    ),
                                    Text(
                                      allotmentlist['Customer_name'].toString(),
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Text(
                                          "Amount: ${allotmentlist['INSTALLMENT_AMT'].toString()}",
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const Spacer(),
                                        _buildStatusIndicator(
                                            allotmentlist['Status'].toString()),
                                      ],
                                    ),
                                    if (isExpanded) ...[
                                      const Divider(height: 16, thickness: 1),
                                      _buildDetailRow(
                                          Icons.account_balance_wallet,
                                          "Portfolio",
                                          allotmentlist['Portfolio']
                                              .toString()),
                                      _buildDetailRow(
                                          Icons.location_city,
                                          "Branch",
                                          allotmentlist['Branch'].toString()),
                                      _buildDetailRow(
                                          Icons.calendar_today,
                                          "Collection Date",
                                          allotmentlist['Collection_Date']
                                              .toString()),
                                      _buildDetailRow(
                                        Icons.person,
                                        "Assigned",
                                        '${filteredExpenses[index]['assigned_employee']?['name'] ?? 'N/A'}',
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      )),
            // SizedBox(height: 50.sp),
          ],
        ),
      ),
    );
  }




  Widget _buildStatusIndicator(String status) {
    Color color;
    IconData icon;
    switch (status) {
      case "Paid":
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case "Pending":
        color = Colors.orange;
        icon = Icons.hourglass_empty;
        break;
      case "Overdue":
        color = Colors.red;
        icon = Icons.warning;
        break;
      default:
        color = Colors.grey;
        icon = Icons.info;
    }
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Text(
          status,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.teal, size: 16),
          const SizedBox(width: 8),
          Text(
            "$label: ",
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value ?? '',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
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

class SalaryDialog extends StatefulWidget {
  const SalaryDialog({super.key});

  @override
  State<SalaryDialog> createState() => _SalaryDialogState();
}

class _SalaryDialogState extends State<SalaryDialog> {
  String? selectedYear;
  String? selectedMonth;
  String generatedSalary = '';

  final List<String> years =
      List.generate(10, (index) => (DateTime.now().year - index).toString());
  final List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedYear = now.year.toString();
    selectedMonth = months[now.month - 1];
  }

  void generateSalary() async {
    if (selectedYear != null && selectedMonth != null) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');

        final response = await http.post(
          Uri.parse(ApiRoutes.genrateSalary),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'year': selectedYear,
            'month': selectedMonth,
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final allotmentlist =
              data['allotmentlist']; // Adjust based on your API response
          setState(() {
            generatedSalary =
                'allotmentlist for $selectedMonth $selectedYear: ₹';
          });
        } else {
          setState(() {
            generatedSalary =
                'Error fetching allotmentlist: ${response.statusCode}';
          });
        }
      } catch (e) {
        setState(() {
          generatedSalary = 'Error: $e';
        });
      }
    } else {
      setState(() {
        generatedSalary = 'Please select both year and month';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      elevation: 10,
      contentPadding: const EdgeInsets.all(20),
      title: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.blueAccent, Colors.indigo],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'Generate allotmentlist',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: DropdownButton<String>(
                hint: const Text('Select Year'),
                value: selectedYear,
                isExpanded: true,
                underline: const SizedBox(),
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                ),
                icon:
                    const Icon(Icons.arrow_drop_down, color: Colors.blueAccent),
                items: years.map((String year) {
                  return DropdownMenuItem<String>(
                    value: year,
                    child: Text(year),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedYear = newValue;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: DropdownButton<String>(
                hint: const Text('Select Month'),
                value: selectedMonth,
                isExpanded: true,
                underline: const SizedBox(),
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                ),
                icon:
                    const Icon(Icons.arrow_drop_down, color: Colors.blueAccent),
                items: months.map((String month) {
                  return DropdownMenuItem<String>(
                    value: month,
                    child: Text(month),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedMonth = newValue;
                  });
                },
              ),
            ),
            const SizedBox(height: 20),
            Text(
              generatedSalary,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: generatedSalary.startsWith('Please')
                    ? Colors.red
                    : Colors.green,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey[600],
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          child: const Text(
            'Close',
            style: TextStyle(fontSize: 16),
          ),
        ),
        ElevatedButton(
          onPressed: generateSalary,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 5,
          ),
          child: const Text(
            'Generate',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class RecoveryDialog extends StatelessWidget {
  const RecoveryDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Allot Recovery'),
      content: const Text('Allot recovery dialog content here.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
