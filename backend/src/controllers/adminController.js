const { supabase, isConfigured, mockDb } = require("../config/supabase");

// 1. Admin Summary Stats
exports.getAdminSummary = async (req, res) => {
    try {
        if (isConfigured && supabase) {
            const { count: studentCount } = await supabase.from("students").select("*", { count: "exact", head: true });
            const { count: facultyCount } = await supabase.from("faculty").select("*", { count: "exact", head: true });
            const { count: deptCount } = await supabase.from("departments").select("*", { count: "exact", head: true });

            return res.json({
                totalStudents: studentCount || mockDb.adminSummary.totalStudents,
                totalFaculty: facultyCount || mockDb.adminSummary.totalFaculty,
                totalDepartments: deptCount || mockDb.adminSummary.totalDepartments,
                feeCollectionRate: "91%",
                activeExams: 3,
                systemAlerts: 1
            });
        }
        return res.json(mockDb.adminSummary);
    } catch (err) {
        console.error("Error in getAdminSummary:", err);
        return res.json(mockDb.adminSummary);
    }
};

// 2. Admin Students List
exports.getAdminStudents = async (req, res) => {
    try {
        if (isConfigured && supabase) {
            const { data, error } = await supabase
                .from("students")
                .select("id, name, department, year, parent_email, overall_attendance");

            if (data && !error && data.length > 0) {
                return res.json(data.map(s => ({
                    id: s.id,
                    name: s.name,
                    department: s.department,
                    year: s.year,
                    email: s.parent_email || `${s.name.toLowerCase()}@hitam.edu`,
                    attendance: `${s.overall_attendance}%`
                })));
            }
        }
        return res.json(mockDb.adminStudents);
    } catch (err) {
        console.error("Error in getAdminStudents:", err);
        return res.json(mockDb.adminStudents);
    }
};

// 3. Add Student by Admin
exports.addAdminStudent = async (req, res) => {
    try {
        const { id, name, department, year, email, attendance } = req.body;
        if (!id || !name) {
            return res.status(400).json({ error: "Student ID and Name are required" });
        }

        const attendanceNum = parseInt(attendance) || 85;

        if (isConfigured && supabase) {
            const { data, error } = await supabase
                .from("students")
                .insert([{
                    id,
                    name,
                    department: department || "CSE",
                    year: year || "1st Year",
                    parent_email: email || `${id.toLowerCase()}@hitam.edu`,
                    overall_attendance: attendanceNum
                }])
                .select()
                .single();

            if (!error && data) {
                return res.status(201).json({
                    message: "Student added successfully in Supabase!",
                    student: data
                });
            }
        }

        // Mock Fallback
        const newStudent = {
            id,
            name,
            department: department || "CSE",
            year: year || "1st Year",
            email: email || `${id.toLowerCase()}@hitam.edu`,
            attendance: `${attendanceNum}%`
        };
        mockDb.adminStudents.push(newStudent);

        return res.status(201).json({
            message: "Student added successfully!",
            student: newStudent
        });
    } catch (err) {
        console.error("Error in addAdminStudent:", err);
        return res.status(500).json({ error: "Failed to add student" });
    }
};

// 4. Delete Student
exports.deleteAdminStudent = async (req, res) => {
    try {
        const { id } = req.params;
        if (!id) {
            return res.status(400).json({ error: "Student ID is required" });
        }

        if (isConfigured && supabase) {
            const { error } = await supabase
                .from("students")
                .delete()
                .eq("id", id);

            if (!error) {
                return res.json({ message: `Student ${id} deleted successfully from Supabase.` });
            }
        }

        // Mock Fallback
        mockDb.adminStudents = mockDb.adminStudents.filter(s => s.id !== id);
        return res.json({ message: `Student ${id} deleted successfully.` });
    } catch (err) {
        console.error("Error in deleteAdminStudent:", err);
        return res.status(500).json({ error: "Failed to delete student" });
    }
};

// 5. Admin Faculty List
exports.getAdminFaculty = async (req, res) => {
    try {
        if (isConfigured && supabase) {
            const { data, error } = await supabase
                .from("faculty")
                .select("id, name, department, designation");

            if (data && !error && data.length > 0) {
                return res.json(data.map(f => ({
                    id: f.id,
                    name: f.name,
                    department: f.department,
                    designation: f.designation,
                    email: `${f.name.toLowerCase().replace(/[^a-z]/g, "")}@hitam.edu`,
                    phone: "+91 9876543210"
                })));
            }
        }
        return res.json(mockDb.adminFaculty);
    } catch (err) {
        console.error("Error in getAdminFaculty:", err);
        return res.json(mockDb.adminFaculty);
    }
};

// 6. Broadcast Announcement by Admin
exports.createAdminAnnouncement = async (req, res) => {
    try {
        const { title, targetAudience, department } = req.body;
        const bodyContent = req.body.content || req.body.message || "";
        const bodyCategory = req.body.type || req.body.category || department || "Administration";

        if (!title) {
            return res.status(400).json({ error: "Title is required" });
        }

        if (isConfigured && supabase) {
            const { data, error } = await supabase
                .from("announcements")
                .insert([{
                    title,
                    content: bodyContent,
                    author_name: "Administration",
                    author_role: "Admin",
                    target_audience: targetAudience || "All",
                    department: department || bodyCategory
                }])
                .select()
                .single();

            if (!error && data) {
                return res.status(201).json({
                    message: "Announcement broadcasted successfully in Supabase!",
                    announcement: data
                });
            }
        }

        // Mock Fallback
        const newAnn = {
            id: mockDb.announcements.length + 1,
            title,
            content: bodyContent,
            message: bodyContent,
            author: "Administration",
            role: "Admin",
            category: bodyCategory,
            type: bodyCategory,
            priority: "normal",
            isPinned: false,
            department: department || "All",
            targetAudience: targetAudience || "All",
            refNo: `HITAM/ADM/2026/0${mockDb.announcements.length + 1}`,
            attachment: null,
            date: "Just now"
        };
        mockDb.announcements.unshift(newAnn);

        return res.status(201).json({
            message: "Announcement broadcasted successfully!",
            announcement: newAnn
        });
    } catch (err) {
        console.error("Error in createAdminAnnouncement:", err);
        return res.status(500).json({ error: "Failed to broadcast announcement" });
    }
};
