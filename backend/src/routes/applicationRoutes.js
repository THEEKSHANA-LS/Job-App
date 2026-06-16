import express from "express";

import {
  applyForJob,
  getMyApplications,
  withdrawApplication,
  getApplicantsForJob,
  updateApplicationStatus
} from "../controllers/applicationController.js";

import { protect } from "../middleware/authMiddleware.js";
import { authorize } from "../middleware/roleMiddleware.js";

const router = express.Router();

router.post(
  "/",
  protect,
  authorize("jobseeker"),
  applyForJob
);

router.get(
  "/my-applications",
  protect,
  authorize("jobseeker"),
  getMyApplications
);

router.delete(
  "/:id",
  protect,
  authorize("jobseeker"),
  withdrawApplication
);

// Employer routes

router.get(
  "/job/:jobId",
  protect,
  authorize("employer"),
  getApplicantsForJob
);

router.put(
  "/:id/status",
  protect,
  authorize("employer"),
  updateApplicationStatus
);

export default router;