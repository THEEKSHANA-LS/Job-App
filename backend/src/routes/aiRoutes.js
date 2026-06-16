import express from "express";

import { recommendJobs } from "../controllers/aiController.js";

import { protect } from "../middleware/authMiddleware.js";
import { authorize } from "../middleware/roleMiddleware.js";

const router = express.Router();

router.get(
  "/recommendations",
  protect,
  authorize("jobseeker"),
  recommendJobs
);

export default router;