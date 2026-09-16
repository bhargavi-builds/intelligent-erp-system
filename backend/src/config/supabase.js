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
        { id: "FA001", subject: "Neural Networks", title: "Perceptron Implementation", dueDate: "20 August 2026", submissions: 35, totalStudents: 42, status: "Active" },
        { id: "FA002", subject: "Big Data", title: "Hadoop MapReduce Assignment", dueDate: "22 August 2026", submissions: 30, totalStudents: 42, status: "Active" },
        { id: "FA003", subject: "Computer Networks", title: "TCP/IP Model Report", dueDate: "25 August 2026", submissions: 28, totalStudents: 42, status: "Active" }
    ],
    facultyAttendanceList: [
        { studentId: "STU001", studentName: "Bhargavi", rollNo: "22K91A0501", status: "Present", percentage: 85 },
        { studentId: "STU002", studentName: "Anjali", rollNo: "22K91A0502", status: "Present", percentage: 92 },
        { studentId: "STU003", studentName: "Rahul", rollNo: "22K91A0503", status: "Absent", percentage: 78 },
        { studentId: "STU004", studentName: "Sneha", rollNo: "22K91A0504", status: "Present", percentage: 88 }
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
    ]
};

module.exports = {
    supabase,
    isConfigured,
    mockDb
};
