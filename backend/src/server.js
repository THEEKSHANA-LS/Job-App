// src/server.js
// Replace your entire existing server.js with this file

import dotenv from "dotenv";
dotenv.config();

import app from "./app.js";
import connectDB from "./config/db.js";
import Conversation from "./models/Conversation.js";
import Message from "./models/Message.js";

import { createServer } from "http";
import { Server } from "socket.io";

connectDB();

const httpServer = createServer(app);

const io = new Server(httpServer, {
  cors: { origin: "*" },
});

io.on("connection", (socket) => {
  console.log("✅ User connected:", socket.id);

  // Join chat room
  socket.on("join_room", (roomId) => {
    socket.join(roomId);
    console.log(`User joined room: ${roomId}`);
  });

  // Send message — now persists to DB before broadcasting
  socket.on("send_message", async (data) => {
    try {
      const { senderId, receiverId, message } = data;

      // Consistent room ID
      const roomId = [senderId, receiverId].sort().join("_");

      // Find or create the conversation between these two users
      let conversation = await Conversation.findOne({
        participants: { $all: [senderId, receiverId] },
      });

      if (!conversation) {
        conversation = await Conversation.create({
          participants: [senderId, receiverId],
        });
      }

      // Persist the message
      const savedMessage = await Message.create({
        conversation: conversation._id,
        sender: senderId,
        text: message,
      });

      // Touch conversation's updatedAt for sorting in conversation list
      conversation.updatedAt = new Date();
      await conversation.save();

      // Broadcast to the room (both users, if both have joined)
      io.to(roomId).emit("receive_message", {
        _id: savedMessage._id,
        conversation: conversation._id,
        senderId,
        receiverId,
        message,
        createdAt: savedMessage.createdAt,
      });
    } catch (error) {
      console.error("❌ send_message error:", error.message);
      socket.emit("message_error", { message: "Failed to send message" });
    }
  });

  socket.on("disconnect", () => {
    console.log("❌ User disconnected:", socket.id);
  });
});

const PORT = process.env.PORT || 5000;

httpServer.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});