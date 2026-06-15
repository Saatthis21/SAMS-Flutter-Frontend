import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../applications/GetReceipt.dart';
import 'FeeSummaryPage.dart';

class ReceiptPage extends StatefulWidget {
  const ReceiptPage({super.key});

  @override
  State<ReceiptPage> createState() =>
      _ReceiptPageState();
}

class _ReceiptPageState
    extends State<ReceiptPage> {

  bool isLoading = true;

  Map<String, dynamic>? receipt;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadReceipt();
  }

  Future<void> loadReceipt() async {

    final args =
        ModalRoute.of(context)!
                .settings
                .arguments
            as Map<String, dynamic>;

    String receiptId =
        args["receipt_id"];

    var result =
        await GetReceipt.execute(
            receiptId);

    if (result["success"] == true) {

      setState(() {

        receipt = result["data"];

        isLoading = false;

      });

    } else {

      setState(() {

        isLoading = false;

      });

    }

  }

  Future<void> generatePdf() async {

    final pdf = pw.Document();

    pdf.addPage(

      pw.Page(

        build: (context) {

          return pw.Column(

            crossAxisAlignment:
                pw.CrossAxisAlignment.start,

            children: [

              pw.Center(

                child: pw.Text(

                  "UMPSA OFFICIAL RECEIPT",

                  style: pw.TextStyle(

                    fontSize: 24,

                    fontWeight:
                        pw.FontWeight.bold,

                  ),

                ),

              ),

              pw.SizedBox(height: 20),

              pw.Text(
                  "Receipt Number : ${receipt!["receipt_number"]}"),

              pw.Text(
                  "Student ID : ${receipt!["student_id"]}"),

              pw.Text(
                  "Payment ID : ${receipt!["payment_id"]}"),

              pw.Text(
                  "Amount Paid : RM ${receipt!["amount_paid"]}"),

              pw.Text(
                  "Outstanding Balance : RM ${receipt!["balance"]}"),

              pw.Text(
                  "Payment Method : ${receipt!["payment_method"]}"),

              pw.Text(
                  "Remarks : ${receipt!["note"]}"),

            ],

          );

        },

      ),

    );

    await Printing.layoutPdf(

      onLayout: (format) async =>
          pdf.save(),

    );

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
        title: const Text("Receipt"),
      ),

      backgroundColor:
          Colors.grey.shade100,

      body: isLoading

          ? const Center(

              child:
                  CircularProgressIndicator(),

            )

          : receipt == null

              ? const Center(

                  child: Text(

                    "Receipt Not Found",

                    style: TextStyle(

                      fontSize: 18,

                    ),

                  ),

                )

              : SingleChildScrollView(

                  child: Column(

                    children: [

                      Container(

                        width:
                            double.infinity,

                        padding:
                            const EdgeInsets.only(

                          top: 20,

                          bottom: 35,

                        ),

                        decoration:
                            const BoxDecoration(

                          gradient:
                              LinearGradient(

                            colors: [

                              Color(
                                  0xff1565C0),

                              Color(
                                  0xff42A5F5),

                            ],

                            begin:
                                Alignment.topLeft,

                            end:
                                Alignment.bottomRight,

                          ),

                          borderRadius:
                              BorderRadius.only(

                            bottomLeft:
                                Radius.circular(
                                    30),

                            bottomRight:
                                Radius.circular(
                                    30),

                          ),

                        ),

                        child: Column(

                          children: const [

                            CircleAvatar(

                              radius: 40,

                              backgroundColor:
                                  Colors.white,

                              child: Icon(

                                Icons.check_circle,

                                color: Colors.green,

                                size: 60,

                              ),

                            ),

                            SizedBox(height: 15),

                            Text(

                              "Payment Successful",

                              style: TextStyle(

                                color: Colors.white,

                                fontSize: 26,

                                fontWeight:
                                    FontWeight.bold,

                              ),

                            ),

                            SizedBox(height: 5),

                            Text(

                              "Official Receipt",

                              style: TextStyle(

                                color: Colors.white70,

                                fontSize: 15,

                              ),

                            ),

                          ],

                        ),

                      ),

                      Padding(

                        padding:
                            const EdgeInsets.all(20),

                        child: Card(

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

                                const Text(

                                  "UMPSA OFFICIAL RECEIPT",

                                  style: TextStyle(

                                    fontSize: 22,

                                    fontWeight:
                                        FontWeight.bold,

                                  ),

                                ),

                                const Divider(),

                                const SizedBox(
                                    height: 15),

                                Container(

                                  padding:
                                      const EdgeInsets
                                          .all(12),

                                  decoration:
                                      BoxDecoration(

                                    color: Colors.blue
                                        .shade50,

                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                                12),

                                  ),

                                  child: Row(

                                    children: [

                                      const Icon(

                                        Icons
                                            .receipt_long,

                                        color:
                                            Colors.blue,

                                      ),

                                      const SizedBox(
                                          width: 10),

                                      Expanded(

                                        child: Text(

                                          receipt![
                                              "receipt_number"],

                                          style:
                                              const TextStyle(

                                            fontWeight:
                                                FontWeight
                                                    .bold,

                                            fontSize: 17,

                                          ),

                                        ),

                                      ),

                                    ],

                                  ),

                                ),

                                const SizedBox(
                                    height: 25),
                                _buildRow(

                                  Icons.person,

                                  "Student ID",

                                  receipt!["student_id"],

                                ),

                                const SizedBox(height: 15),

                                _buildRow(

                                  Icons.payment,

                                  "Payment ID",

                                  receipt!["payment_id"],

                                ),

                                const SizedBox(height: 20),

                                Container(

                                  width: double.infinity,

                                  padding: const EdgeInsets.all(18),

                                  decoration: BoxDecoration(

                                    color: Colors.green.shade50,

                                    borderRadius:
                                        BorderRadius.circular(15),

                                  ),

                                  child: Column(

                                    children: [

                                      const Icon(

                                        Icons.check_circle,

                                        color: Colors.green,

                                        size: 35,

                                      ),

                                      const SizedBox(height: 8),

                                      const Text(

                                        "Amount Paid",

                                        style: TextStyle(

                                          fontSize: 15,

                                        ),

                                      ),

                                      const SizedBox(height: 5),

                                      Text(

                                        "RM ${receipt!["amount_paid"]}",

                                        style: const TextStyle(

                                          color: Colors.green,

                                          fontSize: 28,

                                          fontWeight: FontWeight.bold,

                                        ),

                                      ),

                                    ],

                                  ),

                                ),

                                const SizedBox(height: 18),

                                Container(

                                  width: double.infinity,

                                  padding: const EdgeInsets.all(18),

                                  decoration: BoxDecoration(

                                    color: Colors.red.shade50,

                                    borderRadius:
                                        BorderRadius.circular(15),

                                  ),

                                  child: Column(

                                    children: [

                                      const Icon(

                                        Icons.account_balance_wallet,

                                        color: Colors.red,

                                        size: 35,

                                      ),

                                      const SizedBox(height: 8),

                                      const Text(

                                        "Outstanding Balance",

                                        style: TextStyle(

                                          fontSize: 15,

                                        ),

                                      ),

                                      const SizedBox(height: 5),

                                      Text(

                                        "RM ${receipt!["balance"]}",

                                        style: const TextStyle(

                                          color: Colors.red,

                                          fontSize: 26,

                                          fontWeight: FontWeight.bold,

                                        ),

                                      ),

                                    ],

                                  ),

                                ),

                                const SizedBox(height: 20),

                                _buildRow(

                                  Icons.credit_card,

                                  "Payment Method",

                                  receipt!["payment_method"],

                                ),

                                const SizedBox(height: 15),

                                _buildRow(

                                  Icons.notes,

                                  "Remarks",

                                  receipt!["note"],

                                ),

                                const SizedBox(height: 30),

                                SizedBox(

                                  width: double.infinity,

                                  height: 55,

                                  child: ElevatedButton.icon(

                                    icon: const Icon(

                                      Icons.download,

                                      color: Colors.white,

                                    ),

                                    style: ElevatedButton.styleFrom(

                                      backgroundColor:

                                          Colors.green,

                                      shape:

                                          RoundedRectangleBorder(

                                        borderRadius:

                                            BorderRadius.circular(

                                                15),

                                      ),

                                    ),

                                    onPressed: () {

                                      generatePdf();

                                    },

                                    label: const Text(

                                      "Download Receipt PDF",

                                      style: TextStyle(

                                        color: Colors.white,

                                        fontSize: 16,

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

                                  child: ElevatedButton.icon(

                                    icon: const Icon(

                                      Icons.home,

                                      color: Colors.white,

                                    ),

                                    style: ElevatedButton.styleFrom(

                                      backgroundColor:

                                          Colors.blue,

                                      shape:

                                          RoundedRectangleBorder(

                                        borderRadius:

                                            BorderRadius.circular(

                                                15),

                                      ),

                                    ),

                                    onPressed: () {

                                      Navigator.pushAndRemoveUntil(

                                        context,

                                        MaterialPageRoute(

                                          builder: (context) =>

                                              const FeeSummaryPage(),

                                        ),

                                        (route) => false,

                                      );

                                    },

                                    label: const Text(

                                      "Back to Fee Summary",

                                      style: TextStyle(

                                        color: Colors.white,

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

                      ),

                    ],

                  ),

                ),

    );

  }

  Widget _buildRow(

    IconData icon,

    String title,

    String value,

  ) {

    return Row(

      children: [

        CircleAvatar(

          radius: 18,

          backgroundColor: Colors.blue.shade50,

          child: Icon(

            icon,

            color: Colors.blue,

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

        Flexible(

          child: Text(

            value,

            textAlign: TextAlign.end,

            style: const TextStyle(

              fontWeight: FontWeight.bold,

              fontSize: 15,

            ),
          ),
        ),
      ],
    );
  }
}

