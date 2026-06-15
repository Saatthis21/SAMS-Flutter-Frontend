import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../applications/GetPaymentHistory.dart';

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

        title:
            const Text("Payment History"),

        centerTitle: true,

      ),

      body: isLoading

          ? const Center(
              child:
                  CircularProgressIndicator(),
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

              : ListView.builder(

                  itemCount: payments.length,

                  itemBuilder:
                      (context, index) {

                    return Card(

                      margin:
                          const EdgeInsets.all(10),

                      elevation: 3,

                      child: ListTile(

                        leading: const Icon(
                          Icons.payment,
                          color: Colors.blue,
                        ),

                        title: Text(
                          "RM ${payments[index]["amount"]}",
                        ),

                        subtitle: Column(

                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [

                            Text(
                              "Method : ${payments[index]["payment_method"]}",
                            ),

                            Text(
                              "Status : ${payments[index]["status"]}",
                            ),

                            Text(
                              "Reference : ${payments[index]["transaction_ref"]}",
                            ),

                          ],

                        ),

                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                        ),

                        onTap: () {

                          Navigator.pushNamed(

                            context,

                            "/receipt",

                            arguments: {

                              "receipt_id":
                                  payments[index]["receipt_id"]

                            },

                          );

                        },

                      ),

                    );

                  },

                ),

    );

  }

}
