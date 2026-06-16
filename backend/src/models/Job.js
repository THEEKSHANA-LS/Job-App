import mongoose from "mongoose";

const jobSchema = new mongoose.Schema(
  {
    title: {
      type: String,
      required: true,
      trim: true,
    },

    description: {
      type: String,
      required: true,
    },

    category: {
      type: String,
      required: true,
      enum: [
        "delivery",
        "retail",
        "cashier",
        "tutor",
        "it",
        "design",
        "writing",
        "other",
      ],
    },

    jobType: {
      type: String,
      enum: ["part-time", "full-time", "freelance", "one-day"],
      default: "part-time",
    },

    salary: {
      type: Number,
      required: true,
    },

    location: {
      type: String,
      required: true,
    },

    employer: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },

    isActive: {
      type: Boolean,
      default: true,
    },
  },
  { timestamps: true }
);

const Job = mongoose.model("Job", jobSchema);

export default Job;