const { supabase, isConfigured, mockDb } = require("../config/supabase");

// Helper to compute human-friendly relative time
function getRelativeTime(dateStr) {
    try {
        const diffMs = Date.now() - new Date(dateStr).getTime();
        const diffMins = Math.floor(diffMs / (60 * 1000));
        if (diffMins < 1) return "Just now";
        if (diffMins < 60) return `${diffMins} mins ago`;
        const diffHours = Math.floor(diffMins / 60);
        if (diffHours < 24) return `${diffHours} hours ago`;
        const diffDays = Math.floor(diffHours / 24);
        if (diffDays === 1) return "Yesterday";
        if (diffDays < 7) return `${diffDays} days ago`;
        return new Date(dateStr).toLocaleDateString("en-IN", { day: "numeric", month: "short" });
    } catch {
        return "Recent";
    }
}

// 1. GET Notifications Feed
exports.getNotifications = async (req, res) => {
    try {
        const userId = req.query.userId || "STU001";
        const type = req.query.type;

        if (isConfigured && supabase) {
            let query = supabase
                .from("notifications")
                .select("*")
                .or(`user_id.eq.${userId},user_id.is.null`)
                .order("created_at", { ascending: false });

            if (type && type !== "All") {
                query = query.eq("type", type.toLowerCase());
            }

            const { data, error } = await query;
            if (data && !error && data.length > 0) {
                const list = data.map(n => ({
                    id: n.id.toString(),
                    userId: n.user_id,
                    title: n.title,
                    body: n.body || n.message || "",
                    type: n.type || "general",
                    targetScreen: n.target_screen || n.type || "dashboard",
                    priority: n.priority || "normal",
                    isRead: Boolean(n.is_read),
                    createdAt: n.created_at,
                    timeAgo: getRelativeTime(n.created_at)
                }));

                const unreadCount = list.filter(n => !n.isRead).length;
                return res.json({
                    notifications: list,
                    unreadCount,
                    total: list.length
                });
            }
        }

        // Fallback to in-memory store
        let list = [...mockDb.notifications];
        if (type && type !== "All") {
            list = list.filter(n => n.type.toLowerCase() === type.toLowerCase());
        }

        const unreadCount = list.filter(n => !n.isRead).length;
        return res.json({
            notifications: list,
            unreadCount,
            total: list.length
        });
    } catch (err) {
        console.error("Error in getNotifications:", err);
        return res.json({
            notifications: mockDb.notifications,
            unreadCount: mockDb.notifications.filter(n => !n.isRead).length,
            total: mockDb.notifications.length
        });
    }
};

// 2. SEND Notification (Broadcast or Targeted)
exports.sendNotification = async (req, res) => {
    try {
        const { title, body, message, type, targetScreen, priority, userId } = req.body;

        if (!title) {
            return res.status(400).json({ error: "Notification title is required" });
        }

        const notificationContent = body || message || "You have a new campus notification.";
        const notifType = (type || "general").toLowerCase();
        const screen = targetScreen || notifType;
        const notifPriority = priority || "normal";
        const targetUserId = userId || "STU001";
        const now = new Date().toISOString();

        if (isConfigured && supabase) {
            const { data, error } = await supabase
                .from("notifications")
                .insert([{
                    user_id: targetUserId,
                    title,
                    body: notificationContent,
                    type: notifType,
                    target_screen: screen,
                    priority: notifPriority,
                    is_read: false,
                    created_at: now
                }])
                .select()
                .single();

            if (!error && data) {
                return res.status(201).json({
                    message: "Notification sent and dispatched!",
                    notification: {
                        id: data.id.toString(),
                        userId: data.user_id,
                        title: data.title,
                        body: data.body,
                        type: data.type,
                        targetScreen: data.target_screen,
                        priority: data.priority,
                        isRead: data.is_read,
                        createdAt: data.created_at,
                        timeAgo: "Just now"
                    },
                    pushStatus: "queued_for_background_delivery"
                });
            }
        }

        // Mock in-memory storage
        const newNotif = {
            id: `NOTIF${String(mockDb.notifications.length + 1).padStart(3, "0")}`,
            userId: targetUserId,
            title,
            body: notificationContent,
            type: notifType,
            targetScreen: screen,
            priority: notifPriority,
            isRead: false,
            createdAt: now,
            timeAgo: "Just now"
        };
        mockDb.notifications.unshift(newNotif);

        return res.status(201).json({
            message: "Notification sent successfully!",
            notification: newNotif,
            pushStatus: "queued_for_background_delivery"
        });
    } catch (err) {
        console.error("Error in sendNotification:", err);
        return res.status(500).json({ error: "Failed to dispatch notification" });
    }
};

// 3. REGISTER Device Push Token (FCM / APNs)
exports.registerDeviceToken = async (req, res) => {
    try {
        const { userId, token, platform } = req.body;

        if (!token) {
            return res.status(400).json({ error: "Device push token is required" });
        }

        const now = new Date().toISOString();
        const clientUserId = userId || "STU001";
        const clientPlatform = platform || "android";

        if (isConfigured && supabase) {
            const { error } = await supabase
                .from("device_tokens")
                .upsert(
                    { user_id: clientUserId, token, platform: clientPlatform, updated_at: now },
                    { onConflict: "token" }
                );

            if (!error) {
                return res.json({
                    message: "Device token registered successfully in Supabase!",
                    token,
                    platform: clientPlatform
                });
            }
        }

        // Mock fallback
        const existingIdx = mockDb.deviceTokens.findIndex(d => d.token === token);
        if (existingIdx >= 0) {
            mockDb.deviceTokens[existingIdx].lastActive = now;
        } else {
            mockDb.deviceTokens.push({
                userId: clientUserId,
                token,
                platform: clientPlatform,
                lastActive: now
            });
        }

        return res.json({
            message: "Device token registered successfully!",
            token,
            platform: clientPlatform
        });
    } catch (err) {
        console.error("Error in registerDeviceToken:", err);
        return res.status(500).json({ error: "Failed to register device token" });
    }
};

// 4. MARK Notification As Read
exports.markAsRead = async (req, res) => {
    try {
        const notifId = req.params.id;

        if (isConfigured && supabase) {
            await supabase
                .from("notifications")
                .update({ is_read: true })
                .eq("id", notifId);
        }

        const found = mockDb.notifications.find(n => n.id.toString() === notifId.toString());
        if (found) {
            found.isRead = true;
        }

        return res.json({ message: "Notification marked as read", id: notifId });
    } catch (err) {
        console.error("Error in markAsRead:", err);
        return res.status(500).json({ error: "Failed to update notification" });
    }
};

// 5. MARK ALL Notifications As Read
exports.markAllAsRead = async (req, res) => {
    try {
        const userId = req.body.userId || "STU001";

        if (isConfigured && supabase) {
            await supabase
                .from("notifications")
                .update({ is_read: true })
                .or(`user_id.eq.${userId},user_id.is.null`);
        }

        mockDb.notifications.forEach(n => {
            if (!n.userId || n.userId === userId) {
                n.isRead = true;
            }
        });

        return res.json({ message: "All notifications marked as read" });
    } catch (err) {
        console.error("Error in markAllAsRead:", err);
        return res.status(500).json({ error: "Failed to mark all as read" });
    }
};
