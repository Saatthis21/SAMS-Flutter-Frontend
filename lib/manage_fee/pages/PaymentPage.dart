import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../applications/InitiatePayment.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {

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

  }

  @override
  Widget build(BuildContext context) {

    final args =
        ModalRoute.of(context)!.settings.arguments
            as Map<String, dynamic>;

    String feeId = args["fee_id"];

    return Scaffold(

      appBar: AppBar(

        title: const Text("Fee Payment"),

        centerTitle: true,

      ),

      body: Padding(

        padding: const EdgeInsets.all(20),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Text(

              "Student ID : $studentId",

              style: const TextStyle(
                  fontSize: 18),

            ),

            const SizedBox(height: 15),

            Text(

              "Fee ID : $feeId",

              style: const TextStyle(
                  fontSize: 18),

            ),

            const SizedBox(height: 25),

            TextField(

              controller: amountController,

              keyboardType:
                  TextInputType.number,

              decoration:
                  const InputDecoration(

                labelText: "Payment Amount",

                border:
                    OutlineInputBorder(),

              ),

            ),

            const SizedBox(height: 25),

            DropdownButtonFormField<String>(

              value: paymentMethod,

              decoration:
                  const InputDecoration(

                border:
                    OutlineInputBorder(),

              ),

              items: const [

                DropdownMenuItem(

                  value:
                      "Online Banking",

                  child:
                      Text("Online Banking"),

                ),

                DropdownMenuItem(

                  value:
                      "Debit Card",

                  child:
                      Text("Debit Card"),

                ),

                DropdownMenuItem(

                  value:
                      "Credit Card",

                  child:
                      Text("Credit Card"),

                ),

              ],

              onChanged: (value) {

                setState(() {

                  paymentMethod = value!;

                });

              },

            ),

            const SizedBox(height: 35),

            SizedBox(

              width: double.infinity,

              child: ElevatedButton(

                onPressed: isLoading
                    ? null
                    : () async {

                        setState(() {

                          isLoading = true;

                        });

                        var result =
                            await InitiatePayment.execute(

                          studentId:
                              studentId,

                          feeId:
                              feeId,

                          amount: double.parse(
                              amountController.text),

                          paymentMethod:
                              paymentMethod,

                        );

                        setState(() {

                          isLoading = false;

                        });

                        ScaffoldMessenger.of(
                                context)
                            .showSnackBar(

                          SnackBar(

                            content: Text(
                                result["message"]),

                          ),

                        );

                        if (result["success"] ==
                            true) {

                          Navigator.pushNamed(

                            context,

                            "/receipt",

                            arguments: {

                              "receipt_id":
                                  result["receipt"]
                                      ["receipt_id"]

                            },

                          );

                        }
                      },

                child: isLoading

                    ? const CircularProgressIndicator()

                    : const Text(

                        "Pay Now",

                      ),

              ),

            ),

          ],

        ),

      ),

    );

  }

}

