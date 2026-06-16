import express from "express";

import {
  createJob,
  getAllJobs,
  getJobById,
  updateJob,
  deleteJob,
} from "../controllers/jobController.js";

import { protect } from "../middleware/authMiddleware.js";
import { authorize } from "../middleware/roleMiddleware.js";

const router = express.Router();

// Public Routes
router.get("/", getAllJobs);
router.get("/:id", getJobById);

// Admin/Employer-only routes
router.post(
  "/",
  protect,
  authorize("employer", "admin"),
  createJob
);

router.put(
  "/:id",
  protect,
  authorize("employer", "admin"),
  updateJob
);

router.delete(
  "/:id",
  protect,
  authorize("employer", "admin"),
  deleteJob
);

export default router;