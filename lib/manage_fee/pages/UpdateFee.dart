import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UpdateFee extends StatefulWidget {
  const UpdateFee({super.key});

  @override
  State<UpdateFee> createState() => _UpdateFeeState();
}

class _UpdateFeeState extends State<UpdateFee> {

  final String baseUrl =
      "http://10.0.2.2:8000/api";

  List feeList = [];

  Map<String, dynamic>? selectedFee;

  bool isLoading = true;

  final TextEditingController programController =
      TextEditingController();

  final TextEditingController semesterController =
      TextEditingController();

  final TextEditingController feeAmountController =
      TextEditingController();

  final TextEditingController deadlineController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    loadFeeList();
  }

  Future<void> loadFeeList() async {

    try {

      final response = await http.get(
        Uri.parse(
          "$baseUrl/fee/list",
        ),
      );

      if (response.statusCode == 200) {

        final data =
            jsonDecode(response.body);

        setState(() {

          feeList = data["data"];

          isLoading = false;

        });

      } else {

        setState(() {

          isLoading = false;

        });

      }

    } catch (e) {

      setState(() {

        isLoading = false;

      });

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content: Text(e.toString()),
        ),

      );

    }

  }

  Future<void> updateFee() async {

    if (selectedFee == null) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content: Text(
              "Please Select Fee Structure"),

        ),

      );

      return;

    }

    final response = await http.put(

      Uri.parse(
        "$baseUrl/fee/update/${selectedFee!["id"]}",
      ),

      headers: {

        "Content-Type":
            "application/json",

      },

      body: jsonEncode({

        "program":
            programController.text,

        "semester":
            semesterController.text,

        "fee_amount":
            double.parse(
                feeAmountController.text),

        "deadline_week":
            int.parse(
                deadlineController.text),

      }),

    );

    final data =
        jsonDecode(response.body);

    if (response.statusCode == 200) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          backgroundColor:
              Colors.green,

          content: Text(
              "Fee Updated Successfully"),

        ),

      );

      Navigator.pop(context);

    } else {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(

          backgroundColor:
              Colors.red,

          content: Text(

            data["message"] ??
                "Update Failed",

          ),

        ),

      );

    }

  }

  Widget buildField(

    String title,

    TextEditingController controller,

    TextInputType type,

    IconData icon,

  ) {

    return Padding(

      padding:
          const EdgeInsets.only(
              bottom: 18),

      child: TextField(

        controller: controller,

        keyboardType: type,

        decoration: InputDecoration(

          labelText: title,

          prefixIcon: Icon(icon),

          filled: true,

          fillColor:
              Colors.grey.shade100,

          border:
              OutlineInputBorder(

            borderRadius:
                BorderRadius.circular(
                    15),

          ),

          enabledBorder:
              OutlineInputBorder(

            borderRadius:
                BorderRadius.circular(
                    15),

            borderSide:
                BorderSide(

              color: Colors
                  .grey.shade300,
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

        backgroundColor:
            Colors.blue.shade700,

        foregroundColor:
            Colors.white,

        centerTitle: true,

        title: const Text(
          "Update Fee Structure",
        ),

      ),

      body: isLoading

          ? const Center(
              child:
                  CircularProgressIndicator(),
            )

          : SingleChildScrollView(

              padding:
                  const EdgeInsets.all(20),

              child: Card(

                elevation: 8,

                shape:
                    RoundedRectangleBorder(

                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),

                ),

                child: Padding(

                  padding:
                      const EdgeInsets.all(
                    20,
                  ),

                  child: Column(

                    children: [

                      const Icon(

                        Icons.edit_note,

                        size: 70,

                        color: Colors.blue,

                      ),

                      const SizedBox(
                        height: 15,
                      ),

                      const Text(

                        "Update Fee Structure",

                        style: TextStyle(

                          fontSize: 22,

                          fontWeight:
                              FontWeight.bold,

                        ),

                      ),

                      const SizedBox(
                        height: 25,
                      ),

                      DropdownButtonFormField<
                          Map<String, dynamic>>(

                        decoration:
                            InputDecoration(

                          labelText:
                              "Select Fee Structure",

                          prefixIcon:
                              const Icon(
                            Icons.list_alt,
                          ),

                          filled: true,

                          fillColor:
                              Colors.grey
                                  .shade100,

                          border:
                              OutlineInputBorder(

                            borderRadius:
                                BorderRadius
                                    .circular(
                              15,
                            ),

                          ),

                        ),

                        value:
                            selectedFee,

                        items: feeList.map<
                            DropdownMenuItem<
                                Map<String,
                                    dynamic>>>(
                          (fee) {

                            return DropdownMenuItem(

                              value: fee,

                              child: Text(

                                "${fee["program"]} - ${fee["semester"]}",

                              ),

                            );

                          },
                        ).toList(),

                        onChanged:
                            (value) {

                          setState(() {

                            selectedFee =
                                value;

                            programController
                                    .text =
                                value![
                                    "program"];

                            semesterController
                                    .text =
                                value[
                                    "semester"];

                            feeAmountController
                                    .text =
                                value[
                                        "fee_amount"]
                                    .toString();

                            deadlineController
                                    .text =
                                value[
                                        "deadline_week"]
                                    .toString();

                          });

                        },

                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      buildField(

                        "Program",

                        programController,

                        TextInputType.text,

                        Icons.school,

                      ),

                      buildField(

                        "Semester",

                        semesterController,

                        TextInputType.text,

                        Icons.calendar_month,

                      ),

                      buildField(

                        "Fee Amount",

                        feeAmountController,

                        TextInputType.number,

                        Icons.attach_money,

                      ),

                      buildField(

                        "Deadline Week",

                        deadlineController,

                        TextInputType.number,

                        Icons.schedule,

                      ),

                      const SizedBox(
                        height: 25,
                      ),

                      SizedBox(

                        width:
                            double.infinity,

                        height: 55,

                        child:
                            ElevatedButton
                                .icon(

                          icon:
                              const Icon(
                            Icons.save,
                          ),

                          label:
                              const Text(

                            "UPDATE FEE",

                            style:
                                TextStyle(

                              fontSize:
                                  18,

                              fontWeight:
                                  FontWeight
                                      .bold,

                            ),

                          ),

                          style:
                              ElevatedButton
                                  .styleFrom(

                            backgroundColor:
                                Colors.blue
                                    .shade700,

                            foregroundColor:
                                Colors.white,

                            shape:
                                RoundedRectangleBorder(

                              borderRadius:
                                  BorderRadius
                                      .circular(
                                15,
                              ),
                            ),
                          ),

                          onPressed:updateFee,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
