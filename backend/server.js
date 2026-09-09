const express = require("express");
const cors = require("cors");
require("dotenv").config();

const app = express();

app.use(cors());
app.use(express.json());

// HOME ROUTE
app.get("/", (req, res) => {
    res.json({
        message: "Intelligent ERP Backend is running!"
    });
});

// STUDENT API
app.get("/api/student", (req, res) => {
    res.json({
        id: "STU001",
        name: "Bhargavi",
        department: "CSE",
        year: "4th Year",
        attendance: 85,
        assignmentsPending: 3,
        upcomingExams: 2,
        newAnnouncements: 4
    });
});

// STUDENT ATTENDANCE API
app.get("/api/student/attendance", (req, res) => {
    res.json({
        studentId: "STU001",
        studentName: "Bhargavi",
        overallAttendance: 85,
        subjects: [
            {
                subject: "Data Structures",
                attended: 42,
                total: 48,
                percentage: 88
            },
            {
                subject: "Machine Learning",
                attended: 38,
                total: 45,
                percentage: 84
            },
            {
                subject: "Computer Networks",
                attended: 40,
                total: 46,
                percentage: 87
            },
            {
                subject: "Software Engineering",
                attended: 36,
                total: 44,
                percentage: 82
            }
        ]
    });
});


// STUDENT ASSIGNMENTS API
app.get("/api/student/assignments", (req, res) => {
    res.json([
        {
            id: "ASG001",
            title: "Binary Search Implementation",
            subject: "Data Structures",
            dueDate: "20 August 2026",
            status: "Pending"
        },
        {
            id: "ASG002",
            title: "ML Classification Report",
            subject: "Machine Learning",
            dueDate: "22 August 2026",
            status: "Pending"
        },
        {
            id: "ASG003",
            title: "TCP/IP Protocol Analysis",
            subject: "Computer Networks",
            dueDate: "25 August 2026",
            status: "Pending"
        },
        {
            id: "ASG004",
            title: "Software Testing Case Study",
            subject: "Software Engineering",
            dueDate: "18 August 2026",
            status: "Completed"
        }
    ]);
});




// FACULTY API
app.get("/api/faculty", (req, res) => {
    res.json({
        id: "FAC001",
        name: "Dr. Ramesh",
        department: "CSE",
        students: 42,
        attendanceManagement: "Manage",
        activeAssignments: 5,
        announcements: "Create",
        timetable: "View"
    });
});

// FACULTY STUDENTS API
app.get("/api/faculty/students", (req, res) => {
    res.json([
        {
            id: "STU001",
            name: "Bhargavi",
            attendance: 85,
            assignmentsPending: 3
        },
        {
            id: "STU002",
            name: "Anjali",
            attendance: 92,
            assignmentsPending: 1
        },
        {
            id: "STU003",
            name: "Rahul",
            attendance: 78,
            assignmentsPending: 4
        },
        {
            id: "STU004",
            name: "Sneha",
            attendance: 88,
            assignmentsPending: 2
        }
    ]);
});

// ============================================================
// FACULTY ASSIGNMENTS API
// ============================================================

app.get("/api/faculty/assignments", (req, res) => {
    res.json([
        {
            id: "FA001",
            subject: "Neural Networks",
            title: "Perceptron Implementation",
            dueDate: "20 August 2026",
            submissions: 35,
            totalStudents: 42,
            status: "Active"
        },
        {
            id: "FA002",
            subject: "Big Data",
            title: "Hadoop MapReduce Assignment",
            dueDate: "22 August 2026",
            submissions: 30,
            totalStudents: 42,
            status: "Active"
        },
        {
            id: "FA003",
            subject: "Computer Networks",
            title: "TCP/IP Model Report",
            dueDate: "25 August 2026",
            submissions: 28,
            totalStudents: 42,
            status: "Active"
        }
    ]);
});

// ============================================================
// FACULTY ASSIGNMENTS API
// ============================================================

app.get("/api/faculty/assignments", (req, res) => {
    res.json([
        {
            id: "FA001",
            subject: "Neural Networks",
            title: "Perceptron Implementation",
            dueDate: "20 August 2026",
            status: "Active"
        },
        {
            id: "FA002",
            subject: "Big Data",
            title: "Hadoop MapReduce Assignment",
            dueDate: "22 August 2026",
            status: "Active"
        },
        {
            id: "FA003",
            subject: "Computer Networks",
            title: "TCP/IP Model Report",
            dueDate: "25 August 2026",
            status: "Active"
        }
    ]);
});

