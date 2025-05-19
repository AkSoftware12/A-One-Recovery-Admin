import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../constants.dart';
import '../Allotment/allotment.dart';

// Model classes for type safety
class User {
  final int id;
  final String uniqueId;
  final String name;

  User({required this.id, required this.uniqueId, required this.name});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      uniqueId: json['unique_id'],
      name: json['name'],
    );
  }
}

class Attendance {
  final String userId;
  final int status;
  final String? note;

  Attendance({required this.userId, required this.status, this.note});

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      userId: json['user_id'].toString(),
      status: json['attendance'],
      note: json['note'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': int.parse(userId),
      'status': status,
      'note': note,
    };
  }
}

class AttendanceScreen extends StatefulWidget {
  final String appBar;
  static final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

  const AttendanceScreen({super.key, required this.appBar});

  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> with RouteAware {
  List<Map<String, dynamic>> employees = [];
  DateTime selectedDate = DateTime.now();
  bool isLoading = true;
  Map<String, int> attendanceStatus = {};
  List<String> employeeIds = [];
  List<String> notes = [];
  List<Map<String, dynamic>> attendances = [];
  int? globalAttendance;

  @override
  void initState() {
    super.initState();
    _initializeDefaultDates();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AttendanceScreen.routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
    });
  }

  @override
  void dispose() {
    AttendanceScreen.routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    fetchAttendance();
  }

  void _initializeDefaultDates() {
    setState(() {
      selectedDate = DateTime.now();
      fetchAttendance();
    });
  }

  Future<void> fetchAttendance() async {
    setState(() => isLoading = true);

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.get(
        Uri.parse(
            '${ApiRoutes.baseUrl}/admin/attandance-list?date=${DateFormat('yyyy-MM-dd').format(selectedDate)}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        print("📢 API Response: $responseData");

        setState(() {
          List<User> users =
          List<Map<String, dynamic>>.from(responseData['data']['user'])
              .map((json) => User.fromJson(json))
              .toList();
          List<Attendance> attendanceRecords =
          List<Map<String, dynamic>>.from(responseData['data']['attendances'])
              .map((json) => Attendance.fromJson(json))
              .toList();

          employees = users.map((user) {
            final attendanceRecord = attendanceRecords.firstWhere(
                  (att) => att.userId == user.id.toString(),
              orElse: () =>
                  Attendance(userId: user.id.toString(), status: 0, note: null),
            );
            return {
              'user_id': user.id.toString(),
              'unique_id': user.uniqueId,
              'name': user.name,
              'attendance': attendanceRecord.status,
              'note': attendanceRecord.note,
            };
          }).toList();

          attendanceStatus.clear();
          employeeIds.clear();
          attendances.clear();
          notes.clear();

          for (var employee in employees) {
            String employeeId = employee['user_id'].toString();
            int status = employee['attendance'] ?? 0;
            String note = employee['note']?.toString() ?? '';

            attendanceStatus[employeeId] = status;
            employeeIds.add(employeeId);
            attendances.add({
              'user_id': employeeId,
              'status': status,
              'note': note,
            });
            notes.add(note);
          }

          isLoading = false;
        });

        print("✅ Attendance Status Updated: $attendanceStatus");
        print("✅ Notes Initialized: $notes");
        print("✅ Attendances Initialized: $attendances");
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
            errorData['message'] ?? 'Failed to load attendance data');
      }
    } catch (e) {
      print('❌ Error fetching attendance: $e');
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> submitAttendance() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final String url = ApiRoutes.attendanceCreate;

      List<Map<String, dynamic>> attendanceList = attendances
          .asMap()
          .entries
          .map((entry) => {
        'user_id': int.parse(entry.value['user_id']),
        'status': entry.value['status'],
        'note': entry.value['note'].isEmpty ? null : entry.value['note'],
      })
          .toList();

      Map<String, dynamic> payload = {
        'date': DateFormat('yyyy-MM-dd').format(selectedDate),
        'attendances': attendanceList,
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      print('📤 Payload: ${jsonEncode(payload)}');
      if (response.statusCode == 200) {
        print('✅ Attendance submitted successfully.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Attendance Submitted Successfully!')),
        );
        fetchAttendance();
      } else {
        final errorData = json.decode(response.body);
        print(
            '❌ Failed to submit: ${response.statusCode}, ${errorData['message']}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  errorData['message'] ?? 'Failed to Submit Attendance')),
        );
      }
    } catch (e) {
      print('❌ Error submitting attendance: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting attendance: $e')),
      );
    }
  }

  void _setGlobalAttendance(int status) {
    setState(() {
      globalAttendance = status;
      attendanceStatus = {
        for (var employee in employees)
          employee['user_id'].toString(): status
      };
      employeeIds = employees.map((e) => e['user_id'].toString()).toList();
      attendances = employees.map((e) => {
        'user_id': e['user_id'].toString(),
        'status': status,
        'note': '',
      }).toList();
      notes = List.filled(employees.length, '');
    });
  }

  void _setIndividualAttendance(String employeeId, int status) {
    setState(() {
      attendanceStatus[employeeId] = status;
      int index = employeeIds.indexOf(employeeId);
      if (index != -1) {
        attendances[index] = {
          'user_id':employeeId,
          'status': status,
          'note': notes[index],
        };
      } else {
        employeeIds.add(employeeId);
        attendances.add({
          'user_id': employeeId,
          'status': status,
          'note': '',
        });
        notes.add('');
      }
    });
  }

  Widget _buildAppBar() {
    return Padding(
      padding: EdgeInsets.only(top: 30.sp),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left side with menu and user info
          Row(
            children: [
              // Menu Button
              Builder(
                builder: (context) => GestureDetector(
                  onTap: (){
                    Navigator.of(context).pop();

                  },
                  child: Container(
                    width: 40.sp,
                    // Equal width and height for perfect circle
                    height: 40.sp,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6.sp,
                          offset: Offset(0, 3.sp),
                        ),
                      ],
                    ),
                    child: Center(
                      // Center the icon for better alignment
                      child: Icon(
                        Icons.arrow_back,
                        size: 20.sp,
                        color: AppColors.textWhite,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.sp),
              // User Info
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Attendance', // Ensure username is defined
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textWhite,
                    ),
                  ),
                  SizedBox(height: 2.sp),
                  // Text(
                  //   'Admin ID: 2100101',
                  //   style: GoogleFonts.poppins(
                  //     fontSize: 10.sp,
                  //     fontWeight: FontWeight.w400,
                  //     color: AppColors.subTitlewhite.withOpacity(0.8),
                  //   ),
                  // ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Column(
          children: [
            widget.appBar != ''
                ? Container(
              height: 80.sp,
              decoration: BoxDecoration(
                color: AppColors.bgYellow,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20.sp),
                ),
                // border: Border.all(
                //   color: Colors.purple.shade100, // Or any color you want
                //   width: 1.sp,
                // ),
              ),
              padding: EdgeInsets.all(8.sp),
              alignment: Alignment.center,
              child: _buildAppBar(),
            ):SizedBox(),
            Expanded(
              child: isLoading
                  ? const Center(child: AnimatedLoader())
                  : Padding(
                padding:  EdgeInsets.all(8.sp),
                child: Column(
                  children: [

                    // Date Picker with Refresh Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (pickedDate != null) {
                                setState(() {
                                  selectedDate = pickedDate;
                                  fetchAttendance();
                                });
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                    color: Colors.blueGrey.withOpacity(0.6)),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blueGrey.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    DateFormat('dd MMM, yyyy')
                                        .format(selectedDate),
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Icon(Icons.calendar_month,
                                      color: Colors.blueGrey),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.sp),
                        IconButton(
                          icon: Icon(Icons.refresh,
                              size: 24.sp, color: Colors.grey[700]),
                          onPressed: () {
                            setState(() {
                              selectedDate = DateTime.now();
                            });
                            fetchAttendance();
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 12.sp),

                    // Global Attendance Selection
                    Card(
                      elevation: 5,
                      color: Colors.blue.shade100,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _globalRadioButton(1, "P", Colors.green),
                          _globalRadioButton(2, "A", Colors.red),
                          _globalRadioButton(3, "L", Colors.blue),
                          _globalRadioButton(4, "H", Colors.orange),
                        ],
                      ),
                    ),
                    SizedBox(height: 12.sp),

                    // Attendance List
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.grey.shade300,
                                    blurRadius: 5,
                                    spreadRadius: 2),
                              ],
                            ),
                            child: DataTable(
                              columnSpacing: 25.0,
                              headingRowHeight: 50.0,
                              dataRowHeight: 55.0,
                              headingRowColor: MaterialStateColor.resolveWith(
                                      (states) => Colors.blue.shade100),
                              border:
                              TableBorder.all(color: Colors.grey.shade300),
                              columns: const [
                                DataColumn(
                                  label: Text('Employee ID',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                ),
                                DataColumn(
                                  label: Text('Name',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                ),
                                DataColumn(
                                  label: Text('Attendance',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                ),
                                DataColumn(
                                  label: Text('Note',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                ),
                              ],
                              rows: employees.asMap().entries.map((entry) {
                                int index = entry.key;
                                var employee = entry.value;

                                return DataRow(
                                  color: MaterialStateColor.resolveWith((states) =>
                                  index.isEven
                                      ? Colors.white
                                      : Colors.grey.shade100),
                                  cells: [
                                    DataCell(
                                      Text(
                                        employee['unique_id'].toString(),
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        employee['name'].toString(),
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                    DataCell(
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                        children: [
                                          _attendanceRadioButton(
                                              employee['user_id'].toString(),
                                              1,
                                              "P",
                                              Colors.green),
                                          _attendanceRadioButton(
                                              employee['user_id'].toString(),
                                              2,
                                              "A",
                                              Colors.red),
                                          _attendanceRadioButton(
                                              employee['user_id'].toString(),
                                              3,
                                              "L",
                                              Colors.blue),
                                          _attendanceRadioButton(
                                              employee['user_id'].toString(),
                                              4,
                                              "H",
                                              Colors.orange),
                                        ],
                                      ),
                                    ),
                                    DataCell(
                                      TextField(
                                        controller: TextEditingController(
                                            text: notes[index]),
                                        onChanged: (value) {
                                          setState(() {
                                            notes[index] = value;
                                            attendances[index]['note'] = value;
                                          });
                                        },
                                        decoration: InputDecoration(
                                            hintText: 'Enter note'),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomCenter,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.bottomBg,
          ),
          onPressed: () {
            print("Employees: $employeeIds");
            print("Attendances: $attendances");
            print("Notes: $notes");
            submitAttendance();
          },
          child: Text(
            "Submit Attendance".toUpperCase(),
            style: TextStyle(color: AppColors.textblack),
          ),
        ),
      ),
    );
  }

  Widget _globalRadioButton(int value, String label, Color color) {
    return Row(
      children: [
        Radio<int>(
          value: value,
          groupValue: globalAttendance,
          activeColor: color,
          onChanged: (newValue) {
            _setGlobalAttendance(newValue!);
          },
        ),
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _attendanceRadioButton(
      String employeeId, int value, String label, Color color) {
    return Row(
      children: [
        Radio<int>(
          value: value,
          groupValue: attendanceStatus[employeeId] == 0
              ? null
              : attendanceStatus[employeeId],
          activeColor: color,
          onChanged: (newValue) {
            _setIndividualAttendance(employeeId, newValue!);
          },
        ),
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}