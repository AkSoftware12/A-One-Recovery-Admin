
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import '../../BottomNavigation/Bottom2/screens.dart';
import '../../HexColorCode/HexColor.dart';
import '../../constants.dart';
import '../../strings.dart';
import '../../textSize.dart';



class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {


  @override
  Widget build(BuildContext context) {
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
                  AppColors.topBg, // top
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
                Padding(
                  padding: EdgeInsets.all(TextSizes.padding5),
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
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Welcome, Admin!',
                                        style: GoogleFonts.poppins(
                                          textStyle: Theme.of(context).textTheme.displayLarge,
                                          fontSize: MediaQuery.of(context).size.width * 0.045,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textblack,
                                        ),
                                      ),
                                      SizedBox(height: 5.sp),
                                      Text(
                                        AppStrings.recovery,
                                        style: GoogleFonts.poppins(
                                          textStyle: Theme.of(context).textTheme.displayLarge,
                                          fontSize: MediaQuery.of(context).size.width * 0.03,
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
                                            borderRadius: BorderRadius.circular(5.sp)),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 5.sp),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.calendar_month,
                                                size: 15.sp,
                                                color: AppColors.bgYellow,
                                              ),
                                              SizedBox(width: 5.sp),
                                              Text(
                                                '23 Apr 2025',
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
                              height: MediaQuery.of(context).size.height * 0.15, // or use Expanded if inside a flexible layout
                              child: GridView.builder(
                                itemCount: 3, // number of items
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3, // 2 columns
                                  mainAxisSpacing: 10,
                                  crossAxisSpacing: 10,
                                  childAspectRatio: 1, // adjust as needed
                                ),
                                padding: const EdgeInsets.all(0),
                                itemBuilder: (context, index) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.bottomBg,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child:Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(FontAwesomeIcons.recordVinyl,color: AppColors.bgYellow,size: 11.sp,),
                                                SizedBox(width: 5.sp,),
                                                Text(
                                                  'Total EMIs',
                                                  style: GoogleFonts.poppins(
                                                    textStyle: Theme.of(context).textTheme.displayLarge,
                                                    fontSize: 11.sp,
                                                    fontWeight: FontWeight.w600,
                                                    fontStyle: FontStyle.normal,
                                                    color: AppColors.subTitleBlack,
                                                  ),
                                                ),
                                              ],
                                            ),


                                            SizedBox(height: 8.sp),
                                            Text(
                                              '2535',
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
                                                Icon(FontAwesomeIcons.arrowUp,color: Colors.green,size: 11.sp,),
                                                SizedBox(width: 5.sp,),
                                                Text(
                                                  '3.2%',
                                                  style: GoogleFonts.poppins(
                                                    textStyle: Theme.of(context).textTheme.displayLarge,
                                                    fontSize: TextSizes.text11,
                                                    fontWeight: FontWeight.w500,
                                                    fontStyle: FontStyle.normal,
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
                        )

                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const ClientListSection(),
                const BottomCard(),







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
                      fontSize: MediaQuery.of(context).size.width*0.01,
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
                          fontSize: MediaQuery.of(context).size.width*0.01,
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

class ClientListSection extends StatelessWidget {
  const ClientListSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(
              left: TextSizes.padding15, right: TextSizes.padding5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.insert_chart,
                    color: AppColors.bgYellow,
                    size: 18.sp,
                  ),
                  SizedBox(
                    width: 5.sp,
                  ),
                  Text(
                    'Recent client list',
                    style: GoogleFonts.poppins(
                      textStyle: Theme.of(context).textTheme.displayLarge,
                      fontSize: TextSizes.text15,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.normal,
                      color: AppColors.textblack,
                    ),
                  ),
                ],
              ),
              TextButton(
                  onPressed: () {
                    print('click');
                  },
                  child: Text(
                    "View All",
                    style: GoogleFonts.poppins(
                      textStyle: Theme.of(context).textTheme.displayLarge,
                      fontSize: TextSizes.text15,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.normal,
                      color: AppColors.bgYellow,
                    ),
                  )),
            ],
          ),
        ),
        ListView.builder(
            itemCount: 2,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.all(0),
            itemBuilder: (context, index) {
              return ClientCard(
                name: "Vikram Singh",
                bank: "HDFC Bank - Personal Loan",
                location: "Rohini, Delhi",
                time: "10:30 AM",
                days: "2 Month",
                amount: "₹24,500",
              );
            }),
      ],
    );
  }
}

class BottomCard  extends StatelessWidget {
  const BottomCard({super.key});

