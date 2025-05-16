import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class Offer {
  final String loanNo;
  final String name;
  final String portfolio;
  final String branch;
  final String amountCollection;
  final String collectionDate;
  final String recoveryStatus;
  final String assignedEmployee;

  Offer({
    required this.loanNo,
    required this.name,
    required this.portfolio,
    required this.branch,
    required this.amountCollection,
    required this.collectionDate,
    required this.recoveryStatus,
    required this.assignedEmployee,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      loanNo: json['loanNo'] as String,
      name: json['name'] as String,
      portfolio: json['portfolio'] as String,
      branch: json['branch'] as String,
      amountCollection: json['amountCollection'] as String,
      collectionDate: json['collectionDate'] as String,
      recoveryStatus: json['recoveryStatus'] as String,
      assignedEmployee: json['assignedEmployee'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'loanNo': loanNo,
      'name': name,
      'portfolio': portfolio,
      'branch': branch,
      'amountCollection': amountCollection,
      'collectionDate': collectionDate,
      'recoveryStatus': recoveryStatus,
      'assignedEmployee': assignedEmployee,
    };
  }
}

class LoanPage extends StatefulWidget {
  const LoanPage({super.key});

  @override
  State<LoanPage> createState() => _LoanPageState();
}

class _LoanPageState extends State<LoanPage> {
  final List<Offer> offers = [
    Offer(
      loanNo: "LN001",
      name: "John Doe",
      portfolio: "Personal Loan",
      branch: "Downtown",
      amountCollection: "₹50,000",
      collectionDate: "2025-05-10",
      recoveryStatus: "Pending",
      assignedEmployee: "Alice Smith",
    ),
    Offer(
      loanNo: "LN002",
      name: "Jane Roe",
      portfolio: "Home Loan",
      branch: "Uptown",
      amountCollection: "₹1,50,000",
      collectionDate: "2025-05-12",
      recoveryStatus: "Collected",
      assignedEmployee: "Bob Johnson",
    ),
    Offer(
      loanNo: "LN003",
      name: "Emily Brown",
      portfolio: "Car Loan",
      branch: "Suburb",
      amountCollection: "₹25,000",
      collectionDate: "2025-05-15",
      recoveryStatus: "Overdue",
      assignedEmployee: "Carol White",
    ),
    Offer(
      loanNo: "LN004",
      name: "Michael Green",
      portfolio: "Business Loan",
      branch: "City Center",
      amountCollection: "₹2,00,000",
      collectionDate: "2025-05-08",
      recoveryStatus: "Collected",
      assignedEmployee: "David Lee",
    ),
    Offer(
      loanNo: "LN005",
      name: "Sarah Wilson",
      portfolio: "Personal Loan",
      branch: "Downtown",
      amountCollection: "₹75,000",
      collectionDate: "2025-05-14",
      recoveryStatus: "Pending",
      assignedEmployee: "Emma Davis",
    ),
  ];

  int _selectedIndex = 0;
  final Map<int, bool> _expandedCards = {};

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Handle navigation logic here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal, Colors.tealAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        title: Text(
          "Loan Dashboard",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.white,
            child: Text(
              "JD",
              style: GoogleFonts.poppins(
                color: Colors.teal,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'Add Loan',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 8,
        onTap: _onItemTapped,
      ),
      body: Column(
        children: [
          // Banner
          Container(
            margin: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.teal, Colors.tealAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElasticIn(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Collections Overview",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMetricCard("Total Loans", offers.length.toString()),
                      _buildMetricCard("Pending", offers.where((o) => o.recoveryStatus == "Pending").length.toString()),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                    ),
                    child: Text(
                      "View Full Report",
                      style: GoogleFonts.poppins(
                        color: Colors.teal,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Loan List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {}); // Simulate refresh
                await Future.delayed(const Duration(seconds: 1));
              },
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 16.0),
                itemCount: offers.length,
                itemBuilder: (context, index) {
                  final offer = offers[index];
                  final isExpanded = _expandedCards[index] ?? false;
                  return FadeInUp(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _expandedCards[index] = !isExpanded;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Loan #${offer.loanNo}",
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.teal,
                                  ),
                                ),
                                Icon(
                                  isExpanded ? Icons.expand_less : Icons.expand_more,
                                  color: Colors.teal,
                                ),
                              ],
                            ),
                            Text(
                              offer.name,
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
                                  "Amount: ${offer.amountCollection}",
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const Spacer(),
                                _buildStatusIndicator(offer.recoveryStatus),
                              ],
                            ),
                            if (isExpanded) ...[
                              const Divider(height: 16, thickness: 1),
                              _buildDetailRow(Icons.account_balance_wallet, "Portfolio", offer.portfolio),
                              _buildDetailRow(Icons.location_city, "Branch", offer.branch),
                              _buildDetailRow(Icons.calendar_today, "Collection Date", offer.collectionDate),
                              _buildDetailRow(Icons.person, "Assigned", offer.assignedEmployee),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(String status) {
    Color color;
    IconData icon;
    switch (status) {
      case "Collected":
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
              value,
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