// ============================================================
// FACULTY ATTENDANCE API
// ============================================================

app.get("/api/faculty/attendance", (req, res) => {
    res.json([
        {
            id: "STU001",
            name: "Bhargavi",
            attendance: 85
        },
        {
            id: "STU002",
            name: "Anjali",
            attendance: 92
        },
        {
            id: "STU003",
            name: "Rahul",
            attendance: 78
        },
        {
            id: "STU004",
            name: "Sneha",
            attendance: 88
        }
    ]);
});


// ============================================================
// FACULTY ANNOUNCEMENT API
// ============================================================

app.post("/api/faculty/announcements", (req, res) => {
    const { title, message, type } = req.body;

    res.json({
        success: true,
        message: "Announcement created successfully",
        announcement: {
            title: title,
            message: message,
            type: type,
            date: new Date().toLocaleDateString()
        }
    });
});
// PARENT API
app.get("/api/parent", (req, res) => {
    res.json({
        id: "PAR001",
        parentName: "Mr. Kumar",
        studentName: "Bhargavi",
        studentId: "STU001",
        attendance: 85,
        assignmentsPending: 3,
        upcomingExams: 2,
        feeReminder: "Due",
        newAnnouncements: 4
    });
});

// STUDENT ASSIGNMENTS API
app.get("/api/student/assignments", (req, res) => {
    res.json([
        {
            id: "ASG001",
            title: "Machine Learning Assignment",
            subject: "Machine Learning",
            dueDate: "20 August 2026",
            status: "Pending"
        },
        {
            id: "ASG002",
            title: "Network Programming Assignment",
            subject: "Computer Networks",
            dueDate: "23 August 2026",
            status: "Pending"
        },
        {
            id: "ASG003",
            title: "Software Engineering Report",
            subject: "Software Engineering",
            dueDate: "28 August 2026",
            status: "Submitted"
        },
        {
            id: "ASG004",
            title: "Big Data Practical",
            subject: "Big Data",
            dueDate: "30 August 2026",
            status: "Pending"
        }
    ]);
});

// STUDENT EXAMS API
app.get("/api/student/exams", (req, res) => {
    res.json([
        {
            id: "EXM001",
            subject: "Machine Learning",
            date: "25 August 2026",
            time: "10:00 AM",
            venue: "Block A - Room 101"
        },
        {
            id: "EXM002",
            subject: "Computer Networks",
            date: "28 August 2026",
            time: "10:00 AM",
            venue: "Block B - Room 204"
        },
        {
            id: "EXM003",
            subject: "Big Data",
            date: "2 September 2026",
            time: "2:00 PM",
            venue: "Block A - Room 103"
        }
    ]);
});

// STUDENT RESULTS API
app.get("/api/student/results", (req, res) => {
    res.json({
        studentName: "Bhargavi",
        semester: "3-2",
        cgpa: 7.5,
        results: [
            {
                subject: "Machine Learning",
                marks: 85,
                grade: "A"
            },
            {
                subject: "Computer Networks",
                marks: 78,
                grade: "B+"
            },
            {
                subject: "Big Data",
                marks: 82,
                grade: "A"
            },
            {
                subject: "Compiler Design",
                marks: 88,
                grade: "A+"
            }
        ]
    });
});

// ============================================================
// ADMIN - CREATE ANNOUNCEMENT API
// ============================================================

app.post("/api/admin/announcements", (req, res) => {

    const { title, message, type } = req.body;

    const newAnnouncement = {
        id: "ANN" + String(announcements.length + 1).padStart(3, "0"),
        title: title,
        message: message,
        type: type,
        date: new Date().toLocaleDateString()
    };

    announcements.push(newAnnouncement);

    res.json({
        success: true,
        message: "Announcement created successfully",
        announcement: newAnnouncement
    });
});
// ============================================================
// ANNOUNCEMENTS DATA
// ============================================================

