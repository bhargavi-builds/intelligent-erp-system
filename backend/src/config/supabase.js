const { createClient } = require("@supabase/supabase-js");
const path = require("path");
require("dotenv").config({ path: path.resolve(__dirname, "../../.env") });

const supabaseUrl = process.env.SUPABASE_URL || "https://luzdjghixvegqlwaeyna.supabase.co";
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY && process.env.SUPABASE_SERVICE_ROLE_KEY !== "YOUR_SUPABASE_SERVICE_ROLE_KEY"
    ? process.env.SUPABASE_SERVICE_ROLE_KEY
    : (process.env.SUPABASE_ANON_KEY && process.env.SUPABASE_ANON_KEY !== "YOUR_SUPABASE_ANON_KEY"
        ? process.env.SUPABASE_ANON_KEY
        : null);

let supabase = null;
const isConfigured = Boolean(supabaseUrl && supabaseKey);

if (isConfigured) {
    try {
        supabase = createClient(supabaseUrl, supabaseKey);
        console.log(" Connected to Supabase:", supabaseUrl);
    } catch (err) {
        console.warn(" Failed to initialize Supabase client, using mock fallback:", err.message);
    }
} else {
    console.log("⚠️ Supabase API key not provided yet in backend/.env.");
    console.log(" Using intelligent mock database fallback for all endpoints.");
    console.log(" Add SUPABASE_ANON_KEY in backend/.env to connect to live Supabase.");
}

