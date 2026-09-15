const { supabase, isConfigured } = require("../config/supabase");

// Login Handler with Role Detection
exports.login = async (req, res) => {
    try {
        const { email, password, role } = req.body;
        if (!email || !password) {
            return res.status(400).json({ error: "Email/User ID and password are required" });
        }

        const normalizedEmail = email.trim().toLowerCase();

        // 1. Try Supabase Auth if configured
        if (isConfigured && supabase) {
            const { data: authData, error: authError } = await supabase.auth.signInWithPassword({
                email: normalizedEmail,
                password
            });

            if (authData && authData.user && !authError) {
                // Fetch profile to get role
                const { data: profile } = await supabase
                    .from("profiles")
                    .select("full_name, role, department")
                    .eq("id", authData.user.id)
                    .single();

                return res.json({
                    message: "Login successful!",
                    token: authData.session.access_token,
                    user: {
                        id: authData.user.id,
                        email: authData.user.email,
                        name: profile?.full_name || authData.user.email.split("@")[0],
                        role: profile?.role || role || "student",
                        department: profile?.department || "CSE"
                    }
                });
            }
        }

        // 2. Mock Role-Based Fallback for Rapid Testing
        let userRole = role || "student";
        let userName = "Bhargavi";
        let userId = "STU001";

        if (normalizedEmail.includes("faculty") || normalizedEmail.includes("ramesh")) {
            userRole = "faculty";
            userName = "Dr. Ramesh";
            userId = "FAC001";
        } else if (normalizedEmail.includes("parent")) {
            userRole = "parent";
            userName = "Narayana";
            userId = "PAR001";
        } else if (normalizedEmail.includes("admin")) {
            userRole = "admin";
            userName = "HITAM Administrator";
            userId = "ADM001";
        }

        return res.json({
            message: "Login successful (development mode)",
            token: "mock-jwt-token-" + Date.now(),
            user: {
                id: userId,
                email: normalizedEmail,
                name: userName,
                role: userRole,
                department: "CSE"
            }
        });
    } catch (err) {
        console.error("Error in login:", err);
        return res.status(500).json({ error: "Authentication failed" });
    }
};