let announcements = [
    {
        id: "ANN001",
        title: "Internal Examination Schedule",
        message: "Internal examinations will begin from 28 August 2026.",
        date: "20 August 2026",
        type: "Exam"
    },
    {
        id: "ANN002",
        title: "Assignment Submission Reminder",
        message: "Students are requested to submit pending assignments before the due date.",
        date: "21 August 2026",
        type: "Assignment"
    },
    {
        id: "ANN003",
        title: "Attendance Notice",
        message: "Students with attendance below 75% should contact their faculty advisor.",
        date: "22 August 2026",
        type: "Academic"
    },
    {
        id: "ANN004",
        title: "College Announcement",
        message: "The college will remain closed on the upcoming public holiday.",
        date: "23 August 2026",
        type: "General"
    }
];

// GET ALL ANNOUNCEMENTS
app.get("/api/announcements", (req, res) => {
    res.json(announcements);
});



// PARENT FEE API
app.get("/api/parent/fees", (req, res) => {
    res.json({
        studentName: "Bhargavi",
        totalFee: 50000,
        paidFee: 35000,
        pendingFee: 15000,
        dueDate: "30-08-2026",
        status: "Pending"
    });
});


// ============================================================
// ADMIN DASHBOARD SUMMARY API
// ============================================================

app.get("/api/admin/summary", (req, res) => {

    res.json({
        students: 1250,
        faculty: 85,
        announcements: announcements.length,
        timetable: "Manage",
        reports: "View Reports"
    });

});
// ============================================================
// ADMIN - STUDENT MANAGEMENT API
// ============================================================

app.get("/api/admin/students", (req, res) => {
    res.json([
        {
            id: "STU001",
            name: "Bhargavi",
            department: "CSE",
            year: "4th Year",
            email: "bhargavi@example.com",
            attendance: 85,
            status: "Active"
        },
        {
            id: "STU002",
            name: "Anjali",
            department: "CSE",
            year: "4th Year",
            email: "anjali@example.com",
            attendance: 92,
            status: "Active"
        },
        {
            id: "STU003",
            name: "Rahul",
            department: "ECE",
            year: "3rd Year",
            email: "rahul@example.com",
            attendance: 78,
            status: "Active"
        },
        {
            id: "STU004",
            name: "Sneha",
            department: "IT",
            year: "4th Year",
            email: "sneha@example.com",
            attendance: 88,
            status: "Active"
        },
        {
            id: "STU005",
            name: "Kiran",
            department: "CSE",
            year: "3rd Year",
            email: "kiran@example.com",
            attendance: 81,
            status: "Active"
        }
    ]);
});

// ============================================================
// ADMIN - ADD STUDENT API
// ============================================================

app.post("/api/admin/students", (req, res) => {

    const {
        id,
        name,
        department,
        year,
        email
    } = req.body;

    const newStudent = {
        id: id,
        name: name,
        department: department,
        year: year,
        email: email,
        attendance: 0,
        status: "Active"
    };

    // Demo response
    res.json({
        success: true,
        message: "Student added successfully",
        student: newStudent
    });
});


// ============================================================
// ADMIN - DELETE STUDENT API
// ============================================================

app.delete("/api/admin/students/:id", (req, res) => {

    const studentId = req.params.id;

    res.json({
        success: true,
        message: "Student deleted successfully",
        studentId: studentId
    });
});

// ADMIN - FACULTY MANAGEMENT API
app.get("/api/admin/faculty", (req, res) => {
    res.json([
        {
            id: "FAC001",
            name: "Dr. Ramesh",
            department: "CSE",
            email: "ramesh@example.com",
            students: 42,
            status: "Active"
        },
        {
            id: "FAC002",
            name: "Dr. Priya",
            department: "CSE",
            email: "priya@example.com",
            students: 38,
            status: "Active"
        },
        {
            id: "FAC003",
            name: "Dr. Suresh",
            department: "ECE",
            email: "suresh@example.com",
            students: 35,
            status: "Active"
        },
        {
            id: "FAC004",
            name: "Dr. Kavitha",
            department: "IT",
            email: "kavitha@example.com",
            students: 40,
            status: "Active"
        },
        {
            id: "FAC005",
            name: "Dr. Arun",
            department: "MECH",
            email: "arun@example.com",
            students: 30,
            status: "Active"
        }
    ]);
});


const PORT = 5050;

app.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`);
});
