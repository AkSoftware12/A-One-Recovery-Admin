import 'dart:convert';
import 'package:aoneadmin/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Models for JSON parsing
class Branch {
  final String branchName;
  final double paidSum;
  final double unpaidSum;
  final int paidCount;
  final int unpaidCount;
  final double difference;
  final double perDayTarget;

  Branch({
    required this.branchName,
    required this.paidSum,
    required this.unpaidSum,
    required this.paidCount,
    required this.unpaidCount,
    required this.difference,
    required this.perDayTarget,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      branchName: json['branch_name'],
      paidSum: double.parse(json['paid_sum'].toString()),
      unpaidSum: double.parse(json['unpaid_sum'].toString()),
      paidCount: json['paid_count'],
      unpaidCount: json['unpaid_count'],
      difference: double.parse(json['difference'].toString()),
      perDayTarget: double.parse(json['per_day_target'].toString()),
    );
  }
}

class Bucket {
  final String bktName;
  final double totalPaid;
  final double totalUnpaid;
  final double totalDifference;
  final int remainingDays;
  final double perDayTarget;
  final Map<String, Branch> branches;

  Bucket({
    required this.bktName,
    required this.totalPaid,
    required this.totalUnpaid,
    required this.totalDifference,
    required this.remainingDays,
    required this.perDayTarget,
    required this.branches,
  });

  factory Bucket.fromJson(Map<String, dynamic> json) {
    var branchesJson = json['branches'] as Map<String, dynamic>;
    var branches = branchesJson.map((key, value) => MapEntry(key, Branch.fromJson(value)));

    return Bucket(
      bktName: json['bkt_name'],
      totalPaid: double.parse(json['total_paid'].toString()),
      totalUnpaid: double.parse(json['total_unpaid'].toString()),
      totalDifference: double.parse(json['total_difference'].toString()),
      remainingDays: json['remaining_days'],
      perDayTarget: double.parse(json['per_day_target'].toString()),
      branches: branches,
    );
  }
}

class BktWiseScreen extends StatefulWidget {
  const BktWiseScreen({super.key});

  @override
  _SummaryScreenState createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<BktWiseScreen> {
  late Future<List<Bucket>> _bucketsFuture;
  String _selectedMonth = 'July'; // Default month
  final int _selectedYear = 2025; // Fixed year for simplicity
  final Map<String, int> _monthMap = {
    'January': 1,
    'February': 2,
    'March': 3,
    'April': 4,
    'May': 5,
    'June': 6,
    'July': 7,
    'August': 8,
    'September': 9,
    'October': 10,
    'November': 11,
    'December': 12,
  };

  @override
  void initState() {
    super.initState();
    _bucketsFuture = fetchBuckets(_monthMap[_selectedMonth]!);
  }

  Future<List<Bucket>> fetchBuckets(int month) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      throw Exception('No authentication token found');
    }

