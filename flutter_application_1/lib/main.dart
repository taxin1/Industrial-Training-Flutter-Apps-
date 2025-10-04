import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Ensure google_fonts in pubspec.yaml dependencies

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student ID Card',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: const StudentIDCard(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class StudentIDCard extends StatefulWidget {
  const StudentIDCard({super.key});
  @override
  State<StudentIDCard> createState() => _StudentIDCardState();
}

class _StudentIDCardState extends State<StudentIDCard> {
  int fontIndex = 0;
  int colorIndex = 0;

  final List<TextStyle Function(TextStyle?)> fontFamilies = [
    (style) => GoogleFonts.lato(textStyle: style),
    (style) => GoogleFonts.roboto(textStyle: style),
    (style) => GoogleFonts.openSans(textStyle: style),
    (style) => GoogleFonts.montserrat(textStyle: style),
    (style) => GoogleFonts.poppins(textStyle: style),
  ];

  final List<List<Color>> cardGradients = [
    [const Color(0xFF0A450D), const Color(0xFF042B06)], // Deep green
    [const Color(0xFF283048), const Color(0xFF859398)], // Blue-grey
    [const Color(0xFF6a11cb), const Color(0xFF2575fc)], // Purple-blue
    [const Color(0xFFff9966), const Color(0xFFff5e62)], // Orange-red
    [const Color(0xFF7F7FD5), const Color(0xFF86A8E7)], // Violet-light blue
  ];

  void changeFont() {
    setState(() {
      fontIndex = (fontIndex + 1) % fontFamilies.length;
    });
  }

  void changeBackground() {
    setState(() {
      colorIndex = (colorIndex + 1) % cardGradients.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final styleOverride = fontFamilies[fontIndex];
    final gradientColors = cardGradients[colorIndex];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double cardWidth = (constraints.maxWidth * 0.7).clamp(320.0, 320.0);
            double cardHeight = (constraints.maxHeight * 0.9).clamp(480.0, 620.0);
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    width: cardWidth,
                    height: cardHeight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: gradientColors,
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.school,
                                  size: 42,
                                  color: gradientColors[0],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'ISLAMIC UNIVERSITY OF TECHNOLOGY',
                                style: styleOverride(const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.1,
                                )),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 16.0),
                          alignment: Alignment.center,
                          child: Container(
                            width: 90,
                            height: 110,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              border: Border.all(color: Colors.grey[400]!, width: 2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: const Icon(Icons.person, size: 50, color: Colors.grey),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(16),
                                bottomRight: Radius.circular(16),
                              ),
                            ),
                            margin: EdgeInsets.zero,
                            padding: const EdgeInsets.fromLTRB(24, 4, 24, 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInfoRow(
                                  Icons.key,
                                  'Student ID',
                                  '210041106',
                                  fontOverride: styleOverride,
                                  highlight: true,
                                  highlightColor: Colors.blue.shade900,
                                ),
                                const SizedBox(height: 10),
                                _buildInfoRow(
                                  Icons.person,
                                  'Student Name',
                                  'TAHSIN BIN REZA',
                                  fontOverride: styleOverride,
                                  isBold: true,
                                ),
                                const SizedBox(height: 10),
                                _buildInfoRow(
                                  Icons.menu_book,
                                  'Program',
                                  'B.Sc. in CSE',
                                  fontOverride: styleOverride,
                                ),
                                const SizedBox(height: 10),
                                _buildInfoRow(
                                  Icons.business,
                                  'Department',
                                  'CSE',
                                  fontOverride: styleOverride,
                                ),
                                const SizedBox(height: 10),
                                _buildInfoRow(
                                  Icons.location_on,
                                  '',
                                  'Bangladesh',
                                  fontOverride: styleOverride,
                                ),
                                const Spacer(),
                                Center(
                                  child: Text(
                                    'A subsidiary organ of OIC',
                                    style: styleOverride(TextStyle(
                                      color: gradientColors[0],
                                      fontSize: 13,
                                      fontStyle: FontStyle.italic,
                                    )),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: changeFont,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: gradientColors[0],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text("Change Font"),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: changeBackground,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: gradientColors[1],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text("Change Color"),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    bool highlight = false,
    Color? highlightColor,
    bool isBold = false,
    TextStyle Function(TextStyle?)? fontOverride,
  }) {
    TextStyle labelStyle = fontOverride != null
        ? fontOverride!(TextStyle(
            color: Colors.grey.shade800,
            fontSize: 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          ))
        : TextStyle(
            color: Colors.grey.shade800,
            fontSize: 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          );
    TextStyle valueStyle = fontOverride != null
        ? fontOverride!(TextStyle(
            color: Colors.black,
            fontSize: isBold ? 15 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          ))
        : TextStyle(
            color: Colors.black,
            fontSize: isBold ? 15 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          );

    return Row(
      children: [
        Icon(icon, size: 20, color: highlightColor ?? Colors.green.shade900),
        const SizedBox(width: 10),
        if (label.isNotEmpty)
          Text(
            '$label ',
            style: labelStyle,
          ),
        if (highlight)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: highlightColor ?? Colors.blue.shade900,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              value,
              style: fontOverride != null
                  ? fontOverride!(const TextStyle(
                      color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold))
                  : const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
            ),
          )
        else
          Text(
            value,
            style: valueStyle,
          ),
      ],
    );
  }
}
