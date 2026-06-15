import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../config/api.dart';
import '../applications/GetFeeSummary.dart';
import 'PaymentHistoryPage.dart';
import 'PaymentPage.dart';

class FeeSummaryPage extends StatefulWidget {
  const FeeSummaryPage({super.key});

  @override
  State<FeeSummaryPage> createState() =>
      _FeeSummaryPageState();
}

class _FeeSummaryPageState
    extends State<FeeSummaryPage> {

  bool isLoading = true;

  bool showNotification = false;

  Map<String, dynamic>? feeData;

  String studentId = "";

  @override
  void initState() {
    super.initState();
    loadFeeSummary();
  }

  Future<void> loadFeeSummary() async {

    setState(() {
      isLoading = true;
    });

    SharedPreferences prefs =
        await SharedPreferences.getInstance();

    studentId =
        prefs.getString("student_id") ?? "";

    if (studentId.isEmpty) {

      setState(() {
        isLoading = false;
      });

      return;

    }

    var result =
        await GetFeeSummary.execute(studentId);

    if (result["success"] == true) {

      setState(() {

        feeData = result["data"];

        double balance = double.parse(
          feeData!["balance"].toString(),
        );

        showNotification = balance > 0;

        isLoading = false;

      });

      checkBlockStatus();

    } else {

      setState(() {

        isLoading = false;

      });

    }

  }

  @override
  Widget build(BuildContext context) {

    Color statusColor = Colors.red;

    if (feeData != null) {

      if (feeData!["status"] == "PAID") {

        statusColor = Colors.green;

      } else if (feeData!["status"] == "PARTIAL") {

        statusColor = Colors.orange;

      }

    }

    double total =
        double.parse(
          feeData?["total_fee"]
                  .toString() ??
              "0",
        );

    double paid =
        double.parse(
          feeData?["paid_amount"]
                  .toString() ??
              "0",
        );

    double progress =
        total == 0
            ? 0
            : paid / total;

    return Scaffold(

      appBar: AppBar(

        backgroundColor:
            Colors.blue.shade700,

        foregroundColor:
            Colors.white,

        centerTitle: true,

        leading: IconButton(

          icon: const Icon(
            Icons.arrow_back,
          ),

          onPressed: () {

            Navigator.pop(context);

          },

        ),

        title: const Text(
          "Fee Summary",
        ),

      ),

      backgroundColor:
          Colors.grey.shade100,

      body: isLoading

          ? const Center(

              child:
                  CircularProgressIndicator(),

            )

          : feeData == null

              ? const Center(

                  child: Text(

                    "No Fee Record Found",

                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
 )

              : SingleChildScrollView(

                  child: Column(

                    children: [                      Container(

                        width: double.infinity,

                        padding: const EdgeInsets.only(
                          top: 20,
                          bottom: 40,
                        ),

                        decoration: const BoxDecoration(

                          gradient: LinearGradient(

                            colors: [

                              Color(0xff1565C0),

                              Color(0xff42A5F5),

                            ],

                            begin: Alignment.topLeft,

                            end: Alignment.bottomRight,

                          ),

                          borderRadius: BorderRadius.only(

                            bottomLeft:
                                Radius.circular(30),

                            bottomRight:
                                Radius.circular(30),

                          ),

                        ),

                        child: Column(

                          children: const [

                            Icon(

                              Icons.account_balance_wallet,

                              color: Colors.white,

                              size: 70,

                            ),

                            SizedBox(height: 10),

                            Text(

                              "Tuition Fee Summary",

                              style: TextStyle(

                                color: Colors.white,

                                fontSize: 26,

                                fontWeight: FontWeight.bold,

                              ),

                            ),

                          ],

                        ),

                      ),

                      Padding(

                        padding: const EdgeInsets.all(20),

                        child: Column(

                          children: [

                            if (showNotification)

                              Container(

                                width: double.infinity,

                                margin:
                                    const EdgeInsets.only(
                                  bottom: 20,
                                ),

                                padding:
                                    const EdgeInsets.all(15),

                                decoration: BoxDecoration(

                                  color:
                                      Colors.orange.shade100,

                                  borderRadius:
                                      BorderRadius.circular(
                                          15),

                                  border: Border.all(

                                    color: Colors.orange,

                                  ),

                                ),

                                child: Row(

                                  children: [

                                    const Icon(

                                      Icons
                                          .notifications_active,

                                      color: Colors.orange,

                                      size: 35,

                                    ),

                                    const SizedBox(
                                      width: 10,
                                    ),

                                    Expanded(

                                      child: Text(

                                        "PAYMENT REMINDER\n\nYou have an outstanding tuition fee.\nPlease settle your payment to avoid academic blocking.",

                                        style:
                                            const TextStyle(

                                          fontWeight:
                                              FontWeight.bold,

                                        ),

                                      ),

                                    ),

                                  ],

                                ),

                              ),

                            Card(

                              elevation: 8,

                              shape:
                                  RoundedRectangleBorder(

                                borderRadius:
                                    BorderRadius.circular(
                                        20),

                              ),

                              child: Padding(

                                padding:
                                    const EdgeInsets.all(
                                        20),

                                child: Column(

                                  children: [

                                    LinearProgressIndicator(

                                      value: progress,

                                      minHeight: 10,

                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                                  20),

                                    ),

                                    const SizedBox(
                                      height: 10,
                                    ),

                                    Text(

                                      "${(progress * 100).toStringAsFixed(1)}% Paid",

                                      style:
                                          const TextStyle(

                                        fontWeight:
                                            FontWeight.bold,

                                        fontSize: 16,

                                      ),

                                    ),

                                    const SizedBox(
                                      height: 25,
                                    ),

                                    _buildRow(

                                      Icons.person,

                                      "Student ID",

                                      feeData![
                                          "student_id"],

                                    ),

                                    _buildRow(

                                      Icons.badge,

                                      "Fee ID",

                                      feeData![
                                          "fees_id"],

                                    ),

                                    _buildRow(

                                      Icons.payments,

                                      "Total Fee",

                                      "RM ${feeData!["total_fee"]}",

                                    ),

                                    _buildRow(

                                      Icons.check_circle,

                                      "Paid Amount",

                                      "RM ${feeData!["paid_amount"]}",

                                      color:
                                          Colors.green,

                                    ),

                                    _buildRow(

                                      Icons.warning,

                                      "Outstanding",

                                      "RM ${feeData!["balance"]}",

                                      color: Colors.red,

                                    ),

                                    const SizedBox(
                                      height: 20,
                                    ),

                                    Container(

                                      padding:
                                          const EdgeInsets
                                              .symmetric(

                                        horizontal: 20,

                                        vertical: 10,

                                      ),

                                      decoration:
                                          BoxDecoration(

                                        color: statusColor
                                            .withOpacity(
                                                0.15),

                                        borderRadius:
                                            BorderRadius
                                                .circular(
                                                    30),

                                      ),

                                      child: Text(

                                        feeData!["status"],

                                        style: TextStyle(

                                          color:
                                              statusColor,

                                          fontWeight:
                                              FontWeight.bold,

                                          fontSize: 18,

                                        ),

                                      ),

                                    ),

                                    const SizedBox(
                                      height: 30,
                                    ),
                                    SizedBox(

                                      width: double.infinity,

                                      height: 55,

                                      child: ElevatedButton.icon(

                                        icon: const Icon(
                                          Icons.payment,
                                          color: Colors.white,
                                        ),

                                        style:
                                            ElevatedButton.styleFrom(

                                          backgroundColor:
                                              Colors.blue,

                                          shape:
                                              RoundedRectangleBorder(

                                            borderRadius:
                                                BorderRadius.circular(
                                                    15),

                                          ),

                                        ),

                                        onPressed: () async {

                                          await Navigator.push(

                                            context,

                                            MaterialPageRoute(

                                              builder: (context) =>
                                                  const PaymentPage(),

                                              settings:
                                                  RouteSettings(

                                                arguments: {

                                                  "fee_id":
                                                      feeData!["fees_id"]

                                                },

                                              ),

                                            ),

                                          );

                                          loadFeeSummary();

                                        },

                                        label: const Text(

                                          "Proceed to Payment",

                                          style: TextStyle(

                                            color: Colors.white,

                                            fontSize: 17,

                                            fontWeight:
                                                FontWeight.bold,

                                          ),

                                        ),

                                      ),

                                    ),

                                    const SizedBox(height: 15),

                                    SizedBox(

                                      width: double.infinity,

                                      height: 55,

                                      child: OutlinedButton.icon(

                                        icon: const Icon(
                                          Icons.history,
                                        ),

                                        style:
                                            OutlinedButton.styleFrom(

                                          shape:
                                              RoundedRectangleBorder(

                                            borderRadius:
                                                BorderRadius.circular(
                                                    15),

                                          ),

                                        ),

                                        onPressed: () {

                                          Navigator.push(

                                            context,

                                            MaterialPageRoute(

                                              builder: (context) =>
                                                  const PaymentHistoryPage(),

                                            ),

                                          );

                                        },

                                        label: const Text(

                                          "View Payment History",

                                          style: TextStyle(

                                            fontSize: 16,

                                            fontWeight:
                                                FontWeight.bold,

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

                    ],

                  ),

                ),

    );

  }

  Widget _buildRow(

    IconData icon,

    String title,

    String value, {

    Color color = Colors.blue,

  }) {

    return Padding(

      padding:
          const EdgeInsets.symmetric(vertical: 8),

      child: Row(

        children: [

          CircleAvatar(

            radius: 18,

            backgroundColor:
                color.withOpacity(0.15),

            child: Icon(

              icon,

              color: color,

              size: 20,

            ),

          ),

          const SizedBox(width: 15),

          Expanded(

            child: Text(

              title,

              style: const TextStyle(

                fontWeight: FontWeight.w600,

                fontSize: 15,

              ),

            ),

          ),

          Text(

            value,

            style: const TextStyle(

              fontWeight: FontWeight.bold,

              fontSize: 15,

            ),

          ),

        ],

      ),

    );

  }

  Future<void> checkBlockStatus() async {

    final response = await http.get(

      Uri.parse(

        "${ApiConfig.baseUrl}/block/status/$studentId",

      ),

    );

    final data = jsonDecode(response.body);

    if (data["blocked"] == true) {

      showDialog(

        context: context,

        barrierDismissible: false,

        builder: (context) {

          return AlertDialog(

            title: const Text(

              "Academic Access Blocked",

            ),

            content: Text(

              "Outstanding Balance: RM ${data["balance"]}\n\nPlease settle your tuition fee to regain academic access.",

            ),

            actions: [

              TextButton(

                onPressed: () {

                  Navigator.pop(context);

                },

                child: const Text(
                  "OK",
                ),

              ),

            ],

          );

        },

      );

    }

  }

}                                    