import Notification from "../models/Notification.js";

export const createNotification = async (
  recipient,
  title,
  message,
  type = "system"
) => {
  return await Notification.create({
    recipient,
    title,
    message,
    type,
  });
};

await createNotification(
  employerId,
  "New Application",
  "A new user applied for your job.",
  "application"
);