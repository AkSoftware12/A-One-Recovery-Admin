import 'package:aoneadmin/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProductWiseBucketReportScreen extends StatefulWidget {
  const ProductWiseBucketReportScreen({super.key});

  @override
  State<ProductWiseBucketReportScreen> createState() => _ProductWiseBucketReportScreenState();
}

class _ProductWiseBucketReportScreenState extends State<ProductWiseBucketReportScreen> {
  Map<String, List<Map<String, dynamic>>> groupedData = {};
  bool isLoading = true;
  String? errorMessage;
  int? selectedMonth;
  int selectedYear = DateTime.now().year;

  final List<int> months = List.generate(12, (index) => index + 1);
  final List<int> years = List.generate(5, (index) => DateTime.now().year - index);

  @override
  void initState() {
    super.initState();
    selectedMonth = DateTime.now().month;
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        setState(() {
          errorMessage = 'Authentication token is missing. Please log in again.';
          isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse('${ApiRoutes.productWiseBuketReport}?month=$selectedMonth&year=$selectedYear'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('API Response: $data');

        if (data is Map<String, dynamic>) {
          try {
            final tempGroupedData = <String, List<Map<String, dynamic>>>{};
            if (data['groupedData'] is Map<String, dynamic>) {
              final groupedDataMap = data['groupedData'] as Map<String, dynamic>;
              for (var key in ['CD', 'PL']) {
                final value = groupedDataMap[key];
                if (value is List) {
                  tempGroupedData[key] = value
                      .where((item) => item is Map)
                      .cast<Map>()
                      .map((item) => Map<String, dynamic>.from(item))
                      .toList();
                } else {
                  print('Invalid value for key $key: Expected List, got ${value?.runtimeType}');
                  tempGroupedData[key] = [];
                }
              }
            } else {
              print('Invalid groupedData: Expected Map, got ${data['groupedData']?.runtimeType}');
            }

            setState(() {
              groupedData = tempGroupedData;
              isLoading = false;
            });
          } catch (e) {
            setState(() {
              errorMessage = 'Error parsing data: $e';
              isLoading = false;
            });
          }
        } else {
          setState(() {
            errorMessage = 'Invalid data format: Expected Map, got ${data.runtimeType}';
            isLoading = false;
          });
        }
      } else if (response.statusCode == 401) {
        setState(() {
          errorMessage = 'Unauthorized access. Please log in again.';
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load data: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching data: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    await fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          // Month and Year Dropdowns
          Container(
            margin: EdgeInsets.symmetric(horizontal: 5.sp, vertical: 8.0),
            padding: EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: DropdownButton<int>(
                      value: selectedMonth,
                      hint: Text(
                        'Select Month',
                        style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                      ),
                      items: months.map((month) {
                        return DropdownMenuItem<int>(
                          value: month,
                          child: Text(_getMonthName(month)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedMonth = value;
                          fetchData();
                        });
                      },
                      isExpanded: true,
                      underline: SizedBox(),
                      icon: Icon(Icons.arrow_drop_down, color: Colors.blue, size: 26),
                      style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500),
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                SizedBox(width: 12.0),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: DropdownButton<int>(
                      value: selectedYear,
                      hint: Text(
                        'Select Year',
                        style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                      ),
                      items: years.map((year) {
                        return DropdownMenuItem<int>(
                          value: year,
                          child: Text(year.toString()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedYear = value!;
                          fetchData();
                        });
                      },
                      isExpanded: true,
                      underline: SizedBox(),
                      icon: Icon(Icons.arrow_drop_down, color: Colors.blue, size: 26),
                      style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500),
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Data Display
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage != null
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(errorMessage!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
                : RefreshIndicator(
              onRefresh: _refreshData,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // CD Table
                    if (groupedData['CD']?.isNotEmpty ?? false) ...[
                      Container(
                        color: Colors.blue,
                        width: double.infinity,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 8.0),
                          child: Text(
                            'CD',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 5.sp, vertical: 8.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Table(
                            border: TableBorder(
                              horizontalInside: BorderSide(color: Colors.grey.shade300, width: 2.0),
                              verticalInside: BorderSide(color: Colors.grey.shade300, width: 1.0),
                              top: BorderSide(color: Colors.grey.shade300),
                              bottom: BorderSide(color: Colors.grey.shade300),
                              left: BorderSide(color: Colors.grey.shade300),
                              right: BorderSide(color: Colors.grey.shade300),
                            ),
                            columnWidths: {
                              for (int i = 0; i < _buildColumnTitles().length; i++)
                                i: const FixedColumnWidth(120.0), // Adjust width as needed
                            },
                            children: [
                              // Header Row
                              TableRow(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                ),
                                children: _buildColumnTitles()
                                    .map((title) => TableCell(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.sp),
                                    child: Text(
                                      title,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ))
                                    .toList(),
                              ),
                              // Data Rows
                              ...groupedData['CD']!.asMap().entries.map((entry) {
                                final index = entry.key;
                                final item = entry.value;
                                return TableRow(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                  ),
                                  children: _buildDataRow(item)
                                      .map((cell) => TableCell(
                                    child: cell,
                                  ))
                                      .toList(),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16.sp),
                    ],
                    // PL Table
                    if (groupedData['PL']?.isNotEmpty ?? false) ...[
                      Container(
                        color: Colors.blue,
                        width: double.infinity,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 8.0),
                          child: Text(
                            'PL',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 5.sp, vertical: 8.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Table(
                            border: TableBorder(
                              horizontalInside: BorderSide(color: Colors.grey.shade300, width: 2.0),
                              verticalInside: BorderSide(color: Colors.grey.shade300, width: 1.0),
                              top: BorderSide(color: Colors.grey.shade300),
                              bottom: BorderSide(color: Colors.grey.shade300),
                              left: BorderSide(color: Colors.grey.shade300),
                              right: BorderSide(color: Colors.grey.shade300),
                            ),
                            columnWidths: {
                              for (int i = 0; i < _buildColumnTitles().length; i++)
                                i: const FixedColumnWidth(120.0), // Adjust width as needed
                            },
                            children: [
                              // Header Row
                              TableRow(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                ),
                                children: _buildColumnTitles()
                                    .map((title) => TableCell(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.sp),
                                    child: Text(
                                      title,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ))
                                    .toList(),
                              ),
                              // Data Rows
                              ...groupedData['PL']!.asMap().entries.map((entry) {
                                final index = entry.key;
                                final item = entry.value;
                                return TableRow(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                  ),
                                  children: _buildDataRow(item)
                                      .map((cell) => TableCell(
                                    child: cell,
                                  ))
                                      .toList(),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ),
                    ],
                    if ((groupedData['CD']?.isEmpty ?? true) &&
                        (groupedData['PL']?.isEmpty ?? true))
                      Container(
                        height: MediaQuery.of(context).size.height*0.6,
                        child: Align(
                          alignment: Alignment.center,
                          child: Container(
                            height: 200.sp,
                            width: 200.sp,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(30)),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.all(Radius.circular(30)),
                              child: Image.asset('assets/report_not_found.png'),
                            ),
                          ),
                        ),
                      ),

                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _buildColumnTitles() {
    return const [
      'Product',
      'Bucket',
      'POS Flow',
      'POS Norm',
      'POS Settled',
      'POS Stab',
      'Coll Flow',
      'Coll Norm',
      'Coll Settled',
      'Coll Stab',
      'Loan Flow',
      'Loan Norm',
      'Loan Settled',
      'Loan Stab',
      'Total POS',
      'Total Coll',
      'Total Loan',
    ];
  }

  String _getMonthName(int month) {
    const monthNames = [
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
    return monthNames[month - 1];
  }

  List<Widget> _buildDataRow(Map<String, dynamic> item) {
    return [
      Padding(
        padding: EdgeInsets.all(8.sp),
        child: Text(
          item['Product']?.toString() ?? 'N/A',
          textAlign: TextAlign.center,
        ),
      ),
      Padding(
        padding: EdgeInsets.all(8.sp),
        child: Text(
          item['BKT']?.toString() ?? 'N/A',
          textAlign: TextAlign.center,
        ),
      ),
      Padding(
        padding: EdgeInsets.all(8.sp),
        child: Text(
          item['pos_flow']?.toString() ?? '0',
          textAlign: TextAlign.center,
        ),
      ),
      Padding(
        padding: EdgeInsets.all(8.sp),
        child: Text(
          item['pos_norm']?.toString() ?? '0',
          textAlign: TextAlign.center,
        ),
      ),
      Padding(
        padding: EdgeInsets.all(8.sp),
        child: Text(
          item['pos_settled']?.toString() ?? '0',
          textAlign: TextAlign.center,
        ),
      ),
      Padding(
        padding: EdgeInsets.all(8.sp),
        child: Text(
          item['pos_stab']?.toString() ?? '0',
          textAlign: TextAlign.center,
        ),
      ),
      Padding(
        padding: EdgeInsets.all(8.sp),
        child: Text(
          item['coll_flow']?.toString() ?? '0',
          textAlign: TextAlign.center,
        ),
      ),
      Padding(
        padding: EdgeInsets.all(8.sp),
        child: Text(
          item['coll_norm']?.toString() ?? '0',
          textAlign: TextAlign.center,
        ),
      ),
      Padding(
        padding: EdgeInsets.all(8.sp),
        child: Text(
          item['coll_settled']?.toString() ?? '0',
          textAlign: TextAlign.center,
        ),
      ),
      Padding(
        padding: EdgeInsets.all(8.sp),
        child: Text(
          item['coll_stab']?.toString() ?? '0',
          textAlign: TextAlign.center,
        ),
      ),
      Padding(
        padding: EdgeInsets.all(8.sp),
        child: Text(
          item['loan_flow']?.toString() ?? '0',
          textAlign: TextAlign.center,
        ),
      ),
      Padding(
        padding: EdgeInsets.all(8.sp),
        child: Text(
          item['loan_norm']?.toString() ?? '0',
          textAlign: TextAlign.center,
        ),
      ),
      Padding(
        padding: EdgeInsets.all(8.sp),
        child: Text(
          item['loan_settled']?.toString() ?? '0',
          textAlign: TextAlign.center,
        ),
      ),
      Padding(
        padding: EdgeInsets.all(8.sp),
        child: Text(
          item['loan_stab']?.toString() ?? '0',
          textAlign: TextAlign.center,
        ),
      ),
      Padding(
        padding: EdgeInsets.all(8.sp),
        child: Text(
          item['total_pos']?.toString() ?? '0',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
          textAlign: TextAlign.center,
        ),
      ),
      Padding(
        padding: EdgeInsets.all(8.sp),
        child: Text(
          item['total_collection']?.toString() ?? '0',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
          textAlign: TextAlign.center,
        ),
      ),
      Padding(
        padding: EdgeInsets.all(8.sp),
        child: Text(
          item['total_loan']?.toString() ?? '0',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange),
          textAlign: TextAlign.center,
        ),
      ),
    ];
  }
}