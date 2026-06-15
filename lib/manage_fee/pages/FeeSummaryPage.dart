import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../applications/GetFeeSummary.dart';

class FeeSummaryPage extends StatefulWidget {
  const FeeSummaryPage({super.key});

  @override
  State<FeeSummaryPage> createState() => _FeeSummaryPageState();
}

class _FeeSummaryPageState extends State<FeeSummaryPage> {

  bool isLoading = true;

  Map<String, dynamic>? feeData;

  String studentId = "";

  @override
  void initState() {
    super.initState();
    loadFeeSummary();
  }

  Future<void> loadFeeSummary() async {

    SharedPreferences prefs =
        await SharedPreferences.getInstance();

    studentId =
        prefs.getString("student_id") ?? "";

    if(studentId.isEmpty){

      setState(() {
        isLoading = false;
      });

      return;
    }

    var result =
        await GetFeeSummary.execute(studentId);

    if(result["success"] == true){

      setState(() {

        feeData = result["data"];

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

        title: const Text("Fee Summary"),

        centerTitle: true,

      ),

      body: isLoading

          ? const Center(
              child: CircularProgressIndicator(),
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

                          const Text(

                            "Fee Information",

                            style: TextStyle(

                              fontSize: 22,

                              fontWeight:
                                  FontWeight.bold,

                            ),

                          ),

                          const SizedBox(height: 25),

                          Text(
                            "Student ID : ${feeData!["student_id"]}",
                          ),

                          const SizedBox(height: 10),

                          Text(
                            "Fee ID : ${feeData!["fees_id"]}",
                          ),

                          const SizedBox(height: 10),

                          Text(
                            "Total Fee : RM ${feeData!["total_fee"]}",
                          ),

                          const SizedBox(height: 10),

                          Text(
                            "Paid Amount : RM ${feeData!["paid_amount"]}",
                          ),

                          const SizedBox(height: 10),

                          Text(
                            "Outstanding Balance : RM ${feeData!["balance"]}",
                          ),

                          const SizedBox(height: 10),

                          Text(
                            "Status : ${feeData!["status"]}",
                          ),

                          const SizedBox(height: 30),

                          SizedBox(

                            width: double.infinity,

                            child: ElevatedButton(

                              onPressed: () {

                                Navigator.pushNamed(

                                  context,

                                  "/payment",

                                  arguments: {

                                    "fee_id":
                                        feeData!["fees_id"]

                                  },

                                );

                              },

                              child: const Text(

                                "Proceed to Payment",

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
