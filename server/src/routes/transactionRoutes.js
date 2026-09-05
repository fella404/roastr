import express from "express";
import {
  createTransaction,
  getTransactions,
  getTransaction,
} from "../controllers/transactionController.js";
import { protect } from "../middleware/auth.js";

const router = express.Router();

router.use(protect);

router.route("/").get(getTransactions).post(createTransaction);
router.route("/:id").get(getTransaction);

export default router;
