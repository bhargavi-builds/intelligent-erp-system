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
        studentId: "STU001",
        studentName: "Bhargavi",
        overallAttendance: 85,
        subjects: [
            { subject: "Data Structures", attended: 42, total: 48, percentage: 88 },
            { subject: "Machine Learning", attended: 38, total: 45, percentage: 84 },
            { subject: "Computer Networks", attended: 40, total: 46, percentage: 87 },
            { subject: "Software Engineering", attended: 36, total: 44, percentage: 82 }
        ]
    },
    assignments: [
        { id: "ASG001", title: "Binary Search Implementation", subject: "Data Structures", dueDate: "20 August 2026", status: "Pending" },
        { id: "ASG002", title: "ML Classification Report", subject: "Machine Learning", dueDate: "22 August 2026", status: "Pending" },
        { id: "ASG003", title: "TCP/IP Protocol Analysis", subject: "Computer Networks", dueDate: "25 August 2026", status: "Pending" },
        { id: "ASG004", title: "Software Testing Case Study", subject: "Software Engineering", dueDate: "18 August 2026", status: "Completed" }
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
        { id: 1, title: "Campus Placement Drive 2026", content: "TCS and Infosys recruitment registrations are now open for final year CSE students.", author: "Dr. Ramesh", role: "Faculty", date: "Today" },
        { id: 2, title: "Independence Day Holiday Notice", content: "College will remain closed on 15th August on the occasion of Independence Day.", author: "Admin Office", role: "Admin", date: "Yesterday" },
        { id: 3, title: "Mid-Semester Examination Schedule", content: "Mid-Term Examinations for 3rd and 4th year B.Tech students commence from 12th September.", author: "Examination Cell", role: "Admin", date: "3 days ago" },
        { id: 4, title: "Fee Payment Reminder", content: "Last date for tuition fee payment for odd semester without late fee is 30th August.", author: "Accounts Dept", role: "Admin", date: "5 days ago" }
    ]
};

module.exports = {
    supabase,
    isConfigured,
    mockDb
};
