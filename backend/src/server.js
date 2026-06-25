import dotenv from "dotenv";
dotenv.config();

import app from "./app.js";
import connectDB from "./config/db.js";

import { createServer } from "http";
import { Server } from "socket.io";

connectDB();

const httpServer = createServer(app);

const io = new Server(httpServer, {
  cors: {
    origin: "*",
  },
});

io.on("connection", (socket) => {
  console.log("✅ User connected:", socket.id);

  // Join chat room
  socket.on("join_room", (roomId) => {
    socket.join(roomId);
    console.log(`User joined room: ${roomId}`);
  });

  // Send message
  socket.on("send_message", (data) => {
    const { senderId, receiverId, message } = data;

    // Create consistent room ID (VERY IMPORTANT FIX)
    const roomId = [senderId, receiverId].sort().join("_");

    io.to(roomId).emit("receive_message", {
      senderId,
      receiverId,
      message,
      createdAt: new Date(),
    });
  });

  // Disconnect
  socket.on("disconnect", () => {
    console.log("❌ User disconnected:", socket.id);
  });
});

const PORT = process.env.PORT || 8080;

httpServer.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});