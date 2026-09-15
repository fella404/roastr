import express from "express";
import {
  getUsers,
  getUser,
  createUser,
  updateUser,
  deleteUser,
  searchUsers,
} from "../controllers/userController.js";
import { protect, authorize } from "../middleware/auth.js";

const router = express.Router();

router.use(protect);
router.use(authorize("ADMIN"));

router.route("/").get(getUsers).post(createUser);
router.get("/search", searchUsers);
router.route("/:id").get(getUser).put(updateUser).delete(deleteUser);

export default router;
