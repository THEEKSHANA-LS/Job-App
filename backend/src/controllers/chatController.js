import Conversation from "../models/Conversation.js";
import Message from "../models/Message.js";

/**
 * Start conversation
 */
export const startConversation = async (req, res) => {
  try {
    const { receiverId } = req.body;

    let conversation = await Conversation.findOne({
      participants: {
        $all: [req.user._id, receiverId],
      },
    });

    if (!conversation) {
      conversation = await Conversation.create({
        participants: [req.user._id, receiverId],
      });
    }

    res.status(200).json({
      success: true,
      data: conversation,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

/**
 * Get messages
 */
export const getMessages = async (req, res) => {
  try {
    const messages = await Message.find({
      conversation: req.params.id,
    }).populate("sender", "name");

    res.status(200).json({
      success: true,
      count: messages.length,
      data: messages,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};