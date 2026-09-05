import express from "express";
import { protect, authorize } from "../middleware/auth.js";
import {
  getKeyMetrics,
  getSalesTrend,
  getOrderTypeComposition,
  getTopProducts,
} from "../controllers/dashboardController.js";

const router = express.Router();

router.use(protect);
router.use(authorize("ADMIN"));

router.get("/metrics", getKeyMetrics);
router.get("/sales-trend", getSalesTrend);
router.get("/order-composition", getOrderTypeComposition);
router.get("/top-products", getTopProducts);

export default router;
