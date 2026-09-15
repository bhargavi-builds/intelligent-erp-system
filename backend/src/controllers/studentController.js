const { supabase, isConfigured, mockDb } = require("../config/supabase");

// 1. Student Dashboard Summary
exports.getStudentOverview = async (req, res) => {
    try {
        if (isConfigured && supabase) {
            const { data, error } = await supabase
                .from("students")
                .select("id, name, department, year, overall_attendance, assignments_pending, upcoming_exams, new_announcements")
                .eq("id", "STU001")
                .single();

            if (data && !error) {
                return res.json({
                    id: data.id,
                    name: data.name,
                    department: data.department,
                    year: data.year,
                    attendance: data.overall_attendance,
                    assignmentsPending: data.assignments_pending,
                    upcomingExams: data.upcoming_exams,
                    newAnnouncements: data.new_announcements
                });
            }
        }
        return res.json(mockDb.student);
    } catch (err) {
        console.error("Error in getStudentOverview:", err);
        return res.json(mockDb.student);
    }
};

// 2. Student Attendance Breakdown
exports.getStudentAttendance = async (req, res) => {
    try {
        if (isConfigured && supabase) {
            const { data, error } = await supabase
                .from("attendance_subjects")
                .select("subject, attended, total, percentage")
                .eq("student_id", "STU001");

            if (data && !error && data.length > 0) {
                const total = data.reduce((sum, s) => sum + Number(s.total || 0), 0);
                const attended = data.reduce((sum, s) => sum + Number(s.attended || 0), 0);
                const overall = total > 0 ? Math.round((attended / total) * 100) : 85;

                return res.json({
                    studentId: "22K91A0501",
                    studentName: "Bhargavi",
                    department: "CSE - 4th Year",
                    semester: "Semester 7",
                    overallAttendance: overall,
                    totalClasses: total,
                    attendedClasses: attended,
                    marginClasses: Math.max(0, Math.floor(attended - (0.75 * total))),
                    subjects: data
                });
            }
        }
        return res.json(mockDb.attendance);
    } catch (err) {
        console.error("Error in getStudentAttendance:", err);
        return res.json(mockDb.attendance);
    }
};

// 3. Student Assignments
exports.getStudentAssignments = async (req, res) => {
    try {
        if (isConfigured && supabase) {
            const { data, error } = await supabase
                .from("assignments")
                .select("id, title, subject, due_date, status");

            if (data && !error && data.length > 0) {
                return res.json(data.map(a => ({
                    id: a.id,
                    title: a.title,
                    subject: a.subject,
                    dueDate: a.due_date,
                    status: a.status
                })));
            }
        }
        return res.json(mockDb.assignments);
    } catch (err) {
        console.error("Error in getStudentAssignments:", err);
        return res.json(mockDb.assignments);
    }
};

// 4. Student Exams
exports.getStudentExams = async (req, res) => {
    try {
        if (isConfigured && supabase) {
            const { data, error } = await supabase
                .from("exams")
                .select("id, subject, exam_date, exam_time, room, exam_type");

            if (data && !error && data.length > 0) {
                return res.json(data.map(e => ({
                    id: e.id,
                    subject: e.subject,
                    date: e.exam_date,
                    time: e.exam_time,
                    room: e.room,
                    type: e.exam_type
                })));
            }
        }
        return res.json(mockDb.exams);
    } catch (err) {
        console.error("Error in getStudentExams:", err);
        return res.json(mockDb.exams);
    }
};

// 5. Student Results
exports.getStudentResults = async (req, res) => {
    try {
        if (isConfigured && supabase) {
            const { data: resultsData, error: resultsError } = await supabase
                .from("results")
                .select("id, semester, gpa, cgpa")
                .eq("student_id", "STU001")
                .single();

            if (resultsData && !resultsError) {
                const { data: subjectsData } = await supabase
                    .from("result_subjects")
                    .select("code, name, grade, credits, status")
                    .eq("result_id", resultsData.id);

                return res.json([{
                    semester: resultsData.semester,
                    gpa: Number(resultsData.gpa),
                    cgpa: Number(resultsData.cgpa),
                    subjects: subjectsData || []
                }]);
            }
        }
        return res.json(mockDb.results);
    } catch (err) {
        console.error("Error in getStudentResults:", err);
        return res.json(mockDb.results);
    }
};