// Fallback Mock Data Store (Synchronized with HITAM ERP data)
const mockDb = {
    student: {
        id: "STU001",
        name: "Bhargavi",
        department: "CSE",
        year: "4th Year",
        attendance: 85,
        assignmentsPending: 3,
        upcomingExams: 2,
        newAnnouncements: 4
    },
    attendance: {
        studentId: "22K91A0501",
        studentName: "Bhargavi",
        department: "CSE - 4th Year",
        semester: "Semester 7",
        overallAttendance: 85,
        totalClasses: 120,
        attendedClasses: 103,
        marginClasses: 16,
        subjects: [
            { subject: "Computer Networks", code: "CS701PC", faculty: "Dr. Ramesh", attended: 28, total: 32, percentage: 88 },
            { subject: "Neural Networks", code: "CS702PE", faculty: "Prof. Priya", attended: 25, total: 30, percentage: 83 },
            { subject: "Big Data", code: "CS703PE", faculty: "Dr. Sharma", attended: 27, total: 30, percentage: 90 },
            { subject: "Compiler Design", code: "CS704PC", faculty: "Prof. K. Rao", attended: 23, total: 28, percentage: 82 }
        ]
    },
    assignments: [
        {
            id: "ASG001",
            title: "Binary Search Implementation",
            subject: "Data Structures",
            code: "CS301PC",
            faculty: "Dr. Ramesh Kumar",
            dueDate: "20 August 2026",
            status: "Pending",
            points: 25,
            urgency: "Due in 2 days",
            description: "Implement iterative and recursive binary search algorithms in C++/Java with comprehensive time and space complexity proofs.",
            instructions: "Include unit test cases covering edge cases such as empty array, single element, negative numbers, and target-not-found scenarios."
        },
        {
            id: "ASG002",
            title: "ML Classification Report",
            subject: "Machine Learning",
            code: "CS702PE",
            faculty: "Prof. Priya Nair",
            dueDate: "22 August 2026",
            status: "Pending",
            points: 30,
            urgency: "Due in 4 days",
            description: "Train and benchmark Decision Tree and Random Forest classifiers on the provided customer churn dataset.",
            instructions: "Report confusion matrix, ROC-AUC curve, precision-recall trade-offs, and feature importance scores in a structured PDF document."
        },
        {
            id: "ASG003",
            title: "TCP/IP Protocol Analysis",
            subject: "Computer Networks",
            code: "CS701PC",
            faculty: "Dr. K. Srinivas Rao",
            dueDate: "25 August 2026",
            status: "Pending",
            points: 25,
            urgency: "Due in 7 days",
            description: "Analyze Wireshark packet capture traces for three-way handshakes, TCP sequence numbers, retransmissions, and flow control windows.",
            instructions: "Attach pcap export screenshots and detailed sequence number exchange timing diagrams."
        },
        {
            id: "ASG004",
            title: "Software Testing Case Study",
            subject: "Software Engineering",
            code: "CS503PC",
            faculty: "Prof. Ananya Roy",
            dueDate: "18 August 2026",
            status: "Completed",
            points: 25,
            urgency: "Submitted On Time",
            description: "Write unit and integration test suites using JUnit/PyTest for an e-commerce checkout and payment reconciliation module.",
            submittedDate: "17 August 2026, 09:30 PM",
            score: "24/25",
            grade: "Grade A+",
            feedback: "Exceptional test coverage (98%) and clear boundary value analysis. Well-documented code and edge cases handled effectively."
        }
    ],
    exams: [
        { id: "EXM001", subject: "Machine Learning", date: "12 September 2026", time: "10:00 AM - 01:00 PM", room: "Hall 302", type: "Mid Term" },
        { id: "EXM002", subject: "Computer Networks", date: "15 September 2026", time: "02:00 PM - 05:00 PM", room: "Lab 2", type: "Lab Exam" }
    ],
    results: [
        {
            semester: "Semester 6",
            gpa: 8.65,
            cgpa: 8.42,
            subjects: [
                { code: "CS601", name: "Data Structures & Algorithms", grade: "A+", credits: 4, status: "Pass" },
                { code: "CS602", name: "Machine Learning", grade: "A", credits: 4, status: "Pass" },
                { code: "CS603", name: "Computer Networks", grade: "A", credits: 3, status: "Pass" },
                { code: "CS604", name: "Software Engineering", grade: "A+", credits: 3, status: "Pass" },
                { code: "CS605", name: "Cloud Computing Lab", grade: "O", credits: 2, status: "Pass" }
            ]
        },
        {
            semester: "Semester 5",
            gpa: 8.40,
            cgpa: 8.38,
            subjects: [
                { code: "CS501", name: "Design & Analysis of Algorithms", grade: "A+", credits: 4, status: "Pass" },
                { code: "CS502", name: "Database Management Systems", grade: "O", credits: 4, status: "Pass" },
                { code: "CS503", name: "Operating Systems", grade: "A", credits: 3, status: "Pass" },
                { code: "CS504", name: "Formal Languages & Automata", grade: "B+", credits: 3, status: "Pass" },
                { code: "CS505", name: "DBMS & OS Virtual Lab", grade: "O", credits: 2, status: "Pass" }
            ]
        },
        {
            semester: "Semester 4",
            gpa: 8.50,
            cgpa: 8.36,
            subjects: [
                { code: "CS401", name: "Computer Organization & Arch", grade: "A", credits: 4, status: "Pass" },
                { code: "CS402", name: "Java & OOP Systems", grade: "O", credits: 4, status: "Pass" },
                { code: "CS403", name: "Discrete Mathematical Structures", grade: "A+", credits: 3, status: "Pass" },
                { code: "CS404", name: "Environmental Engineering", grade: "A", credits: 2, status: "Pass" },
                { code: "CS405", name: "Java Programming Laboratory", grade: "O", credits: 2, status: "Pass" }
            ]
        }
    ],
    faculty: {
        id: "FAC001",
        name: "Dr. Ramesh",
        department: "CSE",
        students: 42,
        attendanceManagement: "Manage",
        activeAssignments: 5,
        announcements: "Create",
        timetable: "View"
    },
    facultyStudents: [
        { id: "STU001", name: "Bhargavi", attendance: 85, assignmentsPending: 3 },
        { id: "STU002", name: "Anjali", attendance: 92, assignmentsPending: 1 },
        { id: "STU003", name: "Rahul", attendance: 78, assignmentsPending: 4 },
        { id: "STU004", name: "Sneha", attendance: 88, assignmentsPending: 2 }
    ],
    facultyAssignments: [
        {
            id: "ASG001",
            subject: "Data Structures",
            code: "CS301PC",
            title: "Binary Search Implementation",
            faculty: "Dr. Ramesh Kumar",
            dueDate: "20 August 2026",
            points: 25,
            totalStudents: 42,
            status: "Active",
            description: "Implement iterative and recursive binary search algorithms in C++/Java with comprehensive time and space complexity proofs.",
            instructions: "Upload solutions strictly in PDF format. Include boundary condition test cases.",
            submissions: [
                {
                    studentId: "STU001",
                    studentName: "Bhargavi",
                    rollNo: "22K91A0501",
                    department: "B.Tech CSE - Sec A",
                    status: "Submitted",
                    submittedAt: "19 Aug 2026, 04:30 PM",
                    fileName: "binary_search_22K91A0501.pdf",
                    fileSize: "1.4 MB",
                    score: "24/25",
                    grade: "A+",
                    feedback: "Clean recursive formulation with comprehensive edge cases analysis."
                },
                {
                    studentId: "STU002",
                    studentName: "Anjali Sharma",
                    rollNo: "22K91A0502",
                    department: "B.Tech CSE - Sec A",
                    status: "Submitted",
                    submittedAt: "19 Aug 2026, 11:15 AM",
                    fileName: "binary_search_22K91A0502.pdf",
                    fileSize: "2.1 MB",
                    score: "23/25",
                    grade: "A",
                    feedback: "Well-structured unit tests."
                },
                {
                    studentId: "STU004",
                    studentName: "Sneha Reddy",
                    rollNo: "22K91A0504",
                    department: "B.Tech CSE - Sec A",
                    status: "Submitted",
                    submittedAt: "20 Aug 2026, 09:20 AM",
                    fileName: "binary_search_22K91A0504.pdf",
                    fileSize: "1.8 MB",
                    score: "25/25",
                    grade: "O",
                    feedback: "Outstanding asymptotic proof and clean diagrams."
                },
                {
                    studentId: "STU005",
                    studentName: "Vikram Patel",
                    rollNo: "22K91A0505",
                    department: "B.Tech CSE - Sec A",
                    status: "Submitted",
                    submittedAt: "20 Aug 2026, 10:15 AM",
                    fileName: "binary_search_22K91A0505.pdf",
                    fileSize: "1.2 MB",
                    score: null,
                    grade: null,
                    feedback: null
                },
                {
                    studentId: "STU007",
                    studentName: "Priya Nair",
                    rollNo: "22K91A0507",
                    department: "B.Tech CSE - Sec A",
                    status: "Submitted",
                    submittedAt: "20 Aug 2026, 11:05 AM",
                    fileName: "binary_search_22K91A0507.pdf",
                    fileSize: "1.6 MB",
                    score: null,
                    grade: null,
                    feedback: null
                },
                {
                    studentId: "STU003",
                    studentName: "Rahul Varma",
                    rollNo: "22K91A0503",
                    department: "B.Tech CSE - Sec A",
                    status: "Pending",
                    submittedAt: null,
                    fileName: null,
                    fileSize: null,
                    score: null,
                    grade: null,
                    feedback: null
                },
                {
                    studentId: "STU006",
                    studentName: "Aditya Roy",
                    rollNo: "22K91A0506",
                    department: "B.Tech CSE - Sec A",
                    status: "Pending",
                    submittedAt: null,
                    fileName: null,
                    fileSize: null,
                    score: null,
                    grade: null,
                    feedback: null
                },
                {
                    studentId: "STU008",
                    studentName: "Karthik Raja",
                    rollNo: "22K91A0508",
                    department: "B.Tech CSE - Sec A",
                    status: "Pending",
                    submittedAt: null,
                    fileName: null,
                    fileSize: null,
                    score: null,
                    grade: null,
                    feedback: null
                }
            ]
        },
        {
            id: "ASG002",
            subject: "Machine Learning",
            code: "CS702PE",
            title: "ML Classification Report",
            faculty: "Prof. Priya Nair",
            dueDate: "22 August 2026",
            points: 30,
            totalStudents: 42,
            status: "Active",
            description: "Train and benchmark Decision Tree and Random Forest classifiers on the customer churn dataset.",
            instructions: "Submit comparative ROC-AUC graphs, confusion matrices and hyperparameter tuning analysis in PDF format.",
            submissions: [
                {
                    studentId: "STU001",
                    studentName: "Bhargavi",
                    rollNo: "22K91A0501",
                    department: "B.Tech CSE - Sec A",
                    status: "Submitted",
                    submittedAt: "21 Aug 2026, 05:40 PM",
                    fileName: "ml_classification_report_22K91A0501.pdf",
                    fileSize: "3.2 MB",
                    score: "29/30",
                    grade: "O",
                    feedback: "Impressive cross-validation methodology and ROC curve interpretation."
                },
                {
                    studentId: "STU002",
                    studentName: "Anjali Sharma",
                    rollNo: "22K91A0502",
                    department: "B.Tech CSE - Sec A",
                    status: "Submitted",
                    submittedAt: "21 Aug 2026, 07:15 PM",
                    fileName: "ml_classification_report_22K91A0502.pdf",
                    fileSize: "2.7 MB",
                    score: "27/30",
                    grade: "A+",
                    feedback: "Good feature selection discussion."
                },
                {
                    studentId: "STU003",
                    studentName: "Rahul Varma",
                    rollNo: "22K91A0503",
                    department: "B.Tech CSE - Sec A",
                    status: "Pending",
                    submittedAt: null,
                    fileName: null,
                    fileSize: null,
                    score: null,
                    grade: null,
                    feedback: null
                },
                {
                    studentId: "STU004",
                    studentName: "Sneha Reddy",
                    rollNo: "22K91A0504",
                    department: "B.Tech CSE - Sec A",
                    status: "Pending",
                    submittedAt: null,
                    fileName: null,
                    fileSize: null,
                    score: null,
                    grade: null,
                    feedback: null
                }
            ]
        },
        {
            id: "ASG003",
            subject: "Computer Networks",
            code: "CS701PC",
            title: "TCP/IP Protocol Analysis",
            faculty: "Dr. K. Srinivas Rao",
            dueDate: "25 August 2026",
            points: 25,
            totalStudents: 42,
            status: "Active",
            description: "Analyze Wireshark packet capture traces for three-way handshakes, TCP sequence numbers, and retransmissions.",
            instructions: "Include annotated Wireshark packet captures and sequence diagrams in PDF format.",
            submissions: [
                {
                    studentId: "STU002",
                    studentName: "Anjali Sharma",
                    rollNo: "22K91A0502",
                    department: "B.Tech CSE - Sec A",
                    status: "Submitted",
                    submittedAt: "23 Aug 2026, 03:20 PM",
                    fileName: "tcp_analysis_22K91A0502.pdf",
                    fileSize: "1.9 MB",
                    score: "23/25",
                    grade: "A",
                    feedback: "Good packet dissection."
                },
                {
                    studentId: "STU001",
                    studentName: "Bhargavi",
                    rollNo: "22K91A0501",
                    department: "B.Tech CSE - Sec A",
                    status: "Pending",
                    submittedAt: null,
                    fileName: null,
                    fileSize: null,
                    score: null,
                    grade: null,
                    feedback: null
                },
                {
                    studentId: "STU003",
                    studentName: "Rahul Varma",
                    rollNo: "22K91A0503",
                    department: "B.Tech CSE - Sec A",
                    status: "Pending",
                    submittedAt: null,
                    fileName: null,
                    fileSize: null,
                    score: null,
                    grade: null,
                    feedback: null
                }
            ]
        },
        {
            id: "ASG004",
            subject: "Software Engineering",
            code: "CS503PC",
            title: "Software Testing Case Study",
            faculty: "Prof. Ananya Roy",
            dueDate: "18 August 2026",
            points: 25,
            totalStudents: 42,
            status: "Completed",
            description: "Write unit and integration test suites using JUnit/PyTest for an e-commerce checkout module.",
            instructions: "Provide PDF report with JaCoCo / PyTest test coverage metrics and defect log.",
            submissions: [
                {
                    studentId: "STU001",
                    studentName: "Bhargavi",
                    rollNo: "22K91A0501",
                    department: "B.Tech CSE - Sec A",
                    status: "Submitted",
                    submittedAt: "17 Aug 2026, 09:30 PM",
                    fileName: "software_testing_case_study_22K91A0501.pdf",
                    fileSize: "2.4 MB",
                    score: "24/25",
                    grade: "A+",
                    feedback: "Exceptional test coverage (98%) and clear boundary value analysis."
                },
                {
                    studentId: "STU002",
                    studentName: "Anjali Sharma",
                    rollNo: "22K91A0502",
                    department: "B.Tech CSE - Sec A",
                    status: "Submitted",
                    submittedAt: "18 Aug 2026, 11:00 AM",
                    fileName: "testing_study_22K91A0502.pdf",
                    fileSize: "1.7 MB",
                    score: "22/25",
                    grade: "A",
                    feedback: "Good mocking strategies."
                }
            ]
        }
    ],
    facultyAttendanceList: [
        { id: "STU001", studentId: "STU001", name: "Bhargavi", studentName: "Bhargavi", rollNo: "22K91A0501", status: "Present", percentage: 85, attendance: 85, overallAttendance: 85, branch: "CSE-A" },
        { id: "STU002", studentId: "STU002", name: "Anjali", studentName: "Anjali", rollNo: "22K91A0502", status: "Present", percentage: 92, attendance: 92, overallAttendance: 92, branch: "CSE-A" },
        { id: "STU003", studentId: "STU003", name: "Rahul Sharma", studentName: "Rahul Sharma", rollNo: "22K91A0503", status: "Absent", percentage: 72, attendance: 72, overallAttendance: 72, branch: "CSE-A" },
        { id: "STU004", studentId: "STU004", name: "Sneha Reddy", studentName: "Sneha Reddy", rollNo: "22K91A0504", status: "Present", percentage: 88, attendance: 88, overallAttendance: 88, branch: "CSE-A" },
        { id: "STU005", studentId: "STU005", name: "Vikram Malhotra", studentName: "Vikram Malhotra", rollNo: "22K91A0505", status: "Present", percentage: 81, attendance: 81, overallAttendance: 81, branch: "CSE-A" },
        { id: "STU006", studentId: "STU006", name: "Aditya Roy", studentName: "Aditya Roy", rollNo: "22K91A0506", status: "Absent", percentage: 68, attendance: 68, overallAttendance: 68, branch: "CSE-A" },
        { id: "STU007", studentId: "STU007", name: "Priya Nair", studentName: "Priya Nair", rollNo: "22K91A0507", status: "Present", percentage: 95, attendance: 95, overallAttendance: 95, branch: "CSE-A" },
        { id: "STU008", studentId: "STU008", name: "Karthik Raja", studentName: "Karthik Raja", rollNo: "22K91A0508", status: "Present", percentage: 79, attendance: 79, overallAttendance: 79, branch: "CSE-A" }
    ],
    parent: {
        parentName: "Mr. Narayana Rao",
        studentName: "Bhargavi",
        studentId: "22K91A0501",
        attendance: 85,
        assignmentsPending: 3,
        upcomingExams: 2,
        feeReminder: "₹25,000 Pending",
        newAnnouncements: 4,
        rollNo: "22K91A0501",
        department: "CSE - 4th Year",
        overallAttendance: "85%",
        pendingFees: "₹25,000",
        recentGpa: "8.65",
        alerts: 2
    },
    parentFees: {
        studentName: "Bhargavi",
        studentId: "22K91A0501",
        department: "CSE - 4th Year",
        academicYear: "2025 - 2026",
        totalFee: 117500,
        paidFee: 92500,
        pendingFee: 25000,
        dueDate: "30 August 2026",
        status: "Pending",
        breakdown: [
            { feeType: "Academic Tuition Fee", totalAmount: 85000, paidAmount: 60000, dueAmount: 25000, dueDate: "30 August 2026", status: "Pending" },
            { feeType: "College Bus Transport", totalAmount: 25000, paidAmount: 25000, dueAmount: 0, dueDate: "15 July 2026", status: "Paid" },
            { feeType: "Examination Fee", totalAmount: 2500, paidAmount: 2500, dueAmount: 0, dueDate: "10 August 2026", status: "Paid" },
            { feeType: "Library & Lab Deposit", totalAmount: 5000, paidAmount: 5000, dueAmount: 0, dueDate: "01 June 2026", status: "Paid" }
        ]
    },
    fees: [
        { feeType: "Academic Tuition Fee", totalAmount: 85000, paidAmount: 60000, dueAmount: 25000, dueDate: "30 August 2026", status: "Pending" },
        { feeType: "College Bus Transport", totalAmount: 25000, paidAmount: 25000, dueAmount: 0, dueDate: "15 July 2026", status: "Paid" },
        { feeType: "Examination Fee", totalAmount: 2500, paidAmount: 2500, dueAmount: 0, dueDate: "10 August 2026", status: "Paid" },
        { feeType: "Library & Lab Deposit", totalAmount: 5000, paidAmount: 5000, dueAmount: 0, dueDate: "01 June 2026", status: "Paid" }
    ],
    adminSummary: {
        totalStudents: 1240,
        totalFaculty: 85,
        totalDepartments: 6,
        feeCollectionRate: "91%",
        activeExams: 3,
        systemAlerts: 1
    },
    adminStudents: [
        { id: "STU001", name: "Bhargavi", department: "CSE", year: "4th Year", email: "bhargavi@hitam.edu", attendance: "85%" },
        { id: "STU002", name: "Anjali", department: "CSE", year: "4th Year", email: "anjali@hitam.edu", attendance: "92%" },
        { id: "STU003", name: "Rahul", department: "CSE", year: "4th Year", email: "rahul@hitam.edu", attendance: "78%" },
        { id: "STU004", name: "Sneha", department: "CSE", year: "4th Year", email: "sneha@hitam.edu", attendance: "88%" }
    ],
    adminFaculty: [
        { id: "FAC001", name: "Dr. Ramesh", department: "CSE", designation: "HOD & Professor", email: "ramesh@hitam.edu", phone: "+91 9876543210" },
        { id: "FAC002", name: "Dr. Sharma", department: "ECE", designation: "Professor", email: "sharma@hitam.edu", phone: "+91 9876543211" },
        { id: "FAC003", name: "Prof. Priya", department: "CSE", designation: "Assistant Professor", email: "priya@hitam.edu", phone: "+91 9876543212" }
    ],
    announcements: [
        {
            id: 1,
            title: "Campus Placement Drive 2026",
            content: "TCS and Infosys recruitment registrations are now officially open for final year CSE & ECE students. Eligible candidates must complete company profile registration on the portal before Friday 5:00 PM.",
            message: "TCS and Infosys recruitment registrations are now officially open for final year CSE & ECE students. Eligible candidates must complete company profile registration on the portal before Friday 5:00 PM.",
            author: "Dr. Ramesh Kumar",
            role: "Placement Dean",
            category: "Placements",
            type: "Placements",
            priority: "urgent",
            isPinned: true,
            department: "Training & Placements",
            targetAudience: "Final Year B.Tech",
            refNo: "HITAM/TPO/2026/048",
            attachment: "TCS_Infosys_Drive_Eligibility_2026.pdf",
            date: "Today"
        },
        {
            id: 2,
            title: "Mid-Semester Examination Schedule (Odd Sem)",
            content: "Mid-Term Examinations for 3rd and 4th year B.Tech students will commence from 12th September 2026. Hall tickets and session timetables can be accessed from the examination tab.",
            message: "Mid-Term Examinations for 3rd and 4th year B.Tech students will commence from 12th September 2026. Hall tickets and session timetables can be accessed from the examination tab.",
            author: "Dr. Sharma",
            role: "Examination Cell",
            category: "Examinations",
            type: "Examinations",
            priority: "urgent",
            isPinned: true,
            department: "Controller of Examinations",
            targetAudience: "3rd & 4th Year B.Tech",
            refNo: "HITAM/EXAM/2026/102",
            attachment: "Mid_Term_Timetable_ODD_SEM.pdf",
            date: "Yesterday"
        },
        {
            id: 3,
            title: "Tuition Fee Payment Reminder & Concession Form",
            content: "Last date for odd semester academic fee payment without late penalty is 30th August. Merit-based fee concession applications are also available at the accounts office.",
            message: "Last date for odd semester academic fee payment without late penalty is 30th August. Merit-based fee concession applications are also available at the accounts office.",
            author: "Finance Dept",
            role: "Administration",
            category: "Finance",
            type: "Finance",
            priority: "normal",
            isPinned: false,
            department: "Accounts & Fees",
            targetAudience: "All Students & Parents",
            refNo: "HITAM/ACC/2026/031",
            attachment: "Fee_Structure_and_Payment_Challan.pdf",
            date: "3 days ago"
        },
        {
            id: 4,
            title: "Independence Day Celebrations & Holiday Notice",
            content: "The college campus will host the 80th Independence Day Flag Hoisting ceremony at 8:30 AM on 15th August. Academic classes will remain closed for the national holiday.",
            message: "The college campus will host the 80th Independence Day Flag Hoisting ceremony at 8:30 AM on 15th August. Academic classes will remain closed for the national holiday.",
            author: "Principal Office",
            role: "Administration",
            category: "Holiday",
            type: "Holiday",
            priority: "normal",
            isPinned: false,
            department: "Principal Office",
            targetAudience: "All Students, Staff & Faculty",
            refNo: "HITAM/GEN/2026/019",
            attachment: null,
            date: "5 days ago"
        }
    ],
    notifications: [
        // STUDENT NOTIFICATIONS (FROM FACULTY & ADMINISTRATION)
        {
            id: "NOTIF_STU_001",
            userId: "STU001",
            senderRole: "faculty",
            senderName: "Dr. K. Srinivas Rao (Faculty)",
            targetRole: "student",
            title: "Daily Attendance Recorded: Present",
            body: "Your attendance for Computer Networks was recorded as Present today. Semester aggregate: 85%.",
            type: "attendance",
            targetScreen: "attendance",
            priority: "normal",
            isRead: false,
            createdAt: new Date(Date.now() - 10 * 60 * 1000).toISOString(),
            timeAgo: "10 mins ago"
        },
        {
            id: "NOTIF_STU_002",
            userId: "STU001",
            senderRole: "faculty",
            senderName: "Dr. Ramesh Kumar (Faculty)",
            targetRole: "student",
            title: "Assignment Due in 24 Hours",
            body: "Perceptron Implementation in Neural Networks is due tomorrow at 11:59 PM. Please upload your code in PDF format.",
            type: "assignment",
            targetScreen: "assignments",
            priority: "urgent",
            isRead: false,
            createdAt: new Date(Date.now() - 35 * 60 * 1000).toISOString(),
            timeAgo: "35 mins ago"
        },
        {
            id: "NOTIF_STU_003",
            userId: "STU001",
            senderRole: "admin",
            senderName: "HITAM Accounts & Finance",
            targetRole: "student",
            title: "Tuition Fee Due Reminder: ₹25,000",
            body: "Second installment of odd semester tuition fee (₹25,000) is due by 30th September without late charges.",
            type: "fee",
            targetScreen: "fees",
            priority: "high",
            isRead: false,
            createdAt: new Date(Date.now() - 2 * 3600 * 1000).toISOString(),
            timeAgo: "2 hours ago"
        },
        {
            id: "NOTIF_STU_004",
            userId: "STU001",
            senderRole: "admin",
            senderName: "Examination Cell (HITAM)",
            targetRole: "student",
            title: "Semester 6 Mid-Term Hall Tickets Released",
            body: "Odd semester examination schedule is published. Verify your assigned room number and session timing.",
            type: "exam",
            targetScreen: "exams",
            priority: "high",
            isRead: true,
            createdAt: new Date(Date.now() - 24 * 3600 * 1000).toISOString(),
            timeAgo: "Yesterday"
        },

        // PARENT NOTIFICATIONS (FROM FACULTY & ADMINISTRATION)
        {
            id: "NOTIF_PAR_001",
            userId: "PAR001",
            senderRole: "faculty",
            senderName: "Dr. K. Srinivas Rao (Faculty Mentor)",
            targetRole: "parent",
            title: "Ward Daily Attendance: Present in All Classes",
            body: "Bhargavi (22K91A0501) was marked Present for all scheduled lectures today. Aggregate attendance: 85%.",
            type: "attendance",
            targetScreen: "attendance",
            priority: "normal",
            isRead: false,
            createdAt: new Date(Date.now() - 15 * 60 * 1000).toISOString(),
            timeAgo: "15 mins ago"
        },
        {
            id: "NOTIF_PAR_002",
            userId: "PAR001",
            senderRole: "admin",
            senderName: "HITAM Accounts & Administration",
            targetRole: "parent",
            title: "Fee Reminder: ₹25,000 Balance Pending",
            body: "Tuition installment of ₹25,000 for academic year 2025-2026 is due on 30th September. Pay online to avoid late fee.",
            type: "fee",
            targetScreen: "fees",
            priority: "urgent",
            isRead: false,
            createdAt: new Date(Date.now() - 45 * 60 * 1000).toISOString(),
            timeAgo: "45 mins ago"
        },
        {
            id: "NOTIF_PAR_003",
            userId: "PAR001",
            senderRole: "faculty",
            senderName: "Dr. Ramesh Kumar (Faculty)",
            targetRole: "parent",
            title: "Parent-Teacher Meeting (PTM) Scheduled",
            body: "Parent-Teacher Interaction session is scheduled for Saturday 20th September at 10:00 AM in the CSE Seminar Hall.",
            type: "announcement",
            targetScreen: "announcements",
            priority: "high",
            isRead: false,
            createdAt: new Date(Date.now() - 3 * 3600 * 1000).toISOString(),
            timeAgo: "3 hours ago"
        },
        {
            id: "NOTIF_PAR_004",
            userId: "PAR001",
            senderRole: "faculty",
            senderName: "Dr. Ramesh Kumar (Faculty)",
            targetRole: "parent",
            title: "Mid-Term Progress: 8.65 SGPA Achieved",
            body: "Bhargavi achieved 8.65 SGPA in the recently published Semester 6 university examination results.",
            type: "academic",
            targetScreen: "academic",
            priority: "normal",
            isRead: true,
            createdAt: new Date(Date.now() - 2 * 24 * 3600 * 1000).toISOString(),
            timeAgo: "2 days ago"
        },

        // BOTH STUDENTS & PARENTS (PUSHED BY FACULTY)
        {
            id: "NOTIF_STU_PAR_001",
            userId: null,
            senderRole: "faculty",
            senderName: "Dr. Ramesh Kumar (Faculty)",
            targetRole: "students_parents",
            title: "Project Milestone Review & Code Submission",
            body: "Final Capstone phase-1 demo scheduled for next Tuesday. Students must submit GitHub repos and review with mentors.",
            type: "assignment",
            targetScreen: "assignments",
            priority: "high",
            isRead: false,
            createdAt: new Date(Date.now() - 50 * 60 * 1000).toISOString(),
            timeAgo: "50 mins ago"
        },

        // FACULTY / TEACHER NOTIFICATIONS (FROM ADMINISTRATION & LMS)
        {
            id: "NOTIF_FAC_001",
            userId: "FAC001",
            senderRole: "system",
            senderName: "Academic LMS Portal",
            targetRole: "faculty",
            title: "35 Assignment Submissions Pending Review",
            body: "35 students submitted 'Perceptron Implementation' for Neural Networks. Grade submissions before Friday.",
            type: "assignment",
            targetScreen: "assignments",
            priority: "urgent",
            isRead: false,
            createdAt: new Date(Date.now() - 20 * 60 * 1000).toISOString(),
            timeAgo: "20 mins ago"
        },
        {
            id: "NOTIF_FAC_002",
            userId: "FAC001",
            senderRole: "system",
            senderName: "Attendance Portal",
            targetRole: "faculty",
            title: "Daily Attendance Lock Reminder",
            body: "Section-A attendance for CS603 Computer Networks has not been locked. Please lock roster before 4:30 PM.",
            type: "attendance",
            targetScreen: "attendance",
            priority: "high",
            isRead: false,
            createdAt: new Date(Date.now() - 60 * 60 * 1000).toISOString(),
            timeAgo: "1 hour ago"
        },
        {
            id: "NOTIF_FAC_003",
            userId: "FAC001",
            senderRole: "student",
            senderName: "Rahul Varma (Student)",
            targetRole: "faculty",
            title: "Student Medical Leave Request",
            body: "Rahul (22K91A0503) submitted a medical leave application for 3 days awaiting faculty mentor sign-off.",
            type: "system",
            targetScreen: "dashboard",
            priority: "normal",
            isRead: false,
            createdAt: new Date(Date.now() - 4 * 3600 * 1000).toISOString(),
            timeAgo: "4 hours ago"
        },
        {
            id: "NOTIF_FAC_004",
            userId: "FAC001",
            senderRole: "admin",
            senderName: "HITAM Academic Council",
            targetRole: "faculty",
            title: "Department Curriculum Council Meeting",
            body: "Board of Studies curriculum revision meeting tomorrow at 3:00 PM in Conference Hall A.",
            type: "announcement",
            targetScreen: "announcements",
            priority: "normal",
            isRead: true,
            createdAt: new Date(Date.now() - 24 * 3600 * 1000).toISOString(),
            timeAgo: "Yesterday"
        },

        // ADMINISTRATOR NOTIFICATIONS
        {
            id: "NOTIF_ADM_001",
            userId: "ADM001",
            senderRole: "system",
            senderName: "ERP Payment Gateway",
            targetRole: "admin",
            title: "Daily Tuition Fee Collection Summary",
            body: "₹4,85,000 received today in semester fee settlements. Campus collection milestone reached 82%.",
            type: "fee",
            targetScreen: "fees",
            priority: "high",
            isRead: false,
            createdAt: new Date(Date.now() - 30 * 60 * 1000).toISOString(),
            timeAgo: "30 mins ago"
        },
        {
            id: "NOTIF_ADM_002",
            userId: "ADM001",
            senderRole: "faculty",
            senderName: "Dean of Faculty Affairs",
            targetRole: "admin",
            title: "Staff Leave Applications Pending Review",
            body: "2 faculty leave applications from CSE and ECE departments are pending administrative approval.",
            type: "system",
            targetScreen: "dashboard",
            priority: "normal",
            isRead: false,
            createdAt: new Date(Date.now() - 2 * 3600 * 1000).toISOString(),
            timeAgo: "2 hours ago"
        },
        {
            id: "NOTIF_ADM_003",
            userId: "ADM001",
            senderRole: "system",
            senderName: "Campus IoT Controller",
            targetRole: "admin",
            title: "Biometric Campus Gate Sync Complete",
            body: "All 6 turnstile gate scanners and biometric terminals synced successfully with the central cloud ERP.",
            type: "system",
            targetScreen: "dashboard",
            priority: "normal",
            isRead: false,
            createdAt: new Date(Date.now() - 5 * 3600 * 1000).toISOString(),
            timeAgo: "5 hours ago"
        },
        {
            id: "NOTIF_ADM_004",
            userId: "ADM001",
            senderRole: "admin",
            senderName: "Office of the Principal",
            targetRole: "admin",
            title: "Symposium Circular Ready for Dispatch",
            body: "Annual National Technical Symposium circular has been reviewed and is ready for college broadcast.",
            type: "announcement",
            targetScreen: "announcements",
            priority: "urgent",
            isRead: true,
            createdAt: new Date(Date.now() - 24 * 3600 * 1000).toISOString(),
            timeAgo: "Yesterday"
        },

        // CAMPUS-WIDE BROADCAST BY ADMINISTRATION (RECEIVED BY STUDENTS, PARENTS & FACULTY)
        {
            id: "NOTIF_ALL_001",
            userId: null,
            senderRole: "admin",
            senderName: "HITAM Administration",
            targetRole: "all",
            title: "Campus Placement Registration Open",
            body: "TCS, Infosys & Wipro recruitment drives are open. Eligible final year candidates should register before Friday 5:00 PM.",
            type: "announcement",
            targetScreen: "announcements",
            priority: "high",
            isRead: false,
            createdAt: new Date(Date.now() - 6 * 3600 * 1000).toISOString(),
            timeAgo: "6 hours ago"
        }
    ],
    deviceTokens: []
};

module.exports = {
    supabase,
    isConfigured,
    mockDb
};