  @override
  Widget build(BuildContext context) {
    double collectionsProgress = 7.5/ 9.5;
    double collectionsTargetAchieved = 7.5;
    double collectionsTargetTotal = 9.5;
    double emiResolutionRate = 50; // in percentage
    return Column(
      children: [
        SizedBox(
          height: 10.sp,
        ),
        Padding(
          padding: EdgeInsets.only(
              left: TextSizes.padding15, right: TextSizes.padding5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.insert_chart,
                    color: AppColors.bgYellow,
                    size: 18.sp,
                  ),
                  SizedBox(
                    width: 5.sp,
                  ),
                  Text(
                    'Performance Summary',
                    style: GoogleFonts.poppins(
                      textStyle: Theme.of(context).textTheme.displayLarge,
                      fontSize: TextSizes.text15,
                      fontWeight: FontWeight.w700,
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
          height: 10.sp,
        ),
        Padding(
          padding: EdgeInsets.only(
              left: TextSizes.padding15, right: TextSizes.padding5),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
                color: AppColors.textWhite,
                borderRadius: BorderRadius.circular(10)
            ),
            child: Column(

              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: SummaryBottomCard(
                          title: "Recovery Rate",
                          value: "86%",
                          subValue: "+ 2.5%",
                          icon: FaIcon(FontAwesomeIcons.arrowUp,size: 12.sp,color: Colors.green,),
                          color: Colors.green,

                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: SummaryBottomCard(
                          title: "Monthly Target",
                          value: "92%",
                          subValue: "On Track",
                          icon: FaIcon(FontAwesomeIcons.arrowUp,size: 12.sp,color: Colors.green,),
                          color: Colors.green,

                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:  EdgeInsets.only(left: TextSizes.padding15,right: TextSizes.padding15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Collections Target",
                            style: GoogleFonts.poppins(
                              textStyle: Theme.of(context).textTheme.displayLarge,
                              fontSize: TextSizes.text15,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.normal,
                              color: AppColors.subTitleBlack,
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              "${collectionsTargetAchieved}L of ${collectionsTargetTotal}L",
                              style: GoogleFonts.poppins(
                                textStyle: Theme.of(context).textTheme.displayLarge,
                                fontSize: TextSizes.text15,
                                fontWeight: FontWeight.w500,
                                fontStyle: FontStyle.normal,
                                color: AppColors.subTitleBlack,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: collectionsTargetAchieved / collectionsTargetTotal,
                          color: Colors.orange,
                          backgroundColor: AppColors.subTitleBlack,
                          minHeight: 8,
                        ),
                      ),



                      SizedBox(height: 20.sp),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "EMI Resolution Rate",
                            style: GoogleFonts.poppins(
                              textStyle: Theme.of(context).textTheme.displayLarge,
                              fontSize: TextSizes.text15,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.normal,
                              color: AppColors.subTitleBlack,
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              "${emiResolutionRate.toStringAsFixed(0)}%",
                              style: GoogleFonts.poppins(
                                textStyle: Theme.of(context).textTheme.displayLarge,
                                fontSize: TextSizes.text15,
                                fontWeight: FontWeight.w500,
                                fontStyle: FontStyle.normal,
                                color: AppColors.subTitleBlack,
                              ),
                            ),
                          ),

                        ],
                      ),
                      SizedBox(height: 5.sp),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),

                        child: LinearProgressIndicator(
                          value: emiResolutionRate / 100,
                          color: Colors.orange,
                          backgroundColor: AppColors.subTitleBlack,
                          minHeight: 8,
                        ),
                      ),

                      SizedBox(height: 15.sp),

                    ],
                  ),
                )
              ],




            ),


          ),
        )

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
                      SizedBox(width: 5.sp,),
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

  const ClientCard({
    super.key,
    required this.name,
    required this.bank,
    required this.location,
    required this.time,
    required this.days,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: HexColor('#fefefe'),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SvgPicture.asset(
                  'assets/excla.svg',
                  height: 25.sp,
                  width: 25.sp,
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
                        fontSize: TextSizes.text14,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.normal,
                        color: AppColors.textblack,
                      ),
                    ),
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
            SizedBox(
              height: 10.sp,
            ),
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(5.sp)),
                  child: Padding(
                    padding: EdgeInsets.all(4.sp),
                    child: Row(
                      children: [
                        Icon(Icons.location_on,
                            size: TextSizes.padding15,
                            color: AppColors.bgYellow),
                        const SizedBox(width: 4),
                        Text(
                          location,
                          style: GoogleFonts.poppins(
                            textStyle: Theme.of(context).textTheme.displayLarge,
                            fontSize: TextSizes.text12,
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.normal,
                            color: AppColors.subTitleBlack,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(4.sp),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_month,
                          size: TextSizes.padding15, color: AppColors.bgYellow),
                      const SizedBox(width: 4),
                      Text(
                        '25/04/2025',
                        style: GoogleFonts.poppins(
                          textStyle: Theme.of(context).textTheme.displayLarge,
                          fontSize: TextSizes.text12,
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.normal,
                          color: AppColors.subTitleBlack,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(10.sp)),
                  child: Padding(
                    padding: EdgeInsets.all(5.sp),
                    child: Row(
                      children: [
                        Text(
                          days,
                          style: GoogleFonts.poppins(
                            textStyle: Theme.of(context).textTheme.displayLarge,
                            fontSize: TextSizes.text11,
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.normal,
                            color: AppColors.textWhite,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.sp),
            Divider(
              height: 1.sp,
              color: Colors.grey,
              thickness: 1.sp,
            ),
            SizedBox(height: 10.sp),
            Row(
              children: [
                Text(
                  amount,
                  style: GoogleFonts.poppins(
                    textStyle: Theme.of(context).textTheme.displayLarge,
                    fontSize: TextSizes.text18,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.normal,
                    color: AppColors.textblack,
                  ),
                ),
                const Spacer(),
                Container(
                  height: 30.sp,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.bgYellow, // background color of the circle
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.call,
                      color: Colors.white,
                      size: 15.sp,
                    ),
                    onPressed: () {
                      // your onPressed logic here
                    },
                  ),
                ),
                Container(
                  height: 30.sp,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green, // background color of the circle
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.map,
                      color: Colors.white,
                      size: 15.sp,
                    ),
                    onPressed: () {
                      // your onPressed logic here
                    },
                  ),
                ),
                SizedBox(
                  width: 5.sp,
                ),
                SizedBox(
                  height: 30.sp,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      HexColor('#fe9b07'), // set your desired color here
                    ),
                    child: Text(
                      "Collect",
                      style: GoogleFonts.poppins(
                        textStyle: Theme.of(context).textTheme.displayLarge,
                        fontSize: TextSizes.text13,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.normal,
                        color: AppColors.textWhite,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}



