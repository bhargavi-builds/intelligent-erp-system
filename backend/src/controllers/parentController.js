const { supabase, isConfigured, mockDb } = require("../config/supabase");

// 1. Parent Dashboard Overview
exports.getParentOverview = async (req, res) => {
    try {
        if (isConfigured && supabase) {
            const { data: student, error } = await supabase
                .from("students")
                .select("name, roll_no, department, year, overall_attendance")
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
                    studentName: student.name,
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
            const { data, error } = await supabase
                .from("fees")
                .select("fee_type, total_amount, paid_amount, due_amount, due_date, status")
                .eq("student_id", "STU001");

            if (data && !error && data.length > 0) {
                return res.json(data.map(f => ({
                    feeType: f.fee_type,
                    totalAmount: Number(f.total_amount),
                    paidAmount: Number(f.paid_amount),
                    dueAmount: Number(f.due_amount),
                    dueDate: f.due_date,
                    status: f.status
                })));
            }
        }
        return res.json(mockDb.fees);
    } catch (err) {
        console.error("Error in getParentFees:", err);
        return res.json(mockDb.fees);
    }
};
