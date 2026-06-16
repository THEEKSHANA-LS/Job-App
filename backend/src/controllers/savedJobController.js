import SavedJob from "../models/SavedJob.js";
import Job from "../models/Job.js";

/**
 * Save a job
 */
export const saveJob = async (req, res) => {
  try {
    const { jobId } = req.body;

    const job = await Job.findById(jobId);

    if (!job) {
      return res.status(404).json({
        success: false,
        message: "Job not found",
      });
    }

    const alreadySaved = await SavedJob.findOne({
      user: req.user._id,
      job: jobId,
    });

    if (alreadySaved) {
      return res.status(400).json({
        success: false,
        message: "Job already saved",
      });
    }

    const savedJob = await SavedJob.create({
      user: req.user._id,
      job: jobId,
    });

    res.status(201).json({
      success: true,
      message: "Job saved successfully",
      data: savedJob,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

/**
 * Get all saved jobs
 */
export const getSavedJobs = async (req, res) => {
  try {
    const savedJobs = await SavedJob.find({
      user: req.user._id,
    }).populate("job");

    res.status(200).json({
      success: true,
      count: savedJobs.length,
      data: savedJobs,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

/**
 * Remove saved job
 */
export const removeSavedJob = async (req, res) => {
  try {
    const savedJob = await SavedJob.findById(req.params.id);

    if (!savedJob) {
      return res.status(404).json({
        success: false,
        message: "Saved job not found",
      });
    }

    if (savedJob.user.toString() !== req.user._id.toString()) {
      return res.status(403).json({
        success: false,
        message: "Unauthorized",
      });
    }

    await savedJob.deleteOne();

    res.status(200).json({
      success: true,
      message: "Saved job removed",
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};