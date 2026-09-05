import express from "express";
import {
  getProducts,
  getProduct,
  createProduct,
  updateProduct,
  deleteProduct,
} from "../controllers/productController.js";
import { protect, authorize } from "../middleware/auth.js";
import upload from "../middleware/upload.js";

const router = express.Router();

router.use(protect);

router.route("/").get(getProducts).post(authorize("ADMIN"), upload.single("image"), createProduct);
router
  .route("/:id")
  .get(getProduct)
  .put(authorize("ADMIN"), upload.single("image"), updateProduct)
  .delete(authorize("ADMIN"), deleteProduct);

export default router;
