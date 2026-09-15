const { supabase, isConfigured, mockDb } = require("../config/supabase");

// 1. Parent Dashboard Overview
exports.getParentOverview = async (req, res) => {
    try {
        if (isConfigured && supabase) {
            const { data: student, error } = await supabase
                .from("students")
                .select("name, roll_no, department, year, overall_attendance, assignments_pending, upcoming_exams, new_announcements")
                .eq("id", "STU001")
                .single();

            const { data: feesData } = await supabase
                .from("fees")
                .select("due_amount")
                .eq("student_id", "STU001")
                .eq("status", "Pending");

            const totalDue = (feesData || []).reduce((sum, item) => sum + Number(item.due_amount || 0), 0);

            if (student && !error) {
                return res.json({
                    parentName: "Mr. Narayana Rao",
                    studentName: student.name || "Bhargavi",
                    studentId: student.roll_no || "22K91A0501",
                    attendance: Number(student.overall_attendance || 85),
                    assignmentsPending: Number(student.assignments_pending || 3),
                    upcomingExams: Number(student.upcoming_exams || 2),
                    feeReminder: `₹${totalDue.toLocaleString("en-IN")} Pending`,
                    newAnnouncements: Number(student.new_announcements || 4),
                    // Compatibility aliases
                    rollNo: student.roll_no || "22K91A0501",
                    department: `${student.department} - ${student.year}`,
                    overallAttendance: `${student.overall_attendance}%`,
                    pendingFees: `₹${totalDue.toLocaleString("en-IN")}`,
                    recentGpa: "8.65",
                    alerts: 2
                });
            }
        }
        return res.json(mockDb.parent);
    } catch (err) {
        console.error("Error in getParentOverview:", err);
        return res.json(mockDb.parent);
    }
};

// 2. Parent Fee Details
exports.getParentFees = async (req, res) => {
    try {
        if (isConfigured && supabase) {
            const { data: student } = await supabase
                .from("students")
                .select("name")
                .eq("id", "STU001")
                .single();

            const { data: feesList, error } = await supabase
                .from("fees")
                .select("fee_type, total_amount, paid_amount, due_amount, due_date, status")
                .eq("student_id", "STU001");

            if (feesList && !error && feesList.length > 0) {
                const total = feesList.reduce((sum, f) => sum + Number(f.total_amount || 0), 0);
                const paid = feesList.reduce((sum, f) => sum + Number(f.paid_amount || 0), 0);
                const pending = feesList.reduce((sum, f) => sum + Number(f.due_amount || 0), 0);
                const pendingItem = feesList.find(f => f.status === "Pending") || feesList[0];

                return res.json({
                    studentName: student?.name || "Bhargavi",
                    studentId: student?.roll_no || "22K91A0501",
                    department: student?.department ? `${student.department} - ${student.year || '4th Year'}` : "CSE - 4th Year",
                    academicYear: "2025 - 2026",
                    totalFee: Math.round(total),
                    paidFee: Math.round(paid),
                    pendingFee: Math.round(pending),
                    dueDate: pendingItem?.due_date || "30 August 2026",
                    status: pending > 0 ? "Pending" : "Paid",
                    breakdown: feesList.map(f => ({
                        feeType: f.fee_type,
                        totalAmount: Number(f.total_amount),
                        paidAmount: Number(f.paid_amount),
                        dueAmount: Number(f.due_amount),
                        dueDate: f.due_date,
                        status: f.status
                    }))
                });
            }
        }
        return res.json(mockDb.parentFees);
    } catch (err) {
        console.error("Error in getParentFees:", err);
        return res.json(mockDb.parentFees);
    }
};
