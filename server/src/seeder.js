import mongoose from "mongoose";
import dotenv from "dotenv";
import User from "./models/User.js";

dotenv.config();

const seedAdmin = async () => {
  try {
    await mongoose.connect(process.env.MONGO_URI);
    console.log("MongoDB connected");

    const existingAdmin = await User.findOne({
      email: "tomhagen849@gmail.com",
    });
    if (existingAdmin) {
      console.log("Admin account already exists");
      process.exit(0);
    }

    await User.create({
      name: "Admin",
      email: "tomhagen849@gmail.com",
      password: "admin123",
      role: "ADMIN",
    });

    console.log("Admin account created: tomhagen849@gmail.com / admin123");
    process.exit(0);
  } catch (error) {
    console.error(`Error: ${error.message}`);
    process.exit(1);
  }
};

seedAdmin();
