import 'package:flutter/material.dart';
import '../applications/GetReceipt.dart';

class ReceiptPage extends StatefulWidget {
  const ReceiptPage({super.key});

  @override
  State<ReceiptPage> createState() => _ReceiptPageState();
}

class _ReceiptPageState extends State<ReceiptPage> {

  bool isLoading = true;

  Map<String, dynamic>? receipt;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadReceipt();
  }

  Future<void> loadReceipt() async {

    final args =
        ModalRoute.of(context)!.settings.arguments
            as Map<String, dynamic>;

    String receiptId = args["receipt_id"];

    var result =
        await GetReceipt.execute(receiptId);

    if(result["success"] == true){

      setState(() {

        receipt = result["data"];

        isLoading = false;

      });

    }
    else{

      setState(() {

        isLoading = false;

      });

    }

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text("Payment Receipt"),

        centerTitle: true,

      ),

      body: isLoading

          ? const Center(
              child: CircularProgressIndicator(),
            )

          : receipt == null

              ? const Center(
                  child: Text(
                    "Receipt Not Found",
                    style: TextStyle(fontSize: 18),
                  ),
                )

              : SingleChildScrollView(

                  padding:
                      const EdgeInsets.all(20),

                  child: Card(

                    elevation: 5,

                    child: Padding(

                      padding:
                          const EdgeInsets.all(20),

                      child: Column(

                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [

                          const Center(

                            child: Text(

                              "OFFICIAL RECEIPT",

                              style: TextStyle(

                                fontSize: 24,

                                fontWeight:
                                    FontWeight.bold,

                              ),

                            ),

                          ),

                          const Divider(),

                          const SizedBox(height: 20),

                          Text(
                            "Receipt Number : ${receipt!["receipt_number"]}",
                          ),

                          const SizedBox(height: 10),

                          Text(
                            "Student ID : ${receipt!["student_id"]}",
                          ),

                          const SizedBox(height: 10),

                          Text(
                            "Payment ID : ${receipt!["payment_id"]}",
                          ),

                          const SizedBox(height: 10),

                          Text(
                            "Amount Paid : RM ${receipt!["amount_paid"]}",
                          ),

                          const SizedBox(height: 10),

                          Text(
                            "Outstanding Balance : RM ${receipt!["balance"]}",
                          ),

                          const SizedBox(height: 10),

                          Text(
                            "Payment Method : ${receipt!["payment_method"]}",
                          ),

                          const SizedBox(height: 10),

                          Text(
                            "Remarks : ${receipt!["note"]}",
                          ),

                          const SizedBox(height: 30),

                          SizedBox(

                            width: double.infinity,

                            child: ElevatedButton(

                              onPressed: () {

                                Navigator.pop(context);

                              },

                              child: const Text(
                                "Done",
                              ),

                            ),

                          )

                        ],

                      ),

                    ),

                  ),

                ),

    );

  }

}
