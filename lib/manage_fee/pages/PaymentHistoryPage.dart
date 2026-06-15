import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../applications/GetPaymentHistory.dart';
import 'ReceiptPage.dart';

class PaymentHistoryPage extends StatefulWidget {
  const PaymentHistoryPage({super.key});

  @override
  State<PaymentHistoryPage> createState() =>
      _PaymentHistoryPageState();
}

class _PaymentHistoryPageState
    extends State<PaymentHistoryPage> {

  bool isLoading = true;

  List payments = [];

  String studentId = "";

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {

    SharedPreferences prefs =
        await SharedPreferences.getInstance();

    studentId =
        prefs.getString("student_id") ?? "";

    var result =
        await GetPaymentHistory.execute(studentId);

    if (result["success"] == true) {

      setState(() {

        payments = result["data"];

        isLoading = false;

      });

    } else {

      setState(() {

        isLoading = false;

      });

    }

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text("Payment History"),
      ),

      backgroundColor: Colors.grey.shade100,

      body: isLoading

          ? const Center(
              child: CircularProgressIndicator(),
            )

          : payments.isEmpty

              ? const Center(
                  child: Text(
                    "No Payment History Found",
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                )

              : Column(

                  children: [

                    Container(

                      width: double.infinity,

                      padding: const EdgeInsets.only(
                        top: 20,
                        bottom: 35,
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

                            Icons.history,

                            size: 65,

                            color: Colors.white,

                          ),

                          SizedBox(height: 10),

                          Text(

                            "Payment History",

                            style: TextStyle(

                              color: Colors.white,

                              fontSize: 26,

                              fontWeight:
                                  FontWeight.bold,

                            ),

                          ),

                          SizedBox(height: 5),

                          Text(

                            "View all completed payments",

                            style: TextStyle(

                              color: Colors.white70,

                              fontSize: 15,

                            ),

                          ),

                        ],

                      ),

                    ),

                    Expanded(

                      child: ListView.builder(

                        padding:
                            const EdgeInsets.all(18),

                        itemCount: payments.length,

                        itemBuilder:

                            (context, index) {

                          Color statusColor =
                              Colors.green;

                          if (payments[index]
                                  ["status"] !=
                              "SUCCESS") {

                            statusColor =
                                Colors.red;

                          }

                          return Card(

                            margin:
                                const EdgeInsets.only(
                                    bottom: 18),

                            elevation: 6,

                            shape:
                                RoundedRectangleBorder(

                              borderRadius:
                                  BorderRadius.circular(
                                      18),

                            ),

                            child: Padding(

                              padding:
                                  const EdgeInsets.all(
                                      18),

                              child: Column(

                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,

                                children: [

                                  Row(

                                    children: [

                                      CircleAvatar(

                                        radius: 25,

                                        backgroundColor:
                                            Colors.blue
                                                .shade50,

                                        child:
                                            const Icon(

                                          Icons.payment,

                                          color:
                                              Colors.blue,

                                          size: 30,

                                        ),

                                      ),

                                      const SizedBox(
                                          width: 15),

                                      Expanded(

                                        child: Column(

                                          crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,

                                          children: [

                                            Text(

                                              "RM ${payments[index]["amount"]}",

                                              style:
                                                  const TextStyle(

                                                fontSize:
                                                    22,

                                                fontWeight:
                                                    FontWeight.bold,

                                              ),

                                            ),

                                            const SizedBox(
                                                height: 4),

                                            Container(

                                              padding:
                                                  const EdgeInsets.symmetric(

                                                horizontal:
                                                    12,

                                                vertical:
                                                    5,

                                              ),

                                              decoration:
                                                  BoxDecoration(

                                                color:
                                                    statusColor.withOpacity(
                                                        0.15),

                                                borderRadius:
                                                    BorderRadius.circular(
                                                        20),

                                              ),

                                              child:
                                                  Text(

                                                payments[index]
                                                    [
                                                    "status"],

                                                style:
                                                    TextStyle(

                                                  color:
                                                      statusColor,

                                                  fontWeight:
                                                      FontWeight.bold,

                                                ),

                                              ),

                                            ),

                                          ],

                                        ),

                                      ),

                                    ],

                                  ),

                                  const SizedBox(
                                      height: 18),
                                  _buildInfoRow(

                                    Icons.credit_card,

                                    "Payment Method",

                                    payments[index]
                                        ["payment_method"],

                                  ),

                                  const SizedBox(
                                      height: 10),

                                  _buildInfoRow(

                                    Icons.receipt_long,

                                    "Reference",

                                    payments[index]
                                        ["transaction_ref"],

                                  ),

                                  const SizedBox(
                                      height: 20),

                                  SizedBox(

                                    width: double.infinity,

                                    height: 50,

                                    child:
                                        ElevatedButton.icon(

                                      icon: const Icon(
                                        Icons.receipt,
                                        color:
                                            Colors.white,
                                      ),

                                      style:
                                          ElevatedButton
                                              .styleFrom(

                                        backgroundColor:
                                            Colors.blue,

                                        shape:
                                            RoundedRectangleBorder(

                                          borderRadius:
                                              BorderRadius
                                                  .circular(
                                                      12),

                                        ),

                                      ),

                                      onPressed: () {

                                        if (payments[index]
                                                [
                                                "receipt_id"] ==
                                            null) {

                                          ScaffoldMessenger.of(
                                                  context)
                                              .showSnackBar(

                                            const SnackBar(

                                              content: Text(

                                                "Receipt not available for this payment.",

                                              ),

                                            ),

                                          );

                                          return;

                                        }

                                        Navigator.push(

                                          context,

                                          MaterialPageRoute(

                                            builder:
                                                (context) =>
                                                    const ReceiptPage(),

                                            settings:
                                                RouteSettings(

                                              arguments: {

                                                "receipt_id":
                                                    payments[index]["receipt_id"]

                                              },

                                            ),

                                          ),

                                        );

                                      },

                                      label: const Text(

                                        "View Receipt",

                                        style: TextStyle(

                                          color:
                                              Colors.white,

                                          fontSize: 16,

                                          fontWeight:
                                              FontWeight
                                                  .bold,

                                        ),

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

                ),

    );

  }

  Widget _buildInfoRow(

    IconData icon,

    String title,

    String value,

  ) {

    return Row(

      children: [

        CircleAvatar(

          radius: 16,

          backgroundColor:
              Colors.blue.shade50,

          child: Icon(

            icon,

            size: 18,

            color: Colors.blue,

          ),

        ),

        const SizedBox(width: 12),

        Text(

          "$title : ",

          style: const TextStyle(

            fontWeight: FontWeight.bold,

            fontSize: 15,

          ),

        ),

        Expanded(

          child: Text(

            value,

            style: const TextStyle(

              fontSize: 15,

            ),

          ),

        ),

      ],

    );

  }

}

