const express = require("express");
const router = express.Router();
const announcementController = require("../controllers/announcementController");

router.get("/", announcementController.getAnnouncements);
router.post("/", announcementController.createAnnouncement);

module.exports = router;
