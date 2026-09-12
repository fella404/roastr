import mongoose from "mongoose";

const productSchema = new mongoose.Schema(
  {
    categoryId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Category",
      required: [true, "Category is required"],
    },
    name: {
      type: String,
      required: [true, "Product name is required"],
      trim: true,
    },
    image: {
      type: String,
      default: "",
      // Path: /uploads/products/filename.jpg
    },
    price: {
      type: Number,
      required: [true, "Price is required"],
      min: 0,
    },
  },
  { timestamps: true }
);

const Product = mongoose.model("Product", productSchema);

export default Product;
