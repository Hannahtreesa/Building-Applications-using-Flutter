import 'package:flutter/material.dart';

import 'student.dart';
import 'database_helper.dart';

void main() {
  runApp(
    const MaterialApp(debugShowCheckedModeBanner: false, home: StudentPage()),
  );
}

class StudentPage extends StatefulWidget {
  const StudentPage({super.key});
  @override
  State<StudentPage> createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  final name = TextEditingController();
  final regno = TextEditingController();
  final cgpa = TextEditingController();
  List<Student> students = [];
  // Load students from database
  void loadStudents() async {
    students = await DatabaseHelper.getStudents();
    setState(() {});
  }

  // Save student details
  void saveStudent() async {
    if (name.text.isEmpty || regno.text.isEmpty || cgpa.text.isEmpty) {
      return;
    }
    Student s = Student(name.text, regno.text, double.tryParse(cgpa.text) ?? 0);
    await DatabaseHelper.insertStudent(s);
    name.clear();
    regno.clear();
    cgpa.clear();
    loadStudents();
  }

  @override
  void initState() {
    super.initState();
    loadStudents();
  }

  @override
  void dispose() {
    name.dispose();
    regno.dispose();
    cgpa.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Students Info Mgmt'),
        backgroundColor: Colors.amber,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            TextField(
              controller: name,
              decoration: const InputDecoration(
                labelText: 'Enter Student Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: regno,
              decoration: const InputDecoration(
                labelText: 'Enter Student Regno',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: cgpa,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Enter Student CGPA',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            ElevatedButton(
              onPressed: saveStudent,
              child: const Text('Save Details'),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: students.length,
                itemBuilder: (context, index) {
                  Student s = students[index];
                  return ListTile(
                    leading: CircleAvatar(child: Text(s.name[0].toUpperCase())),
                    title: Text(s.name),
                    subtitle: Text('Regno: ${s.regno}, CGPA: ${s.cgpa}'),
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
