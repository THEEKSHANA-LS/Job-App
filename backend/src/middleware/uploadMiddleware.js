import multer from "multer";
import { CloudinaryStorage } from "multer-storage-cloudinary";
import cloudinary from "../config/cloudinary.js";

const storage = new CloudinaryStorage({
  cloudinary,
  params: {
    folder: "worklink_cvs",
    allowed_formats: ["pdf", "png", "jpg", "jpeg"],
  },
});

const upload = multer({ storage });

export default upload;