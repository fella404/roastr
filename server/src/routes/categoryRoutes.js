import express from "express";
import {
  getCategories,
  getCategory,
  createCategory,
  updateCategory,
  deleteCategory,
} from "../controllers/categoryController.js";
import { protect, authorize } from "../middleware/auth.js";

const router = express.Router();

router.use(protect);

router.route("/").get(getCategories).post(authorize("ADMIN"), createCategory);
router
  .route("/:id")
  .get(getCategory)
  .put(authorize("ADMIN"), updateCategory)
  .delete(authorize("ADMIN"), deleteCategory);

export default router;
