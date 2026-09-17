const { supabase, isConfigured, mockDb } = require("../config/supabase");

function deduceCategory(title = "", department = "") {
    const t = (title + " " + department).toLowerCase();
    if (t.includes("placement") || t.includes("recruitment") || t.includes("job") || t.includes("internship")) return "Placements";
    if (t.includes("exam") || t.includes("mid") || t.includes("timetable") || t.includes("hall ticket")) return "Examinations";
    if (t.includes("fee") || t.includes("payment") || t.includes("challan") || t.includes("dues")) return "Finance";
    if (t.includes("holiday") || t.includes("closed") || t.includes("independence") || t.includes("republic")) return "Holiday";
    if (t.includes("workshop") || t.includes("fest") || t.includes("conference") || t.includes("hackathon") || t.includes("event")) return "Events";
    return "Academic";
}

function deducePriority(title = "", category = "") {
    const t = (title + " " + category).toLowerCase();
    if (t.includes("urgent") || t.includes("exam") || t.includes("placement") || t.includes("last date")) return "urgent";
    return "normal";
}

// Get Shared Announcements Feed
exports.getAnnouncements = async (req, res) => {
    try {
        if (isConfigured && supabase) {
            const { data, error } = await supabase
                .from("announcements")
                .select("*")
                .order("created_at", { ascending: false });

            if (data && !error && data.length > 0) {
                return res.json(data.map(a => {
                    const category = a.department && ["Placements", "Examinations", "Finance", "Holiday", "Events"].includes(a.department)
                        ? a.department
                        : deduceCategory(a.title, a.department);
                    const priority = a.is_pinned ? "urgent" : deducePriority(a.title, category);
                    const contentStr = a.content || a.message || "Official college notice. Please check with your department coordinator or campus notice board for additional instructions.";

                    return {
                        id: a.id,
                        title: a.title || "Campus Notice",
                        content: contentStr,
                        message: contentStr, // Guarantee non-null message for older/legacy screens
                        author: a.author_name || "HITAM Administration",
                        role: a.author_role || "Official",
                        department: a.department || "Academic Affairs",
                        targetAudience: a.target_audience || "All Students",
                        category: category,
                        type: category, // Guarantee non-null type for legacy screens
                        priority: priority,
                        isPinned: priority === "urgent" || Boolean(a.is_pinned),
                        refNo: `HITAM/CIR/2026/0${a.id}`,
                        attachment: category === "Placements"
                            ? "Placement_Drive_Guidelines_2026.pdf"
                            : category === "Examinations"
                            ? "Semester_Examination_Notice.pdf"
                            : null,
                        date: a.created_at
                            ? new Date(a.created_at).toLocaleDateString("en-IN", { day: "numeric", month: "short", year: "numeric" })
                            : "Recent"
                    };
                }));
            }
        }

        // Return normalized mockDb.announcements
        const normalized = mockDb.announcements.map(a => ({
            ...a,
            message: a.message || a.content || "",
            type: a.type || a.category || "General",
            refNo: a.refNo || `HITAM/CIR/2026/0${a.id}`
        }));

        return res.json(normalized);
    } catch (err) {
        console.error("Error in getAnnouncements:", err);
        return res.json(mockDb.announcements);
    }
};

// Create Shared Announcement (Admin or Faculty)
exports.createAnnouncement = async (req, res) => {
    try {
        const { title, content, message, category, type, author, role, department, targetAudience } = req.body;
        if (!title) {
            return res.status(400).json({ error: "Announcement title is required" });
        }

        const bodyContent = content || message || "";
        const bodyCategory = category || type || deduceCategory(title, department);
        const authorName = author || "HITAM Administration";
        const authorRole = role || "Admin";

        if (isConfigured && supabase) {
            const { data, error } = await supabase
                .from("announcements")
                .insert([{
                    title,
                    content: bodyContent,
                    author_name: authorName,
                    author_role: authorRole,
                    target_audience: targetAudience || "All Students",
                    department: department || bodyCategory
                }])
                .select()
                .single();

            if (!error && data) {
                return res.status(201).json({
                    message: "Announcement broadcasted successfully to campus!",
                    announcement: data
                });
            }
        }

        const newAnn = {
            id: mockDb.announcements.length + 1,
            title,
            content: bodyContent,
            message: bodyContent,
            author: authorName,
            role: authorRole,
            category: bodyCategory,
            type: bodyCategory,
            priority: deducePriority(title, bodyCategory),
            isPinned: false,
            department: department || "General",
            targetAudience: targetAudience || "All Students",
            refNo: `HITAM/CIR/2026/0${mockDb.announcements.length + 1}`,
            attachment: null,
            date: "Just now"
        };
        mockDb.announcements.unshift(newAnn);

        // Also push a real-time notification to campus (Students, Parents, Faculty)
        if (mockDb.notifications) {
            const audLower = (targetAudience || "All").toLowerCase();
            let notifTarget = "all";
            if (audLower.includes("student") && !audLower.includes("parent") && !audLower.includes("all")) notifTarget = "student";
            else if (audLower.includes("parent") && !audLower.includes("student")) notifTarget = "parent";
            else if (audLower.includes("faculty")) notifTarget = "faculty";

            mockDb.notifications.unshift({
                id: `NOTIF_${Date.now()}_ADM_ANN`,
                userId: null,
                targetRole: notifTarget,
                senderRole: "admin",
                senderName: authorName || "HITAM Administration",
                type: "announcement",
                targetScreen: "announcements",
                priority: deducePriority(title, bodyCategory),
                title: `College Circular: ${title}`,
                body: bodyContent || `Official notice from ${authorName || "Administration"}.`,
                createdAt: new Date().toISOString(),
                timeAgo: "Just now",
                isRead: false
            });
        }

        return res.status(201).json({
            message: "Announcement broadcasted successfully!",
            announcement: newAnn
        });
    } catch (err) {
        console.error("Error in createAnnouncement:", err);
        return res.status(500).json({ error: "Failed to broadcast announcement" });
    }
};
