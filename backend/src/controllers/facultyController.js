const { supabase, isConfigured, mockDb } = require("../config/supabase");

// 1. Faculty Dashboard Overview
exports.getFacultyOverview = async (req, res) => {
    try {
        if (isConfigured && supabase) {
            const { data, error } = await supabase
                .from("faculty")
                .select("id, name, department, students_count, active_assignments, designation")
                .eq("id", "FAC001")
                .single();

            if (data && !error) {
                return res.json({
                    id: data.id,
                    name: data.name,
                    department: data.department,
                    students: data.students_count,
                    attendanceManagement: "Manage",
                    activeAssignments: data.active_assignments,
                    announcements: "Create",
                    timetable: "View"
                });
            }
        }
        return res.json(mockDb.faculty);
    } catch (err) {
        console.error("Error in getFacultyOverview:", err);
        return res.json(mockDb.faculty);
    }
};

// 2. Faculty Students List
exports.getFacultyStudents = async (req, res) => {
    try {
        if (isConfigured && supabase) {
            const { data, error } = await supabase
                .from("students")
                .select("id, name, overall_attendance, assignments_pending");

            if (data && !error && data.length > 0) {
                return res.json(data.map(s => ({
                    id: s.id,
                    name: s.name,
                    attendance: s.overall_attendance,
                    assignmentsPending: s.assignments_pending
                })));
            }
        }
        return res.json(mockDb.facultyStudents);
    } catch (err) {
        console.error("Error in getFacultyStudents:", err);
        return res.json(mockDb.facultyStudents);
    }
};

// 3. Faculty Assignments
exports.getFacultyAssignments = async (req, res) => {
    try {
        if (isConfigured && supabase) {
            const { data, error } = await supabase
                .from("assignments")
                .select("id, subject, title, due_date, submissions, total_students, status");

            if (data && !error && data.length > 0) {
                return res.json(data.map(a => ({
                    id: a.id,
                    subject: a.subject,
                    title: a.title,
                    dueDate: a.due_date,
                    submissions: a.submissions || 30,
                    totalStudents: a.total_students || 42,
                    status: a.status
                })));
            }
        }
        return res.json(mockDb.facultyAssignments);
    } catch (err) {
        console.error("Error in getFacultyAssignments:", err);
        return res.json(mockDb.facultyAssignments);
    }
};

// 4. Faculty Attendance Roster
exports.getFacultyAttendance = async (req, res) => {
    try {
        if (isConfigured && supabase) {
            const { data, error } = await supabase
                .from("faculty_attendance")
                .select("student_id, student_name, attendance, assignments_pending")
                .eq("faculty_id", "FAC001");

            if (data && !error && data.length > 0) {
                return res.json(data.map(item => ({
                    studentId: item.student_id,
                    studentName: item.student_name,
                    rollNo: "22K91A0501",
                    status: item.attendance >= 80 ? "Present" : "Absent",
                    percentage: item.attendance
                })));
            }
        }
        return res.json(mockDb.facultyAttendanceList);
    } catch (err) {
        console.error("Error in getFacultyAttendance:", err);
        return res.json(mockDb.facultyAttendanceList);
    }
};

// 5. Create Announcement from Faculty
exports.createFacultyAnnouncement = async (req, res) => {
    try {
        const { title, department, targetAudience } = req.body;
        const bodyContent = req.body.content || req.body.message || "";
        const bodyCategory = req.body.type || req.body.category || department || "General";

        if (!title) {
            return res.status(400).json({ error: "Title is required" });
        }

        if (isConfigured && supabase) {
            const { data, error } = await supabase
                .from("announcements")
                .insert([{
                    title,
                    content: bodyContent,
                    author_name: "Dr. Ramesh",
                    author_role: "Faculty",
                    target_audience: targetAudience || "Students",
                    department: department || bodyCategory
                }])
                .select()
                .single();

            if (!error && data) {
                return res.status(201).json({
                    message: "Announcement created successfully in Supabase!",
                    announcement: data
                });
            }
        }

        // Fallback save to memory
        const newAnn = {
            id: mockDb.announcements.length + 1,
            title,
            content: bodyContent,
            message: bodyContent,
            author: "Dr. Ramesh",
            role: "Faculty",
            category: bodyCategory,
            type: bodyCategory,
            priority: "normal",
            isPinned: false,
            department: department || "CSE",
            targetAudience: targetAudience || "Students",
            refNo: `HITAM/FAC/2026/0${mockDb.announcements.length + 1}`,
            attachment: null,
            date: "Just now"
        };
        mockDb.announcements.unshift(newAnn);

        return res.status(201).json({
            message: "Announcement created successfully!",
            announcement: newAnn
        });
    } catch (err) {
        console.error("Error in createFacultyAnnouncement:", err);
        return res.status(500).json({ error: "Failed to create announcement" });
    }
};
