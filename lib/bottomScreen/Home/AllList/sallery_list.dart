import 'dart:convert';
import 'dart:math';
import 'package:animate_do/animate_do.dart';
import 'package:aoneadmin/HexColorCode/HexColor.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../DialogClass/ExpensesDialog/addExpenseDialog.dart'; // Adjust path as needed
import '../../../constants.dart'; // Adjust path as needed
import '../../../textSize.dart'; // Adjust path as needed
import 'package:url_launcher/url_launcher.dart';

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
          return Salary['month'].toString().toLowerCase().contains(query) ||
              Salary['month'].toLowerCase().contains(query) ||
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
        padding: EdgeInsets.only(bottom: 50.sp),
        child: ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => const SalaryDialog(),
            );
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
      body: Padding(
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
            Expanded(
              child: isLoading
                  ? const Center(child: AnimatedLoader())
                  : ListView.builder(
                padding: const EdgeInsets.all(12.0),
                itemCount: filteredExpenses.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final salary = filteredExpenses[index];
                  return FadeInUp(
                    duration: Duration(milliseconds: 300 + (index * 100)),
                    child: _buildSalaryCard(context,
                      salary['unique_id'].toString(),
                      salary['month'].toString(),
                      salary['basic_salary'].toString(),
                      salary['total_allowance'].toString(),
                      salary['total_deduction'].toString(),
                      salary['net_salary'].toString(),
                    ),
                  );
                },
              ),
            ),
            // SizedBox(height: 50.sp),

          ],
        ),
      ),
    );
  }
  Widget _buildSalaryCard(BuildContext context,
  String name,String month,
  String basic, String allowance, String deduction, String netSalary,
      ) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Selected ${name}',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.teal[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Card(
        elevation: 6.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            gradient: LinearGradient(
              colors:  [Colors.white, Colors.teal[50]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color:  Colors.teal.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                ZoomIn(
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.teal[600],
                    child: Text(
                      name[0].toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10.0),
                // Salary Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.poppins(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'Month: ${month}',
                        style: GoogleFonts.poppins(
                          fontSize: 11.0,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildDetailColumn(
                            'Basic',
                            '₹${basic}',
                            Colors.green[400]!,
                          ),
                          _buildDetailColumn(
                            'Allow.',
                            '₹${allowance}',
                            Colors.blue[400]!,
                          ),
                          _buildDetailColumn(
                            'Deduct.',
                            '₹${deduction}',
                            Colors.red[400]!,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        'Net: ₹${netSalary}',
                        style: GoogleFonts.poppins(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w600,
                          color:  Colors.teal[600],
                        ),
                      ),
                    ],
                  ),
                ),
                // Print Button
                ZoomIn(
                  child: IconButton(
                    icon: Icon(
                      Icons.print_rounded,
                      color: Colors.teal[600],
                      size: 22,
                    ),

                    onPressed: () async {
                      final Uri uri = Uri.parse(ApiRoutes.genrateSlip);
                      try {
                        if (!await launchUrl(uri,
                            mode: LaunchMode.externalApplication)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Could not open URL')),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    },
                    // onPressed: () {
                    //   print('Printing salary details for ${name}');
                    //   ScaffoldMessenger.of(context).showSnackBar(
                    //     SnackBar(
                    //       content: Text(
                    //         'Printing salary for ${name}',
                    //         style: GoogleFonts.poppins(
                    //           fontSize: 14,
                    //           color: Colors.white,
                    //         ),
                    //       ),
                    //       backgroundColor: Colors.teal[600],
                    //       behavior: SnackBarBehavior.floating,
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(10.0),
                    //       ),
                    //       duration: const Duration(seconds: 2),
                    //     ),
                    //   );
                    // },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailColumn(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 9.0,
            color:  Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 11.0,
            fontWeight: FontWeight.w500,
            color: valueColor,
          ),
        ),
      ],
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

  final List<String> years = List.generate(
      10, (index) => (DateTime.now().year - index).toString());
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
          final salary = data['salary']; // Adjust based on your API response
          setState(() {
            generatedSalary =
            'Salary for $selectedMonth $selectedYear: ₹$salary';
          });
        } else {
          setState(() {
            generatedSalary = 'Error fetching salary: ${response.statusCode}';
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
            'Generate Salary',
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
                icon: const Icon(Icons.arrow_drop_down, color: Colors.blueAccent),
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
                icon: const Icon(Icons.arrow_drop_down, color: Colors.blueAccent),
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