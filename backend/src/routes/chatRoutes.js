// src/routes/chatRoutes.js
// Replace your entire existing chatRoutes.js with this file

import express from "express";
import {
  startConversation,
  getMyConversations,
  getMessages,
} from "../controllers/chatController.js";
import { protect } from "../middleware/authMiddleware.js";

const router = express.Router();

router.post("/conversation", protect, startConversation);
router.get("/conversations", protect, getMyConversations);
router.get("/messages/:id", protect, getMessages);

export default router;