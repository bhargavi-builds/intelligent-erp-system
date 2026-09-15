const express = require("express");
const router = express.Router();
const parentController = require("../controllers/parentController");

router.get("/", parentController.getParentOverview);
router.get("/fees", parentController.getParentFees);

module.exports = router;
