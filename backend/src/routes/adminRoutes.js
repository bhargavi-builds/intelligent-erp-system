const express = require("express");
const router = express.Router();
const adminController = require("../controllers/adminController");

router.get("/summary", adminController.getAdminSummary);
router.get("/students", adminController.getAdminStudents);
router.post("/students", adminController.addAdminStudent);
router.delete("/students/:id", adminController.deleteAdminStudent);
router.get("/faculty", adminController.getAdminFaculty);
router.post("/announcements", adminController.createAdminAnnouncement);

module.exports = router;
