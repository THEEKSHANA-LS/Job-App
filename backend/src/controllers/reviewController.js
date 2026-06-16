import Review from "../models/Review.js";

/**
 * Create review
 */
export const createReview = async (req, res) => {
  try {
    const { employerId, rating, comment } = req.body;

    const existingReview = await Review.findOne({
      reviewer: req.user._id,
      employer: employerId,
    });

    if (existingReview) {
      return res.status(400).json({
        success: false,
        message: "You have already reviewed this employer",
      });
    }

    const review = await Review.create({
      reviewer: req.user._id,
      employer: employerId,
      rating,
      comment,
    });

    res.status(201).json({
      success: true,
      message: "Review created successfully",
      data: review,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

/**
 * Get reviews of an employer
 */
export const getEmployerReviews = async (req, res) => {
  try {
    const reviews = await Review.find({
      employer: req.params.id,
    }).populate("reviewer", "name profileImage");

    res.status(200).json({
      success: true,
      count: reviews.length,
      data: reviews,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

/**
 * Delete review
 */
export const deleteReview = async (req, res) => {
  try {
    const review = await Review.findById(req.params.id);

    if (!review) {
      return res.status(404).json({
        success: false,
        message: "Review not found",
      });
    }

    if (review.reviewer.toString() !== req.user._id.toString()) {
      return res.status(403).json({
        success: false,
        message: "Unauthorized",
      });
    }

    await review.deleteOne();

    res.status(200).json({
      success: true,
      message: "Review deleted successfully",
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};