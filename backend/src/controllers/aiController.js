import User from "../models/User.js";
import Job from "../models/Job.js";
import { getJobRecommendations } from "../services/aiService.js";

export const recommendJobs = async (
  req,
  res
) => {
  try {
    const user = await User.findById(req.user._id);

    const jobs = await Job.find();

    const recommendations =
      await getJobRecommendations(
        user.skills,
        jobs
      );

    res.status(200).json({
      success: true,
      recommendations,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};