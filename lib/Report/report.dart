import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import 'BKTWISEFOSAMOUNT/bkt_wise_fos_amount.dart';
import 'BKTWISEFOSCOUNT/bktwise_fos_count.dart';
import 'BktReportScreen/bkt_wise.dart';
import 'ProductWiseBuketReport/product_wise_buket_report.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final List<Map<String, dynamic>> reports = [
    {
      'title': 'BKT-WISE',
      'category': 'Bucket Reports',
      'icon': Icons.analytics,
      'color': Colors.blue.shade400,
    },
    {
      'title': 'BKT-WISE-FOS-COUNT',
      'category': 'Bucket Reports',
      'icon': Icons.calculate,
      'color': Colors.green.shade400,
    },
    {
      'title': 'BKT-WISE-FOS-AMOUNT',
      'category': 'Bucket Reports',
      'icon': Icons.monetization_on,
      'color': Colors.orange.shade400,
    },
    {
      'title': 'POS-BUCKET WISE',
      'category': 'POS Reports',
      'icon': Icons.point_of_sale,
      'color': Colors.purple.shade400,
    },
    {
      'title': 'POS-WISE-AMOUNT',
      'category': 'POS Reports',
      'icon': Icons.account_balance_wallet,
      'color': Colors.red.shade400,
    },
    {
      'title': 'PRODUCT-WISE-BUKET-REPORT',
      'category': 'Product Wise Report',
      'icon': Icons.account_balance_wallet,
      'color': Colors.blue.shade400,
    },

  ];

  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> filteredReports = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    filteredReports = reports;
    _searchController.addListener(_filterReports);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterReports() {
    setState(() {
      filteredReports = reports.where((report) {
        return report['title']
            .toString()
            .toLowerCase()
            .contains(_searchController.text.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: Padding(
        padding: EdgeInsets.all(10.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar with Animation
            BounceInDown(
              duration: const Duration(milliseconds: 500),
              child: Container(
                margin: EdgeInsets.only(bottom: 10.sp),
                decoration: BoxDecoration(
                  color: Colors.white,
                  // gradient: LinearGradient(
                  //   colors: [Colors.white, Colors.white],
                  //   begin: Alignment.topLeft,
                  //   end: Alignment.bottomRight,
                  // ),
                  borderRadius: BorderRadius.circular(12.r),
                  // boxShadow: [
                  //   BoxShadow(
                  //     color: Colors.blue.shade100.withOpacity(0.3),
                  //     spreadRadius: 2,
                  //     blurRadius: 10,
                  //     offset: const Offset(0, 4),
                  //   ),
                  // ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search reports...',
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.blue.shade600,
                      size: 20.sp,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: Colors.blue.shade600,
                        size: 20.sp,
                      ),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                        : null,
                    filled: true,
                    fillColor: Colors.transparent,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.sp,
                      vertical: 12.sp,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade800),
                ),
              ),
            ),
            // Report List
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredReports.isEmpty
                  ? Center(
                child: FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 48.sp,
                        color: Colors.grey.shade400,
                      ),
                      SizedBox(height: 16.sp),
                      Text(
                        'No reports found',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              )
                  : ListView.builder(
                itemCount: filteredReports.length,
                padding: EdgeInsets.zero,
                physics: const BouncingScrollPhysics(), // Changed to enable scrolling
                itemBuilder: (context, index) {
                  final report = filteredReports[index];
                  bool showCategoryHeader = index == 0 ||
                      filteredReports[index]['category'] !=
                          filteredReports[index - 1]['category'];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showCategoryHeader)
                        FadeInLeft(
                          duration: const Duration(milliseconds: 600),
                          child: Padding(
                            padding: EdgeInsets.only(
                              top: 8.sp,
                              bottom: 8.sp,
                            ),
                            child: Text(
                              report['category'],
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      FadeInUp(
                        duration: Duration(milliseconds: 400 + (index * 100)),
                        child: ScaleTransitionCard(
                          report: report,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            SizedBox(
              height: 50.sp,
            )
          ],
        ),
      ),
    );
  }
}

// Custom Widget for Scale Animation on Tap
class ScaleTransitionCard extends StatefulWidget {
  final Map<String, dynamic> report;

  const ScaleTransitionCard ({super.key, required this.report});

  @override
  State<ScaleTransitionCard> createState() => _ScaleTransitionCardState();
}

class _ScaleTransitionCardState extends State<ScaleTransitionCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();

        if( widget.report['title'].toString().toUpperCase()=='BKT-WISE'){
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BktWiseScreen(),
            ),
          );

        } else  if( widget.report['title'].toString().toUpperCase()=='BKT-WISE-FOS-COUNT'){

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BktWiseFosCountScreen(),
            ),
          );

        } else  if( widget.report['title'].toString().toUpperCase()=='BKT-WISE-FOS-AMOUNT'){

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BktWiseFosAmountScreen(),
            ),
          );

        }else  if( widget.report['title'].toString().toUpperCase()=='PRODUCT-WISE-BUKET-REPORT'){

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductWiseBucketReportScreen(),
            ),
          );

        }


      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Card(
          margin: EdgeInsets.only(bottom: 8.sp),
          elevation: 4,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              gradient: LinearGradient(
                colors: [
                  widget.report['color'].withOpacity(0.1),
                  Colors.white,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.sp,
                vertical: 5.sp,
              ),
              leading: CircleAvatar(
                backgroundColor: widget.report['color'].withOpacity(0.2),
                child: Icon(
                  widget.report['icon'],
                  color: widget.report['color'],
                  size: 24.sp,
                ),
              ),
              title: Text(
                widget.report['title'],
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade900,
                ),
              ),
              subtitle: Text(
                widget.report['category'],
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.grey.shade600,
                ),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 16.sp,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}