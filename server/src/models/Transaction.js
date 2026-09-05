import mongoose from "mongoose";

const orderItemSchema = new mongoose.Schema(
  {
    productId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Product",
      required: true,
    },
    productName: { type: String, required: true },
    variantName: { type: String, default: null },
    quantity: { type: Number, required: true, min: 1 },
    unitPrice: { type: Number, required: true, min: 0 },
    subTotal: { type: Number, required: true, min: 0 },
  },
  { _id: false }
);

const transactionSchema = new mongoose.Schema(
  {
    cashierId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    orderType: {
      type: String,
      enum: ["DINE_IN", "TAKEAWAY"],
      required: true,
    },
    customerName: { type: String, required: true, trim: true },
    customerEmail: { type: String, default: null, trim: true },
    totalPrice: { type: Number, required: true, min: 0 },
    cashGiven: { type: Number, required: true, min: 0 },
    changeAmount: { type: Number, required: true, min: 0 },
    orderItems: { type: [orderItemSchema], required: true, min: 1 },
  },
  { timestamps: true }
);

transactionSchema.index({ cashierId: 1, createdAt: -1 });
transactionSchema.index({ createdAt: -1 });

const Transaction = mongoose.model("Transaction", transactionSchema);

export default Transaction;
