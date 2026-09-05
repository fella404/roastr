import express from "express";
import {
  getUsers,
  getUser,
  createUser,
  updateUser,
  toggleActive,
} from "../controllers/userController.js";
import { protect, authorize } from "../middleware/auth.js";

const router = express.Router();

router.use(protect);
router.use(authorize("ADMIN"));

router.route("/").get(getUsers).post(createUser);
router.route("/:id").get(getUser).put(updateUser);
router.patch("/:id/toggle-active", toggleActive);

export default router;
