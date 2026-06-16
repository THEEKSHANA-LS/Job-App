import User from "../models/User.js";

/**
 * Upload CV
 */
export const uploadCV = async (req, res) => {
  try {
    const user = await User.findById(req.user._id);

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    user.cvUrl = req.file.path; // Cloudinary URL

    await user.save();

    res.status(200).json({
      success: true,
      message: "CV uploaded successfully",
      data: user.cvUrl,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};