import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const IntelligentERP());
}

class IntelligentERP extends StatelessWidget {
  const IntelligentERP({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Intelligent ERP',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}

// ============================================================
// LOGIN PAGE
// ============================================================

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Icon(
                  Icons.school,
                  size: 80,
                  color: Colors.blue,
                ),

                const SizedBox(height: 20),

                const Text(
                  'Intelligent ERP',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Smart Academic Communication System',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 40),

                TextField(
                  decoration: InputDecoration(
                    labelText: 'Email / User ID',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RolePage(),
                        ),
                      );
                    },
                    child: const Text(
                      'Login',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'Students • Faculty • Parents • Administrators',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
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

// ============================================================
// ROLE PAGE
// ============================================================

class RolePage extends StatelessWidget {
  const RolePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Your Role'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),

            const Text(
              'Welcome to Intelligent ERP',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Choose your role to continue',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 30),

            RoleButton(
              icon: Icons.school,
              title: 'Student',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StudentDashboard(),
                  ),
                );
              },
            ),

            RoleButton(
              icon: Icons.person,
              title: 'Faculty',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FacultyDashboard(),
                  ),
                );
              },
            ),

            RoleButton(
              icon: Icons.family_restroom,
              title: 'Parent',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ParentDashboard(),
                  ),
                );
              },
            ),

            RoleButton(
              icon: Icons.admin_panel_settings,
              title: 'Administrator',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminDashboard(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// ROLE BUTTON
// ============================================================

class RoleButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onPressed;

  const RoleButton({
    super.key,
    required this.icon,
    required this.title,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(
          title,
          style: const TextStyle(fontSize: 18),
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}

// ============================================================
// STUDENT DASHBOARD
// ============================================================

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  bool isLoading = true;
  String errorMessage = '';

  String studentName = '';
  String department = '';
  String year = '';

  int attendance = 0;
  int assignmentsPending = 0;
  int upcomingExams = 0;
  int newAnnouncements = 0;

  @override
  void initState() {
    super.initState();
    fetchStudentData();
  }

  Future<void> fetchStudentData() async {
    try {
      final response = await http.get(
        Uri.parse(
          'http://10.0.2.2:5050/api/student',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          studentName = data['name'];
          department = data['department'];
          year = data['year'];
          attendance = data['attendance'];
          assignmentsPending = data['assignmentsPending'];
          upcomingExams = data['upcomingExams'];
          newAnnouncements = data['newAnnouncements'];

          isLoading = false;
          errorMessage = '';
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load student data';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Backend connection failed';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 60,
                        color: Colors.red,
                      ),

                      const SizedBox(height: 15),

                      Text(
                        errorMessage,
                        style: const TextStyle(fontSize: 18),
                      ),

                      const SizedBox(height: 15),

                      ElevatedButton(
                        onPressed: fetchStudentData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, $studentName',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        '$department • $year',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(height: 30),

                      // DASHBOARD CARDS
                      Row(
                        children: [
                          Expanded(
                            child: DashboardCard(
                              icon: Icons.calendar_month,
                              title: 'Attendance',
                              value: '$attendance%',
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: DashboardCard(
                              icon: Icons.assignment,
                              title: 'Assignments',
                              value: '$assignmentsPending Pending',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: DashboardCard(
                              icon: Icons.event,
                              title: 'Examinations',
                              value: '$upcomingExams Upcoming',
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: DashboardCard(
                              icon: Icons.notifications,
                              title: 'Announcements',
                              value: '$newAnnouncements New',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // ATTENDANCE DETAILS
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AttendanceDetailsScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.bar_chart),
                          label: const Text(
                            'View Attendance Details',
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ASSIGNMENTS
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AssignmentsScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.assignment),
                          label: const Text(
                            'View Assignments',
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // EXAMINATIONS
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ExaminationDetailsScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.event),
                          label: const Text(
                            'View Examination Details',
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),


                      // ANNOUNCEMENTS BUTTON
SizedBox(
  width: double.infinity,
  child: ElevatedButton.icon(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AnnouncementsScreen(),
        ),
      );
    },
    icon: const Icon(Icons.notifications),
    label: const Text('View Announcements'),
  ),
),

const SizedBox(height: 12),


// RESULTS
SizedBox(
  width: double.infinity,
  child: ElevatedButton.icon(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const StudentResultsScreen(),
        ),
      );
    },
    icon: const Icon(Icons.grade),
    label: const Text(
      'View Results',
    ),
  ),
),

const SizedBox(height: 12),

                      // REFRESH
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: fetchStudentData,
                          icon: const Icon(Icons.refresh),
                          label: const Text(
                            'Refresh Data',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

// ============================================================
// ATTENDANCE DETAILS SCREEN
// ============================================================

class AttendanceDetailsScreen extends StatelessWidget {
  const AttendanceDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bhargavi',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'Overall Attendance',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    const Text(
                      '85%',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),

                    const SizedBox(height: 15),

                    LinearProgressIndicator(
                      value: 0.85,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Subject-wise Attendance',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            AttendanceSubjectCard(
              subject: 'Computer Networks',
              attended: 28,
              total: 32,
              percentage: 88,
            ),

            AttendanceSubjectCard(
              subject: 'Neural Networks',
              attended: 25,
              total: 30,
              percentage: 83,
            ),

            AttendanceSubjectCard(
              subject: 'Big Data',
              attended: 27,
              total: 30,
              percentage: 90,
            ),

            AttendanceSubjectCard(
              subject: 'Compiler Design',
              attended: 23,
              total: 28,
              percentage: 82,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// ATTENDANCE SUBJECT CARD
// ============================================================

class AttendanceSubjectCard extends StatelessWidget {
  final String subject;
  final int attended;
  final int total;
  final int percentage;

  const AttendanceSubjectCard({
    super.key,
    required this.subject,
    required this.attended,
    required this.total,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subject,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              '$attended / $total classes attended',
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 8),

            LinearProgressIndicator(
              value: percentage / 100,
            ),

            const SizedBox(height: 8),

            Text(
              '$percentage%',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ANNOUNCEMENTS SCREEN
class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  bool isLoading = true;
  String errorMessage = '';

  List<dynamic> announcements = [];

  @override
  void initState() {
    super.initState();
    fetchAnnouncements();
  }

  Future<void> fetchAnnouncements() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:5050/api/announcements'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          announcements = data;
          isLoading = false;
          errorMessage = '';
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load announcements';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Backend connection failed';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Announcements'),
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 60,
                        color: Colors.red,
                      ),

                      const SizedBox(height: 15),

                      Text(
                        errorMessage,
                        style: const TextStyle(fontSize: 18),
                      ),

                      const SizedBox(height: 15),

                      ElevatedButton(
                        onPressed: fetchAnnouncements,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: fetchAnnouncements,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: announcements.length,
                    itemBuilder: (context, index) {
                      final announcement = announcements[index];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 15),
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.notifications,
                                    color: Colors.blue,
                                  ),

                                  const SizedBox(width: 10),

                                  Expanded(
                                    child: Text(
                                      announcement['title'],
                                      style: const TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              Text(
                                announcement['message'],
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),

                              const SizedBox(height: 12),

                              Text(
                                'Date: ${announcement['date']}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                ),
                              ),

                              const SizedBox(height: 5),

                              Text(
                                'Type: ${announcement['type']}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}


// ============================================================
// ASSIGNMENTS SCREEN
// ============================================================

class AssignmentsScreen extends StatefulWidget {
  const AssignmentsScreen({super.key});

  @override
  State<AssignmentsScreen> createState() =>
      _AssignmentsScreenState();
}

class _AssignmentsScreenState
    extends State<AssignmentsScreen> {
  bool isLoading = true;
  String errorMessage = '';

  List<dynamic> assignments = [];

  @override
  void initState() {
    super.initState();
    fetchAssignments();
  }

  Future<void> fetchAssignments() async {
    try {
      final response = await http.get(
        Uri.parse(
          'http://10.0.2.2:5050/api/student/assignments',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          assignments = data;
          isLoading = false;
          errorMessage = '';
        });
      } else {
        setState(() {
          errorMessage =
              'Failed to load assignments';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage =
            'Backend connection failed';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignments'),
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )

          : errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 60,
                        color: Colors.red,
                      ),

                      const SizedBox(height: 15),

                      Text(
                        errorMessage,
                        style:
                            const TextStyle(
                          fontSize: 18,
                        ),
                      ),

                      const SizedBox(height: 15),

                      ElevatedButton(
                        onPressed:
                            fetchAssignments,
                        child:
                            const Text('Retry'),
                      ),
                    ],
                  ),
                )

              : RefreshIndicator(
                  onRefresh:
                      fetchAssignments,

                  child: ListView.builder(
                    padding:
                        const EdgeInsets.all(20),

                    itemCount:
                        assignments.length,

                    itemBuilder:
                        (context, index) {
                      final assignment =
                          assignments[index];

                      return AssignmentCard(
                        subject:
                            assignment['subject'],
                        title:
                            assignment['title'],
                        dueDate:
                            assignment['dueDate'],
                        status:
                            assignment['status'],
                      );
                    },
                  ),
                ),
    );
  }
}

// ============================================================
// ASSIGNMENT CARD
// ============================================================

class AssignmentCard extends StatelessWidget {
  final String subject;
  final String title;
  final String dueDate;
  final String status;

  const AssignmentCard({
    super.key,
    required this.subject,
    required this.title,
    required this.dueDate,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subject,
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'Due Date: $dueDate',
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'Status: $status',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// ============================================================
// ============================================================
// EXAMINATION DETAILS SCREEN
// ============================================================

class ExaminationDetailsScreen extends StatefulWidget {
  const ExaminationDetailsScreen({super.key});

  @override
  State<ExaminationDetailsScreen> createState() =>
      _ExaminationDetailsScreenState();
}

class _ExaminationDetailsScreenState
    extends State<ExaminationDetailsScreen> {
  bool isLoading = true;
  String errorMessage = '';

  List<dynamic> exams = [];

  @override
  void initState() {
    super.initState();
    fetchExamData();
  }

  Future<void> fetchExamData() async {
    try {
      final response = await http.get(
        Uri.parse(
          'http://10.0.2.2:5050/api/student/exams',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          exams = data;
          isLoading = false;
          errorMessage = '';
        });
      } else {
        setState(() {
          errorMessage =
              'Failed to load examination details';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage =
            'Backend connection failed';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Examination Details',
        ),
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )

          : errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 60,
                        color: Colors.red,
                      ),

                      const SizedBox(height: 15),

                      Text(
                        errorMessage,
                        style:
                            const TextStyle(
                          fontSize: 18,
                        ),
                      ),

                      const SizedBox(height: 15),

                      ElevatedButton(
                        onPressed:
                            fetchExamData,
                        child:
                            const Text('Retry'),
                      ),
                    ],
                  ),
                )

              : RefreshIndicator(
                  onRefresh: fetchExamData,

                  child: ListView.builder(
                    padding:
                        const EdgeInsets.all(20),

                    itemCount: exams.length,

                    itemBuilder:
                        (context, index) {
                      final exam =
                          exams[index];

                      return ExamCard(
                        subject:
                            exam['subject'],
                        date:
                            exam['date'],
                        time:
                            exam['time'],
                        venue:
                            exam['venue'],
                      );
                    },
                  ),
                ),
    );
  }
}
// ============================================================
// ============================================================
// EXAM CARD
// ============================================================

class ExamCard extends StatelessWidget {
  final String subject;
  final String date;
  final String time;
  final String venue;

  const ExamCard({
    super.key,
    required this.subject,
    required this.date,
    required this.time,
    required this.venue,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),

      child: Padding(
        padding: const EdgeInsets.all(18),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            Text(
              subject,
              style: const TextStyle(
                fontSize: 19,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              'Date: $date',
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Time: $time',
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Venue: $venue',
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// ============================================================
// STUDENT RESULTS SCREEN
// ============================================================

class StudentResultsScreen extends StatefulWidget {
  const StudentResultsScreen({super.key});

  @override
  State<StudentResultsScreen> createState() =>
      _StudentResultsScreenState();
}

class _StudentResultsScreenState
    extends State<StudentResultsScreen> {
  bool isLoading = true;
  String errorMessage = '';

  String studentName = '';
  String semester = '';
  double cgpa = 0.0;

  List<dynamic> results = [];

  @override
  void initState() {
    super.initState();
    fetchResults();
  }

  Future<void> fetchResults() async {
    try {
      final response = await http.get(
        Uri.parse(
          'http://10.0.2.2:5050/api/student/results',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          studentName = data['studentName'];
          semester = data['semester'];
          cgpa = (data['cgpa'] as num).toDouble();
          results = data['results'];

          isLoading = false;
          errorMessage = '';
        });
      } else {
        setState(() {
          errorMessage =
              'Failed to load results';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage =
            'Backend connection failed';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Student Results',
        ),
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )

          : errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 60,
                        color: Colors.red,
                      ),

                      const SizedBox(height: 15),

                      Text(
                        errorMessage,
                        style:
                            const TextStyle(
                          fontSize: 18,
                        ),
                      ),

                      const SizedBox(height: 15),

                      ElevatedButton(
                        onPressed: fetchResults,
                        child:
                            const Text('Retry'),
                      ),
                    ],
                  ),
                )

              : RefreshIndicator(
                  onRefresh: fetchResults,

                  child: ListView(
                    padding:
                        const EdgeInsets.all(20),

                    children: [
                      Text(
                        studentName,
                        style:
                            const TextStyle(
                          fontSize: 26,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Semester: $semester',
                        style:
                            const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(height: 25),

                      Card(
                        child: Padding(
                          padding:
                              const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.school,
                                size: 45,
                                color: Colors.blue,
                              ),

                              const SizedBox(
                                  height: 12),

                              const Text(
                                'CGPA',
                                style:
                                    TextStyle(
                                  fontSize: 18,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),

                              const SizedBox(
                                  height: 8),

                              Text(
                                cgpa.toStringAsFixed(2),
                                style:
                                    const TextStyle(
                                  fontSize: 40,
                                  fontWeight:
                                      FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      const Text(
                        'Subject-wise Results',
                        style:
                            TextStyle(
                          fontSize: 20,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 15),

                      ...results.map(
                        (result) {
                          return Card(
                            margin:
                                const EdgeInsets.only(
                              bottom: 12,
                            ),

                            child: Padding(
                              padding:
                                  const EdgeInsets.all(
                                18,
                              ),

                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.grade,
                                    color: Colors.blue,
                                    size: 35,
                                  ),

                                  const SizedBox(
                                      width: 15),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                      children: [
                                        Text(
                                          result[
                                              'subject'],
                                          style:
                                              const TextStyle(
                                            fontSize:
                                                17,
                                            fontWeight:
                                                FontWeight
                                                    .bold,
                                          ),
                                        ),

                                        const SizedBox(
                                            height: 6),

                                        Text(
                                          'Marks: ${result['marks']}',
                                          style:
                                              const TextStyle(
                                            color:
                                                Colors.grey,
                                          ),
                                        ),

                                        const SizedBox(
                                            height: 4),

                                        Text(
                                          'Grade: ${result['grade']}',
                                          style:
                                              const TextStyle(
                                            fontWeight:
                                                FontWeight
                                                    .bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
    );
  }
}
// ============================================================
// DASHBOARD CARD
// ============================================================

class DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const DashboardCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Icon(
              icon,
              size: 40,
              color: Colors.blue,
            ),

            const SizedBox(height: 12),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// ============================================================
// ============================================================
// FACULTY DASHBOARD
// ============================================================

class FacultyDashboard extends StatefulWidget {
  const FacultyDashboard({super.key});

  @override
  State<FacultyDashboard> createState() =>
      _FacultyDashboardState();
}

class _FacultyDashboardState extends State<FacultyDashboard> {
  bool isLoading = true;
  String errorMessage = '';

  String facultyName = '';
  String department = '';

  int students = 0;
  String attendanceManagement = '';
  int activeAssignments = 0;
  String announcements = '';
  String timetable = '';

  List<dynamic> studentList = [];

  @override
  void initState() {
    super.initState();
    fetchFacultyData();
  }

  // ============================================================
  // FETCH FACULTY DATA
  // ============================================================

  Future<void> fetchFacultyData() async {
    try {
      final facultyResponse = await http.get(
        Uri.parse(
          'http://10.0.2.2:5050/api/faculty',
        ),
      );

      final studentsResponse = await http.get(
        Uri.parse(
          'http://10.0.2.2:5050/api/faculty/students',
        ),
      );

      if (facultyResponse.statusCode == 200 &&
          studentsResponse.statusCode == 200) {
        final facultyData =
            jsonDecode(facultyResponse.body);

        final studentsData =
            jsonDecode(studentsResponse.body);

        setState(() {
          facultyName =
              facultyData['name']?.toString() ?? '';

          department =
              facultyData['department']?.toString() ?? '';

          students =
              facultyData['students'] ?? 0;

          attendanceManagement =
              facultyData['attendanceManagement']
                      ?.toString() ??
                  '';

          activeAssignments =
              facultyData['activeAssignments'] ?? 0;

          announcements =
              facultyData['announcements']
                      ?.toString() ??
                  '';

          timetable =
              facultyData['timetable']
                      ?.toString() ??
                  '';

          studentList = studentsData;

          isLoading = false;
          errorMessage = '';
        });
      } else {
        setState(() {
          errorMessage =
              'Failed to load faculty data';

          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage =
            'Backend connection failed';

        isLoading = false;
      });
    }
  }

  // ============================================================
  // BUILD FACULTY DASHBOARD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Faculty Dashboard',
        ),
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )

          : errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 60,
                        color: Colors.red,
                      ),

                      const SizedBox(height: 15),

                      Text(
                        errorMessage,
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),

                      const SizedBox(height: 15),

                      ElevatedButton(
                        onPressed:
                            fetchFacultyData,
                        child: const Text(
                          'Retry',
                        ),
                      ),
                    ],
                  ),
                )

              : SingleChildScrollView(
                  padding:
                      const EdgeInsets.all(20),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      // ==================================================
                      // FACULTY NAME
                      // ==================================================

                      Text(
                        'Welcome, $facultyName',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        department,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(height: 30),

                      // ==================================================
                      // DASHBOARD CARDS - ROW 1
                      // ==================================================

                      Row(
                        children: [

                          Expanded(
                            child: DashboardCard(
                              icon: Icons.people,
                              title: 'Students',
                              value:
                                  '$students Students',
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: DashboardCard(
                              icon:
                                  Icons.fact_check,
                              title: 'Attendance',
                              value:
                                  attendanceManagement,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // ==================================================
                      // DASHBOARD CARDS - ROW 2
                      // ==================================================

                      Row(
                        children: [

                          Expanded(
                            child: DashboardCard(
                              icon:
                                  Icons.assignment,
                              title:
                                  'Assignments',
                              value:
                                  '$activeAssignments Active',
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: DashboardCard(
                              icon:
                                  Icons.campaign,
                              title:
                                  'Announcements',
                              value:
                                  announcements,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // ==================================================
                      // TIMETABLE
                      // ==================================================

                      DashboardCard(
                        icon:
                            Icons.calendar_month,
                        title:
                            'Timetable',
                        value:
                            timetable,
                      ),

                      const SizedBox(height: 30),

                      // ==================================================
                      // MANAGE STUDENT ATTENDANCE
                      // ==================================================

                      SizedBox(
                        width: double.infinity,

                        child:
                            ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        const FacultyAttendanceScreen(),
                              ),
                            );
                          },

                          icon: const Icon(
                            Icons.fact_check,
                          ),

                          label: const Text(
                            'Manage Student Attendance',
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ==================================================
                      // VIEW ASSIGNMENTS
                      // ==================================================

                      SizedBox(
                        width: double.infinity,

                        child:
                            ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        const FacultyAssignmentsScreen(),
                              ),
                            );
                          },

                          icon: const Icon(
                            Icons.assignment,
                          ),

                          label: const Text(
                            'View Assignments',
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ==================================================
                      // CREATE ANNOUNCEMENT
                      // ==================================================

                      SizedBox(
                        width: double.infinity,

                        child:
                            ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        const FacultyAnnouncementsScreen(),
                              ),
                            );
                          },

                          icon: const Icon(
                            Icons.campaign,
                          ),

                          label: const Text(
                            'Create Announcement',
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // ==================================================
                      // STUDENT DETAILS
                      // ==================================================

                      const Text(
                        'Student Details',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 15),

                      ListView.builder(
                        shrinkWrap: true,

                        physics:
                            const NeverScrollableScrollPhysics(),

                        itemCount:
                            studentList.length,

                        itemBuilder:
                            (context, index) {

                          final student =
                              studentList[index];

                          final name =
                              student['name']
                                  ?.toString() ??
                                  'Student';

                          return Card(
                            margin:
                                const EdgeInsets.only(
                              bottom: 12,
                            ),

                            child: ListTile(

                              leading:
                                  CircleAvatar(
                                child: Text(
                                  name
                                      .substring(0, 1)
                                      .toUpperCase(),
                                ),
                              ),

                              title: Text(
                                name,
                                style:
                                    const TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),

                              subtitle: Text(
                                'ID: ${student['id']}\n'
                                'Attendance: '
                                '${student['attendance']}%\n'
                                'Assignments Pending: '
                                '${student['assignmentsPending']}',
                              ),

                              isThreeLine: true,
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 20),

                      // ==================================================
                      // REFRESH DATA
                      // ==================================================

                      SizedBox(
                        width: double.infinity,

                        child:
                            ElevatedButton.icon(
                          onPressed:
                              fetchFacultyData,

                          icon: const Icon(
                            Icons.refresh,
                          ),

                          label: const Text(
                            'Refresh Data',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}


// ============================================================
// FACULTY ASSIGNMENTS SCREEN
// ============================================================

class FacultyAssignmentsScreen
    extends StatefulWidget {
  const FacultyAssignmentsScreen({
    super.key,
  });

  @override
  State<FacultyAssignmentsScreen> createState() =>
      _FacultyAssignmentsScreenState();
}

class _FacultyAssignmentsScreenState
    extends State<FacultyAssignmentsScreen> {

  bool isLoading = true;
  String errorMessage = '';

  List<dynamic> assignments = [];

  @override
  void initState() {
    super.initState();
    fetchAssignments();
  }

  // ============================================================
  // FETCH ASSIGNMENTS
  // ============================================================

  Future<void> fetchAssignments() async {
    try {
      final response = await http.get(
        Uri.parse(
          'http://10.0.2.2:5050/api/faculty/assignments',
        ),
      );

      if (response.statusCode == 200) {
        final data =
            jsonDecode(response.body);

        setState(() {
          assignments = data;

          isLoading = false;
          errorMessage = '';
        });
      } else {
        setState(() {
          errorMessage =
              'Failed to load assignments';

          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage =
            'Backend connection failed';

        isLoading = false;
      });
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Faculty Assignments'),
      ),

      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )

          : errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,

                    children: [

                      const Icon(
                        Icons.error_outline,
                        size: 60,
                        color: Colors.red,
                      ),

                      const SizedBox(height: 15),

                      Text(
                        errorMessage,
                        style:
                            const TextStyle(
                          fontSize: 18,
                        ),
                      ),

                      const SizedBox(height: 15),

                      ElevatedButton(
                        onPressed:
                            fetchAssignments,

                        child:
                            const Text('Retry'),
                      ),
                    ],
                  ),
                )

              : assignments.isEmpty
                  ? const Center(
                      child: Text(
                        'No assignments available',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    )

                  : RefreshIndicator(
                      onRefresh:
                          fetchAssignments,

                      child:
                          ListView.builder(
                        padding:
                            const EdgeInsets.all(
                          20,
                        ),

                        itemCount:
                            assignments.length,

                        itemBuilder:
                            (context, index) {

                          final assignment =
                              assignments[index];

                          return Card(
                            margin:
                                const EdgeInsets.only(
                              bottom: 15,
                            ),

                            child: Padding(
                              padding:
                                  const EdgeInsets.all(
                                18,
                              ),

                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,

                                children: [

                                  Row(
                                    children: [

                                      const Icon(
                                        Icons.assignment,
                                        color:
                                            Colors.blue,
                                      ),

                                      const SizedBox(
                                          width: 10),

                                      Expanded(
                                        child: Text(
                                          assignment[
                                                  'title']
                                              ?.toString() ??
                                              'Assignment',

                                          style:
                                              const TextStyle(
                                            fontSize: 19,
                                            fontWeight:
                                                FontWeight
                                                    .bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(
                                      height: 12),

                                  Text(
                                    'Subject: '
                                    '${assignment['subject']}',
                                  ),

                                  const SizedBox(
                                      height: 8),

                                  Text(
                                    'Due Date: '
                                    '${assignment['dueDate']}',
                                    style:
                                        const TextStyle(
                                      color:
                                          Colors.grey,
                                    ),
                                  ),

                                  const SizedBox(
                                      height: 8),

                                  Text(
                                    'Status: '
                                    '${assignment['status']}',
                                    style:
                                        const TextStyle(
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}


// ============================================================
// FACULTY ATTENDANCE SCREEN
// ============================================================

class FacultyAttendanceScreen
    extends StatefulWidget {

  const FacultyAttendanceScreen({
    super.key,
  });

  @override
  State<FacultyAttendanceScreen> createState() =>
      _FacultyAttendanceScreenState();
}

class _FacultyAttendanceScreenState
    extends State<FacultyAttendanceScreen> {

  bool isLoading = true;
  String errorMessage = '';

  List<dynamic> students = [];

  @override
  void initState() {
    super.initState();
    fetchAttendance();
  }

  // ============================================================
  // FETCH ATTENDANCE
  // ============================================================

  Future<void> fetchAttendance() async {
    try {
      final response = await http.get(
        Uri.parse(
          'http://10.0.2.2:5050/api/faculty/attendance',
        ),
      );

      if (response.statusCode == 200) {
        final data =
            jsonDecode(response.body);

        setState(() {
          students = data;

          isLoading = false;
          errorMessage = '';
        });
      } else {
        setState(() {
          errorMessage =
              'Failed to load attendance';

          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage =
            'Backend connection failed';

        isLoading = false;
      });
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Manage Attendance'),
      ),

      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )

          : errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,

                    children: [

                      const Icon(
                        Icons.error_outline,
                        size: 60,
                        color: Colors.red,
                      ),

                      const SizedBox(height: 15),

                      Text(
                        errorMessage,
                        style:
                            const TextStyle(
                          fontSize: 18,
                        ),
                      ),

                      const SizedBox(height: 15),

                      ElevatedButton(
                        onPressed:
                            fetchAttendance,

                        child:
                            const Text('Retry'),
                      ),
                    ],
                  ),
                )

              : RefreshIndicator(
                  onRefresh:
                      fetchAttendance,

                  child:
                      ListView.builder(
                    padding:
                        const EdgeInsets.all(
                      20,
                    ),

                    itemCount:
                        students.length,

                    itemBuilder:
                        (context, index) {

                      final student =
                          students[index];

                      final attendance =
                          (student['attendance']
                                  as num)
                              .toDouble();

                      return Card(
                        margin:
                            const EdgeInsets.only(
                          bottom: 15,
                        ),

                        child: Padding(
                          padding:
                              const EdgeInsets.all(
                            18,
                          ),

                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,

                            children: [

                              Text(
                                student['name']
                                    .toString(),

                                style:
                                    const TextStyle(
                                  fontSize: 19,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),

                              const SizedBox(
                                  height: 8),

                              Text(
                                'ID: '
                                '${student['id']}',
                              ),

                              const SizedBox(
                                  height: 8),

                              Text(
                                'Attendance: '
                                '${student['attendance']}%',
                              ),

                              const SizedBox(
                                  height: 12),

                              LinearProgressIndicator(
                                value:
                                    attendance / 100,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}


// ============================================================
// FACULTY ANNOUNCEMENTS SCREEN
// ============================================================

class FacultyAnnouncementsScreen
    extends StatefulWidget {

  const FacultyAnnouncementsScreen({
    super.key,
  });

  @override
  State<FacultyAnnouncementsScreen> createState() =>
      _FacultyAnnouncementsScreenState();
}

class _FacultyAnnouncementsScreenState
    extends State<FacultyAnnouncementsScreen> {

  final TextEditingController
      titleController =
      TextEditingController();

  final TextEditingController
      messageController =
      TextEditingController();

  String selectedType = 'General';

  bool isLoading = false;

  // ============================================================
  // CREATE ANNOUNCEMENT
  // ============================================================

  Future<void> createAnnouncement() async {

    if (titleController.text.trim().isEmpty ||
        messageController.text.trim().isEmpty) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter title and message',
          ),
        ),
      );

      return;
    }

    setState(() {
      isLoading = true;
    });

    try {

      final response = await http.post(
        Uri.parse(
          'http://10.0.2.2:5050/api/faculty/announcements',
        ),

        headers: {
          'Content-Type':
              'application/json',
        },

        body: jsonEncode({
          'title':
              titleController.text.trim(),

          'message':
              messageController.text.trim(),

          'type':
              selectedType,
        }),
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201) {

        titleController.clear();
        messageController.clear();

        setState(() {
          selectedType = 'General';
          isLoading = false;
        });

        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              'Announcement created successfully',
            ),
          ),
        );

      } else {

        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              'Failed to create announcement '
              '(${response.statusCode})',
            ),
          ),
        );
      }

    } catch (e) {

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Backend connection failed',
          ),
        ),
      );
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {

    titleController.dispose();
    messageController.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title:
            const Text(
          'Create Announcement',
        ),
      ),

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            // ==================================================
            // TITLE
            // ==================================================

            const Text(
              'Announcement Title',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller:
                  titleController,

              decoration:
                  const InputDecoration(
                border:
                    OutlineInputBorder(),

                hintText:
                    'Enter announcement title',
              ),
            ),

            const SizedBox(height: 20),

            // ==================================================
            // MESSAGE
            // ==================================================

            const Text(
              'Message',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller:
                  messageController,

              maxLines: 5,

              decoration:
                  const InputDecoration(
                border:
                    OutlineInputBorder(),

                hintText:
                    'Enter announcement message',
              ),
            ),

            const SizedBox(height: 20),

            // ==================================================
            // TYPE
            // ==================================================

            const Text(
              'Announcement Type',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              initialValue:
                  selectedType,

              decoration:
                  const InputDecoration(
                border:
                    OutlineInputBorder(),
              ),

              items: const [

                DropdownMenuItem(
                  value: 'General',
                  child:
                      Text('General'),
                ),

                DropdownMenuItem(
                  value: 'Exam',
                  child:
                      Text('Exam'),
                ),

                DropdownMenuItem(
                  value: 'Assignment',
                  child:
                      Text('Assignment'),
                ),

                DropdownMenuItem(
                  value: 'Important',
                  child:
                      Text('Important'),
                ),
              ],

              onChanged:
                  (value) {

                if (value != null) {

                  setState(() {
                    selectedType =
                        value;
                  });
                }
              },
            ),

            const SizedBox(height: 30),

            // ==================================================
            // CREATE BUTTON
            // ==================================================

            SizedBox(
              width:
                  double.infinity,

              child:
                  ElevatedButton.icon(

                onPressed:
                    isLoading
                        ? null
                        : createAnnouncement,

                icon: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.campaign,
                      ),

                label: Text(
                  isLoading
                      ? 'Creating...'
                      : 'Create Announcement',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// ADMIN DASHBOARD
// ============================================================
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() =>
      _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {

  int students = 0;
  int faculty = 0;
  int announcements = 0;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAdminSummary();
  }

  Future<void> fetchAdminSummary() async {
    try {
      final response = await http.get(
        Uri.parse(
          'http://10.0.2.2:5050/api/admin/summary',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          students = data['students'];
          faculty = data['faculty'];
          announcements = data['announcements'];
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Administrator Dashboard',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              'Welcome, Administrator',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Manage the Intelligent ERP system',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 30),

            Row(
              children: [

                Expanded(
                  child: DashboardCard(
                    icon: Icons.people,
                    title: 'Students',
                    value: isLoading ? '...' : '$students',
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: DashboardCard(
                    icon: Icons.person,
                    title: 'Faculty',
                    value: isLoading ? '...' : '$faculty',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [

                Expanded(
                  child: DashboardCard(
                    icon: Icons.campaign,
                    title: 'Announcements',
                    value: isLoading
                        ? '...'
                        : '$announcements Active',
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: DashboardCard(
                    icon: Icons.calendar_month,
                    title: 'Timetable',
                    value: 'Manage',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            DashboardCard(
              icon: Icons.bar_chart,
              title: 'Reports',
              value: 'View Reports',
            ),

            const SizedBox(height: 30),

            // STUDENT MANAGEMENT BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const AdminStudentManagementScreen(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.manage_accounts,
                ),
                label: const Text(
                  'Student Management',
                ),
              ),
            ),

            const SizedBox(height: 12),

            // FACULTY MANAGEMENT BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const AdminFacultyManagementScreen(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.school,
                ),
                label: const Text(
                  'Faculty Management',
                ),


              ),
            ),

          const SizedBox(height: 12),

            // ANNOUNCEMENT MANAGEMENT BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const AdminAnnouncementManagementScreen(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.campaign,
                ),
                label: const Text(
                  'Announcement Management',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// ADMIN - STUDENT MANAGEMENT
// ============================================================

class AdminStudentManagementScreen extends StatefulWidget {
  const AdminStudentManagementScreen({super.key});

  @override
  State<AdminStudentManagementScreen> createState() =>
      _AdminStudentManagementScreenState();
}

class _AdminStudentManagementScreenState
    extends State<AdminStudentManagementScreen> {

  List<dynamic> students = [];
  bool isLoading = true;
  bool isAdding = false;

  final TextEditingController idController =
      TextEditingController();

  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController departmentController =
      TextEditingController();

  final TextEditingController yearController =
      TextEditingController();

  final TextEditingController emailController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchStudents();
  }

  // ============================================================
  // FETCH STUDENTS
  // ============================================================

  Future<void> fetchStudents() async {

    try {

      final response = await http.get(
        Uri.parse(
          'http://10.0.2.2:5050/api/admin/students',
        ),
      );

      if (response.statusCode == 200) {

        setState(() {
          students = jsonDecode(response.body);
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

    }
  }

  // ============================================================
  // ADD STUDENT
  // ============================================================

  Future<void> addStudent() async {

    if (idController.text.trim().isEmpty ||
        nameController.text.trim().isEmpty ||
        departmentController.text.trim().isEmpty ||
        yearController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please fill all student details',
          ),
        ),
      );

      return;
    }

    setState(() {
      isAdding = true;
    });

    try {

      final response = await http.post(
        Uri.parse(
          'http://10.0.2.2:5050/api/admin/students',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'id': idController.text.trim(),
          'name': nameController.text.trim(),
          'department': departmentController.text.trim(),
          'year': yearController.text.trim(),
          'email': emailController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {

        idController.clear();
        nameController.clear();
        departmentController.clear();
        yearController.clear();
        emailController.clear();

        setState(() {
          isAdding = false;
        });

        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Student added successfully',
            ),
          ),
        );

      } else {

        setState(() {
          isAdding = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Failed to add student',
            ),
          ),
        );
      }

    } catch (e) {

      setState(() {
        isAdding = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Backend connection failed',
          ),
        ),
      );
    }
  }

  // ============================================================
  // ADD STUDENT FORM
  // ============================================================

  void showAddStudentForm() {

    showDialog(
      context: context,
      builder: (context) {

        return AlertDialog(
          title: const Text(
            'Add Student',
          ),

          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                TextField(
                  controller: idController,
                  decoration: const InputDecoration(
                    labelText: 'Student ID',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Student Name',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: departmentController,
                  decoration: const InputDecoration(
                    labelText: 'Department',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: yearController,
                  decoration: const InputDecoration(
                    labelText: 'Year',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),

          actions: [

            TextButton(
              onPressed: isAdding
                  ? null
                  : () {
                      Navigator.pop(context);
                    },
              child: const Text(
                'Cancel',
              ),
            ),

            ElevatedButton(
              onPressed: isAdding
                  ? null
                  : addStudent,
              child: isAdding
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Add Student',
                    ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {

    idController.dispose();
    nameController.dispose();
    departmentController.dispose();
    yearController.dispose();
    emailController.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          'Student Management',
        ),

        actions: [

          IconButton(
            onPressed: fetchStudents,
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: showAddStudentForm,
        icon: const Icon(
          Icons.person_add,
        ),
        label: const Text(
          'Add Student',
        ),
      ),

      body: isLoading

          ? const Center(
              child: CircularProgressIndicator(),
            )

          : students.isEmpty

              ? const Center(
                  child: Text(
                    'No students found',
                  ),
                )

              : ListView.builder(
                  padding: const EdgeInsets.all(16),

                  itemCount: students.length,

                  itemBuilder: (context, index) {

                    final student = students[index];

                    return Card(
                      margin: const EdgeInsets.only(
                        bottom: 14,
                      ),

                      elevation: 3,

                      child: Padding(
                        padding: const EdgeInsets.all(16),

                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,

                          children: [

                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,

                              children: [

                                Expanded(
                                  child: Text(
                                    student['name'],
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                ),

                                IconButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(
                                      context,
                                    ).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Delete functionality coming next',
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.delete,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            Text(
                              'Student ID: ${student['id']}',
                            ),

                            const SizedBox(height: 5),

                            Text(
                              'Department: ${student['department']}',
                            ),

                            const SizedBox(height: 5),

                            Text(
                              'Year: ${student['year']}',
                            ),

                            const SizedBox(height: 5),

                            Text(
                              'Email: ${student['email']}',
                            ),

                            const SizedBox(height: 5),

                            Text(
                              'Attendance: ${student['attendance']}%',
                            ),

                            const SizedBox(height: 5),

                            Text(
                              'Status: ${student['status']}',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
                  

// ============================================================

// PARENT DASHBOARD
// ============================================================

class ParentDashboard extends StatefulWidget {
  const ParentDashboard({super.key});

  @override
  State<ParentDashboard> createState() =>
      _ParentDashboardState();
}

class _ParentDashboardState
    extends State<ParentDashboard> {
  bool isLoading = true;
  String errorMessage = '';

  String parentName = '';
  String studentName = '';
  String studentId = '';

  int attendance = 0;
  int assignmentsPending = 0;
  int upcomingExams = 0;

  String feeReminder = '';

  int newAnnouncements = 0;

  @override
  void initState() {
    super.initState();
    fetchParentData();
  }

  Future<void> fetchParentData() async {
    try {
      final response = await http.get(
        Uri.parse(
          'http://10.0.2.2:5050/api/parent',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(
          response.body,
        );

        setState(() {
          parentName = data['parentName'];

          studentName = data['studentName'];

          studentId = data['studentId'];

          attendance = data['attendance'];

          assignmentsPending =
              data['assignmentsPending'];

          upcomingExams =
              data['upcomingExams'];

          feeReminder =
              data['feeReminder'];

          newAnnouncements =
              data['newAnnouncements'];

          isLoading = false;
          errorMessage = '';
        });
      } else {
        setState(() {
          errorMessage =
              'Failed to load parent data';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage =
            'Backend connection failed';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Parent Dashboard',
        ),
      ),

      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )

          : errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 60,
                        color: Colors.red,
                      ),

                      const SizedBox(height: 15),

                      Text(
                        errorMessage,
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),

                      const SizedBox(height: 15),

                      ElevatedButton(
                        onPressed:
                            fetchParentData,
                        child:
                            const Text('Retry'),
                      ),
                    ],
                  ),
                )

              : SingleChildScrollView(
                  padding:
                      const EdgeInsets.all(20),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      Text(
                        'Welcome, $parentName',
                        style:
                            const TextStyle(
                          fontSize: 26,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Student: $studentName ($studentId)',
                        style:
                            const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(height: 30),

                      // ATTENDANCE + ASSIGNMENTS
                      Row(
                        children: [
                          Expanded(
                            child:
                                DashboardCard(
                              icon:
                                  Icons.calendar_month,
                              title:
                                  'Attendance',
                              value:
                                  '$attendance%',
                            ),
                          ),

                          const SizedBox(
                              width: 12),

                          Expanded(
                            child:
                                DashboardCard(
                              icon:
                                  Icons.assignment,
                              title:
                                  'Assignments',
                              value:
                                  '$assignmentsPending Pending',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // EXAMINATIONS + ANNOUNCEMENTS
                      Row(
                        children: [
                          Expanded(
                            child:
                                DashboardCard(
                              icon:
                                  Icons.event,
                              title:
                                  'Examinations',
                              value:
                                  '$upcomingExams Upcoming',
                            ),
                          ),

                          const SizedBox(
                              width: 12),

                          Expanded(
                            child:
                                DashboardCard(
                              icon:
                                  Icons.notifications,
                              title:
                                  'Announcements',
                              value:
                                  '$newAnnouncements New',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // FEE REMINDER CARD
                      DashboardCard(
                        icon: Icons.payment,
                        title:
                            'Fee Reminder',
                        value:
                            feeReminder,
                      ),

                      const SizedBox(height: 30),

                      // VIEW FEE DETAILS BUTTON
                      SizedBox(
                        width: double.infinity,
                        child:
                            ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        const ParentFeeDetailsScreen(),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.payment,
                          ),
                          label: const Text(
                            'View Fee Details',
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),


                      // VIEW ANNOUNCEMENTS BUTTON
SizedBox(
  width: double.infinity,
  child: ElevatedButton.icon(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const AnnouncementsScreen(),
        ),
      );
    },
    icon: const Icon(
      Icons.notifications,
    ),
    label: const Text(
      'View Announcements',
    ),
  ),
),

const SizedBox(height: 12),

                      // REFRESH BUTTON
                      SizedBox(
                        width: double.infinity,
                        child:
                            ElevatedButton.icon(
                          onPressed:
                              fetchParentData,
                          icon: const Icon(
                            Icons.refresh,
                          ),
                          label: const Text(
                            'Refresh Data',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}


class AdminFacultyManagementScreen extends StatefulWidget {
  const AdminFacultyManagementScreen({super.key});

  @override
  State<AdminFacultyManagementScreen> createState() =>
      _AdminFacultyManagementScreenState();
}

class _AdminFacultyManagementScreenState
    extends State<AdminFacultyManagementScreen> {
  List<dynamic> faculty = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFaculty();
  }

  Future<void> fetchFaculty() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:5050/api/admin/faculty'),
      );

      if (response.statusCode == 200) {
        setState(() {
          faculty = jsonDecode(response.body);
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Faculty Management'),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : faculty.isEmpty
              ? const Center(
                  child: Text('No faculty records found'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: faculty.length,
                  itemBuilder: (context, index) {
                    final member = faculty[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 14),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              member['name'],
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 10),

                            Text(
                              'Faculty ID: ${member['id']}',
                              style: const TextStyle(fontSize: 15),
                            ),

                            const SizedBox(height: 5),

                            Text(
                              'Department: ${member['department']}',
                              style: const TextStyle(fontSize: 15),
                            ),

                            const SizedBox(height: 5),

                            Text(
                              'Email: ${member['email']}',
                              style: const TextStyle(fontSize: 15),
                            ),

                            const SizedBox(height: 5),

                            Text(
                              'Students: ${member['students']}',
                              style: const TextStyle(fontSize: 15),
                            ),

                            const SizedBox(height: 8),

                            Row(
                              children: [
                                const Text(
                                  'Status: ',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  member['status'],
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}


// ============================================================
// ADMIN - ANNOUNCEMENT MANAGEMENT
// ============================================================

class AdminAnnouncementManagementScreen extends StatefulWidget {
  const AdminAnnouncementManagementScreen({super.key});

  @override
  State<AdminAnnouncementManagementScreen> createState() =>
      _AdminAnnouncementManagementScreenState();
}

class _AdminAnnouncementManagementScreenState
    extends State<AdminAnnouncementManagementScreen> {

  final TextEditingController titleController =
      TextEditingController();

  final TextEditingController messageController =
      TextEditingController();

  String selectedType = 'General';

  bool isLoading = false;

  Future<void> createAnnouncement() async {
    if (titleController.text.trim().isEmpty ||
        messageController.text.trim().isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter title and message',
          ),
        ),
      );

      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(
          'http://10.0.2.2:5050/api/admin/announcements',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'title': titleController.text.trim(),
          'message': messageController.text.trim(),
          'type': selectedType,
        }),
      );

      if (response.statusCode == 200) {

        titleController.clear();
        messageController.clear();

        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Announcement created successfully',
            ),
          ),
        );

      } else {

        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Failed to create announcement',
            ),
          ),
        );
      }

    } catch (e) {

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Backend connection failed',
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Announcement Management',
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            const Text(
              'Create Announcement',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Announcement Title',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: messageController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Announcement Message',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              value: selectedType,

              decoration: const InputDecoration(
                labelText: 'Announcement Type',
                border: OutlineInputBorder(),
              ),

              items: const [
                DropdownMenuItem(
                  value: 'General',
                  child: Text('General'),
                ),
                DropdownMenuItem(
                  value: 'Exam',
                  child: Text('Exam'),
                ),
                DropdownMenuItem(
                  value: 'Assignment',
                  child: Text('Assignment'),
                ),
                DropdownMenuItem(
                  value: 'Academic',
                  child: Text('Academic'),
                ),
              ],

              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedType = value;
                  });
                }
              },
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton.icon(
                onPressed:
                    isLoading
                        ? null
                        : createAnnouncement,

                icon: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.send,
                      ),

                label: Text(
                  isLoading
                      ? 'Creating...'
                      : 'Create Announcement',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// PARENT FEE DETAILS SCREEN
class ParentFeeDetailsScreen extends StatefulWidget {
  const ParentFeeDetailsScreen({super.key});

  @override
  State<ParentFeeDetailsScreen> createState() =>
      _ParentFeeDetailsScreenState();
}

class _ParentFeeDetailsScreenState
    extends State<ParentFeeDetailsScreen> {
  bool isLoading = true;
  String errorMessage = '';

  String studentName = '';
  int totalFee = 0;
  int paidFee = 0;
  int pendingFee = 0;
  String dueDate = '';
  String status = '';

  @override
  void initState() {
    super.initState();
    fetchFeeData();
  }

  Future<void> fetchFeeData() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:5050/api/parent/fees'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          studentName = data['studentName'];
          totalFee = data['totalFee'];
          paidFee = data['paidFee'];
          pendingFee = data['pendingFee'];
          dueDate = data['dueDate'];
          status = data['status'];
          isLoading = false;
          errorMessage = '';
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load fee details';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Backend connection failed';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fee Details'),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 60,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 15),
                      Text(
                        errorMessage,
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: fetchFeeData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        studentName,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 25),

                      DashboardCard(
                        icon: Icons.currency_rupee,
                        title: 'Total Fee',
                        value: '₹$totalFee',
                      ),

                      const SizedBox(height: 12),

                      DashboardCard(
                        icon: Icons.check_circle,
                        title: 'Paid Fee',
                        value: '₹$paidFee',
                      ),

                      const SizedBox(height: 12),

                      DashboardCard(
                        icon: Icons.pending,
                        title: 'Pending Fee',
                        value: '₹$pendingFee',
                      ),

                      const SizedBox(height: 12),

                      DashboardCard(
                        icon: Icons.calendar_month,
                        title: 'Due Date',
                        value: dueDate,
                      ),

                      const SizedBox(height: 12),

                      DashboardCard(
                        icon: Icons.info,
                        title: 'Status',
                        value: status,
                      ),

                      const SizedBox(height: 25),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: fetchFeeData,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Refresh Data'),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

