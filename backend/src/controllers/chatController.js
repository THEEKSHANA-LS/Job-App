// src/controllers/chatController.js
// Replace your entire existing chatController.js with this file

import Conversation from "../models/Conversation.js";
import Message from "../models/Message.js";

/**
 * POST /api/chat/conversation
 * Start (or get existing) conversation between current user and receiverId
 */
export const startConversation = async (req, res) => {
  try {
    const { receiverId } = req.body;

    let conversation = await Conversation.findOne({
      participants: { $all: [req.user._id, receiverId] },
    }).populate("participants", "name email profileImage role");

    if (!conversation) {
      conversation = await Conversation.create({
        participants: [req.user._id, receiverId],
      });
      conversation = await Conversation.findById(conversation._id)
        .populate("participants", "name email profileImage role");
    }

    res.status(200).json({ success: true, data: conversation });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

/**
 * GET /api/chat/conversations
 * List all conversations for the logged-in user, with last message preview
 */
export const getMyConversations = async (req, res) => {
  try {
    const conversations = await Conversation.find({
      participants: req.user._id,
    })
      .populate("participants", "name email profileImage role")
      .sort({ updatedAt: -1 });

    // Attach last message to each conversation
    const withLastMessage = await Promise.all(
      conversations.map(async (conv) => {
        const lastMsg = await Message.findOne({ conversation: conv._id })
          .sort({ createdAt: -1 })
          .select("text sender createdAt");

        return {
          ...conv.toObject(),
          lastMessage: lastMsg ? lastMsg.text : null,
          lastMessageAt: lastMsg ? lastMsg.createdAt : conv.createdAt,
        };
      })
    );

    res.status(200).json({ success: true, count: withLastMessage.length, data: withLastMessage });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

/**
 * GET /api/chat/messages/:id
 */
export const getMessages = async (req, res) => {
  try {
    const messages = await Message.find({
      conversation: req.params.id,
    })
      .populate("sender", "name")
      .sort({ createdAt: 1 });

    res.status(200).json({ success: true, count: messages.length, data: messages });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};