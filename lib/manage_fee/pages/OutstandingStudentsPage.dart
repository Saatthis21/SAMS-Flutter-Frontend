import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class OutstandingStudents extends StatefulWidget {
  const OutstandingStudents({super.key});

  @override
  State<OutstandingStudents> createState() =>
      _OutstandingStudentsState();
}

class _OutstandingStudentsState
    extends State<OutstandingStudents> {

  final String baseUrl =
      "http://10.0.2.2:8000/api";

  List students = [];
  List filteredStudents = [];

  bool isLoading = true;

  final TextEditingController searchController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    loadStudents();
  }

  Future<void> loadStudents() async {

    setState(() {
      isLoading = true;
    });

    try {

      final response = await http.get(
        Uri.parse(
          "$baseUrl/treasury/outstanding",
        ),
      );

      if (response.statusCode == 200) {

        final jsonData =
            json.decode(response.body);

        students = jsonData["data"];

        filteredStudents = students;

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

  void searchStudent(String keyword) {

    setState(() {

      filteredStudents =
          students.where((student) {

        return student["student_id"]
            .toString()
            .toLowerCase()
            .contains(
              keyword.toLowerCase(),
            );

      }).toList();

    });

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          "Outstanding Students",
        ),

        centerTitle: true,

      ),

      body: RefreshIndicator(

        onRefresh: loadStudents,

        child: Column(

          children: [

            Padding(

              padding:
                  const EdgeInsets.all(12),

              child: TextField(

                controller:
                    searchController,

                onChanged:
                    searchStudent,

                decoration:
                    InputDecoration(

                  hintText:
                      "Search Student ID",

                  prefixIcon:
                      const Icon(
                    Icons.search,
                  ),

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

              child: isLoading

                  ? const Center(
                      child:
                          CircularProgressIndicator(),
                    )

                  : filteredStudents
                          .isEmpty

                      ? const Center(
                          child: Text(
                            "No Outstanding Students",
                          ),
                        )

                      : ListView.builder(

                          itemCount:
                              filteredStudents
                                  .length,

                          itemBuilder:
                              (context,
                                  index) {

                            final student =
                                filteredStudents[
                                    index];

                            return Card(

                              margin:
                                  const EdgeInsets
                                      .all(
                                10,
                              ),

                              elevation:
                                  4,

                              child:
                                  ListTile(

                                leading:
                                    CircleAvatar(

                                  backgroundColor:
                                      Colors.orange,

                                  child:
                                      Text(

                                    student[
                                            "student_id"]
                                        .toString()
                                        .substring(
                                            0,
                                            1),

                                  ),

                                ),

                                title:
                                    Text(

                                  student[
                                          "student_id"]
                                      .toString(),

                                  style:
                                      const TextStyle(
                                    fontWeight:
                                        FontWeight.bold,
                                  ),

                                ),

                                subtitle:
                                    Column(

                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,

                                  children: [

                                    const SizedBox(
                                      height:
                                          5,
                                    ),

                                    Text(
                                      "Balance : RM ${student["balance"]}",
                                    ),

                                    Text(
                                      "Status : ${student["status"]}",
                                    ),

                                  ],

                                ),

                                trailing:
                                    const Icon(
                                  Icons.warning,
                                  color: Colors.red,
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
