import { GoogleGenAI } from "@google/genai";
import dotenv from "dotenv";
dotenv.config();

const ai = new GoogleGenAI({
  apiKey: process.env.GEMINI_API_KEY,
});

export const getJobRecommendations = async (
  userSkills,
  jobs
) => {
  const prompt = `
User skills:
${userSkills.join(", ")}

Available jobs:
${JSON.stringify(jobs)}

Recommend the top 5 matching jobs.
Return JSON only.
`;

  const response = await ai.models.generateContent({
    model: "gemini-2.5-flash",
    contents: prompt,
  });

  return response.text;
};