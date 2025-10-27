import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aoneadmin/constants.dart';

class BktWiseFosAmountScreen extends StatefulWidget {
  const BktWiseFosAmountScreen({super.key});

  @override
  _RecoveryReportScreenState createState() => _RecoveryReportScreenState();
}

class _RecoveryReportScreenState extends State<BktWiseFosAmountScreen> {
  Map<String, dynamic>? jsonData;
  bool isLoading = true;
  String? errorMessage;
  Map<String, bool> expandedBuckets = {};
  int? selectedMonth;
  int selectedYear = DateTime.now().year;

  // List of months (1 = January, 2 = February, etc.)
  final List<int> months = List.generate(12, (index) => index + 1);
  final List<int> years = List.generate(5, (index) => DateTime.now().year - index);

  @override
  void initState() {
    super.initState();
    // Set default to current month
    selectedMonth = DateTime.now().month;
    fetchData();
  }

  Future<void> fetchData() async {
    if (selectedMonth == null) return;

    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('${ApiRoutes.bktWiseFosAmountReport}?month=$selectedMonth&year=$selectedYear'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          jsonData = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to load data: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error fetching data: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Stack(
        children: [
          Padding(
            padding:  EdgeInsets.only(bottom: 50.0),
            child: Column(
              children: [
                // Month and Year Selection
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 5.sp, vertical: 8.0),
                  padding: EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                    // boxShadow: [
                    //   BoxShadow(
                    //     color: Colors.black.withOpacity(0.1),
                    //     blurRadius: 6.0,
                    //     offset: Offset(0, 3),
                    //   ),
                    // ],
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
                Expanded(
                  child: isLoading
                      ? Center(child: CircularProgressIndicator(color: Colors.blueAccent))
                      : errorMessage != null
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          errorMessage!,
                          style: TextStyle(color: Colors.red, fontSize: 16),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: fetchData,
                          child: Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  )
                      : jsonData == null || jsonData!['status'] != 'success'
                      ? Center(child: Text('No data available', style: TextStyle(fontSize: 16)))
                      : _buildReportContent(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportContent() {
    List<dynamic> buckets = jsonData!['data'];
    Map<String, dynamic> grandTotal = jsonData!['grand_total'];
    Map<String, dynamic> summary = jsonData!['summary'];

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Padding(
        padding:  EdgeInsets.all(5.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.summarize, color: Colors.blueAccent.shade700, size: 20),
                SizedBox(width: 5),
                Text(
                  'Grand Total - ${summary['month']}/${summary['year']}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.blueAccent.shade700,
                  ),
                ),
              ],
            ),

            /// GRAND TOTAL CARD
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white, Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),

                    // Row 1: Total Count & Paid Count
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: _buildInfoRow(Icons.calculate, 'Total Amount\n₹', grandTotal['total_amount'])),
                        SizedBox(width: 10),
                        Expanded(child: _buildInfoRow(Icons.check_circle, 'Paid Amount\n₹', grandTotal['paid_amount'], iconColor: Colors.green.shade600)),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Row 2: Unpaid Count & Collection %
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: _buildInfoRow(Icons.cancel, 'Unpaid Amount\n₹', grandTotal['unpaid_amount'], iconColor: Colors.red.shade600)),
                        SizedBox(width: 10),
                        Expanded(child: _buildInfoRow(Icons.percent, 'Collection %\n', '${grandTotal['collection_percent'].toStringAsFixed(1)}%', iconColor: Colors.blueAccent)),
                      ],
                    ),
                    const SizedBox(height: 10),

                  ],
                ),
              ),
            ),

            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.list_alt, color: Colors.black, size: 20),
                SizedBox(width: 5),
                Text(
                  'BUKET WISE FOS AMOUNT REPORT',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),

            /// BUCKETS
            ///
            ///
            ...buckets.map((bucket) {
              String bktName = bucket['bkt_name'];
              List<dynamic> fosEntries = bucket['fos_entries'];

              if (!expandedBuckets.containsKey(bktName)) {
                expandedBuckets[bktName] = false;
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// DROPDOWN FULL WIDTH
                  InkWell(
                    onTap: () {
                      setState(() {
                        expandedBuckets[bktName] = !expandedBuckets[bktName]!;
                      });
                    },
                    child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.blue.withOpacity(0.2),
                              child: Icon(
                                Icons.calculate,
                                color: Colors.blue,
                                size: 24.sp,
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                bktName.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Icon(
                              expandedBuckets[bktName]! ? Icons.expand_less : Icons.expand_more,
                              color: Colors.black,
                            ),
                          ],
                        )

                    ),
                  ),

                  /// TABLE UI IMPROVED
                  if (expandedBuckets[bktName]!)
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Table(
                          border: TableBorder.all(
                            color: Colors.black87,
                            width: 1,
                          ),
                          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                          columnWidths: const {
                            0: IntrinsicColumnWidth(),
                            1: IntrinsicColumnWidth(),
                            2: IntrinsicColumnWidth(),
                            3: IntrinsicColumnWidth(),
                            4: IntrinsicColumnWidth(),
                          },
                          children: [
                            // Header Row
                            TableRow(
                              decoration: BoxDecoration(color: Colors.blue),
                              children:  [
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Center(child: Text('FOS Name'.toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white,fontSize: 14.sp))),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Total'.toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white,fontSize: 14.sp)),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Paid'.toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white,fontSize: 14.sp)),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Unpaid'.toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white,fontSize: 14.sp)),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Collection %'.toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white,fontSize: 14.sp)),
                                ),
                              ],
                            ),

                            // Data Rows
                            ...fosEntries.asMap().entries.map((entry) {
                              int index = entry.key;
                              var data = entry.value;
                              return TableRow(
                                decoration: BoxDecoration(
                                  color: index % 2 == 0 ? Colors.white : Colors.grey.shade100,
                                ),
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      data['fos_name'].replaceAll('\n', ''),
                                      style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600// <-- Set your desired font size here
                                      ),
                                    ),
                                  ),

                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(
                                      child: Text(data['total_amount'].toString(),
                                        style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w600// <-- Set your desired font size here
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(
                                      child: Text(data['paid_amount'].toString(),
                                        style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w600// <-- Set your desired font size here
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(
                                      child: Text(data['unpaid_amount'].toString(),
                                        style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w600// <-- Set your desired font size here
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(
                                      child: Text('${data['collection_percent'].toStringAsFixed(1)}%',
                                        style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w600// <-- Set your desired font size here
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),

                ],
              );
            }).toList(),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// Helper row builder for icons + text
  Widget _buildInfoRow(IconData icon, String label, dynamic value, {Color iconColor = Colors.black54}) {
    return Row(
      children: [
        Icon(icon, size: 22, color: iconColor),
        SizedBox(width: 12),
        Expanded(
          child:Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$label ',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                TextSpan(
                  text: '$value',
                  style: TextStyle(
                    fontSize: 16.sp, // Bigger or smaller as needed
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          )

        ),
      ],
    );
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
}