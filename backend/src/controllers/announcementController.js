const { supabase, isConfigured, mockDb } = require("../config/supabase");

// Get Shared Announcements Feed
exports.getAnnouncements = async (req, res) => {
    try {
        if (isConfigured && supabase) {
            const { data, error } = await supabase
                .from("announcements")
                .select("id, title, content, author_name, author_role, created_at")
                .order("created_at", { ascending: false });

            if (data && !error && data.length > 0) {
                return res.json(data.map(a => ({
                    id: a.id,
                    title: a.title,
                    content: a.content,
                    author: a.author_name,
                    role: a.author_role,
                    date: new Date(a.created_at).toLocaleDateString("en-IN", { day: "numeric", month: "short", year: "numeric" })
                })));
            }
        }
        return res.json(mockDb.announcements);
    } catch (err) {
        console.error("Error in getAnnouncements:", err);
        return res.json(mockDb.announcements);
    }
};
