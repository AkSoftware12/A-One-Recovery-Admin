import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RecoveryNotificationScreen extends StatelessWidget {
  const RecoveryNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> recoveryList = [
      {
        "title": "Payment Pending",
        "message": "₹2,000 is pending from client Ramesh Kumar.",
        "time": "Today, 9:30 AM"
      },
      {
        "title": "Partial Payment Received",
        "message": "₹1,000 received from client Sunil Sharma.",
        "time": "Yesterday, 6:20 PM"
      },
      {
        "title": "Payment Reminder Sent",
        "message": "Reminder message sent to Ankit Enterprises.",
        "time": "2 days ago"
      },
      {
        "title": "Full Payment Received",
        "message": "₹5,000 received from Deepak Traders.",
        "time": "3 days ago"
      },
      {
        "title": "Overdue Alert",
        "message": "₹8,000 payment from Rajeev Textiles is overdue by 7 days.",
        "time": "1 week ago"
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xfff5f7fa),
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        centerTitle: true,
        elevation: 0,
        title: Text(
          'Recovery Notifications',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: recoveryList.length,
        itemBuilder: (context, index) {
          final item = recoveryList[index];
          final bool isReceived = item['title']!.contains("Received");
          final bool isPending = item['title']!.contains("Pending");
          final bool isReminder = item['title']!.contains("Reminder");

          Color iconBg;
          IconData iconData;

          if (isReceived) {
            iconBg = Colors.green.shade100;
            iconData = Icons.check_circle_outline;
          } else if (isPending) {
            iconBg = Colors.orange.shade100;
            iconData = Icons.warning_amber_rounded;
          } else if (isReminder) {
            iconBg = Colors.blue.shade100;
            iconData = Icons.notifications_active_outlined;
          } else {
            iconBg = Colors.red.shade100;
            iconData = Icons.error_outline;
          }

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(iconData, color: Colors.indigo, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'] ?? '',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['message'] ?? '',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item['time'] ?? '',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
