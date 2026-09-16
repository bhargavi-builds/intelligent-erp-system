import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'config/api_config.dart';
import 'services/notification_service.dart';

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final notificationService = NotificationService();
  await notificationService.initialize();
  await notificationService.requestPermissions();

  runApp(const IntelligentERP());
}

class IntelligentERP extends StatefulWidget {
  const IntelligentERP({super.key});

  @override
  State<IntelligentERP> createState() => _IntelligentERPState();
}

class _IntelligentERPState extends State<IntelligentERP> {
  StreamSubscription<String?>? _notificationSubscription;

  @override
  void initState() {
    super.initState();
    _notificationSubscription =
        NotificationService().onNotificationTap.listen((payload) {
      if (payload == null || payload.isEmpty) return;
      final context = appNavigatorKey.currentContext;
      if (context == null) return;

      final p = payload.toLowerCase();
      if (p.contains('assignment')) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AssignmentsScreen()),
        );
      } else if (p.contains('announcement')) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AnnouncementsScreen()),
        );
      } else if (p.contains('exam')) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ExaminationDetailsScreen()),
        );
      } else if (p.contains('fee')) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ParentFeeDetailsScreen()),
        );
      } else if (p.contains('attendance')) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AttendanceDetailsScreen()),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NotificationsScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: appNavigatorKey,
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

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController =
      TextEditingController(text: 'bhargavi@hitam.edu');
  final TextEditingController _passwordController =
      TextEditingController(text: 'password123');
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter both Email and Password';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.post(
        ApiConfig.loginUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final role = data['user']?['role']?.toString().toLowerCase() ?? 'student';
        final userId = data['user']?['id']?.toString() ?? 'STU001';
        final userEmail = data['user']?['email']?.toString() ?? email;

        // Sync active session with NotificationService for zero-delay role alerts
        NotificationService().setUserSession(
          role: role,
          userId: userId,
          email: userEmail,
        );

        if (!mounted) return;

        // Route to the corresponding role dashboard
        Widget targetDashboard;
        switch (role) {
          case 'faculty':
            targetDashboard = const FacultyDashboard();
            break;
          case 'parent':
            targetDashboard = const ParentDashboard();
            break;
          case 'admin':
            targetDashboard = const AdminDashboard();
            break;
          case 'student':
          default:
            targetDashboard = const StudentDashboard();
            break;
        }

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => targetDashboard),
        );
      } else {
        setState(() {
          _errorMessage = 'Invalid credentials. Please try again.';
        });
      }
    } catch (e) {
      // If network fails, navigate to role selector as graceful fallback
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connecting to backend (${ApiConfig.baseUrl})...'),
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RolePage()),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

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

                const SizedBox(height: 30),

                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),

                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email / User ID',
                    hintText: 'e.g. bhargavi@hitam.edu',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                TextField(
                  controller: _passwordController,
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
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'Sign In',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RolePage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.touch_app),
                  label: const Text('Quick Role Selector (Demo Mode)'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
                NotificationService().setUserSession(
                  role: 'student',
                  userId: 'STU001',
                  email: 'bhargavi@hitam.edu',
                );
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
                NotificationService().setUserSession(
                  role: 'faculty',
                  userId: 'FAC001',
                  email: 'ramesh@hitam.edu',
                );
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
                NotificationService().setUserSession(
                  role: 'parent',
                  userId: 'PAR001',
                  email: 'narayana@hitam.edu',
                );
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
                NotificationService().setUserSession(
                  role: 'admin',
                  userId: 'ADM001',
                  email: 'admin@hitam.edu',
                );
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
          '${ApiConfig.baseUrl}/api/student',
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
        actions: const [
          NotificationBellIcon(role: 'student'),
        ],
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
// ATTENDANCE DETAILS SCREEN (OPTIMIZED RESPONSIVE DASHBOARD)
// ============================================================

class AttendanceDetailsScreen extends StatefulWidget {
  const AttendanceDetailsScreen({super.key});

  @override
  State<AttendanceDetailsScreen> createState() =>
      _AttendanceDetailsScreenState();
}

class _AttendanceDetailsScreenState extends State<AttendanceDetailsScreen> {
  bool isLoading = true;
  String errorMessage = '';

  String studentName = 'Bhargavi';
  String studentId = '22K91A0501';
  String department = 'CSE - 4th Year';
  String semester = 'Semester 7';
  int overallAttendance = 85;
  int totalClasses = 120;
  int attendedClasses = 103;
  int marginClasses = 16;

  List<Map<String, dynamic>> subjects = [];

  @override
  void initState() {
    super.initState();
    fetchAttendanceData();
  }

  Future<void> fetchAttendanceData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/student/attendance'),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          studentName = data['studentName']?.toString() ?? 'Bhargavi';
          studentId = data['studentId']?.toString() ?? '22K91A0501';
          department = data['department']?.toString() ?? 'CSE - 4th Year';
          semester = data['semester']?.toString() ?? 'Semester 7';

          overallAttendance = (data['overallAttendance'] is num)
              ? (data['overallAttendance'] as num).toInt()
              : int.tryParse(data['overallAttendance']?.toString() ?? '') ?? 85;

          totalClasses = (data['totalClasses'] is num)
              ? (data['totalClasses'] as num).toInt()
              : int.tryParse(data['totalClasses']?.toString() ?? '') ?? 120;

          attendedClasses = (data['attendedClasses'] is num)
              ? (data['attendedClasses'] as num).toInt()
              : int.tryParse(data['attendedClasses']?.toString() ?? '') ?? 103;

          marginClasses = (data['marginClasses'] is num)
              ? (data['marginClasses'] as num).toInt()
              : int.tryParse(data['marginClasses']?.toString() ?? '') ?? 16;

          if (data['subjects'] is List && (data['subjects'] as List).isNotEmpty) {
            subjects = List<Map<String, dynamic>>.from(
              (data['subjects'] as List).map(
                (s) => Map<String, dynamic>.from(s as Map),
              ),
            );
          } else {
            subjects = [
              {
                "subject": "Computer Networks",
                "code": "CS701PC",
                "faculty": "Dr. Ramesh",
                "attended": 28,
                "total": 32,
                "percentage": 88
              },
              {
                "subject": "Neural Networks",
                "code": "CS702PE",
                "faculty": "Prof. Priya",
                "attended": 25,
                "total": 30,
                "percentage": 83
              },
              {
                "subject": "Big Data",
                "code": "CS703PE",
                "faculty": "Dr. Sharma",
                "attended": 27,
                "total": 30,
                "percentage": 90
              },
              {
                "subject": "Compiler Design",
                "code": "CS704PC",
                "faculty": "Prof. K. Rao",
                "attended": 23,
                "total": 28,
                "percentage": 82
              }
            ];
          }

          isLoading = false;
          errorMessage = '';
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load attendance details';
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      // Fallback with realistic HITAM mock data
      setState(() {
        studentName = 'Bhargavi';
        studentId = '22K91A0501';
        department = 'CSE - 4th Year';
        semester = 'Semester 7';
        overallAttendance = 85;
        totalClasses = 120;
        attendedClasses = 103;
        marginClasses = 16;
        subjects = [
          {
            "subject": "Computer Networks",
            "code": "CS701PC",
            "faculty": "Dr. Ramesh",
            "attended": 28,
            "total": 32,
            "percentage": 88
          },
          {
            "subject": "Neural Networks",
            "code": "CS702PE",
            "faculty": "Prof. Priya",
            "attended": 25,
            "total": 30,
            "percentage": 83
          },
          {
            "subject": "Big Data",
            "code": "CS703PE",
            "faculty": "Dr. Sharma",
            "attended": 27,
            "total": 30,
            "percentage": 90
          },
          {
            "subject": "Compiler Design",
            "code": "CS704PC",
            "faculty": "Prof. K. Rao",
            "attended": 23,
            "total": 28,
            "percentage": 82
          }
        ];
        isLoading = false;
        errorMessage = '';
      });
    }
  }

  void _showLeaveModal(BuildContext context) {
    String leaveType = 'Medical Leave';
    final reasonController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 24,
                      left: 24,
                      right: 24,
                      bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.edit_calendar, color: Colors.blue),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Apply for Leave / On-Duty (OD)',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Student: $studentName ($studentId)',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(ctx),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Select Category',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: leaveType,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'Medical Leave', child: Text('Medical Leave (Sick / Hospitalization)')),
                            DropdownMenuItem(value: 'On-Duty (Hackathon)', child: Text('On-Duty (Hackathon / Tech Fest)')),
                            DropdownMenuItem(value: 'On-Duty (Sports)', child: Text('On-Duty (University Sports Meet)')),
                            DropdownMenuItem(value: 'Personal / Family', child: Text('Personal / Family Event')),
                          ],
                          onChanged: (val) => setModalState(() => leaveType = val!),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Duration / Date(s)',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.calendar_today, size: 18, color: Colors.blue),
                                  SizedBox(width: 10),
                                  Text('16 Sep 2026  ➔  18 Sep 2026 (3 Days)'),
                                ],
                              ),
                              Text('Change', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Reason / Justification',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: reasonController,
                          maxLines: 2,
                          decoration: InputDecoration(
                            hintText: 'e.g. Attending Smart India Hackathon finals with college team',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.all(12),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.send),
                            label: const Text('Submit Application to HOD', style: TextStyle(fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade700,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('$leaveType request submitted to Dr. Ramesh (HOD CSE). Tracking Ref: HITAM-OD-2026-891'),
                                  backgroundColor: Colors.green.shade800,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showMarginCalculator(BuildContext context) {
    int simulateMiss = 2;
    int simulateAttend = 4;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final int projAttended = attendedClasses + simulateAttend;
            final int projTotal = totalClasses + simulateAttend + simulateMiss;
            final double projPercent = projTotal > 0 ? (projAttended / projTotal) * 100 : 85.0;

            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.calculate, color: Colors.blue),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Attendance Margin Calculator',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      Text(
                        'Project your future attendance by simulating upcoming attended vs. missed lectures:',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: projPercent >= 75 ? Colors.green.shade50 : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: projPercent >= 75 ? Colors.green.shade300 : Colors.red.shade300,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Projected Attendance:', style: TextStyle(fontWeight: FontWeight.bold)),
                                Text(
                                  projPercent >= 75 ? 'Safe Zone (Exam Eligible)' : 'Warning: Below 75% Cutoff',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: projPercent >= 75 ? Colors.green.shade900 : Colors.red.shade900,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '${projPercent.toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: projPercent >= 75 ? Colors.green.shade900 : Colors.red.shade900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Upcoming Classes Attending:'),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: simulateAttend > 0 ? () => setDialogState(() => simulateAttend--) : null,
                              ),
                              Text('$simulateAttend', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: () => setDialogState(() => simulateAttend++),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Upcoming Classes Missing:'),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: simulateMiss > 0 ? () => setDialogState(() => simulateMiss--) : null,
                              ),
                              Text('$simulateMiss', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: () => setDialogState(() => simulateMiss++),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Close'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showTranscriptDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 550),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.school, size: 28, color: Colors.blue),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'HITAM HYDERABAD',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              'Official Attendance Transcript',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Doc Ref: HITAM/ATT/2026/0411', style: TextStyle(fontSize: 13, color: Colors.grey.shade800, fontWeight: FontWeight.bold)),
                    const Text('Issued: 15 Sep 2026', style: TextStyle(fontSize: 13, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Candidate: $studentName', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Roll No: $studentId | Department: $department'),
                      const SizedBox(height: 4),
                      Text('Semester: $semester | Academic Year: 2025-2026'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Subject-wise Verified Records:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                for (var s in subjects) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${s['subject']} (${s['code'] ?? 'CS'})'),
                        Text(
                          '${s['attended']} / ${s['total']} (${s['percentage']}%)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: (s['percentage'] as int) >= 75 ? Colors.green.shade800 : Colors.orange.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Aggregate Attendance:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(
                      '$overallAttendance% (EXAM ELIGIBLE)',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade800, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Attendance Transcript PDF downloaded to local storage.')),
                        );
                      },
                      icon: const Icon(Icons.download),
                      label: const Text('Download PDF'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStudentHeroCard() {
    final bool isEligible = overallAttendance >= 75;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blue.shade100,
              child: const Icon(Icons.school, size: 32, color: Colors.blue),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    studentName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          'Roll: $studentId',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade800, fontWeight: FontWeight.w500),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Text(
                          department,
                          style: TextStyle(fontSize: 12, color: Colors.blue.shade800, fontWeight: FontWeight.w500),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.purple.shade200),
                        ),
                        child: Text(
                          semester,
                          style: TextStyle(fontSize: 12, color: Colors.purple.shade800, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isEligible ? Colors.green.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isEligible ? Colors.green.shade300 : Colors.red.shade300),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isEligible ? Icons.verified : Icons.warning_amber_rounded,
                    size: 18,
                    color: isEligible ? Colors.green.shade800 : Colors.red.shade800,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isEligible ? 'Exam Eligible ($overallAttendance%)' : 'Shortage ($overallAttendance%)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isEligible ? Colors.green.shade900 : Colors.red.shade900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiCard({
    required IconData icon,
    required Color color,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Expanded(
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKpiSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth >= 720;
        if (isDesktop) {
          return Row(
            children: [
              _buildKpiCard(
                icon: Icons.donut_large,
                color: Colors.blue.shade700,
                title: 'Overall Attendance',
                value: '$overallAttendance.0%',
                subtitle: '+10% above university cutoff',
              ),
              const SizedBox(width: 12),
              _buildKpiCard(
                icon: Icons.class_outlined,
                color: Colors.indigo.shade700,
                title: 'Total Lectures Held',
                value: '$totalClasses Classes',
                subtitle: 'Across 4 Major Subjects',
              ),
              const SizedBox(width: 12),
              _buildKpiCard(
                icon: Icons.check_circle_outline,
                color: Colors.green.shade700,
                title: 'Lectures Attended',
                value: '$attendedClasses Attended',
                subtitle: '${totalClasses - attendedClasses} missed lectures',
              ),
              const SizedBox(width: 12),
              _buildKpiCard(
                icon: Icons.shield_outlined,
                color: Colors.orange.shade800,
                title: 'Attendance Buffer',
                value: '$marginClasses Classes',
                subtitle: 'Can miss up to $marginClasses & stay ≥75%',
              ),
            ],
          );
        } else {
          return Column(
            children: [
              Row(
                children: [
                  _buildKpiCard(
                    icon: Icons.donut_large,
                    color: Colors.blue.shade700,
                    title: 'Overall Attendance',
                    value: '$overallAttendance%',
                    subtitle: 'Safe Zone',
                  ),
                  const SizedBox(width: 12),
                  _buildKpiCard(
                    icon: Icons.class_outlined,
                    color: Colors.indigo.shade700,
                    title: 'Total Classes',
                    value: '$totalClasses',
                    subtitle: 'Held',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildKpiCard(
                    icon: Icons.check_circle_outline,
                    color: Colors.green.shade700,
                    title: 'Attended',
                    value: '$attendedClasses',
                    subtitle: 'Recorded',
                  ),
                  const SizedBox(width: 12),
                  _buildKpiCard(
                    icon: Icons.shield_outlined,
                    color: Colors.orange.shade800,
                    title: 'Buffer Margin',
                    value: '$marginClasses Classes',
                    subtitle: 'Above 75%',
                  ),
                ],
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildOverallProgressCard() {
    final double ratio = (overallAttendance / 100).clamp(0.0, 1.0);
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.assessment_outlined, size: 20, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    const Text(
                      'Aggregate Attendance vs. University Criteria',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ],
                ),
                Text(
                  '$overallAttendance% (Target: 75%)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: overallAttendance >= 75 ? Colors.green.shade800 : Colors.red.shade800,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 12,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  overallAttendance >= 75 ? Colors.green.shade600 : Colors.orange.shade600,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Minimum 75% required for regular semester exam eligibility',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                Text(
                  '+10% Safe Margin',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green.shade800),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getSubjectIcon(String subject) {
    final lower = subject.toLowerCase();
    if (lower.contains('network')) return Icons.devices;
    if (lower.contains('neural') || lower.contains('learn') || lower.contains('ai')) return Icons.psychology;
    if (lower.contains('data')) return Icons.storage;
    if (lower.contains('compiler') || lower.contains('software')) return Icons.code;
    return Icons.menu_book;
  }

  Widget _buildSubjectCard(Map<String, dynamic> item) {
    final String subject = item['subject']?.toString() ?? 'Subject';
    final String code = item['code']?.toString() ?? 'CS70X';
    final String faculty = item['faculty']?.toString() ?? 'Department Faculty';
    final int attended = (item['attended'] is num) ? (item['attended'] as num).toInt() : 0;
    final int total = (item['total'] is num) ? (item['total'] as num).toInt() : 0;
    final int percentage = (item['percentage'] is num)
        ? (item['percentage'] as num).toInt()
        : (total > 0 ? ((attended / total) * 100).round() : 0);

    final bool isSafe = percentage >= 75;
    final int bufferOrNeeded = isSafe
        ? ((attended - (0.75 * total)) / 0.75).floor().clamp(0, 99)
        : (((0.75 * total) - attended) / 0.25).ceil().clamp(1, 99);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSafe ? Colors.blue.shade50 : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getSubjectIcon(subject),
                    color: isSafe ? Colors.blue.shade700 : Colors.orange.shade800,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subject,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$code • $faculty',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSafe ? Colors.green.shade100 : Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$percentage%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSafe ? Colors.green.shade900 : Colors.orange.shade900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: (percentage / 100).clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isSafe ? Colors.green.shade600 : Colors.orange.shade600,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$attended / $total classes attended  (${total - attended} missed)',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
                Text(
                  isSafe ? 'Can miss $bufferOrNeeded more' : 'Must attend next $bufferOrNeeded',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isSafe ? Colors.green.shade800 : Colors.orange.shade900,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth >= 720;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.menu_book_outlined, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    const Text(
                      'Subject-wise Attendance Breakdown',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${subjects.length} Registered Courses',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue.shade700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (isDesktop) ...[
              // 2-column grid for desktop
              for (int i = 0; i < subjects.length; i += 2) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildSubjectCard(subjects[i])),
                    const SizedBox(width: 14),
                    if (i + 1 < subjects.length)
                      Expanded(child: _buildSubjectCard(subjects[i + 1]))
                    else
                      const Spacer(),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ] else ...[
              // 1-column list for mobile/narrow
              for (var s in subjects) ...[
                _buildSubjectCard(s),
                const SizedBox(height: 12),
              ],
            ],
          ],
        );
      },
    );
  }

  Widget _buildActionBar() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () => _showLeaveModal(context),
              icon: const Icon(Icons.edit_calendar),
              label: const Text(
                'Apply for Leave / On-Duty (OD)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 1,
          child: SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () => _showMarginCalculator(context),
              icon: const Icon(Icons.calculate_outlined),
              label: const Text('Margin Calc'),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 1,
          child: SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () => _showTranscriptDialog(context),
              icon: const Icon(Icons.receipt_long),
              label: const Text('Transcript'),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegulationsCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.blue.shade50.withOpacity(0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 26, color: Colors.blue.shade700),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'HITAM Academic Regulations & Attendance Policy',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  '• Regular Eligibility: ≥ 75% aggregate attendance is mandatory to appear for Semester End Examinations (SEE).\n'
                  '• Condonation Zone: 65% – 74% permitted on genuine medical grounds subject to Principal approval.\n'
                  '• Detention Zone: < 65% attendance leads to semester detention as per autonomous academic bylaws.',
                  style: TextStyle(fontSize: 12, height: 1.4, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Details & Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: fetchAttendanceData,
          ),
          IconButton(
            icon: const Icon(Icons.receipt_long),
            tooltip: 'Official Transcript',
            onPressed: () => _showTranscriptDialog(context),
          ),
          const SizedBox(width: 8),
        ],
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
                      ElevatedButton.icon(
                        onPressed: fetchAttendanceData,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1080),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStudentHeroCard(),
                          const SizedBox(height: 20),
                          _buildKpiSection(),
                          const SizedBox(height: 20),
                          _buildOverallProgressCard(),
                          const SizedBox(height: 24),
                          _buildActionBar(),
                          const SizedBox(height: 28),
                          _buildSubjectGrid(),
                          const SizedBox(height: 28),
                          _buildRegulationsCard(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }
}


// ============================================================
// NOTIFICATION BELL ICON WIDGET
// ============================================================

class NotificationBellIcon extends StatefulWidget {
  final String? role;
  final String? userId;
  const NotificationBellIcon({super.key, this.role, this.userId});

  @override
  State<NotificationBellIcon> createState() => _NotificationBellIconState();
}

class _NotificationBellIconState extends State<NotificationBellIcon> {
  int unreadCount = 0;

  @override
  void initState() {
    super.initState();
    fetchUnreadCount();
  }

  @override
  void didUpdateWidget(covariant NotificationBellIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.role != widget.role || oldWidget.userId != widget.userId) {
      fetchUnreadCount();
    }
  }

  Future<void> fetchUnreadCount() async {
    try {
      final effectiveRole = (widget.role ?? NotificationService().currentRole).toLowerCase();
      final effectiveUser = widget.userId ?? NotificationService().currentUserId;
      final res = await http
          .get(Uri.parse('${ApiConfig.baseUrl}/api/notifications?role=$effectiveRole&userId=$effectiveUser'))
          .timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (mounted) {
          setState(() {
            unreadCount = data['unreadCount'] ?? 0;
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          unreadCount = 0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveRole = widget.role ?? NotificationService().currentRole;

    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          IconButton(
            tooltip: '$effectiveRole Notifications',
            icon: Icon(
              unreadCount > 0
                  ? Icons.notifications_active_rounded
                  : Icons.notifications_outlined,
              color: unreadCount > 0
                  ? const Color(0xFF2563EB)
                  : const Color(0xFF475569),
            ),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationsScreen(
                    initialRole: effectiveRole,
                  ),
                ),
              );
              fetchUnreadCount();
            },
          ),
          if (unreadCount > 0)
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                constraints:
                    const BoxConstraints(minWidth: 18, minHeight: 18),
                child: Center(
                  child: Text(
                    unreadCount > 9 ? '9+' : '$unreadCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      height: 1,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================
// NOTIFICATIONS SCREEN (CAMPUS BACKGROUND & PUSH ALERTS)
// ============================================================

class NotificationsScreen extends StatefulWidget {
  final String? initialRole;
  const NotificationsScreen({super.key, this.initialRole});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool isLoading = true;
  String selectedFilter = 'All';
  late String activeRole;
  List<Map<String, dynamic>> notifications = [];

  final List<Map<String, dynamic>> _fallbackNotifications = [
    {
      'id': 'NOTIF_STU_001',
      'userId': 'STU001',
      'targetRole': 'student',
      'title': 'Daily Attendance Recorded: Present',
      'body':
          'Your attendance for Computer Networks was recorded as Present. Current semester aggregate: 85%.',
      'type': 'attendance',
      'targetScreen': 'attendance',
      'priority': 'normal',
      'isRead': false,
      'createdAt':
          DateTime.now().subtract(const Duration(minutes: 10)).toIso8601String(),
      'timeAgo': '10 mins ago'
    },
    {
      'id': 'NOTIF_STU_002',
      'userId': 'STU001',
      'targetRole': 'student',
      'title': 'Assignment Due in 24 Hours',
      'body':
          'Perceptron Implementation in Neural Networks is due tomorrow at 11:59 PM. Please upload your code proofs.',
      'type': 'assignment',
      'targetScreen': 'assignments',
      'priority': 'urgent',
      'isRead': false,
      'createdAt':
          DateTime.now().subtract(const Duration(minutes: 35)).toIso8601String(),
      'timeAgo': '35 mins ago'
    },
    {
      'id': 'NOTIF_STU_003',
      'userId': 'STU001',
      'targetRole': 'student',
      'title': 'Tuition Fee Due Reminder: ₹25,000',
      'body':
          'Second installment of odd semester tuition fee (₹25,000) is due by 30th September without penalty.',
      'type': 'fee',
      'targetScreen': 'fees',
      'priority': 'high',
      'isRead': false,
      'createdAt':
          DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
      'timeAgo': '2 hours ago'
    },
    {
      'id': 'NOTIF_PAR_001',
      'userId': 'PAR001',
      'targetRole': 'parent',
      'title': 'Ward Daily Attendance: Present in All Classes',
      'body':
          'Bhargavi (22K91A0501) was marked Present for all 4 lectures today. Aggregate attendance: 85%.',
      'type': 'attendance',
      'targetScreen': 'attendance',
      'priority': 'normal',
      'isRead': false,
      'createdAt':
          DateTime.now().subtract(const Duration(minutes: 15)).toIso8601String(),
      'timeAgo': '15 mins ago'
    },
    {
      'id': 'NOTIF_PAR_002',
      'userId': 'PAR001',
      'targetRole': 'parent',
      'title': 'Fee Reminder: ₹25,000 Balance Pending',
      'body':
          'Tuition installment of ₹25,000 for academic year 2025-2026 is due on 30th September.',
      'type': 'fee',
      'targetScreen': 'fees',
      'priority': 'urgent',
      'isRead': false,
      'createdAt':
          DateTime.now().subtract(const Duration(minutes: 45)).toIso8601String(),
      'timeAgo': '45 mins ago'
    },
    {
      'id': 'NOTIF_FAC_001',
      'userId': 'FAC001',
      'targetRole': 'faculty',
      'title': '35 Assignment Submissions Pending Review',
      'body':
          '35 students submitted "Perceptron Implementation" for Neural Networks. Grade submissions before Friday.',
      'type': 'assignment',
      'targetScreen': 'assignments',
      'priority': 'urgent',
      'isRead': false,
      'createdAt':
          DateTime.now().subtract(const Duration(minutes: 20)).toIso8601String(),
      'timeAgo': '20 mins ago'
    },
    {
      'id': 'NOTIF_ADM_001',
      'userId': 'ADM001',
      'targetRole': 'admin',
      'title': 'Daily Tuition Fee Collection Summary',
      'body':
          '₹4,85,000 received today in semester fee settlements. Campus collection milestone reached 82%.',
      'type': 'fee',
      'targetScreen': 'fees',
      'priority': 'high',
      'isRead': false,
      'createdAt':
          DateTime.now().subtract(const Duration(minutes: 30)).toIso8601String(),
      'timeAgo': '30 mins ago'
    }
  ];

  @override
  void initState() {
    super.initState();
    activeRole = (widget.initialRole ?? NotificationService().currentRole).toLowerCase();
    fetchNotifications();
  }

  Map<String, dynamic> _normalizeNotification(dynamic item) {
    if (item is! Map) return {};
    final id = (item['id'] ?? '0').toString();
    final title = (item['title'] ?? 'Campus Alert').toString();
    final body = (item['body'] ??
            item['message'] ??
            'You have a new update from HITAM Administration.')
        .toString();
    final type = (item['type'] ?? 'general').toString().toLowerCase();
    final targetScreen = (item['targetScreen'] ?? type).toString().toLowerCase();
    final priority = (item['priority'] ?? 'normal').toString().toLowerCase();
    final targetRole = (item['targetRole'] ?? item['target_role'] ?? 'all')
        .toString()
        .toLowerCase();
    final isRead = item['isRead'] == true || item['is_read'] == true;
    final timeAgo = (item['timeAgo'] ?? 'Recent').toString();

    return {
      'id': id,
      'userId': item['userId'] ?? item['user_id'] ?? 'STU001',
      'targetRole': targetRole,
      'title': title,
      'body': body,
      'type': type,
      'targetScreen': targetScreen,
      'priority': priority,
      'isRead': isRead,
      'timeAgo': timeAgo,
    };
  }

  Future<void> fetchNotifications() async {
    setState(() {
      isLoading = true;
    });

    try {
      final res = await http
          .get(Uri.parse(
              '${ApiConfig.baseUrl}/api/notifications?role=$activeRole&userId=${NotificationService().currentUserId}'))
          .timeout(const Duration(seconds: 5));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final list = data['notifications'];
        if (list is List && list.isNotEmpty) {
          final List<Map<String, dynamic>> parsed = [];
          for (var item in list) {
            final norm = _normalizeNotification(item);
            if (norm.isNotEmpty) parsed.add(norm);
          }
          if (mounted) {
            setState(() {
              notifications = parsed;
              isLoading = false;
            });
          }
          return;
        }
      }

      // Filter fallback based on active role
      final filteredFallback = _fallbackNotifications.where((n) {
        final r = (n['targetRole'] ?? 'all').toString().toLowerCase();
        return r == 'all' || r == activeRole;
      }).toList();

      if (mounted) {
        setState(() {
          notifications = filteredFallback;
          isLoading = false;
        });
      }
    } catch (_) {
      final filteredFallback = _fallbackNotifications.where((n) {
        final r = (n['targetRole'] ?? 'all').toString().toLowerCase();
        return r == 'all' || r == activeRole;
      }).toList();

      if (mounted) {
        setState(() {
          notifications = filteredFallback;
          isLoading = false;
        });
      }
    }
  }

  Future<void> markAsRead(String id) async {
    setState(() {
      final item =
          notifications.firstWhere((n) => n['id'] == id, orElse: () => {});
      if (item.isNotEmpty) {
        item['isRead'] = true;
      }
    });

    try {
      await http.put(Uri.parse('${ApiConfig.baseUrl}/api/notifications/$id/read'));
    } catch (_) {}
  }

  Future<void> markAllAsRead() async {
    setState(() {
      for (var n in notifications) {
        n['isRead'] = true;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('All $activeRole notifications marked as read.'),
        backgroundColor: const Color(0xFF0F172A),
      ),
    );

    try {
      await http.put(
        Uri.parse('${ApiConfig.baseUrl}/api/notifications/read-all'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'role': activeRole,
          'userId': NotificationService().currentUserId,
        }),
      );
    } catch (_) {}
  }

  void _triggerBackgroundSimulation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.alarm_on_rounded, color: Color(0xFF2563EB)),
            const SizedBox(width: 8),
            Text('Simulate 5s Background Push ($activeRole)',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This simulates a real-time $activeRole notification delivered outside the app in 5 seconds.',
              style: const TextStyle(fontSize: 13.5, height: 1.4),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '👉 HOW TO TEST:\n1. Tap "Start 5s Countdown"\n2. Immediately press Home or minimize this app\n3. In 5s, the system banner alert will drop down in your notification tray with sound and vibration!',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                    height: 1.4),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              // Pick scenario based on active role
              String scenario = 'attendance';
              if (activeRole == 'parent') scenario = 'attendance';
              if (activeRole == 'faculty') scenario = 'submissions';
              if (activeRole == 'admin') scenario = 'finance';

              NotificationService().simulateRoleNotification(
                role: activeRole,
                scenario: scenario,
                delaySeconds: 5,
              );

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '⏳ 5s Background Push for $activeRole scheduled! Minimize app now to see notification.',
                  ),
                  backgroundColor: const Color(0xFF2563EB),
                  duration: const Duration(seconds: 5),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
            ),
            child: const Text('Start 5s Countdown'),
          ),
        ],
      ),
    );
  }

  void _openBroadcastDialog() {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();
    String targetRole = activeRole;
    String priority = 'high';
    String type = 'announcement';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.campaign_rounded,
                        color: Color(0xFF2563EB), size: 22),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Broadcast Real-Time Notice',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Target Role:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: ['all', 'student', 'parent', 'faculty', 'admin'].map((r) {
                  final isSel = targetRole == r;
                  return ChoiceChip(
                    label: Text(r.toUpperCase()),
                    selected: isSel,
                    onSelected: (val) {
                      if (val) setModalState(() => targetRole = r);
                    },
                    selectedColor: const Color(0xFF2563EB),
                    labelStyle: TextStyle(
                      color: isSel ? Colors.white : const Color(0xFF334155),
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Notice Title',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: bodyController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Message Body',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final title = titleController.text.trim();
                    final body = bodyController.text.trim();
                    if (title.isEmpty) return;

                    Navigator.pop(ctx);

                    await NotificationService().sendRealtimeNotification(
                      title: title,
                      body: body.isNotEmpty
                          ? body
                          : 'Official campus notification.',
                      targetRole: targetRole,
                      type: type,
                      priority: priority,
                      targetScreen: 'announcements',
                    );

                    if (!mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            '🚀 Real-time alert dispatched to $targetRole!'),
                        backgroundColor: const Color(0xFF059669),
                      ),
                    );

                    fetchNotifications();
                  },
                  icon: const Icon(Icons.send_rounded, size: 16),
                  label: const Text('Dispatch to Role in Real-Time'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleOpenTarget(Map<String, dynamic> item) {
    markAsRead(item['id']);
    final target =
        (item['targetScreen'] ?? item['type'] ?? '').toString().toLowerCase();

    if (target.contains('assignment')) {
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => const AssignmentsScreen()));
    } else if (target.contains('announcement')) {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => const AnnouncementsScreen()));
    } else if (target.contains('exam')) {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => const ExaminationDetailsScreen()));
    } else if (target.contains('fee')) {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => const ParentFeeDetailsScreen()));
    } else if (target.contains('attendance')) {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => const AttendanceDetailsScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Opening ${item['title']}'),
          backgroundColor: const Color(0xFF0F172A),
        ),
      );
    }
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'assignment':
        return const Color(0xFFF59E0B);
      case 'exam':
        return const Color(0xFF4F46E5);
      case 'fee':
        return const Color(0xFF7C3AED);
      case 'announcement':
        return const Color(0xFF059669);
      case 'attendance':
        return const Color(0xFF0284C7);
      case 'system':
        return const Color(0xFFE11D48);
      default:
        return const Color(0xFF2563EB);
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'assignment':
        return Icons.assignment_outlined;
      case 'exam':
        return Icons.quiz_outlined;
      case 'fee':
        return Icons.account_balance_wallet_outlined;
      case 'announcement':
        return Icons.campaign_outlined;
      case 'attendance':
        return Icons.calendar_month_outlined;
      case 'system':
        return Icons.security_outlined;
      default:
        return Icons.notifications_active_outlined;
    }
  }

  List<Map<String, dynamic>> get _filteredList {
    return notifications.where((n) {
      if (selectedFilter == 'All') return true;
      if (selectedFilter == 'Unread') return n['isRead'] == false;
      final t = (n['type'] ?? '').toString().toLowerCase();
      return t.contains(selectedFilter.toLowerCase());
    }).toList();
  }

  Widget _buildRoleSelectorPills() {
    final roles = [
      {'key': 'student', 'label': 'Student', 'icon': Icons.school_outlined},
      {'key': 'parent', 'label': 'Parent', 'icon': Icons.family_restroom_outlined},
      {'key': 'faculty', 'label': 'Faculty', 'icon': Icons.person_outline},
      {'key': 'admin', 'label': 'Administrator', 'icon': Icons.admin_panel_settings_outlined},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: roles.map((r) {
            final isSelected = activeRole == r['key'];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: InkWell(
                onTap: () {
                  setState(() {
                    activeRole = r['key'] as String;
                    selectedFilter = 'All';
                  });
                  fetchNotifications();
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF0F172A)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        r['icon'] as IconData,
                        size: 16,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        r['label'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF334155),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildHeroHeader(BoxConstraints constraints) {
    final isMobile = constraints.maxWidth < 600;
    final unreadCount =
        notifications.where((n) => n['isRead'] == false).length;

    String roleSubtitle = '';
    switch (activeRole) {
      case 'parent':
        roleSubtitle =
            'Real-time updates on your child\'s attendance, fee dues, academic progress & PTM schedules.';
        break;
      case 'faculty':
        roleSubtitle =
            'Instant alerts for assignment submissions, daily attendance lock reminders & student leaves.';
        break;
      case 'admin':
        roleSubtitle =
            'System alerts for daily fee collections, campus biometric gate sync & administrative notices.';
        break;
      case 'student':
      default:
        roleSubtitle =
            'Get instant updates regarding your college, attendance, fees, pending tasks, assignments & exams.';
        break;
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 18 : 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.notifications_active_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF38BDF8)
                                .withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: const Color(0xFF38BDF8)
                                    .withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            'ROLE TARGETED: ${activeRole.toUpperCase()}',
                            style: const TextStyle(
                              color: Color(0xFF38BDF8),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF22C55E),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Zero-Delay Realtime',
                          style: TextStyle(
                            color: Color(0xFF86EFAC),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${activeRole[0].toUpperCase()}${activeRole.substring(1)} Notifications',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isMobile ? 20 : 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$unreadCount unread • $roleSubtitle',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.88),
                        fontSize: isMobile ? 12 : 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Action Buttons
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ElevatedButton.icon(
                onPressed: _triggerBackgroundSimulation,
                icon: const Icon(Icons.alarm_on_rounded, size: 16),
                label: Text(
                  'Simulate 5s Background Push ($activeRole)',
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: _openBroadcastDialog,
                icon: const Icon(Icons.campaign_rounded, size: 16),
                label: const Text(
                  'Broadcast Notice',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInstantRoleSimulatorStrip() {
    List<Map<String, String>> scenarios = [];
    if (activeRole == 'student') {
      scenarios = [
        {'id': 'attendance', 'label': '+ Attendance Recorded (85%)'},
        {'id': 'fee', 'label': '+ Tuition Fee Due (₹25k)'},
        {'id': 'assignment', 'label': '+ Assignment Due (24h)'},
        {'id': 'exam', 'label': '+ Hall Tickets Ready'},
      ];
    } else if (activeRole == 'parent') {
      scenarios = [
        {'id': 'attendance', 'label': '+ Ward Present Today'},
        {'id': 'fee', 'label': '+ Fee Invoice Reminder'},
        {'id': 'ptm', 'label': '+ PTM Scheduled (Sat)'},
        {'id': 'progress', 'label': '+ 8.65 SGPA Progress'},
      ];
    } else if (activeRole == 'faculty') {
      scenarios = [
        {'id': 'submissions', 'label': '+ 35 Submissions Pending'},
        {'id': 'attendance', 'label': '+ Daily Attendance Lock'},
        {'id': 'leave', 'label': '+ Student Leave Request'},
        {'id': 'meeting', 'label': '+ Curriculum Council'},
      ];
    } else {
      scenarios = [
        {'id': 'finance', 'label': '+ Daily Fee Summary (₹4.85L)'},
        {'id': 'staff', 'label': '+ Faculty Leave Queue'},
        {'id': 'security', 'label': '+ Gate Biometric Sync'},
        {'id': 'broadcast', 'label': '+ Official Notice Draft'},
      ];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.bolt_rounded, size: 16, color: Color(0xFFF59E0B)),
            const SizedBox(width: 4),
            Text(
              'Instant Real-Time Test Triggers ($activeRole):',
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF334155),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: scenarios.map((sc) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ActionChip(
                  label: Text(sc['label']!),
                  avatar: const Icon(Icons.touch_app_rounded, size: 14),
                  backgroundColor: Colors.white,
                  labelStyle: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  onPressed: () {
                    NotificationService().simulateRoleNotification(
                      role: activeRole,
                      scenario: sc['id']!,
                      delaySeconds: 0,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('⚡ Instant $activeRole alert triggered!'),
                        duration: const Duration(seconds: 2),
                        backgroundColor: const Color(0xFF0F172A),
                      ),
                    );
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterStrip() {
    List<String> categories = ['All', 'Unread'];
    if (activeRole == 'student') {
      categories.addAll(['Attendance', 'Assignment', 'Fee', 'Exam']);
    } else if (activeRole == 'parent') {
      categories.addAll(['Attendance', 'Fee', 'Academic', 'Announcement']);
    } else if (activeRole == 'faculty') {
      categories.addAll(['Assignment', 'Attendance', 'System', 'Announcement']);
    } else {
      categories.addAll(['Fee', 'System', 'Announcement']);
    }

    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: categories.map((cat) {
                final isSelected = selectedFilter == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) setState(() => selectedFilter = cat);
                    },
                    selectedColor: const Color(0xFF0F172A),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF334155),
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 12,
                    ),
                    backgroundColor: const Color(0xFFF1F5F9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? const Color(0xFF0F172A)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        TextButton(
          onPressed: markAllAsRead,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'Mark all read',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2563EB),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> item) {
    final type = item['type'] ?? 'general';
    final themeColor = _getTypeColor(type);
    final isRead = item['isRead'] == true;
    final isUrgent = item['priority'] == 'urgent';
    final targetRole = (item['targetRole'] ?? 'all').toString().toUpperCase();

    Color roleBadgeColor;
    switch (targetRole.toLowerCase()) {
      case 'student':
        roleBadgeColor = const Color(0xFF0284C7);
        break;
      case 'parent':
        roleBadgeColor = const Color(0xFF7C3AED);
        break;
      case 'faculty':
        roleBadgeColor = const Color(0xFF059669);
        break;
      case 'admin':
        roleBadgeColor = const Color(0xFFD97706);
        break;
      default:
        roleBadgeColor = const Color(0xFF475569);
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: isRead ? Colors.white : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: !isRead
              ? const Color(0xFFBFDBFE)
              : isUrgent
                  ? const Color(0xFFFDE68A)
                  : const Color(0xFFE2E8F0),
          width: !isRead ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleOpenTarget(item),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Avatar
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: themeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getTypeIcon(type),
                    color: themeColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),

                // Content Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row: Role chip, Type pill, Priority, TimeAgo, Unread dot
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          // Role Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: roleBadgeColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              targetRole == 'ALL' ? 'CAMPUS-WIDE' : targetRole,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: roleBadgeColor,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),

                          // Type Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: themeColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              type.toString().toUpperCase(),
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: themeColor,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),

                          if (isUrgent)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'URGENT',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFB45309),
                                ),
                              ),
                            ),

                          Text(
                            item['timeAgo'] ?? 'Recent',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (!isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF2563EB),
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Title
                      Text(
                        item['title'] ?? 'Notice',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight:
                              isRead ? FontWeight.w600 : FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Body
                      Text(
                        item['body'] ?? '',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.4,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Action link
                      Row(
                        children: [
                          Text(
                            'Open ${item['type'] ?? 'notice'}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: themeColor,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.arrow_forward_rounded,
                              size: 13, color: themeColor),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Icon(Icons.notifications_off_outlined,
              size: 44, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            'No $activeRole notifications found',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'You are completely caught up for the $activeRole role! New alerts will appear here in real-time.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() => selectedFilter = 'All');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F172A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Show All Notifications'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredList;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          '${activeRole[0].toUpperCase()}${activeRole.substring(1)} Notifications',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.campaign_outlined),
            tooltip: 'Broadcast notice',
            onPressed: _openBroadcastDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh feed',
            onPressed: fetchNotifications,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 850;

          return RefreshIndicator(
            onRefresh: fetchNotifications,
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: constraints.maxWidth < 600 ? 16 : 24,
                      vertical: 20,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1100),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildRoleSelectorPills(),
                            const SizedBox(height: 16),
                            _buildHeroHeader(constraints),
                            const SizedBox(height: 16),
                            _buildInstantRoleSimulatorStrip(),
                            const SizedBox(height: 18),
                            _buildFilterStrip(),
                            const SizedBox(height: 16),
                            if (filtered.isEmpty)
                              _buildEmptyState()
                            else if (isWide)
                              Wrap(
                                spacing: 14,
                                runSpacing: 14,
                                children: filtered.map((item) {
                                  return SizedBox(
                                    width: (constraints.maxWidth - 48 - 14) / 2,
                                    child: _buildNotificationCard(item),
                                  );
                                }).toList(),
                              )
                            else
                              Column(
                                children: filtered.map((item) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _buildNotificationCard(item),
                                  );
                                }).toList(),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
          );
        },
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
  List<Map<String, dynamic>> announcements = [];
  String selectedCategory = 'All';
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _fallbackAnnouncements = [
    {
      'id': '1',
      'title': 'Campus Placement Drive 2026',
      'content':
          'TCS and Infosys recruitment registrations are now officially open for final year CSE & ECE students. Eligible candidates must complete company profile registration on the portal before Friday 5:00 PM.',
      'message':
          'TCS and Infosys recruitment registrations are now officially open for final year CSE & ECE students. Eligible candidates must complete company profile registration on the portal before Friday 5:00 PM.',
      'author': 'Dr. Ramesh Kumar',
      'role': 'Placement Dean',
      'category': 'Placements',
      'type': 'Placements',
      'priority': 'urgent',
      'isPinned': true,
      'department': 'Training & Placements',
      'targetAudience': 'Final Year B.Tech',
      'refNo': 'HITAM/TPO/2026/048',
      'attachment': 'TCS_Infosys_Drive_Eligibility_2026.pdf',
      'date': 'Today'
    },
    {
      'id': '2',
      'title': 'Mid-Semester Examination Schedule (Odd Sem)',
      'content':
          'Mid-Term Examinations for 3rd and 4th year B.Tech students will commence from 12th September 2026. Hall tickets and session timetables can be accessed from the examination portal tab.',
      'message':
          'Mid-Term Examinations for 3rd and 4th year B.Tech students will commence from 12th September 2026. Hall tickets and session timetables can be accessed from the examination portal tab.',
      'author': 'Dr. Sharma',
      'role': 'Examination Cell',
      'category': 'Examinations',
      'type': 'Examinations',
      'priority': 'urgent',
      'isPinned': true,
      'department': 'Controller of Examinations',
      'targetAudience': '3rd & 4th Year B.Tech',
      'refNo': 'HITAM/EXAM/2026/102',
      'attachment': 'Mid_Term_Timetable_ODD_SEM.pdf',
      'date': 'Yesterday'
    },
    {
      'id': '3',
      'title': 'Tuition Fee Payment Reminder & Concession Form',
      'content':
          'Last date for odd semester academic fee payment without late penalty is 30th August. Merit-based fee concession applications are also available at the accounts office.',
      'message':
          'Last date for odd semester academic fee payment without late penalty is 30th August. Merit-based fee concession applications are also available at the accounts office.',
      'author': 'Finance Dept',
      'role': 'Administration',
      'category': 'Finance',
      'type': 'Finance',
      'priority': 'normal',
      'isPinned': false,
      'department': 'Accounts & Fees',
      'targetAudience': 'All Students & Parents',
      'refNo': 'HITAM/ACC/2026/031',
      'attachment': 'Fee_Structure_and_Payment_Challan.pdf',
      'date': '3 days ago'
    },
    {
      'id': '4',
      'title': 'Independence Day Celebrations & Holiday Notice',
      'content':
          'The college campus will host the 80th Independence Day Flag Hoisting ceremony at 8:30 AM on 15th August. Academic classes will remain closed for the national holiday.',
      'message':
          'The college campus will host the 80th Independence Day Flag Hoisting ceremony at 8:30 AM on 15th August. Academic classes will remain closed for the national holiday.',
      'author': 'Principal Office',
      'role': 'Administration',
      'category': 'Holiday',
      'type': 'Holiday',
      'priority': 'normal',
      'isPinned': false,
      'department': 'Principal Office',
      'targetAudience': 'All Students, Staff & Faculty',
      'refNo': 'HITAM/GEN/2026/019',
      'attachment': null,
      'date': '5 days ago'
    }
  ];

  @override
  void initState() {
    super.initState();
    fetchAnnouncements();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _normalizeAnnouncement(dynamic raw) {
    if (raw is! Map) return {};
    final id = (raw['id'] ?? '0').toString();
    final title = (raw['title'] ?? 'Campus Notice').toString();
    final content = (raw['content'] ??
            raw['message'] ??
            'Official college notice. Please refer to your department notice board for additional instructions.')
        .toString();
    final author =
        (raw['author'] ?? raw['author_name'] ?? 'College Administration')
            .toString();
    final role =
        (raw['role'] ?? raw['author_role'] ?? 'Administration').toString();
    final department =
        (raw['department'] ?? 'Campus Wide').toString();
    final category =
        (raw['category'] ?? raw['type'] ?? 'Academic').toString();
    final priority = (raw['priority'] ?? 'normal').toString();
    final isPinned = raw['isPinned'] == true ||
        raw['is_pinned'] == true ||
        priority.toLowerCase() == 'urgent';
    final date = (raw['date'] ?? 'Recent').toString();
    final targetAudience =
        (raw['targetAudience'] ?? raw['target_audience'] ?? 'All Students')
            .toString();
    final refNo =
        (raw['refNo'] ?? raw['ref_no'] ?? 'HITAM/CIR/2026/0$id').toString();
    final attachment = raw['attachment']?.toString();

    return {
      'id': id,
      'title': title,
      'content': content,
      'message': content,
      'author': author,
      'role': role,
      'department': department,
      'category': category,
      'type': category,
      'priority': priority,
      'isPinned': isPinned,
      'date': date,
      'targetAudience': targetAudience,
      'refNo': refNo,
      'attachment': attachment,
    };
  }

  Future<void> fetchAnnouncements() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/api/announcements'),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List && decoded.isNotEmpty) {
          final List<Map<String, dynamic>> parsed = [];
          for (var item in decoded) {
            final normalized = _normalizeAnnouncement(item);
            if (normalized.isNotEmpty) {
              parsed.add(normalized);
            }
          }
          if (mounted) {
            setState(() {
              announcements = parsed;
              isLoading = false;
              errorMessage = '';
            });
          }
          return;
        }
      }
      // Fallback
      if (mounted) {
        setState(() {
          announcements = _fallbackAnnouncements;
          isLoading = false;
          errorMessage = '';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          announcements = _fallbackAnnouncements;
          isLoading = false;
          errorMessage = '';
        });
      }
    }
  }

  List<Map<String, dynamic>> get _filteredAnnouncements {
    return announcements.where((a) {
      // Category filter
      if (selectedCategory != 'All') {
        if (selectedCategory == 'Pinned') {
          if (a['isPinned'] != true) return false;
        } else {
          final cat = (a['category'] ?? '').toString().toLowerCase();
          final sel = selectedCategory.toLowerCase();
          if (cat != sel && !cat.contains(sel)) return false;
        }
      }

      // Search query
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        final title = (a['title'] ?? '').toString().toLowerCase();
        final content = (a['content'] ?? '').toString().toLowerCase();
        final author = (a['author'] ?? '').toString().toLowerCase();
        final dept = (a['department'] ?? '').toString().toLowerCase();
        final ref = (a['refNo'] ?? '').toString().toLowerCase();
        if (!title.contains(q) &&
            !content.contains(q) &&
            !author.contains(q) &&
            !dept.contains(q) &&
            !ref.contains(q)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'placements':
        return const Color(0xFF059669);
      case 'examinations':
        return const Color(0xFF4F46E5);
      case 'finance':
        return const Color(0xFF7C3AED);
      case 'holiday':
        return const Color(0xFFD97706);
      case 'events':
        return const Color(0xFF0284C7);
      case 'academic':
      default:
        return const Color(0xFF2563EB);
    }
  }

  Color _getCategoryBgColor(String category) {
    switch (category.toLowerCase()) {
      case 'placements':
        return const Color(0xFFECFDF5);
      case 'examinations':
        return const Color(0xFFEEF2FF);
      case 'finance':
        return const Color(0xFFF5F3FF);
      case 'holiday':
        return const Color(0xFFFFFBEB);
      case 'events':
        return const Color(0xFFF0F9FF);
      case 'academic':
      default:
        return const Color(0xFFEFF6FF);
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'placements':
        return Icons.work_outline_rounded;
      case 'examinations':
        return Icons.quiz_outlined;
      case 'finance':
        return Icons.account_balance_wallet_outlined;
      case 'holiday':
        return Icons.celebration_outlined;
      case 'events':
        return Icons.event_available_outlined;
      case 'academic':
      default:
        return Icons.school_outlined;
    }
  }

  void _showNoticeDialog(BuildContext context, Map<String, dynamic> item) {
    final category = item['category'] ?? 'Academic';
    final themeColor = _getCategoryColor(category);

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Modal Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _getCategoryBgColor(category),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getCategoryIcon(category),
                        color: themeColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: _getCategoryBgColor(category),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: themeColor.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Text(
                                  category.toString().toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: themeColor,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              if (item['isPinned'] == true) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF3C7),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'URGENT',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFB45309),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['refNo'] ?? 'HITAM/CIR/2026',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Title
                Text(
                  item['title'] ?? 'Notice',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 14),

                // Metadata Details Strip
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.person_outline_rounded,
                              size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Issued By: ${item['author']} (${item['role']})',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey.shade800),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_outlined,
                              size: 15, color: Colors.grey.shade600),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Date: ${item['date']} • Dept: ${item['department']}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey.shade800),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.group_outlined,
                              size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Target Audience: ${item['targetAudience']}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey.shade800),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Full Content
                const Text(
                  'Circular Description',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF475569),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item['content'] ?? item['message'] ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 20),

                // Attachment Section if present
                if (item['attachment'] != null &&
                    item['attachment'].toString().isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.picture_as_pdf_rounded,
                            color: Color(0xFFDC2626), size: 28),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['attachment'],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              Text(
                                'Official PDF Attachment • Signed',
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Downloading ${item['attachment']}...'),
                                backgroundColor: const Color(0xFF0F172A),
                              ),
                            );
                          },
                          icon: const Icon(Icons.download_rounded, size: 14),
                          label: const Text('Download',
                              style: TextStyle(fontSize: 11)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            elevation: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Action Close Button
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Close Notice',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroBanner(BoxConstraints constraints) {
    final isMobile = constraints.maxWidth < 600;
    final totalCount = announcements.length;
    final urgentCount = announcements.where((a) => a['isPinned'] == true).length;
    final placementCount = announcements
        .where((a) => (a['category'] ?? '').toString().toLowerCase() == 'placements')
        .length;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 18 : 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF334155)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.campaign_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF38BDF8).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: const Color(0xFF38BDF8).withValues(alpha: 0.4)),
                          ),
                          child: const Text(
                            'CAMPUS BULLETIN',
                            style: TextStyle(
                              color: Color(0xFF38BDF8),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF22C55E),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Live Sync',
                          style: TextStyle(
                            color: Color(0xFF86EFAC),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Official Announcements',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isMobile ? 20 : 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Academic circulars, placement notifications, and campus notices.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: isMobile ? 12 : 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Metric Badges Strip
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              _buildMetricChip(
                icon: Icons.article_outlined,
                label: '$totalCount Active Circulars',
                bgColor: Colors.white.withValues(alpha: 0.1),
                textColor: Colors.white,
              ),
              _buildMetricChip(
                icon: Icons.alarm_rounded,
                label: '$urgentCount Urgent Notices',
                bgColor: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                textColor: const Color(0xFFFDE68A),
              ),
              _buildMetricChip(
                icon: Icons.work_outline_rounded,
                label: '$placementCount Placements',
                bgColor: const Color(0xFF10B981).withValues(alpha: 0.2),
                textColor: const Color(0xFFA7F3D0),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricChip({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(BoxConstraints constraints) {
    final isMobile = constraints.maxWidth < 650;
    final categories = [
      'All',
      'Pinned',
      'Placements',
      'Examinations',
      'Finance',
      'Holiday',
      'Events',
      'Academic'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Box
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (val) => setState(() => searchQuery = val.trim()),
            decoration: InputDecoration(
              hintText: isMobile
                  ? 'Search notices, circulars, tags...'
                  : 'Search by title, department, author, or circular reference...',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              prefixIcon: const Icon(Icons.search_rounded,
                  color: Color(0xFF64748B), size: 20),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => searchQuery = '');
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Horizontal Category Pill Strip
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: categories.map((cat) {
              final isSelected = selectedCategory == cat;
              int count;
              if (cat == 'All') {
                count = announcements.length;
              } else if (cat == 'Pinned') {
                count = announcements.where((a) => a['isPinned'] == true).length;
              } else {
                count = announcements
                    .where((a) =>
                        (a['category'] ?? '').toString().toLowerCase() ==
                        cat.toLowerCase())
                    .length;
              }

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: () => setState(() => selectedCategory = cat),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF0F172A)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF0F172A)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (cat == 'Pinned')
                          Icon(
                            Icons.push_pin_rounded,
                            size: 13,
                            color: isSelected
                                ? const Color(0xFFFBBF24)
                                : const Color(0xFFD97706),
                          )
                        else
                          Icon(
                            _getCategoryIcon(cat),
                            size: 13,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF475569),
                          ),
                        const SizedBox(width: 6),
                        Text(
                          cat,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF334155),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withValues(alpha: 0.2)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$count',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildUrgentNoticeSpotlight(Map<String, dynamic> notice) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFCD34D), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD97706).withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFD97706),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        size: 13, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'URGENT NOTICE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  notice['refNo'] ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF92400E),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                notice['date'] ?? '',
                style: const TextStyle(fontSize: 11, color: Color(0xFFB45309)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            notice['title'] ?? '',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF78350F),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            notice['content'] ?? notice['message'] ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.4,
              color: Color(0xFF92400E),
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => _showNoticeDialog(context, notice),
              icon: const Icon(Icons.arrow_forward_rounded,
                  size: 14, color: Color(0xFFB45309)),
              label: const Text(
                'Read Full Circular',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFB45309),
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementCard(Map<String, dynamic> item) {
    final category = item['category'] ?? 'Academic';
    final themeColor = _getCategoryColor(category);
    final isPinned = item['isPinned'] == true;
    final author = item['author'] ?? 'Admin';
    final initial = author.isNotEmpty ? author[0].toUpperCase() : 'C';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPinned ? const Color(0xFFFDE68A) : const Color(0xFFE2E8F0),
          width: isPinned ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Category badge, Pinned pill, Date
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getCategoryBgColor(category),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: themeColor.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_getCategoryIcon(category),
                          size: 12, color: themeColor),
                      const SizedBox(width: 4),
                      Text(
                        category.toString().toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: themeColor,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isPinned) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.push_pin_rounded,
                            size: 11, color: Color(0xFFD97706)),
                        SizedBox(width: 2),
                        Text(
                          'PINNED',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFB45309),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const Spacer(),
                Text(
                  item['date'] ?? 'Recent',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Author Row with Avatar
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: themeColor.withValues(alpha: 0.15),
                  child: Text(
                    initial,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: themeColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${item['author']} • ${item['role']}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Title
            Text(
              item['title'] ?? 'Campus Notice',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
                height: 1.3,
              ),
            ),
            const SizedBox(height: 6),

            // Content Snippet
            Text(
              item['content'] ?? item['message'] ?? '',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.5,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),

            // Metadata: Target Audience & Reference
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.group_outlined,
                          size: 11, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        item['targetAudience'] ?? 'All Students',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                if (item['attachment'] != null &&
                    item['attachment'].toString().isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.attach_file_rounded,
                            size: 11, color: Color(0xFF2563EB)),
                        SizedBox(width: 2),
                        Text(
                          'PDF Attached',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),

            // Actions Row
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showNoticeDialog(context, item),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1E293B),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Read Full Circular',
                      style:
                          TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                if (item['attachment'] != null &&
                    item['attachment'].toString().isNotEmpty) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Downloading ${item['attachment']}...'),
                          backgroundColor: const Color(0xFF0F172A),
                        ),
                      );
                    },
                    icon: const Icon(Icons.download_rounded, size: 18),
                    color: const Color(0xFF2563EB),
                    tooltip: 'Download PDF',
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFEFF6FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Icon(Icons.search_off_rounded, size: 44, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          const Text(
            'No matching notices found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try clearing your search query or choosing another category.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              _searchController.clear();
              setState(() {
                searchQuery = '';
                selectedCategory = 'All';
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F172A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Reset All Filters'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Campus Announcements',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Circulars',
            onPressed: fetchAnnouncements,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;
          final filtered = _filteredAnnouncements;
          final urgentNotice = announcements.firstWhere(
            (a) => a['isPinned'] == true,
            orElse: () => {},
          );

          return RefreshIndicator(
            onRefresh: fetchAnnouncements,
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: constraints.maxWidth < 600 ? 16 : 24,
                      vertical: 20,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Hero Banner
                            _buildHeroBanner(constraints),
                            const SizedBox(height: 18),

                            // Filter & Search Bar
                            _buildFilterBar(constraints),
                            const SizedBox(height: 18),

                            // Urgent Notice Spotlight (if any exists and not filtering out)
                            if (urgentNotice.isNotEmpty &&
                                (selectedCategory == 'All' ||
                                    selectedCategory == 'Pinned') &&
                                searchQuery.isEmpty)
                              _buildUrgentNoticeSpotlight(urgentNotice),

                            // Notice Cards Grid / Stream
                            if (filtered.isEmpty)
                              _buildEmptyState()
                            else if (isWide)
                              Wrap(
                                spacing: 16,
                                runSpacing: 16,
                                children: filtered.map((item) {
                                  return SizedBox(
                                    width: (constraints.maxWidth - 48 - 16) / 2,
                                    child: _buildAnnouncementCard(item),
                                  );
                                }).toList(),
                              )
                            else
                              Column(
                                children: filtered.map((item) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 14),
                                    child: _buildAnnouncementCard(item),
                                  );
                                }).toList(),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
          );
        },
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
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen> {
  bool isLoading = true;
  String errorMessage = '';
  List<Map<String, dynamic>> assignments = [];
  String selectedFilter = 'All'; // 'All', 'Pending', 'Completed'
  String selectedSubject = 'All Subjects';
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _fallbackAssignments = [
    {
      'id': 'ASG001',
      'title': 'Binary Search Implementation',
      'subject': 'Data Structures',
      'code': 'CS301PC',
      'faculty': 'Dr. Ramesh Kumar',
      'dueDate': '20 August 2026',
      'status': 'Pending',
      'points': 25,
      'urgency': 'Due in 2 days',
      'description':
          'Implement iterative and recursive binary search algorithms in C++/Java with comprehensive time and space complexity proofs.',
      'instructions':
          'Include unit test cases covering edge cases such as empty array, single element, negative numbers, and target-not-found scenarios.'
    },
    {
      'id': 'ASG002',
      'title': 'ML Classification Report',
      'subject': 'Machine Learning',
      'code': 'CS702PE',
      'faculty': 'Prof. Priya Nair',
      'dueDate': '22 August 2026',
      'status': 'Pending',
      'points': 30,
      'urgency': 'Due in 4 days',
      'description':
          'Train and benchmark Decision Tree and Random Forest classifiers on the provided customer churn dataset.',
      'instructions':
          'Report confusion matrix, ROC-AUC curve, precision-recall trade-offs, and feature importance scores in a structured PDF document.'
    },
    {
      'id': 'ASG003',
      'title': 'TCP/IP Protocol Analysis',
      'subject': 'Computer Networks',
      'code': 'CS701PC',
      'faculty': 'Dr. K. Srinivas Rao',
      'dueDate': '25 August 2026',
      'status': 'Pending',
      'points': 25,
      'urgency': 'Due in 7 days',
      'description':
          'Analyze Wireshark packet capture traces for three-way handshakes, TCP sequence numbers, retransmissions, and flow control windows.',
      'instructions':
          'Attach pcap export screenshots and detailed sequence number exchange timing diagrams.'
    },
    {
      'id': 'ASG004',
      'title': 'Software Testing Case Study',
      'subject': 'Software Engineering',
      'code': 'CS503PC',
      'faculty': 'Prof. Ananya Roy',
      'dueDate': '18 August 2026',
      'status': 'Completed',
      'points': 25,
      'urgency': 'Submitted On Time',
      'description':
          'Write unit and integration test suites using JUnit/PyTest for an e-commerce checkout and payment reconciliation module.',
      'instructions': 'Adhere to the rubric and test cases.',
      'submittedDate': '17 August 2026, 09:30 PM',
      'score': '24/25',
      'grade': 'Grade A+',
      'feedback':
          'Exceptional test coverage (98%) and clear boundary value analysis. Well-documented code and edge cases handled effectively.'
    }
  ];

  @override
  void initState() {
    super.initState();
    fetchAssignments();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchAssignments() async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/api/student/assignments'),
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          assignments = data.map((item) {
            final map = Map<String, dynamic>.from(item);
            return map;
          }).toList();
          isLoading = false;
          errorMessage = '';
        });
      } else {
        _useFallback();
      }
    } catch (e) {
      _useFallback();
    }
  }

  void _useFallback() {
    setState(() {
      assignments = List<Map<String, dynamic>>.from(_fallbackAssignments);
      isLoading = false;
      errorMessage = '';
    });
  }

  List<String> get availableSubjects {
    final set = <String>{'All Subjects'};
    for (var a in assignments) {
      if (a['subject'] != null) {
        set.add(a['subject'].toString());
      }
    }
    return set.toList();
  }

  List<Map<String, dynamic>> get filteredAssignments {
    return assignments.where((a) {
      // Status filter
      if (selectedFilter != 'All') {
        if (selectedFilter == 'Pending' && a['status'] != 'Pending') {
          return false;
        }
        if (selectedFilter == 'Completed' &&
            a['status'] != 'Completed' &&
            a['status'] != 'Submitted') {
          return false;
        }
      }
      // Subject filter
      if (selectedSubject != 'All Subjects' &&
          a['subject'] != selectedSubject) {
        return false;
      }
      // Search query
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        final title = (a['title'] ?? '').toString().toLowerCase();
        final subject = (a['subject'] ?? '').toString().toLowerCase();
        final faculty = (a['faculty'] ?? '').toString().toLowerCase();
        final code = (a['code'] ?? '').toString().toLowerCase();
        if (!title.contains(q) &&
            !subject.contains(q) &&
            !faculty.contains(q) &&
            !code.contains(q)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  Future<void> _submitAssignment(String id, String comments, String fileName) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/api/student/assignments/submit'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'assignmentId': id,
              'comments': comments,
              'fileName': fileName,
            }),
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        // Success from backend
      }
    } catch (_) {}

    // Optimistic update in UI
    setState(() {
      final index = assignments.indexWhere((a) => a['id'] == id);
      if (index != -1) {
        assignments[index]['status'] = 'Completed';
        assignments[index]['submittedDate'] = 'Just now';
        assignments[index]['urgency'] = 'Submitted On Time';
        assignments[index]['submittedFile'] = fileName;
        assignments[index]['studentComments'] = comments;
      }
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Assignment submitted successfully! Attached: $fileName'),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF059669),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _showSubmitDialog(BuildContext context, Map<String, dynamic> assignment) {
    final commentsController = TextEditingController();
    String selectedFile =
        '${assignment['title'].toString().toLowerCase().replaceAll(' ', '_')}_22K91A0501.pdf';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) {
          return Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(22.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.upload_file_rounded,
                              color: Color(0xFF2563EB), size: 26),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Submit Assignment',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${assignment['subject']} (${assignment['code'] ?? 'CS301PC'})',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            assignment['title'] ?? 'Assignment',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.person_outline,
                                  size: 14, color: Colors.grey.shade600),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  assignment['faculty'] ?? 'Faculty Dept',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(Icons.calendar_today_outlined,
                                  size: 13, color: const Color(0xFFD97706)),
                              const SizedBox(width: 4),
                              Text(
                                'Due: ${assignment['dueDate']}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFD97706),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Attach Solution File *',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.picture_as_pdf,
                              color: Color(0xFFEF4444), size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              selectedFile,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setDialogState(() {
                                if (selectedFile.endsWith('.pdf')) {
                                  selectedFile = selectedFile.replaceAll('.pdf', '.zip');
                                } else if (selectedFile.endsWith('.zip')) {
                                  selectedFile = selectedFile.replaceAll('.zip', '.cpp');
                                } else {
                                  selectedFile = selectedFile.replaceAll('.cpp', '.pdf');
                                }
                              });
                            },
                            child: const Text('Change Format', style: TextStyle(fontSize: 11)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Submission Remarks / Notes',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: commentsController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText:
                            'e.g., Attached complete source code with automated unit tests and time complexity analysis...',
                        hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        const Icon(Icons.verified_user_outlined,
                            size: 16, color: Color(0xFF10B981)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Submission is timestamped and verified against university plagiarism checks.',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(ctx),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              final comments = commentsController.text.trim().isEmpty
                                  ? 'Submitted via HITAM ERP Student Portal'
                                  : commentsController.text.trim();
                              Navigator.pop(ctx);
                              _submitAssignment(
                                assignment['id'] ?? 'ASG001',
                                comments,
                                selectedFile,
                              );
                            },
                            icon: const Icon(Icons.send_rounded, size: 15),
                            label: const Text('Submit Work'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context, Map<String, dynamic> assignment) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.military_tech_rounded,
                          color: Color(0xFF059669), size: 26),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Evaluation & Feedback',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            '${assignment['subject']} • ${assignment['code'] ?? 'CS503PC'}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF059669), Color(0xFF10B981)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'FINAL SCORE',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            assignment['score'] ?? '24 / 25',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          assignment['grade'] ?? 'Grade A+',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Professor Remarks',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.format_quote_rounded,
                          color: Color(0xFF64748B), size: 22),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          assignment['feedback'] ??
                              'Excellent submission! All test cases passed with thorough boundary analysis.',
                          style: const TextStyle(
                            fontSize: 12,
                            height: 1.5,
                            color: Color(0xFF334155),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Rubric Breakdown',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 8),
                _buildRubricRow('Algorithm Correctness & Logic', '10 / 10', 1.0),
                _buildRubricRow('Test Coverage & Edge Cases', '9 / 10', 0.9),
                _buildRubricRow('Code Quality & Documentation', '5 / 5', 1.0),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Close Review'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRubricRow(String criteria, String score, double progress) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  criteria,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                ),
              ),
              Text(score,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  void _showBriefDialog(BuildContext context, Map<String, dynamic> assignment) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.menu_book_rounded,
                          color: Color(0xFF2563EB), size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            assignment['title'] ?? 'Assignment Details',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            '${assignment['subject']} • ${assignment['code'] ?? 'CS301PC'}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Text(
                  'Problem Statement & Objectives',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  assignment['description'] ?? 'No description provided.',
                  style: const TextStyle(fontSize: 12, height: 1.5, color: Color(0xFF475569)),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Specific Guidelines & Test Criteria',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Text(
                    assignment['instructions'] ??
                        'Ensure code conforms to academic coding standards and compiles without warnings.',
                    style: const TextStyle(fontSize: 12, height: 1.4, color: Color(0xFF334155)),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Close'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          if (assignment['status'] == 'Pending') {
                            _showSubmitDialog(context, assignment);
                          }
                        },
                        icon: Icon(
                          assignment['status'] == 'Pending'
                              ? Icons.upload_file
                              : Icons.check,
                          size: 15,
                        ),
                        label: Text(assignment['status'] == 'Pending'
                            ? 'Submit Now'
                            : 'Already Submitted'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount = assignments.where((a) => a['status'] == 'Pending').length;
    final completedCount = assignments
        .where((a) => a['status'] == 'Completed' || a['status'] == 'Submitted')
        .length;
    final totalCount = assignments.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Assignments Portal',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        actions: [
          IconButton(
            tooltip: 'Refresh Assignments',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: fetchAssignments,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 60, color: Colors.red),
                      const SizedBox(height: 15),
                      Text(errorMessage, style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: fetchAssignments,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: fetchAssignments,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1120),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. HERO BANNER
                            _buildHeroBanner(totalCount, pendingCount),
                            const SizedBox(height: 16),

                            // 2. EXECUTIVE KPI CARDS
                            _buildKpiMetrics(totalCount, pendingCount, completedCount),
                            const SizedBox(height: 20),

                            // 3. SEARCH & FILTER CONTROLS
                            _buildFilterBar(),
                            const SizedBox(height: 16),

                            // 4. ASSIGNMENTS GRID
                            filteredAssignments.isEmpty
                                ? _buildEmptyState()
                                : LayoutBuilder(
                                    builder: (context, constraints) {
                                      final isDesktop = constraints.maxWidth > 720;
                                      if (isDesktop) {
                                        // 2-Column Responsive Layout
                                        return Wrap(
                                          spacing: 16,
                                          runSpacing: 16,
                                          children: filteredAssignments.map((assignment) {
                                            final cardWidth = (constraints.maxWidth - 16) / 2;
                                            return SizedBox(
                                              width: cardWidth,
                                              child: _buildAssignmentCard(assignment),
                                            );
                                          }).toList(),
                                        );
                                      } else {
                                        // 1-Column Mobile Layout
                                        return Column(
                                          children: filteredAssignments.map((assignment) {
                                            return Padding(
                                              padding: const EdgeInsets.only(bottom: 14),
                                              child: _buildAssignmentCard(assignment),
                                            );
                                          }).toList(),
                                        );
                                      }
                                    },
                                  ),
                            const SizedBox(height: 36),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }

  // 1. HERO BANNER (MOBILE + DESKTOP RESPONSIVE)
  Widget _buildHeroBanner(int total, int pending) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(isMobile ? 16 : 22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withOpacity(0.12),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                alignment: WrapAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'HITAM ACADEMIC PORTAL',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: pending > 0
                          ? const Color(0xFFF59E0B).withOpacity(0.2)
                          : const Color(0xFF10B981).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: pending > 0
                            ? const Color(0xFFF59E0B)
                            : const Color(0xFF10B981),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          pending > 0 ? Icons.warning_amber_rounded : Icons.check_circle_rounded,
                          size: 13,
                          color: pending > 0 ? const Color(0xFFF59E0B) : const Color(0xFF10B981),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          pending > 0 ? '$pending Tasks Require Action' : 'All Tasks Submitted',
                          style: TextStyle(
                            color: pending > 0 ? const Color(0xFFFCD34D) : const Color(0xFF6EE7B7),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Course Deliverables & Submissions',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isMobile ? 18 : 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Roll No: 22K91A0501 • B.Tech CSE (Year 4, Sem 7)',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.75),
                  fontSize: isMobile ? 12 : 13,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 2. EXECUTIVE KPI CARDS (RESPONSIVE BREAKPOINT FOR MOBILE & DESKTOP)
  Widget _buildKpiMetrics(int total, int pending, int completed) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // >= 880px: 4 cards in one row
        // < 880px: 2 cards in one row (mobile & tablet)
        final bool isDesktop = constraints.maxWidth >= 880;
        final bool isNarrow = constraints.maxWidth < 580;
        final double cardWidth = isDesktop
            ? (constraints.maxWidth - 36) / 4
            : (constraints.maxWidth - 12) / 2;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildStatCard(
              title: 'Total Assigned',
              value: '$total',
              subtitle: 'Active semester courses',
              icon: Icons.assignment_outlined,
              iconColor: const Color(0xFF2563EB),
              badgeColor: const Color(0xFFEFF6FF),
              width: cardWidth,
              isNarrow: isNarrow,
            ),
            _buildStatCard(
              title: 'Pending Work',
              value: '$pending',
              subtitle: 'Upcoming deadlines',
              icon: Icons.pending_actions_rounded,
              iconColor: const Color(0xFFD97706),
              badgeColor: const Color(0xFFFEF3C7),
              width: cardWidth,
              isNarrow: isNarrow,
            ),
            _buildStatCard(
              title: 'Completed',
              value: '$completed',
              subtitle: 'Submitted on time',
              icon: Icons.task_alt_rounded,
              iconColor: const Color(0xFF059669),
              badgeColor: const Color(0xFFECFDF5),
              width: cardWidth,
              isNarrow: isNarrow,
            ),
            _buildStatCard(
              title: 'Standing',
              value: '96%',
              subtitle: 'Grade A+ average score',
              icon: Icons.auto_awesome_rounded,
              iconColor: const Color(0xFF7C3AED),
              badgeColor: const Color(0xFFF3E8FF),
              width: cardWidth,
              isNarrow: isNarrow,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color badgeColor,
    required double width,
    required bool isNarrow,
  }) {
    return Container(
      width: width,
      padding: EdgeInsets.all(isNarrow ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isNarrow ? 11 : 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: EdgeInsets.all(isNarrow ? 6 : 8),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: isNarrow ? 16 : 18),
              ),
            ],
          ),
          SizedBox(height: isNarrow ? 6 : 10),
          Text(
            value,
            style: TextStyle(
              fontSize: isNarrow ? 20 : 24,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: isNarrow ? 10 : 11,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  // 3. SEARCH & FILTER CONTROLS (MOBILE-RESPONSIVE FLOW)
  Widget _buildFilterBar() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 650;

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isMobile) ...[
                // Mobile Search Bar (Full Width)
                TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      searchQuery = val.trim();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search by title, course, faculty...',
                    hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                    prefixIcon: const Icon(Icons.search, size: 18, color: Color(0xFF64748B)),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 16),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                searchQuery = '';
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Mobile Subject Filter Dropdown (Full Width)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedSubject,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155),
                      ),
                      items: availableSubjects.map((s) {
                        return DropdownMenuItem<String>(
                          value: s,
                          child: Text(s, overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            selectedSubject = val;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ] else ...[
                // Desktop Search + Dropdown Row
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) {
                          setState(() {
                            searchQuery = val.trim();
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search by assignment title, course, or faculty...',
                          hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                          prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFF64748B)),
                          suffixIcon: searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      searchQuery = '';
                                    });
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedSubject,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF334155),
                          ),
                          items: availableSubjects.map((s) {
                            return DropdownMenuItem<String>(
                              value: s,
                              child: Text(s),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                selectedSubject = val;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 10),
              // Horizontal Scrollable Status Tabs (Swipeable on Mobile Phones)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildFilterPill('All', assignments.length),
                    const SizedBox(width: 8),
                    _buildFilterPill('Pending',
                        assignments.where((a) => a['status'] == 'Pending').length),
                    const SizedBox(width: 8),
                    _buildFilterPill(
                        'Completed',
                        assignments
                            .where((a) =>
                                a['status'] == 'Completed' ||
                                a['status'] == 'Submitted')
                            .length),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterPill(String label, int count) {
    final isSelected = selectedFilter == label;
    return InkWell(
      onTap: () {
        setState(() {
          selectedFilter = label;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF475569),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withOpacity(0.2) : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : const Color(0xFF334155),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 4. ASSIGNMENT CARD (FLEXIBLE WRAP FOR ZERO OVERFLOW)
  Widget _buildAssignmentCard(Map<String, dynamic> assignment) {
    final isPending = assignment['status'] == 'Pending';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPending ? const Color(0xFFE2E8F0) : const Color(0xFFD1FAE5),
          width: isPending ? 1 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Subject Badge + Status Badge (with Expanded protection)
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${assignment['subject']} • ${assignment['code'] ?? 'CS301PC'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF2563EB),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPending ? const Color(0xFFFEF3C7) : const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPending ? Icons.schedule_rounded : Icons.check_circle_rounded,
                      size: 12,
                      color: isPending ? const Color(0xFFD97706) : const Color(0xFF059669),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isPending ? 'Pending' : 'Completed',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isPending ? const Color(0xFFB45309) : const Color(0xFF047857),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Title
          Text(
            assignment['title'] ?? 'Assignment Title',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 4),

          // Description snippet
          Text(
            assignment['description'] ??
                'Complete all deliverables according to the academic syllabus guidelines.',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),

          // Metadata Row: Faculty & Points
          Row(
            children: [
              Icon(Icons.person_outline_rounded, size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  assignment['faculty'] ?? 'Department Faculty',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.military_tech_outlined, size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                '${assignment['points'] ?? 25} Pts',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF334155),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Due Date & Urgency Callout Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: isPending ? const Color(0xFFFFFBEB) : const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isPending ? const Color(0xFFFDE68A) : const Color(0xFFBBF7D0),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isPending ? Icons.alarm_rounded : Icons.verified_rounded,
                  size: 14,
                  color: isPending ? const Color(0xFFD97706) : const Color(0xFF059669),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    isPending
                        ? 'Due: ${assignment['dueDate']} (${assignment['urgency'] ?? 'Due Soon'})'
                        : '${assignment['urgency'] ?? 'Submitted'} • Score: ${assignment['score'] ?? '24/25'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isPending ? const Color(0xFF92400E) : const Color(0xFF166534),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showBriefDialog(context, assignment),
                  icon: const Icon(Icons.info_outline_rounded, size: 14),
                  label: const Text('Brief', style: TextStyle(fontSize: 11)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF334155),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (isPending) {
                      _showSubmitDialog(context, assignment);
                    } else {
                      _showFeedbackDialog(context, assignment);
                    }
                  },
                  icon: Icon(
                    isPending ? Icons.upload_file_rounded : Icons.grade_rounded,
                    size: 14,
                  ),
                  label: Text(
                    isPending ? 'Submit' : 'Feedback',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isPending ? const Color(0xFF2563EB) : const Color(0xFF059669),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Icon(Icons.search_off_rounded, size: 44, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          const Text(
            'No matching assignments found',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try clearing your search query or switching the status filter.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: () {
              _searchController.clear();
              setState(() {
                searchQuery = '';
                selectedFilter = 'All';
                selectedSubject = 'All Subjects';
              });
            },
            child: const Text('Reset All Filters'),
          ),
        ],
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
          '${ApiConfig.baseUrl}/api/student/exams',
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
          '${ApiConfig.baseUrl}/api/student/results',
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
          '${ApiConfig.baseUrl}/api/faculty',
        ),
      );

      final studentsResponse = await http.get(
        Uri.parse(
          '${ApiConfig.baseUrl}/api/faculty/students',
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
        actions: const [
          NotificationBellIcon(role: 'faculty'),
        ],
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
          '${ApiConfig.baseUrl}/api/faculty/assignments',
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
          '${ApiConfig.baseUrl}/api/faculty/attendance',
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
          '${ApiConfig.baseUrl}/api/faculty/announcements',
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
          '${ApiConfig.baseUrl}/api/admin/summary',
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
        actions: const [
          NotificationBellIcon(role: 'admin'),
        ],
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
          '${ApiConfig.baseUrl}/api/admin/students',
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
          '${ApiConfig.baseUrl}/api/admin/students',
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
          '${ApiConfig.baseUrl}/api/parent',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(
          response.body,
        );

        setState(() {
          parentName = data['parentName']?.toString() ?? 'Parent';
          studentName = data['studentName']?.toString() ?? 'Bhargavi';
          studentId = (data['studentId'] ?? data['rollNo'])?.toString() ?? '22K91A0501';
          attendance = (data['attendance'] is num)
              ? (data['attendance'] as num).toInt()
              : int.tryParse(data['attendance']?.toString() ?? '') ?? 85;
          assignmentsPending = (data['assignmentsPending'] is num)
              ? (data['assignmentsPending'] as num).toInt()
              : int.tryParse(data['assignmentsPending']?.toString() ?? '') ?? 3;
          upcomingExams = (data['upcomingExams'] is num)
              ? (data['upcomingExams'] as num).toInt()
              : int.tryParse(data['upcomingExams']?.toString() ?? '') ?? 2;
          feeReminder = data['feeReminder']?.toString() ??
              data['pendingFees']?.toString() ??
              '₹25,000 Pending';
          newAnnouncements = (data['newAnnouncements'] is num)
              ? (data['newAnnouncements'] as num).toInt()
              : int.tryParse(data['newAnnouncements']?.toString() ?? '') ?? 4;

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
        actions: const [
          NotificationBellIcon(role: 'parent'),
        ],
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

              : Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, $parentName',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Student: $studentName ($studentId)',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 28),

                          // ATTENDANCE + ASSIGNMENTS
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const AttendanceDetailsScreen(),
                                      ),
                                    );
                                  },
                                  child: DashboardCard(
                                    icon: Icons.calendar_month,
                                    title: 'Attendance (View)',
                                    value: '$attendance%',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
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

                          // EXAMINATIONS + ANNOUNCEMENTS
                          Row(
                            children: [
                              Expanded(
                                child: DashboardCard(
                                  icon: Icons.event,
                                  title: 'Examinations',
                                  value: '$upcomingExams Upcoming',
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: DashboardCard(
                                  icon: Icons.notifications,
                                  title: 'Announcements',
                                  value: '$newAnnouncements New',
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // FEE REMINDER CARD
                          SizedBox(
                            width: double.infinity,
                            child: DashboardCard(
                              icon: Icons.payment,
                              title: 'Fee Reminder',
                              value: feeReminder,
                            ),
                          ),

                          const SizedBox(height: 28),

                          // ACTION BUTTONS
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 48,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const ParentFeeDetailsScreen(),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.payment),
                                    label: const Text(
                                      'View Fee Details',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue.shade700,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: SizedBox(
                                  height: 48,
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const AnnouncementsScreen(),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.notifications_outlined),
                                    label: const Text(
                                      'View Announcements',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // REFRESH BUTTON
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: TextButton.icon(
                              onPressed: fetchParentData,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Refresh Dashboard Data'),
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
        Uri.parse('${ApiConfig.baseUrl}/api/admin/faculty'),
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
          '${ApiConfig.baseUrl}/api/admin/announcements',
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

  String studentName = 'Bhargavi';
  String studentId = '22K91A0501';
  String department = 'CSE - 4th Year';
  String academicYear = '2025 - 2026';
  int totalFee = 117500;
  int paidFee = 92500;
  int pendingFee = 25000;
  String dueDate = '30 August 2026';
  String status = 'Pending';
  List<Map<String, dynamic>> breakdown = [];

  @override
  void initState() {
    super.initState();
    fetchFeeData();
  }

  String _formatRupees(num amount) {
    int intVal = amount.round();
    String str = intVal.toString();
    if (str.length <= 3) return str;
    String lastThree = str.substring(str.length - 3);
    String otherNumbers = str.substring(0, str.length - 3);
    final buffer = StringBuffer();
    for (int i = 0; i < otherNumbers.length; i++) {
      if ((otherNumbers.length - i) % 2 == 0 && i != 0) {
        buffer.write(',');
      }
      buffer.write(otherNumbers[i]);
    }
    buffer.write(',');
    buffer.write(lastThree);
    return buffer.toString();
  }

  Future<void> fetchFeeData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/parent/fees'),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          studentName = data['studentName']?.toString() ?? 'Bhargavi';
          studentId = data['studentId']?.toString() ?? '22K91A0501';
          department = data['department']?.toString() ?? 'CSE - 4th Year';
          academicYear = data['academicYear']?.toString() ?? '2025 - 2026';

          totalFee = (data['totalFee'] is num)
              ? (data['totalFee'] as num).toInt()
              : int.tryParse(data['totalFee']?.toString() ?? '') ?? 117500;

          paidFee = (data['paidFee'] is num)
              ? (data['paidFee'] as num).toInt()
              : int.tryParse(data['paidFee']?.toString() ?? '') ?? 92500;

          pendingFee = (data['pendingFee'] is num)
              ? (data['pendingFee'] as num).toInt()
              : int.tryParse(data['pendingFee']?.toString() ?? '') ?? 25000;

          dueDate = data['dueDate']?.toString() ?? '30 August 2026';
          status = data['status']?.toString() ?? (pendingFee > 0 ? 'Pending' : 'Paid');

          if (data['breakdown'] is List) {
            breakdown = List<Map<String, dynamic>>.from(
              (data['breakdown'] as List).map(
                (item) => Map<String, dynamic>.from(item as Map),
              ),
            );
          } else {
            breakdown = [
              {
                "feeType": "Academic Tuition Fee",
                "totalAmount": 85000,
                "paidAmount": 60000,
                "dueAmount": 25000,
                "dueDate": "30 August 2026",
                "status": "Pending"
              },
              {
                "feeType": "College Bus Transport",
                "totalAmount": 25000,
                "paidAmount": 25000,
                "dueAmount": 0,
                "dueDate": "15 July 2026",
                "status": "Paid"
              },
              {
                "feeType": "Examination Fee",
                "totalAmount": 2500,
                "paidAmount": 2500,
                "dueAmount": 0,
                "dueDate": "10 August 2026",
                "status": "Paid"
              },
              {
                "feeType": "Library & Lab Deposit",
                "totalAmount": 5000,
                "paidAmount": 5000,
                "dueAmount": 0,
                "dueDate": "01 June 2026",
                "status": "Paid"
              }
            ];
          }

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
      if (!mounted) return;
      setState(() {
        errorMessage = 'Backend connection failed';
        isLoading = false;
      });
    }
  }

  void _showPaymentModal(BuildContext context, {int? specificAmount, String? feeType}) {
    final payAmount = specificAmount ?? pendingFee;
    if (payAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No pending fees to pay! All dues cleared.')),
      );
      return;
    }

    String selectedMethod = 'UPI';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 24,
                      left: 24,
                      right: 24,
                      bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.account_balance, color: Colors.blue),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'HITAM Payment Gateway',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      feeType ?? 'Semester Academic Dues',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(ctx),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Student: $studentName',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Roll No: $studentId | $department',
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                                  ),
                                ],
                              ),
                              Text(
                                '₹${_formatRupees(payAmount)}',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Select Payment Method',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 10),
                        RadioListTile<String>(
                          value: 'UPI',
                          groupValue: selectedMethod,
                          onChanged: (val) => setModalState(() => selectedMethod = val!),
                          title: const Text('UPI (Google Pay, PhonePe, Paytm, BHIM)'),
                          secondary: const Icon(Icons.qr_code_2, color: Colors.deepPurple),
                        ),
                        RadioListTile<String>(
                          value: 'NetBanking',
                          groupValue: selectedMethod,
                          onChanged: (val) => setModalState(() => selectedMethod = val!),
                          title: const Text('Net Banking (SBI, HDFC, ICICI, Axis)'),
                          secondary: const Icon(Icons.account_balance, color: Colors.blue),
                        ),
                        RadioListTile<String>(
                          value: 'Cards',
                          groupValue: selectedMethod,
                          onChanged: (val) => setModalState(() => selectedMethod = val!),
                          title: const Text('Debit / Credit Card'),
                          secondary: const Icon(Icons.credit_card, color: Colors.teal),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.lock),
                            label: Text(
                              'Pay ₹${_formatRupees(payAmount)} Securely',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade700,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(ctx);
                              _processPayment(payAmount, feeType);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _processPayment(int amountPaid, String? feeType) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(28.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Connecting to Bank Gateway...', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 6),
                Text('Please do not close this window', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );

    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      setState(() {
        paidFee += amountPaid;
        pendingFee = (pendingFee - amountPaid).clamp(0, totalFee);
        status = pendingFee == 0 ? 'Paid' : 'Pending';

        if (feeType != null) {
          for (var item in breakdown) {
            if (item['feeType'] == feeType) {
              item['paidAmount'] = ((item['paidAmount'] as num?) ?? 0) + amountPaid;
              item['dueAmount'] = 0;
              item['status'] = 'Paid';
            }
          }
        } else {
          for (var item in breakdown) {
            item['paidAmount'] = item['totalAmount'];
            item['dueAmount'] = 0;
            item['status'] = 'Paid';
          }
        }
      });

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          icon: const Icon(Icons.check_circle, color: Colors.green, size: 60),
          title: const Text('Payment Successful!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Amount Paid: ₹${_formatRupees(amountPaid)}', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              const Text('Transaction ID: HITAM-TXN-2026-98124'),
              const SizedBox(height: 4),
              Text('Student: $studentName ($studentId)'),
              const SizedBox(height: 4),
              const Text('Status: Verified by Accounts Section'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.verified, color: Colors.green, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'E-receipt has been sent to parent email & college portal.',
                        style: TextStyle(fontSize: 12, color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Done'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                _showReceiptDialog(context);
              },
              icon: const Icon(Icons.receipt),
              label: const Text('View Receipt'),
            ),
          ],
        ),
      );
    });
  }

  void _showReceiptDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.school, size: 28, color: Colors.blue),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'HITAM HYDERABAD',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              'Autonomous Fee Receipt',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Receipt No: HITAM/FEE/2026/08492', style: TextStyle(fontSize: 13, color: Colors.grey.shade800, fontWeight: FontWeight.bold)),
                    const Text('Date: 15 Sep 2026', style: TextStyle(fontSize: 13, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Student: $studentName', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Roll No: $studentId | Dept: $department'),
                      const SizedBox(height: 4),
                      Text('Academic Year: $academicYear'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Payment Summary:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Academic Dues:'),
                    Text('₹${_formatRupees(totalFee)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Amount Paid:'),
                    Text('₹${_formatRupees(paidFee)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Balance Remaining:'),
                    Text('₹${_formatRupees(pendingFee)}', style: TextStyle(fontWeight: FontWeight.bold, color: pendingFee > 0 ? Colors.orange.shade800 : Colors.green)),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Fee Receipt PDF downloaded to local storage.')),
                        );
                      },
                      icon: const Icon(Icons.download),
                      label: const Text('Download PDF'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStudentHeroCard() {
    final bool isDue = pendingFee > 0;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blue.shade100,
              child: const Icon(Icons.school, size: 32, color: Colors.blue),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    studentName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          'Roll: $studentId',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade800, fontWeight: FontWeight.w500),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Text(
                          department,
                          style: TextStyle(fontSize: 12, color: Colors.blue.shade800, fontWeight: FontWeight.w500),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.purple.shade200),
                        ),
                        child: Text(
                          'AY: $academicYear',
                          style: TextStyle(fontSize: 12, color: Colors.purple.shade800, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isDue ? Colors.amber.shade50 : Colors.green.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDue ? Colors.amber.shade300 : Colors.green.shade300),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isDue ? Icons.schedule : Icons.check_circle,
                    size: 16,
                    color: isDue ? Colors.orange.shade800 : Colors.green.shade800,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isDue ? 'Due: ₹${_formatRupees(pendingFee)}' : 'All Cleared',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDue ? Colors.orange.shade900 : Colors.green.shade900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(double percentage, double progress) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.pie_chart_outline, size: 20, color: Colors.teal.shade700),
                    const SizedBox(width: 8),
                    const Text(
                      'Fee Clearance Progress',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ],
                ),
                Text(
                  '${percentage.toStringAsFixed(1)}% Settled',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade800,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 12,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  percentage >= 100 ? Colors.green.shade600 : Colors.teal.shade600,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Paid ₹${_formatRupees(paidFee)} of ₹${_formatRupees(totalFee)}',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                ),
                Text(
                  pendingFee > 0 ? 'Remaining ₹${_formatRupees(pendingFee)} due by $dueDate' : 'All semester fees cleared',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: pendingFee > 0 ? Colors.orange.shade800 : Colors.green.shade800,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiCard({
    required IconData icon,
    required Color color,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Expanded(
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKpiSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth >= 720;
        if (isDesktop) {
          return Row(
            children: [
              _buildKpiCard(
                icon: Icons.account_balance_wallet_outlined,
                color: Colors.blue.shade700,
                title: 'Total Academic Fee',
                value: '₹${_formatRupees(totalFee)}',
                subtitle: 'Annual AY 2025-2026',
              ),
              const SizedBox(width: 12),
              _buildKpiCard(
                icon: Icons.check_circle_outline,
                color: Colors.green.shade700,
                title: 'Total Amount Paid',
                value: '₹${_formatRupees(paidFee)}',
                subtitle: 'Verified Receipts',
              ),
              const SizedBox(width: 12),
              _buildKpiCard(
                icon: Icons.pending_actions_outlined,
                color: Colors.orange.shade800,
                title: 'Pending Balance',
                value: '₹${_formatRupees(pendingFee)}',
                subtitle: 'Due by $dueDate',
              ),
              const SizedBox(width: 12),
              _buildKpiCard(
                icon: Icons.verified_outlined,
                color: Colors.purple.shade700,
                title: 'Account Status',
                value: status,
                subtitle: 'Online / NetBanking',
              ),
            ],
          );
        } else {
          return Column(
            children: [
              Row(
                children: [
                  _buildKpiCard(
                    icon: Icons.account_balance_wallet_outlined,
                    color: Colors.blue.shade700,
                    title: 'Total Fee',
                    value: '₹${_formatRupees(totalFee)}',
                    subtitle: 'Annual Fee',
                  ),
                  const SizedBox(width: 12),
                  _buildKpiCard(
                    icon: Icons.check_circle_outline,
                    color: Colors.green.shade700,
                    title: 'Paid Fee',
                    value: '₹${_formatRupees(paidFee)}',
                    subtitle: 'Verified',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildKpiCard(
                    icon: Icons.pending_actions_outlined,
                    color: Colors.orange.shade800,
                    title: 'Pending Balance',
                    value: '₹${_formatRupees(pendingFee)}',
                    subtitle: 'Due: $dueDate',
                  ),
                  const SizedBox(width: 12),
                  _buildKpiCard(
                    icon: Icons.verified_outlined,
                    color: Colors.purple.shade700,
                    title: 'Status',
                    value: status,
                    subtitle: 'Current State',
                  ),
                ],
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildActionBar() {
    return Row(
      children: [
        if (pendingFee > 0) ...[
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => _showPaymentModal(context),
                icon: const Icon(Icons.payment),
                label: Text(
                  'Pay Pending Fee (₹${_formatRupees(pendingFee)})',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          flex: 1,
          child: SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () => _showReceiptDialog(context),
              icon: const Icon(Icons.receipt_long),
              label: const Text('Download Receipt'),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  IconData _getFeeIcon(String feeType) {
    final lower = feeType.toLowerCase();
    if (lower.contains('tuition')) return Icons.school_outlined;
    if (lower.contains('bus') || lower.contains('transport')) return Icons.directions_bus_outlined;
    if (lower.contains('exam')) return Icons.assignment_outlined;
    if (lower.contains('lib') || lower.contains('lab')) return Icons.biotech_outlined;
    return Icons.receipt_outlined;
  }

  Widget _buildBreakdownSection() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.format_list_bulleted, color: Colors.blue.shade700),
                    const SizedBox(width: 10),
                    const Text(
                      'Fee Structure & Breakdown',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${breakdown.length} Items',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue.shade700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Detailed semester breakdown including academic tuition, transport, exams, and facility charges',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const Divider(height: 24),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: breakdown.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = breakdown[index];
                final feeType = item['feeType']?.toString() ?? 'Fee Component';
                final totalAmount = (item['totalAmount'] is num) ? (item['totalAmount'] as num).toInt() : 0;
                final paidAmount = (item['paidAmount'] is num) ? (item['paidAmount'] as num).toInt() : 0;
                final dueAmount = (item['dueAmount'] is num) ? (item['dueAmount'] as num).toInt() : 0;
                final itemDueDate = item['dueDate']?.toString() ?? dueDate;
                final itemStatus = item['status']?.toString() ?? (dueAmount > 0 ? 'Pending' : 'Paid');
                final bool isPaid = itemStatus.toLowerCase() == 'paid';

                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isPaid ? Colors.grey.shade50 : Colors.amber.shade50.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isPaid ? Colors.grey.shade200 : Colors.amber.shade200,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isPaid ? Colors.green.shade50 : Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          _getFeeIcon(feeType),
                          color: isPaid ? Colors.green.shade700 : Colors.orange.shade800,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              feeType,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Due Date: $itemDueDate | Total: ₹${_formatRupees(totalAmount)}',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Paid: ₹${_formatRupees(paidAmount)}',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            dueAmount > 0 ? 'Due: ₹${_formatRupees(dueAmount)}' : 'Cleared',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: dueAmount > 0 ? Colors.orange.shade900 : Colors.green.shade800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isPaid ? Colors.green.shade100 : Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          itemStatus.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isPaid ? Colors.green.shade900 : Colors.orange.shade900,
                          ),
                        ),
                      ),
                      if (dueAmount > 0) ...[
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () => _showPaymentModal(
                            context,
                            specificAmount: dueAmount,
                            feeType: feeType,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          child: const Text('Pay'),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.blue.shade50.withOpacity(0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        children: [
          Icon(Icons.headset_mic_outlined, size: 32, color: Colors.blue.shade700),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'HITAM Accounts Section & Helpline',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  'For payment plans, scholarship verifications, or fee queries: accounts@hitam.edu | +91 91000 00000',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double progress = totalFee > 0 ? (paidFee / totalFee).clamp(0.0, 1.0) : 0.0;
    final double percentage = progress * 100;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fee Details & Invoices'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: fetchFeeData,
          ),
          IconButton(
            icon: const Icon(Icons.receipt_long),
            tooltip: 'View Receipt',
            onPressed: () => _showReceiptDialog(context),
          ),
          const SizedBox(width: 8),
        ],
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
                      ElevatedButton.icon(
                        onPressed: fetchFeeData,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1080),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStudentHeroCard(),
                          const SizedBox(height: 20),
                          _buildProgressCard(percentage, progress),
                          const SizedBox(height: 20),
                          _buildKpiSection(),
                          const SizedBox(height: 24),
                          _buildActionBar(),
                          const SizedBox(height: 24),
                          _buildBreakdownSection(),
                          const SizedBox(height: 24),
                          _buildSupportCard(),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }
}


