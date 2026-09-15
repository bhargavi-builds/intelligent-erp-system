const express = require("express");
const router = express.Router();
const facultyController = require("../controllers/facultyController");

router.get("/", facultyController.getFacultyOverview);
router.get("/students", facultyController.getFacultyStudents);
router.get("/assignments", facultyController.getFacultyAssignments);
router.get("/attendance", facultyController.getFacultyAttendance);
router.post("/announcements", facultyController.createFacultyAnnouncement);

module.exports = router;
