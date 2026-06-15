import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../LoginPage.dart';


import 'SetFee.dart';
import 'UpdateFee.dart';
import 'PaymentRecordsPage.dart';
import 'OutstandingStudentsPage.dart';

class TreasuryDashboard extends StatefulWidget {
  const TreasuryDashboard({super.key});

  @override
  State<TreasuryDashboard> createState() => _TreasuryDashboardState();
}

class _TreasuryDashboardState extends State<TreasuryDashboard> {
  final String baseUrl = "http://127.0.0.1:8000/api";

  bool isLoading = true;

  int totalStudents = 0;
  double totalCollected = 0;
  double totalOutstanding = 0;
  int blockedStudents = 0;

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/treasury/dashboard"),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        setState(() {
          totalStudents =
              jsonData["data"]["total_students"] ?? 0;

          totalCollected =
              double.parse(
                jsonData["data"]["total_collected"]
                    .toString(),
              );

          totalOutstanding =
              double.parse(
                jsonData["data"]["total_outstanding"]
                    .toString(),
              );

          blockedStudents =
              jsonData["data"]["blocked_students"] ?? 0;

          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  Widget dashboardCard(
      String title,
      String value,
      IconData icon,
      Color color) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(15),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        width: 170,
        child: Column(
          children: [
            Icon(
              icon,
              size: 45,
              color: color,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                color: color,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget menuButton(
      String title,
      IconData icon,
      Widget page,
      Color color) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 8,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton.icon(
          style:
              ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor:
                Colors.white,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => page,
              ),
            );
          },
          icon: Icon(icon),
          label: Text(
            title,
            style: const TextStyle(
              fontSize: 17,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.grey.shade100,

    
appBar: AppBar(
  backgroundColor: Colors.blue.shade700,
  foregroundColor: Colors.white,
  centerTitle: true,
  title: const Text(
    "Treasury Dashboard",
  ),
  actions: [

    IconButton(

      icon: const Icon(
        Icons.logout,
      ),

      tooltip: "Logout",

      onPressed: () async {

        SharedPreferences prefs =
            await SharedPreferences.getInstance();

        await prefs.clear();

        if (context.mounted) {

          Navigator.pushAndRemoveUntil(

            context,

            MaterialPageRoute(

              builder: (_) =>
                  const LoginPage(),

            ),

            (route) => false,

          );

        }

      },

    ),

  ],
),


      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Column(
                children: [

                  const SizedBox(
                    height: 20,
                  ),

                  const Text(
                    "Treasury Management",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  Wrap(
                    alignment:
                        WrapAlignment
                            .center,
                    children: [

                      dashboardCard(
                        "Students",
                        totalStudents
                            .toString(),
                        Icons.people,
                        Colors.blue,
                      ),

                      dashboardCard(
                        "Collected",
                        "RM ${totalCollected.toStringAsFixed(2)}",
                        Icons.attach_money,
                        Colors.green,
                      ),

                      dashboardCard(
                        "Outstanding",
                        "RM ${totalOutstanding.toStringAsFixed(2)}",
                        Icons.warning,
                        Colors.orange,
                      ),

                      dashboardCard(
                        "Blocked",
                        blockedStudents
                            .toString(),
                        Icons.block,
                        Colors.red,
                      ),

                    ],
                  ),

                  const SizedBox(
                    height: 30,
                  ),

                  menuButton(
                    "Outstanding Students",
                    Icons.people_alt,
                    const OutstandingStudents(),
                    Colors.orange,
                  ),

                  menuButton(
                    "Set Fee",
                    Icons.add,
                    const SetFee(),
                    Colors.green,
                  ),

                  menuButton(
                    "Update Fee",
                    Icons.edit,
                    const UpdateFee(),
                    Colors.blue,
                  ),

                  menuButton(
                    "Payment Records",
                    Icons.receipt_long,
                    const PaymentRecord(),
                    Colors.purple,
                  ),

                  const SizedBox(
                    height: 30,
                  ),
                ],
              ),
            ),
    );
  }


}
