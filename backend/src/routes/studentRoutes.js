const express = require("express");
const router = express.Router();
const studentController = require("../controllers/studentController");

router.get("/", studentController.getStudentOverview);
router.get("/overview", studentController.getStudentOverview);
router.get("/attendance", studentController.getStudentAttendance);
router.get("/assignments", studentController.getStudentAssignments);
router.post("/assignments/submit", studentController.submitStudentAssignment);
router.get("/exams", studentController.getStudentExams);
router.get("/results", studentController.getStudentResults);

module.exports = router;
