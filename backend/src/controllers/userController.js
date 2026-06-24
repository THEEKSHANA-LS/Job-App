// controllers/userController.js

import User from "../models/User.js";
import cloudinary from "../config/cloudinary.js";

/**
 * GET /api/users/profile — get current user
 */
export const getProfile = async (req, res) => {
  try {
    const user = await User.findById(req.user._id).select("-password");
    if (!user) {
      return res.status(404).json({ success: false, message: "User not found" });
    }
    res.status(200).json({ success: true, data: user });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

/**
 * PUT /api/users/profile — update name, phone
 */
export const updateProfile = async (req, res) => {
  try {
    const { name, phone } = req.body;

    const user = await User.findById(req.user._id);
    if (!user) {
      return res.status(404).json({ success: false, message: "User not found" });
    }

    if (name)  user.name  = name.trim();
    if (phone !== undefined) user.phone = phone.trim();

    await user.save();

    // Return without password
    const updated = await User.findById(user._id).select("-password");

    res.status(200).json({
      success: true,
      message: "Profile updated successfully",
      data: updated,
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

/**
 * PUT /api/users/profile/skills — update skills array
 */
export const updateSkills = async (req, res) => {
  try {
    const { skills } = req.body;

    if (!Array.isArray(skills)) {
      return res.status(400).json({ success: false, message: "Skills must be an array" });
    }

    const user = await User.findById(req.user._id);
    if (!user) {
      return res.status(404).json({ success: false, message: "User not found" });
    }

    // Deduplicate & trim
    user.skills = [...new Set(skills.map((s) => s.trim()).filter(Boolean))];
    await user.save();

    const updated = await User.findById(user._id).select("-password");

    res.status(200).json({
      success: true,
      message: "Skills updated successfully",
      data: updated,
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

/**
 * POST /api/users/upload-cv — upload CV via Cloudinary
 */
export const uploadCV = async (req, res) => {
  try {
    const user = await User.findById(req.user._id);
    if (!user) {
      return res.status(404).json({ success: false, message: "User not found" });
    }

    if (!req.file) {
      return res.status(400).json({ success: false, message: "No file uploaded" });
    }

    user.cvUrl = req.file.path; // Cloudinary URL

    await user.save();

    res.status(200).json({
      success: true,
      message: "CV uploaded successfully",
      data: user.cvUrl,
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};