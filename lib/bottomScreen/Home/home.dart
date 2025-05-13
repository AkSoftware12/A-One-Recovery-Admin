import 'package:aoneadmin/bottomScreen/Home/AllList/deducation_list.dart';
import 'package:aoneadmin/bottomScreen/Home/AllList/expenses_list.dart';
import 'package:aoneadmin/bottomScreen/Home/AllList/allowances_list.dart';
import 'package:aoneadmin/bottomScreen/Home/AllList/sallery_list.dart';
import 'package:aoneadmin/bottomScreen/Home/DialogClass/deductionDialog.dart';
import 'package:aoneadmin/bottomScreen/Home/DialogClass/manageFundDialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import '../../HexColorCode/HexColor.dart';
import '../../constants.dart';
import '../../strings.dart';
import '../../textSize.dart';
import 'AllList/employee_list.dart';
import 'DialogClass/addExpenseDialog.dart';
import 'DialogClass/allowanceDialog.dart';
import 'DialogClass/createSalleryDialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  List<Map<String, dynamic>> items = [
    {
      "icon": FaIcon(
        FontAwesomeIcons.fileInvoiceDollar,
        size: 16.sp,
        color: AppColors.bgYellow,
      ),
      "title": "Total EMIs",
      "subtitle": "3.2%",
      "amount": "142",
      "icon2": FaIcon(
        FontAwesomeIcons.arrowUp,
        size: 12.sp,
        color: Colors.green,
      ),
    },
    {
      "icon": FaIcon(
        FontAwesomeIcons.users,
        size: 16.sp,
        color: AppColors.bgYellow,
      ),
      "title": "Agents",
      "subtitle": "Active",
      "amount": "12",
      "icon2": FaIcon(
        FontAwesomeIcons.userPlus,
        size: 12.sp,
        color: Colors.green,
      ),
    },
    {
      "icon": FaIcon(
        FontAwesomeIcons.chartBar,
        size: 16.sp,
        color: AppColors.bgYellow,
      ),
      "title": "Recovery",
      "subtitle": "5.7%",
      "amount": "68%",
      "icon2": FaIcon(
        FontAwesomeIcons.arrowUp,
        size: 12.sp,
        color: Colors.green,
      ),
    },
  ];

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('dd-MMM-yyyy').format(now);
    print(formattedDate); // e.g., 2025-04-25
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.bottomBg, // top
                  AppColors.bottomBg, // middle
                ],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // 1st card Start Welcome and total,agent recovery
                Padding(
                  padding: EdgeInsets.all(TextSizes.padding11),
                  child: SizedBox(
                    width: double.infinity,
                    child: Card(
                      color: HexColor('#fefefe'),
                      child: Padding(
                          padding: EdgeInsets.all(10.sp),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Welcome, Admin!',
                                          style: GoogleFonts.poppins(
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .displayLarge,
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.045,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.textblack,
                                          ),
                                        ),
                                        SizedBox(height: 5.sp),
                                        Text(
                                          AppStrings.recovery,
                                          style: GoogleFonts.poppins(
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .displayLarge,
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.035,
                                            color: AppColors.subTitleBlack,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Container(
                                          height: 25.sp,
                                          decoration: BoxDecoration(
                                              color: AppColors.bottomBg,
                                              borderRadius:
                                                  BorderRadius.circular(5.sp)),
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 5.sp),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.calendar_month,
                                                  size: 15.sp,
                                                  color: AppColors.bgYellow,
                                                ),
                                                SizedBox(width: 5.sp),
                                                Text(
                                                  formattedDate,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: TextSizes.text12,
                                                    fontWeight: FontWeight.w500,
                                                    color: AppColors.textBlack,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: TextSizes.padding11),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: 10.sp),

                              // 👉 GridView here
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.12,
                                // or use Expanded if inside a flexible layout
                                child: GridView.builder(
                                  itemCount: items.length, // number of items
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3, // 2 columns
                                    mainAxisSpacing: 10,
                                    crossAxisSpacing: 10,
                                    childAspectRatio: 1.2, // adjust as needed
                                  ),
                                  padding: const EdgeInsets.all(0),
                                  itemBuilder: (context, index) {
                                    final item = items[index];

                                    return Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.bottomBg,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Row(
                                                children: [
                                                  item["icon"],
                                                  SizedBox(
                                                    width: 5.sp,
                                                  ),
                                                  Text(
                                                    items[index]['title']
                                                            .toString() ??
                                                        'Total EMIs',
                                                    style: GoogleFonts.poppins(
                                                      textStyle:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .displayLarge,
                                                      fontSize: 13.sp,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontStyle:
                                                          FontStyle.normal,
                                                      color: AppColors
                                                          .textblack,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 8.sp),
                                              Text(
                                                items[index]['amount']
                                                        .toString() ??
                                                    '0.0',
                                                style: GoogleFonts.poppins(
                                                  textStyle: Theme.of(context)
                                                      .textTheme
                                                      .displayLarge,
                                                  fontSize: TextSizes.text20,
                                                  fontWeight: FontWeight.w700,
                                                  fontStyle: FontStyle.normal,
                                                  color: AppColors.textblack,
                                                ),
                                              ),
                                              SizedBox(height: 8.sp),
                                              Row(
                                                children: [
                                                  item["icon2"],
                                                  SizedBox(
                                                    width: 5.sp,
                                                  ),
                                                  Text(
                                                    items[index]['subtitle']
                                                            .toString() ??
                                                        '0.0',
                                                    style: GoogleFonts.poppins(
                                                      textStyle:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .displayLarge,
                                                      fontSize:
                                                          TextSizes.text13,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontStyle:
                                                          FontStyle.normal,
                                                      color: Colors.green,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          )),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // 1st card Close


                // Quick Access Start

                Padding(
                  padding:  EdgeInsets.only(left: TextSizes.padding20,right: TextSizes.padding20),
                  child: const BottomCard(),
                ),

                // Quick Access Close


                Padding(
                  padding:  EdgeInsets.only(left: TextSizes.padding15,right: TextSizes.padding15),
                  child: Card(
                    color: AppColors.textWhite,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                    child: Padding(
                      padding:  EdgeInsets.all(TextSizes.padding20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                               Text(
                                'Recovery Progress',
                                style: GoogleFonts.poppins(
                                  textStyle: Theme.of(context).textTheme.displayLarge,
                                  fontSize: TextSizes.text15,
                                  fontWeight: FontWeight.w800,
                                  fontStyle: FontStyle.normal,
                                  color: AppColors.textblack,
                                ),
                              ),
                              // TextButton(
                              //   onPressed: () {},
                              //   child:  Text('View All', style: GoogleFonts.poppins(
                              //     textStyle: Theme.of(context).textTheme.displayLarge,
                              //     fontSize: TextSizes.text15,
                              //     fontWeight: FontWeight.w800,
                              //     fontStyle: FontStyle.normal,
                              //     color: AppColors.textblack,
                              //   ),),
                              // ),
                            ],
                          ),
                           SizedBox(height: 18.sp),
                          // Monthly Target
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children:  [
                              Text(
                                'Monthly Target',
                                style: GoogleFonts.poppins(
                                  textStyle: Theme.of(context).textTheme.displayLarge,
                                  fontSize: TextSizes.text13,
                                  fontWeight: FontWeight.w500,
                                  fontStyle: FontStyle.normal,
                                  color: AppColors.subTitleBlack,
                                ),
                              ),
                              Text(
                                '₹8.5L / ₹12L',
                                style: GoogleFonts.poppins(
                                  textStyle: Theme.of(context).textTheme.displayLarge,
                                  fontSize: TextSizes.text13,
                                  fontWeight: FontWeight.w500,
                                  fontStyle: FontStyle.normal,
                                  color: AppColors.subTitleBlack,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Progress Bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: 0.70,
                              backgroundColor: Colors.grey.shade300,
                              color: AppColors.bgYellow,
                              minHeight: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Completed & Days Left
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children:  [
                              Text('70% Completed',
                                style: GoogleFonts.poppins(
                                  textStyle: Theme.of(context).textTheme.displayLarge,
                                  fontSize: TextSizes.text13,
                                  fontWeight: FontWeight.w500,
                                  fontStyle: FontStyle.normal,
                                  color: AppColors.subTitleBlack,
                                ),),
                              Text('15 days left',
                                style: GoogleFonts.poppins(
                                  textStyle: Theme.of(context).textTheme.displayLarge,
                                  fontSize: TextSizes.text13,
                                  fontWeight: FontWeight.w500,
                                  fontStyle: FontStyle.normal,
                                  color: AppColors.subTitleBlack,
                                ),),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Line Chart
                          SizedBox(
                            height: 230.sp,
                            child: LineChart(
                              LineChartData(
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: true,
                                  horizontalInterval: 100000,
                                  getDrawingHorizontalLine: (value) {
                                    return FlLine(
                                      color: Colors.grey.withOpacity(0.2),
                                      strokeWidth: 1,
                                    );
                                  },
                                  getDrawingVerticalLine: (value) {
                                    return FlLine(
                                      color: Colors.grey.withOpacity(0.1),
                                      strokeWidth: 1,
                                    );
                                  },
                                ),
                                titlesData: FlTitlesData(
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      interval: 100000,
                                      reservedSize: 50,
                                      getTitlesWidget: (value, meta) {
                                        return Text(
                                          '₹${(value / 1000).toStringAsFixed(0)}K',
                                          style: GoogleFonts.poppins(
                                            fontSize: TextSizes.text9,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.subTitleBlack,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 30,
                                      getTitlesWidget: (value, meta) {
                                        const months = [
                                          'Jan',
                                          'Feb',
                                          'Mar',
                                          'Apr',
                                          'May',
                                          'Jun',
                                          'Jul'
                                        ];
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 8),
                                          child: Text(
                                            months[value.toInt()],
                                            style: GoogleFonts.poppins(
                                              fontSize: TextSizes.text11,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.subTitleBlack,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                ),
                                borderData: FlBorderData(
                                  show: true,
                                  border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
                                ),
                                minX: 0,
                                maxX: 6,
                                minY: 0,
                                maxY: 600000,
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: [
                                      FlSpot(0, 300000),
                                      FlSpot(1, 320000),
                                      FlSpot(2, 450000),
                                      FlSpot(3, 370000),
                                      FlSpot(4, 420000),
                                      FlSpot(5, 500000),
                                      FlSpot(6, 560000),
                                    ],
                                    isCurved: true,
                                    color: AppColors.bgYellow,
                                    barWidth: 4,
                                    isStrokeCapRound: true,
                                    belowBarData: BarAreaData(
                                      show: true,
                                      color: AppColors.bgYellow.withOpacity(0.15),
                                    ),
                                    dotData: FlDotData(
                                      show: true,
                                      getDotPainter: (spot, percent, barData, index) =>
                                          FlDotCirclePainter(
                                            radius: 4,
                                            color: AppColors.bgYellow,
                                            strokeWidth: 2,
                                            strokeColor: Colors.white,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding:  EdgeInsets.only(left: TextSizes.padding15,right: TextSizes.padding15,top: TextSizes.padding15),
                  child: Card(
                    color: AppColors.textWhite,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                    child: Padding(
                      padding:  EdgeInsets.all(TextSizes.padding11),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Top Performing Employee',
                                style: GoogleFonts.poppins(
                                  textStyle: Theme.of(context).textTheme.displayLarge,
                                  fontSize: TextSizes.text15,
                                  fontWeight: FontWeight.w800,
                                  fontStyle: FontStyle.normal,
                                  color: AppColors.textblack,
                                ),
                              ),
                              TextButton(
                                onPressed: () {},
                                child:  Text('View All', style: GoogleFonts.poppins(
                                  textStyle: Theme.of(context).textTheme.displayLarge,
                                  fontSize: TextSizes.text15,
                                  fontWeight: FontWeight.w500,
                                  fontStyle: FontStyle.normal,
                                  color: AppColors.bgYellow,
                                ),),
                              ),
                            ],
                          ),
                          SizedBox(height: 10.sp),
                          // Monthly Target
                          ListView.builder(
                              itemCount: 3,
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.all(0),
                              itemBuilder: (context, index) {
                                return ClientCard(
                                  name: "Vikram Singh",
                                  bank: "H92% Recovery Rate",
                                  location: "Rohini, Delhi",
                                  time: "10:30 AM",
                                  days: "2 Month",
                                  amount: "₹24,500",
                                  color: Colors.purple,
                                );
                              }),


                          // Progress Bar

                          // Line Chart
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(
                  height: 80.sp,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EmiSummarySection extends StatelessWidget {
  const EmiSummarySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        children: [
          SizedBox(height: 5.sp),
          Row(
            children: [
              Expanded(
                child: SummaryCard(
                  title: "Allotted EMIs",
                  value: "47225",
                  subValue: "Assigned",
                  icon: Icons.check,
                  color: Colors.green,
                  img: SvgPicture.asset(
                    'assets/emi.svg',
                    height: 30.sp,
                    width: 30.sp,
                  ),
                ),
              ),
              SizedBox(width: 5),
              Expanded(
                child: SummaryCard(
                  title: "Pending EMIs",
                  value: "28225",
                  subValue: "In progress",
                  icon: Icons.timer,
                  color: HexColor('#f8ca4a'),
                  img: SvgPicture.asset(
                    'assets/time.svg',
                    height: 30.sp,
                    width: 30.sp,
                  ),
                ),
              ),
              SizedBox(width: 5),
              Expanded(
                child: SummaryCard(
                  title: "Pending EMIs",
                  value: "28225",
                  subValue: "In progress",
                  icon: Icons.timer,
                  color: HexColor('#f8ca4a'),
                  img: SvgPicture.asset(
                    'assets/time.svg',
                    height: 30.sp,
                    width: 30.sp,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String subValue;
  final IconData icon;
  final Color color;
  final SvgPicture img;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.subValue,
    required this.icon,
    required this.color,
    required this.img,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100.sp,
      child: Card(
        color: HexColor('#fefefe'),
        child: Padding(
          padding: EdgeInsets.all(TextSizes.padding9),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      textStyle: Theme.of(context).textTheme.displayLarge,
                      fontSize: TextSizes.text11,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.normal,
                      color: AppColors.subTitleBlack,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      textStyle: Theme.of(context).textTheme.displayLarge,
                      fontSize: MediaQuery.of(context).size.width * 0.01,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.normal,
                      color: AppColors.textblack,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 3.sp),
                        child: Icon(
                          icon,
                          size: 18.sp,
                          color: color,
                        ),
                      ),
                      Text(
                        subValue,
                        style: GoogleFonts.poppins(
                          textStyle: Theme.of(context).textTheme.displayLarge,
                          fontSize: MediaQuery.of(context).size.width * 0.01,
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.normal,
                          color: AppColors.subTitleBlack,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              img
            ],
          ),
        ),
      ),
    );
  }
}


class BottomCard extends StatefulWidget {
  const BottomCard({super.key});

  @override
  State<BottomCard> createState() => _BottomCardState();
}

class _BottomCardState extends State<BottomCard> {
  final AllowanceDialog _allowanceDialog = AllowanceDialog();
  final CreateSalleryDialog _createSalleryDialog = CreateSalleryDialog();
  final DeductionDialog _deductionDialog = DeductionDialog();
  final ManageFundDialog _manageFundDialog = ManageFundDialog();

  List<Map<String, dynamic>> items = [
    {
      "icon": FaIcon(
        FontAwesomeIcons.userPlus,
        size: 16.sp,
        color: AppColors.textWhite,
      ),
      "title": "Total EMIs",
      "subtitle": "3.2%",
      "amount": "Employee",
      "icon2": FaIcon(
        FontAwesomeIcons.arrowUp,
        size: 12.sp,
        color: AppColors.textWhite,
      ),
      "color":HexColor('#3b82f6')
    },
    {
      "icon": FaIcon(
        FontAwesomeIcons.fileInvoiceDollar,
        size: 16.sp,
        color: AppColors.textWhite,
      ),
      "title": "Agents",
      "subtitle": "Active",
      "amount": "Expenses",
      "icon2": FaIcon(
        FontAwesomeIcons.userPlus,
        size: 12.sp,
        color: Colors.green,
      ),
      "color":HexColor('#22c55e')

    },
    {
      "icon": FaIcon(
        FontAwesomeIcons.fileInvoiceDollar,
        size: 16.sp,
        color: AppColors.textWhite,
      ),
      "title": "Recovery",
      "subtitle": "5.7%",
      "amount": "Allowance",
      "icon2": FaIcon(
        FontAwesomeIcons.arrowUp,
        size: 12.sp,
        color: Colors.green,
      ),
      "color":HexColor('#eab308')

    },
    {
      "icon": FaIcon(
        FontAwesomeIcons.moneyBill1Wave,
        size: 16.sp,
        color: AppColors.textWhite,
      ),
      "title": "Total EMIs",
      "subtitle": "3.2%",
      "amount": "Salary",
      "icon2": FaIcon(
        FontAwesomeIcons.arrowUp,
        size: 12.sp,
        color: Colors.green,
      ),
      "color":HexColor('#ef4444')

    },
    {
      "icon": FaIcon(
        FontAwesomeIcons.minusCircle,
        size: 16.sp,
        color: AppColors.textWhite,
      ),
      "title": "Agents",
      "subtitle": "Active",
      "amount": "Deduction",
      "icon2": FaIcon(
        FontAwesomeIcons.userPlus,
        size: 12.sp,
        color: Colors.green,
      ),
      "color":HexColor('#6366f1')

    },
    {
      "icon": FaIcon(
        FontAwesomeIcons.wallet,
        size: 16.sp,
        color: AppColors.textWhite,
      ),
      "title": "Recovery",
      "subtitle": "5.7%",
      "amount": "Manage Fund",
      "icon2": FaIcon(
        FontAwesomeIcons.arrowUp,
        size: 12.sp,
        color: Colors.green,
      ),
      "color":HexColor('#6366f1')

    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        Padding(
          padding: EdgeInsets.only(
              left: TextSizes.padding5, right: TextSizes.padding5,bottom: 10.sp),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Quick Access',
                    style: GoogleFonts.poppins(
                      textStyle: Theme.of(context).textTheme.displayLarge,
                      fontSize: TextSizes.text15,
                      fontWeight: FontWeight.w800,
                      fontStyle: FontStyle.normal,
                      color: AppColors.textblack,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(
          height: 2.sp,
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.3,
          // or use Expanded if inside a flexible layout
          child: GridView.builder(
            itemCount: items.length, // number of items
            physics: NeverScrollableScrollPhysics(),
            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // 2 columns
              mainAxisSpacing: 15,
              crossAxisSpacing: 15,
              childAspectRatio: 0.94, // adjust as needed
            ),
            padding: const EdgeInsets.all(0),
            itemBuilder: (context, index) {
              final item = items[index];

              return GestureDetector(
                onTap: (){

                  if(item['amount']=='Employee'){

                    PersistentNavBarNavigator.pushNewScreen(
                      context,
                      screen: EmployeeScreen(
                        menuScreenContext: context,
                      ),
                    );
                  } else if(item['amount']=='Expenses'){

                    PersistentNavBarNavigator.pushNewScreen(
                      context,
                      screen: ExpensesScreen(
                        // menuScreenContext: context,
                      ),
                    );

                  } else if(item['amount']=='Allowance'){
                    // _allowanceDialog.show(context);

                    PersistentNavBarNavigator.pushNewScreen(
                      context,
                      screen: AllowanceScreen(
                        // menuScreenContext: context,
                      ),
                    );

                  }else if(item['amount']=='Salary'){
                    // _createSalleryDialog.show(context);
                    PersistentNavBarNavigator.pushNewScreen(
                      context,
                      screen: SalaryScreen(
                        // menuScreenContext: context,
                      ),
                    );

                  }else if(item['amount']=='Deduction'){

                    PersistentNavBarNavigator.pushNewScreen(
                      context,
                      screen: DeducationScreen(
                        // menuScreenContext: context,
                      ),
                    );

                  }else if(item['amount']=='Manage Fund'){
                    _manageFundDialog.show(context);

                  }



                },
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.textWhite,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Stack(
                    children: [
                      // Align(
                      //   alignment: Alignment.topRight,
                      //   child: Container(
                      //     width: 25.sp,
                      //     height: 20.sp,
                      //     decoration: BoxDecoration(
                      //         color: AppColors.bgYellow,
                      //
                      //         borderRadius:BorderRadius.all(Radius.circular(10))
                      //     ),
                      //     child: Center(
                      //       child: Padding(
                      //         padding: const EdgeInsets.all(5.0),
                      //         child: Text('25',style: TextStyle(fontSize: 12.sp,color: Colors.white),),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 45.sp,  // size
                                height: 45.sp,
                                decoration: BoxDecoration(
                                  color: item['color'],
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: item["icon"],

                                ),
                              ),
                              SizedBox(height: 8.sp),
                              Center(
                                child: Column(
                                  children: [
                                    Text(
                                     '${ items[index]['amount'].toString()}',
                                      style: GoogleFonts.poppins(
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .displayLarge,
                                        fontSize: TextSizes.text12,
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FontStyle.normal,
                                        color: AppColors.textblack,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 5.sp),

                                    Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(0.0),
                                        child: Text('(${25})', style: GoogleFonts.poppins(
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .displayLarge,
                                          fontSize: TextSizes.text12,
                                          fontWeight: FontWeight.w800,
                                          fontStyle: FontStyle.normal,
                                          color: AppColors.textblack,
                                        ),),
                                      ),
                                    )
                                  ],
                                ),

                              ),
                              SizedBox(height: 8.sp),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

      ],
    );
  }
}

class SummaryBottomCard extends StatelessWidget {
  final String title;
  final String value;
  final String subValue;
  final FaIcon icon;
  final Color color;

  const SummaryBottomCard({
    super.key,
    required this.title,
    required this.value,
    required this.subValue,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        color: Colors.grey.shade300,
        child: Padding(
          padding: EdgeInsets.all(TextSizes.padding15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      textStyle: Theme.of(context).textTheme.displayLarge,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.normal,
                      color: AppColors.subTitleBlack,
                    ),
                  ),
                  SizedBox(height: 8.sp),
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      textStyle: Theme.of(context).textTheme.displayLarge,
                      fontSize: TextSizes.text20,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.normal,
                      color: AppColors.textblack,
                    ),
                  ),
                  SizedBox(height: 8.sp),
                  Row(
                    children: [
                      icon,
                      SizedBox(
                        width: 5.sp,
                      ),
                      Text(
                        subValue,
                        style: GoogleFonts.poppins(
                          textStyle: Theme.of(context).textTheme.displayLarge,
                          fontSize: TextSizes.text11,
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.normal,
                          color: color,
                        ),
                      ),
                    ],
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

class ClientCard extends StatelessWidget {
  final String name;
  final String bank;
  final String location;
  final String time;
  final String days;
  final String amount;
  final Color color;

  const ClientCard({
    super.key,
    required this.name,
    required this.bank,
    required this.location,
    required this.time,
    required this.days,
    required this.amount, required this.color,
  });

  @override
  Widget build(BuildContext context) {
    String initials = '';
    if (name.isNotEmpty) initials += name[0];
    // if (lastName.isNotEmpty) initials += lastName[0];
    return  Padding(
      padding:  EdgeInsets.only(bottom: TextSizes.padding15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                height: 40.sp, // or 25.sp if using flutter_screenutil
                width: 40.sp,
                decoration: BoxDecoration(
                  color: color, // background color
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  initials.toUpperCase(),
                  style: GoogleFonts.poppins(
                    textStyle: Theme.of(context).textTheme.displayLarge,
                    fontSize: TextSizes.text16,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.normal,
                    color: AppColors.textWhite,
                  ),
                ),
              ),
              SizedBox(
                width: 5.sp,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.poppins(
                      textStyle: Theme.of(context).textTheme.displayLarge,
                      fontSize: TextSizes.text13,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.normal,
                      color: AppColors.textblack,
                    ),
                  ),
                  SizedBox(height: 3.sp,),
                  Text(
                    bank,
                    style: GoogleFonts.poppins(
                      textStyle: Theme.of(context).textTheme.displayLarge,
                      fontSize: TextSizes.text12,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.normal,
                      color: AppColors.subTitleBlack,
                    ),
                  ),
                ],
              )
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '₹3.2L',
                style: GoogleFonts.poppins(
                  textStyle: Theme.of(context).textTheme.displayLarge,
                  fontSize: TextSizes.text13,
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.normal,
                  color: AppColors.textblack,
                ),
              ),
              SizedBox(height: 3.sp,),
              Text(
                '+12% this month',
                style: GoogleFonts.poppins(
                  textStyle: Theme.of(context).textTheme.displayLarge,
                  fontSize: TextSizes.text12,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.normal,
                  color: Colors.green,
                ),
              ),
            ],
          )

        ],
      ),
    );
  }
}
