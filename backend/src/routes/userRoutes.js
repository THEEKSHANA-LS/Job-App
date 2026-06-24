// routes/userRoutes.js

import express from "express";
import {
  getProfile,
  updateProfile,
  updateSkills,
  uploadCV,
} from "../controllers/userController.js";
import { protect } from "../middleware/authMiddleware.js";
import upload from "../middleware/uploadMiddleware.js";

const router = express.Router();

// GET  /api/users/profile      — get current user profile
router.get("/profile", protect, getProfile);

// PUT  /api/users/profile      — update name, phone
router.put("/profile", protect, updateProfile);

// PUT  /api/users/profile/skills — update skills array
router.put("/profile/skills", protect, updateSkills);

// POST /api/users/upload-cv    — upload CV file
router.post("/upload-cv", protect, upload.single("cv"), uploadCV);

export default router;