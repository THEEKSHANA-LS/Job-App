import express from "express";

import {
  saveJob,
  getSavedJobs,
  removeSavedJob,
} from "../controllers/savedJobController.js";

import { protect } from "../middleware/authMiddleware.js";
import { authorize } from "../middleware/roleMiddleware.js";

const router = express.Router();

router.post(
  "/",
  protect,
  authorize("jobseeker"),
  saveJob
);

router.get(
  "/",
  protect,
  authorize("jobseeker"),
  getSavedJobs
);

router.delete(
  "/:id",
  protect,
  authorize("jobseeker"),
  removeSavedJob
);

export default router;