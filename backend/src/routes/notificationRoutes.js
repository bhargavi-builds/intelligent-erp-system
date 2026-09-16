const express = require("express");
const router = express.Router();
const notificationController = require("../controllers/notificationController");

// Feed & Unread count
router.get("/", notificationController.getNotifications);
router.get("/poll", notificationController.pollNotifications);

// Dispatch new notification (Admin / System / Faculty)
router.post("/", notificationController.sendNotification);
router.post("/send", notificationController.sendNotification);

// Register device FCM/APNs push token
router.post("/register-token", notificationController.registerDeviceToken);

// Mark as read
router.put("/:id/read", notificationController.markAsRead);
router.put("/read-all", notificationController.markAllAsRead);

module.exports = router;
