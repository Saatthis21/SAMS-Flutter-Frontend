import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PaymentRecord extends StatefulWidget {
  const PaymentRecord({super.key});

  @override
  State<PaymentRecord> createState() =>
      _PaymentRecordState();
}

class _PaymentRecordState
    extends State<PaymentRecord> {

  final String baseUrl =
      "http://10.0.2.2:8000/api";

  List payments = [];
  List filteredPayments = [];

  bool isLoading = true;

  final TextEditingController searchController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    loadPayments();
  }

  Future<void> loadPayments() async {

    setState(() {
      isLoading = true;
    });

    try {

      final response = await http.get(

        Uri.parse(
          "$baseUrl/treasury/payments",
        ),

      );

      if (response.statusCode == 200) {

        final jsonData =
            jsonDecode(response.body);

        setState(() {

          payments =
              jsonData["data"];

          filteredPayments =
              payments;

        });

      }

    } catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(

          content: Text(
            e.toString(),
          ),

        ),

      );

    }

    setState(() {

      isLoading = false;

    });

  }

  void searchPayment(
      String keyword) {

    setState(() {

      filteredPayments =
          payments.where((payment) {

        return payment["student_id"]
            .toString()
            .toLowerCase()
            .contains(
              keyword.toLowerCase(),
            );

      }).toList();

    });

  }

  Widget infoRow(

    IconData icon,

    String text,

  ) {

    return Padding(

      padding:
          const EdgeInsets.only(
              top: 4),

      child: Row(

        children: [

          Icon(

            icon,

            size: 18,

            color: Colors.blue,

          ),

          const SizedBox(
            width: 8,
          ),

          Expanded(

            child: Text(

              text,

              style:
                  const TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          Colors.grey.shade100,

      appBar: AppBar(

        backgroundColor:
            Colors.blue.shade700,

        foregroundColor:
            Colors.white,

        centerTitle: true,

        title: const Text(
          "Payment Records",
        ),

      ),

      body: RefreshIndicator(

        onRefresh: loadPayments,

        child: isLoading

            ? const Center(
                child:
                    CircularProgressIndicator(),
              )

            : Column(

                children: [

                  Padding(

                    padding:
                        const EdgeInsets.all(
                      15,
                    ),

                    child: TextField(

                      controller:
                          searchController,

                      onChanged:
                          searchPayment,

                      decoration:
                          InputDecoration(

                        hintText:
                            "Search Student ID",

                        prefixIcon:
                            const Icon(
                          Icons.search,
                        ),

                        filled: true,

                        fillColor:
                            Colors.white,

                        border:
                            OutlineInputBorder(

                          borderRadius:
                              BorderRadius.circular(
                            15,
                          ),

                        ),

                      ),

                    ),

                  ),

                  Expanded(

                    child:
                        filteredPayments.isEmpty

                            ? const Center(

                                child: Text(

                                  "No Payment Records",

                                  style:
                                      TextStyle(
                                    fontSize:
                                        18,
                                  ),

                                ),

                              )

                            : ListView.builder(

                                itemCount:
                                    filteredPayments
                                        .length,

                                itemBuilder:
                                    (context,
                                        index) {

                                  final payment =
                                      filteredPayments[
                                          index];

                                  return Card(

                                    elevation: 5,

                                    margin:
                                        const EdgeInsets
                                            .symmetric(

                                      horizontal:
                                          15,

                                      vertical:
                                          8,

                                    ),

                                    shape:
                                        RoundedRectangleBorder(

                                      borderRadius:
                                          BorderRadius.circular(
                                        15,
                                      ),

                                    ),

                                    child:
                                        Padding(

                                      padding:
                                          const EdgeInsets
                                              .all(
                                        15,
                                      ),

                                      child:
                                          Column(

                                        crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,

                                        children: [

                                          Row(

                                            children: [

                                              CircleAvatar(

                                                radius:
                                                    25,

                                                backgroundColor:
                                                    Colors.green,

                                                child:
                                                    const Icon(

                                                  Icons.payments,

                                                  color:
                                                      Colors.white,

                                                ),

                                              ),

                                              const SizedBox(
                                                width:
                                                    15,
                                              ),

                                              Expanded(

                                                child:
                                                    Text(

                                                  payment["student_id"]
                                                      .toString(),

                                                  style:
                                                      const TextStyle(

                                                    fontSize:
                                                        18,

                                                    fontWeight:
                                                        FontWeight.bold,

                                                  ),

                                                ),

                                              ),

                                              Container(

                                                padding:
                                                    const EdgeInsets.symmetric(

                                                  horizontal:
                                                      12,

                                                  vertical:
                                                      6,

                                                ),

                                                decoration:
                                                    BoxDecoration(

                                                  color: payment["status"] ==
                                                          "SUCCESS"
                                                      ? Colors.green
                                                      : Colors.red,

                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    20,
                                                  ),

                                                ),

                                                child:
                                                    Text(

                                                  payment["status"],

                                                  style:
                                                      const TextStyle(

                                                    color:
                                                        Colors.white,

                                                    fontWeight:
                                                        FontWeight.bold,

                                                  ),

                                                ),

                                              ),

                                            ],

                                          ),

                                          const SizedBox(
                                            height:
                                                15,
                                          ),

                                          infoRow(

                                            Icons.attach_money,

                                            "Amount : RM ${payment["amount"]}",

                                          ),

                                          infoRow(

                                            Icons.credit_card,

                                            "Method : ${payment["payment_method"]}",

                                          ),

                                          infoRow(

                                            Icons.calendar_today,

                                            "Date : ${payment["paid_at"]}",

                                          ),

                                          infoRow(

                                            Icons.confirmation_number,

                                            "Transaction : ${payment["transaction_ref"]}",

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
      ),
    );
  }
}