    try {
      final response = await http.get(
        Uri.parse('${ApiRoutes.bktWiseReport}?month=$month'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        if (response.body.trim().startsWith('{') || response.body.trim().startsWith('[')) {
          final jsonData = jsonDecode(response.body);
          if (jsonData is Map<String, dynamic> && jsonData['status'] == 'success') {
            if (jsonData['data'] == null || jsonData['data'] is! List) {
              throw Exception('Invalid data format: "data" field is missing or not a list');
            }
            return (jsonData['data'] as List).map((e) => Bucket.fromJson(e)).toList();
          } else {
            throw Exception('API error: ${jsonData['message'] ?? 'Unknown error'}');
          }
        } else {
          throw FormatException('Response is not JSON: ${response.body.substring(0, response.body.length.clamp(0, 100))}');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Invalid or expired token');
      } else if (response.statusCode == 403) {
        throw Exception('Forbidden: Access denied');
      } else if (response.statusCode == 404) {
        throw Exception('Endpoint not found: ${ApiRoutes.bktWiseReport}');
      } else {
        throw Exception('Failed to load data: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching buckets: $e');
      throw Exception('Error fetching buckets from ${ApiRoutes.bktWiseReport}: $e');
    }
  }

  void _onMonthChanged(String? newMonth) {
    if (newMonth != null && newMonth != _selectedMonth) {
      setState(() {
        _selectedMonth = newMonth;
        _bucketsFuture = fetchBuckets(_monthMap[newMonth]!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,



      body: Column(
        children: [
          Card(
            color: Colors.white,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0.0), // Adjust the radius as needed
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue[800]!, width: 2),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: DropdownButton<String>(
                  value: _selectedMonth,
                  isExpanded: true,
                  hint: const Text('Select Month'),
                  items: _monthMap.keys.map((String month) {
                    return DropdownMenuItem<String>(
                      value: month,
                      child: Text(month, style: const TextStyle(fontSize: 16)),
                    );
                  }).toList(),
                  onChanged: _onMonthChanged,
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                  dropdownColor: Colors.white,
                  underline: const SizedBox(),
                  icon: Icon(Icons.arrow_drop_down, color: Colors.blue[800]),
                ),
              ),
            ),
          ),
          SizedBox(height: 5.sp,),
          Card(
            margin: EdgeInsets.zero,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0.0), // Adjust the radius as needed
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.account_balance, color: Colors.blueAccent, size: 24),
                  SizedBox(width: 8),
                  Text(
                    '$_selectedMonth - Bucket Wise',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      fontStyle: FontStyle.italic, // Add italic style for flair
                    ),
                  ),
                ],
              ),
            ),
          ),
          // SizedBox(height: 5.sp,),
          Expanded(
            child: FutureBuilder<List<Bucket>>(
              future: _bucketsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: SizedBox(
                      height: 200.sp,
                      width: 200.sp,
                      child: Image.asset('assets/report_not_found.png'),
                    ),
                  );
                }

                final buckets = snapshot.data!;

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: Container(
                      decoration: BoxDecoration(
                        // border: Border.all(color: Colors.grey[400]!, width: 1.0), // Table border
                        borderRadius: BorderRadius.circular(8.0), // Rounded corners
                        // boxShadow: [
                        //   BoxShadow(
                        //     color: Colors.grey.withOpacity(0.2),
                        //     spreadRadius: 2,
                        //     blurRadius: 5,
                        //     offset: const Offset(0, 3), // Subtle shadow for depth
                        //   ),
                        // ],
                      ),
                      margin: const EdgeInsets.all(0.0), // Margin around the table
                      child: DataTable(
                        headingRowHeight: 56.0,
                        dataRowHeight: 48.0,
                        headingRowColor: WidgetStateProperty.all(Colors.blue[800]), // Header background
                        headingTextStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        dataRowColor: WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.hovered)) {
                            return Colors.blue[50]; // Hover effect
                          }
                          return buckets.indexOf(buckets.elementAt(states.length)) % 2 == 0
                              ? Colors.grey[200] // Alternating row colors
                              : Colors.white;
                        }),
                        columnSpacing: 24.0,
                        dividerThickness: 1.0, // Thickness of cell borders
                        border: TableBorder(
                          // Define colored borders for rows and columns
                          top: BorderSide(color: Colors.grey[400]!, width: 1.0),
                          bottom: BorderSide(color: Colors.grey[400]!, width: 1.0),
                          left: BorderSide(color: Colors.grey[400]!, width: 1.0),
                          right: BorderSide(color: Colors.grey[400]!, width: 1.0),
                          horizontalInside: BorderSide(color: Colors.grey[400]!, width: 1.0), // Row lines
                          verticalInside: BorderSide(color: Colors.grey[400]!, width: 1.0), // Column lines
                        ),
                        columns:  [
                          DataColumn(
                            label: Text(
                              'Bucket'.toUpperCase(),
                              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold,),
                            )
                          ),
                          DataColumn(
                            label: Text(
                              'Total Paid'.toUpperCase(),
                              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold,),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Total Unpaid'.toUpperCase(),
                              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold,),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Difference'.toUpperCase(),
                              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold,),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Per Day Target'.toUpperCase(),
                              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold,),
                            ),
                          ),
                          DataColumn(
                            label: Center(
                              child: Text(
                                'Action'.toUpperCase(),
                                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold,),
                              ),
                            ),
                          ),
                        ],
                        rows: buckets.asMap().entries.map((entry) {
                          final index = entry.key;
                          final bucket = entry.value;
                          return DataRow(
                            cells: [
                              DataCell(
                                Container(
                                  child: Padding(
                                    padding:  EdgeInsets.symmetric(vertical: 8.sp, horizontal: 5.sp),
                                    child: Text(
                                      bucket.bktName.toUpperCase(),
                                      style:  TextStyle(fontSize: 13.sp, color: Colors.black87,fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                Container(

                                  child: Padding(
                                    padding:  EdgeInsets.symmetric(vertical: 8.sp, horizontal: 5.sp),
                                    child: Text(
                                      bucket.totalPaid.toStringAsFixed(2),
                                      style:  TextStyle(fontSize: 12.sp, color: Colors.black87,fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                Container(
                                  child: Padding(
                                    padding:  EdgeInsets.symmetric(vertical: 8.sp, horizontal: 12.sp),
                                    child: Text(
                                      bucket.totalUnpaid.toStringAsFixed(2),
                                      style:  TextStyle(fontSize: 12.sp, color: Colors.black87,fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                Container(
                                  child: Padding(
                                    padding:  EdgeInsets.symmetric(vertical: 8.sp, horizontal: 12.sp),
                                    child: Text(
                                      bucket.totalDifference.toStringAsFixed(2),
                                      style:  TextStyle(fontSize: 12.sp, color: Colors.black87,fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                Container(
                                  child: Padding(
                                    padding:  EdgeInsets.symmetric(vertical: 8.sp, horizontal: 12.sp),
                                    child: Text(
                                      bucket.perDayTarget.toStringAsFixed(2),
                                      style:  TextStyle(fontSize: 12.sp, color: Colors.black87,fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                Container(
                                  child: Padding(
                                    padding:  EdgeInsets.symmetric(vertical: 8.sp, horizontal: 12.sp),
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => BranchDetailsScreen(bucket: bucket),
                                          ),
                                        );
                                      },
                                      child:  Text(
                                        'View'.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class BranchDetailsScreen extends StatelessWidget {
  final Bucket bucket;

  const BranchDetailsScreen({super.key, required this.bucket});

  @override
  Widget build(BuildContext context) {
    final branches = bucket.branches.values.toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      body: Column(
        children: [
          Card(
            margin: EdgeInsets.zero,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0.0), // Adjust the radius as needed
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.account_balance, color: Colors.blueAccent, size: 24),
                  SizedBox(width: 8),
                  Text(
                    '${bucket.bktName.toUpperCase()} - Branch Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      fontStyle: FontStyle.italic, // Add italic style for flair
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 5.sp,),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(0.0), // Add padding around the table
                child: DataTable(
                  headingRowHeight: 60.0, // Slightly taller headers
                  dataRowHeight: 52.0, // Comfortable row height
                  headingRowColor: WidgetStateProperty.all(Colors.blue[900]), // Consistent header color
                  headingTextStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                  dataRowColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.hovered)) {
                      return Colors.blue[100]!.withOpacity(0.3); // Subtle hover effect
                    }
                    // Alternating row colors for better readability
                    return branches.indexOf(branches.elementAt(states.length)) % 2 == 0
                        ? Colors.grey[200]
                        : Colors.white;
                  }),
                  border: TableBorder(
                    horizontalInside: BorderSide(color: Colors.grey[300]!, width: 1), // Row separators
                    verticalInside: BorderSide(color: Colors.grey[300]!, width: 1), // Column separators
                    top: BorderSide(color: Colors.grey[400]!, width: 1),
                    bottom: BorderSide(color: Colors.grey[400]!, width: 1),
                    left: BorderSide(color: Colors.grey[400]!, width: 1),
                    right: BorderSide(color: Colors.grey[400]!, width: 1),
                  ),
                  columnSpacing: 20.0, // Balanced spacing between columns
                  dataTextStyle:  TextStyle(
                    fontSize: 14.sp,
                    color: Colors.black87, // Darker text for better contrast
                  ),
                  columns:  [
                    DataColumn(
                      label: Text(
                        'Branch'.toUpperCase(),
                        style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold,),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Paid Sum'.toUpperCase(),
                        style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold,),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Unpaid Sum'.toUpperCase(),
                        style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold,),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Difference'.toUpperCase(),
                        style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold,),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Paid Count'.toUpperCase(),
                        style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold,),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Unpaid Count'.toUpperCase(),
                        style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold,),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Per Day Target'.toUpperCase(),
                        style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold,),
                      ),
                    ),
                  ],
                  rows: branches.asMap().entries.map((entry) {
                    final branch = entry.value;
                    return DataRow(
                      cells: [
                        DataCell(
                          Center(
                            child: Text(
                              branch.branchName.toUpperCase(),
                              style:  TextStyle(fontSize: 13.sp, color: Colors.black87,fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        DataCell(
                          Center(
                            child: Text(
                              branch.paidSum.toStringAsFixed(2),
                              style: TextStyle(
                                color: Colors.green[700], // Green for paid amounts
                                fontWeight: FontWeight.w700,
                                fontSize: 12.sp
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Center(
                            child: Text(
                              branch.unpaidSum.toStringAsFixed(2),
                              style: TextStyle(
                                color: Colors.red[700], // Red for unpaid amounts
                                fontWeight: FontWeight.w700,
                                  fontSize: 12.sp

                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Center(
                            child: Text(
                              branch.difference.toStringAsFixed(2),
                              style: TextStyle(
                                color: branch.difference >= 0 ? Colors.green[700] : Colors.red[700],
                                fontWeight: FontWeight.w700,
                                  fontSize: 12.sp

                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Center(
                            child: Text(
                              branch.paidCount.toString(),
                              style:  TextStyle(fontSize: 12.sp, color: Colors.black87,fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        DataCell(
                          Center(
                            child: Text(
                              branch.unpaidCount.toString(),
                              style:  TextStyle(fontSize: 12.sp, color: Colors.black87,fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        DataCell(
                          Center(
                            child: Text(
                              branch.perDayTarget.toStringAsFixed(2),
                              style:  TextStyle(fontSize: 12.sp, color: Colors.black87,fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}