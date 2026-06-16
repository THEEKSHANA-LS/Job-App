import express from "express";

import {
  createReview,
  getEmployerReviews,
  deleteReview,
} from "../controllers/reviewController.js";

import { protect } from "../middleware/authMiddleware.js";
import { authorize } from "../middleware/roleMiddleware.js";

const router = express.Router();

router.post(
  "/",
  protect,
  authorize("jobseeker"),
  createReview
);

router.get(
  "/employer/:id",
  getEmployerReviews
);

router.delete(
  "/:id",
  protect,
  authorize("jobseeker"),
  deleteReview
);

export default router;