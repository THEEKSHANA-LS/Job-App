import express from "express";

import {
  startConversation,
  getMessages,
} from "../controllers/chatController.js";

import { protect } from "../middleware/authMiddleware.js";

const router = express.Router();

router.post(
  "/conversation",
  protect,
  startConversation
);

router.get(
  "/messages/:id",
  protect,
  getMessages
);

export default router;