import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ID Card Generator',
      home: const FormPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class FormPage extends StatefulWidget {
  const FormPage({super.key});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final TextEditingController studentIDController = TextEditingController(text: '210041106');
  final TextEditingController studentNameController = TextEditingController(text: 'TAHSIN BIN REZA');
  final TextEditingController programController = TextEditingController(text: 'B.Sc. in CSE');
  final TextEditingController departmentController = TextEditingController(text: 'CSE');
  final TextEditingController countryController = TextEditingController(text: 'Bangladesh');

  Uint8List? pictureBytes;

  Future<void> pickImage() async {
    if (!kIsWeb) return;
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        pictureBytes = result.files.single.bytes!;
      });
    }
  }

  void onGenerateCard() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CardPage(
          studentID: studentIDController.text,
          studentName: studentNameController.text,
          program: programController.text,
          department: departmentController.text,
          country: countryController.text,
          pictureBytes: pictureBytes,
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ID Card Input Form'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildTextField('Student ID', studentIDController),
            _buildTextField('Student Name', studentNameController),
            _buildTextField('Program', programController),
            _buildTextField('Department', departmentController),
            _buildTextField('Country', countryController),
            const SizedBox(height: 20),
            if (kIsWeb)
              ElevatedButton(
                onPressed: pickImage,
                child: const Text('Upload Picture'),
              ),
            const SizedBox(height: 10),
            if (pictureBytes != null)
              Container(
                width: 120,
                height: 160,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: MemoryImage(pictureBytes!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onGenerateCard,
              child: const Text('Generate ID Card'),
            ),
          ],
        ),
      ),
    );
  }
}

class CardPage extends StatelessWidget {
  final String studentID;
  final String studentName;
  final String program;
  final String department;
  final String country;
  final Uint8List? pictureBytes;

  const CardPage({
    super.key,
    required this.studentID,
    required this.studentName,
    required this.program,
    required this.department,
    required this.country,
    this.pictureBytes,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ID Card'),
      ),
      body: Center(
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Container(
            width: 320,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0A450D), Color(0xFF042B06)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  children: const [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.school, size: 38, color: Color(0xFF0A450D)),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'ISLAMIC UNIVERSITY OF TECHNOLOGY',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1.2),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 100,
                      height: 130,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 2),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[200],
                        image: pictureBytes != null ? DecorationImage(image: MemoryImage(pictureBytes!), fit: BoxFit.cover) : null,
                      ),
                      child: pictureBytes == null
                          ? const Icon(Icons.person, size: 60, color: Colors.grey)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _infoRow(Icons.key, 'Student ID', studentID),
                          const SizedBox(height: 8),
                          _infoRow(Icons.person, 'Student Name', studentName, isBold: true),
                          const SizedBox(height: 8),
                          _infoRow(Icons.school, 'Program', program),
                          const SizedBox(height: 8),
                          _infoRow(Icons.business, 'Department', department),
                          const SizedBox(height: 8),
                          _infoRow(Icons.location_on, '', country),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(color: Colors.white54),
                const SizedBox(height: 8),
                const Text(
                  'A subsidiary organ of OIC',
                  style: TextStyle(color: Colors.white70, fontStyle: FontStyle.italic, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, {bool isBold = false}) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 18),
        const SizedBox(width: 8),
        if (label.isNotEmpty)
          Text(label,
              style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12)),
        if (label.isNotEmpty) const SizedBox(width: 6),
        Flexible(
          child: Text(
            value,
            style: TextStyle(color: Colors.white, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: isBold ? 14 : 12),
          ),
        ),
      ],
    );
  }
}
