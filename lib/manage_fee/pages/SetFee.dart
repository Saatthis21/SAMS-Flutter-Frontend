import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SetFee extends StatefulWidget {
  const SetFee({super.key});

  @override
  State<SetFee> createState() => _SetFeeState();
}

class _SetFeeState extends State<SetFee> {
  final String baseUrl = "http://127.0.0.1:8000/api";

  final _formKey = GlobalKey<FormState>();

  final TextEditingController programController =
      TextEditingController();

  final TextEditingController semesterController =
      TextEditingController();

  final TextEditingController feeController =
      TextEditingController();

  final TextEditingController deadlineController =
      TextEditingController();

  bool isLoading = false;

  Future<void> saveFee() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/fee/set"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "program": programController.text,
          "semester": semesterController.text,
          "fee_amount":
              double.parse(feeController.text),
          "deadline_week":
              int.parse(deadlineController.text),
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 ||
          response.statusCode == 201) {

        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content:
                Text("Fee Structure Added Successfully"),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);

      } else {

        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              data["message"] ??
                  "Failed to Save Fee",
            ),
            backgroundColor: Colors.red,
          ),
        );

      }
    } catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );

    }

    setState(() {
      isLoading = false;
    });
  }

  Widget buildField(
    String title,
    TextEditingController controller,
    TextInputType type,
    IconData icon,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 18),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        validator: (value) {
          if (value == null ||
              value.isEmpty) {
            return "Please enter $title";
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: title,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(15),
          ),
          enabledBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(15),
            borderSide:
                BorderSide(
              color: Colors.grey.shade300,
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
          "Set Fee Structure",
        ),
      ),

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(20),

        child: Form(

          key: _formKey,

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
                    Icons.account_balance_wallet,
                    size: 70,
                    color: Colors.blue,
                  ),

                  const SizedBox(
                    height: 15,
                  ),

                  const Text(

                    "Create Fee Structure",

                    style: TextStyle(

                      fontSize: 22,

                      fontWeight:
                          FontWeight.bold,

                    ),

                  ),

                  const SizedBox(
                    height: 25,
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
                    feeController,
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

                    width: double.infinity,

                    height: 55,

                    child:
                        ElevatedButton.icon(

                      icon: const Icon(
                        Icons.save,
                      ),

                      label: isLoading

                          ? const CircularProgressIndicator(
                              color:
                                  Colors.white,
                            )

                          : const Text(

                              "SAVE FEE",

                              style:
                                  TextStyle(

                                fontSize:
                                    18,

                                fontWeight:
                                    FontWeight.bold,

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

                      onPressed:
                          isLoading
                              ? null
                              : saveFee,

                    ),

                  ),

                ],

              ),

            ),

          ),

        ),

      ),

    );
  }
}

