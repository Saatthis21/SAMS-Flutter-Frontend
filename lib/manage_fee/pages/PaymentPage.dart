import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../applications/InitiatePayment.dart';
import 'FeeSummaryPage.dart';
import 'ReceiptPage.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() =>
      _PaymentPageState();
}

class _PaymentPageState
    extends State<PaymentPage> {

  final TextEditingController amountController =
      TextEditingController();

  String studentId = "";

  String paymentMethod = "Online Banking";

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadStudent();
  }

  Future<void> loadStudent() async {

    SharedPreferences prefs =
        await SharedPreferences.getInstance();

    studentId =
        prefs.getString("student_id") ?? "";

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {

    final args =
        ModalRoute.of(context)!
                .settings
                .arguments
            as Map<String, dynamic>;

    String feeId = args["fee_id"];

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
        title: const Text("Payment"),
      ),

      backgroundColor:
          Colors.grey.shade100,

      body: SingleChildScrollView(

        child: Column(

          children: [

            Container(

              width: double.infinity,

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

                    Color(0xff1565C0),

                    Color(0xff42A5F5),

                  ],

                  begin:
                      Alignment.topLeft,

                  end:
                      Alignment.bottomRight,

                ),

                borderRadius:
                    BorderRadius.only(

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

                    size: 70,

                    color: Colors.white,

                  ),

                  SizedBox(height: 10),

                  Text(

                    "Tuition Fee Payment",

                    style: TextStyle(

                      color: Colors.white,

                      fontSize: 26,

                      fontWeight:
                          FontWeight.bold,

                    ),

                  ),

                  SizedBox(height: 5),

                  Text(

                    "Secure Online Payment",

                    style: TextStyle(

                      color:
                          Colors.white70,

                      fontSize: 15,

                    ),

                  ),

                ],

              ),

            ),

            Padding(

              padding:
                  const EdgeInsets.all(20),

              child: Column(

                children: [

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

                          _buildRow(

                            Icons.person,

                            "Student ID",

                            studentId,

                          ),

                          const SizedBox(
                              height: 15),

                          _buildRow(

                            Icons.badge,

                            "Fee ID",

                            feeId,

                          ),

                        ],

                      ),

                    ),

                  ),

                  const SizedBox(
                      height: 20),

                  Card(

                    color:
                        Colors.blue.shade50,

                    elevation: 2,

                    shape:
                        RoundedRectangleBorder(

                      borderRadius:
                          BorderRadius.circular(
                              15),

                    ),

                    child:
                        const Padding(

                      padding:
                          EdgeInsets.all(
                              15),

                      child: Row(

                        children: [

                          Icon(

                            Icons.info,

                            color:
                                Colors.blue,

                          ),

                          SizedBox(
                              width: 10),

                          Expanded(

                            child: Text(

                              "Enter the amount you wish to pay and choose your preferred payment method.",

                              style:
                                  TextStyle(

                                fontSize:
                                    14,

                              ),

                            ),

                          ),

                        ],

                      ),

                    ),

                  ),

                  const SizedBox(
                      height: 25),

                  TextField(

                    controller:
                        amountController,

                    keyboardType:
                        TextInputType.number,

                    decoration:
                        InputDecoration(

                      labelText:
                          "Payment Amount",

                      hintText:
                          "Enter amount (RM)",

                      prefixIcon:
                          const Icon(

                        Icons.attach_money,

                        color:
                            Colors.blue,

                      ),

                      filled: true,

                      fillColor:
                          Colors.white,

                      border:
                          OutlineInputBorder(

                        borderRadius:
                            BorderRadius.circular(
                                15),

                      ),

                    ),

                  ),

                  const SizedBox(
                      height: 20),

                  DropdownButtonFormField<
                      String>(

                    value:
                        paymentMethod,

                    decoration:
                        InputDecoration(

                      labelText:
                          "Payment Method",

                      prefixIcon:
                          const Icon(

                        Icons.credit_card,

                        color:
                            Colors.blue,

                      ),

                      filled: true,
                      fillColor:
                          Colors.white,
                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                                15),
                      ),
                    ),

                    items: const [

                      DropdownMenuItem(
                        value:
                            "Online Banking",
                        child: Text(
                          "🏦 Online Banking",
                        ),
                      ),

                      DropdownMenuItem(

                        value:
                            "Debit Card",
                        child: Text(
                          "💳 Debit Card",
                        ),
                      ),

                      DropdownMenuItem(

                        value:
                            "Credit Card",
                        child: Text(
                          "💳 Credit Card",
                        ),
                      ),
                    ],

                    onChanged:
                        (value) {

                      setState(() {

                        paymentMethod =
                            value!;

                      });
                    },
                  ),

                  const SizedBox(
                      height: 35),
                  SizedBox(

                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      icon: isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )

                          : const Icon(

                              Icons.lock,

                              color: Colors.white,

                            ),

                      label: Text(

                        isLoading

                            ? "Processing..."

                            : "PAY NOW",

                        style: const TextStyle(

                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      style: ElevatedButton.styleFrom(

                        backgroundColor: Colors.blue,
                        elevation: 5,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: isLoading
                          ? null
                          : () async {
                              if (amountController.text
                                  .trim()
                                  .isEmpty) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Please enter payment amount.",
                                    ),
                                  ),
                                );
                                return;
                              }

                              setState(() {

                                isLoading = true;

                              });

                              var result =
                                  await InitiatePayment.execute(

                                studentId: studentId,
                                feeId: feeId,
                                amount: double.parse(
                                  amountController.text,
                                ),

                                paymentMethod:
                                    paymentMethod,

                              );

                              setState(() {

                                isLoading = false;

                              });

                              ScaffoldMessenger.of(context)
                                  .showSnackBar(

                                SnackBar(

                                  content: Text(
                                    result["message"],
                                  ),

                                ),

                              );

                              if (result["success"] ==
                                  true) {

                                Navigator.push(

                                  context,

                                  MaterialPageRoute(

                                    builder: (context) =>
                                        const ReceiptPage(),

                                    settings: RouteSettings(
                                      arguments: {

                                        "receipt_id":
                                            result["receipt"]
                                                ["receipt_id"]

                                      },

                                    ),
                                  ),
                                );
                              }
                            },
                    ),
                  ),

                  const SizedBox(height: 15),

                  SizedBox(

                    width: double.infinity,
                    height: 55,
                    child: OutlinedButton.icon(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.red,
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Colors.red,
                          width: 2,
                        ),

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(15),
                        ),
                      ),

                      onPressed: () {

                        showDialog(

                          context: context,
                          builder: (context) {

                            return AlertDialog(
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(15),
                              ),

                              title: const Text(
                                "Cancel Payment?",
                              ),

                              content: const Text(

                                "Are you sure you want to cancel this payment and return to the Fee Summary page?",

                              ),

                              actions: [

                                TextButton(

                                  onPressed: () {
                                    Navigator.pop(
                                      context,
                                    );

                                  },

                                  child: const Text(
                                    "No",
                                  ),

                                ),

                                ElevatedButton(

                                  style:
                                      ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Colors.red,

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

                                  child: const Text(

                                    "Yes",

                                    style: TextStyle(

                                      color: Colors.white,

                                    ),

                                  ),

                                ),

                              ],

                            );

                          },

                        );

                      },

                      label: const Text(

                        "Cancel Payment",

                        style: TextStyle(

                          color: Colors.red,

                          fontSize: 16,

                          fontWeight: FontWeight.bold,

                        ),

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

    String value,

  ) {

    return Row(

      children: [

        CircleAvatar(

          radius: 18,

          backgroundColor:
              Colors.blue.shade50,

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

        Text(

          value,

          style: const TextStyle(

            fontWeight: FontWeight.bold,

            fontSize: 15,

          ),

        ),

      ],

    );

  }

}