import Product from "../models/Product.js";
import { deleteFileImage } from "../lib/utils.js";

// @desc    Get all products (paginated)
// @route   GET /api/products?page=1&limit=10&categoryId=xxx
export const getProducts = async (req, res) => {
  try {
    const page = Math.max(1, parseInt(req.query.page) || 1);
    const limit = Math.min(100, Math.max(1, parseInt(req.query.limit) || 10));
    const skip = (page - 1) * limit;

    const filter = {};
    if (req.query.categoryId) {
      filter.categoryId = req.query.categoryId;
    }

    const [products, total] = await Promise.all([
      Product.find(filter).populate("categoryId", "name icon").skip(skip).limit(limit),
      Product.countDocuments(filter),
    ]);

    res.json({
      data: products,
      pagination: { page, limit, total, totalPages: Math.ceil(total / limit) },
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    Get single product
// @route   GET /api/products/:id
export const getProduct = async (req, res) => {
  try {
    const product = await Product.findById(req.params.id).populate(
      "categoryId",
      "name icon"
    );
    if (!product) {
      return res.status(404).json({ message: "Product not found" });
    }
    res.json(product);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    Create product
// @route   POST /api/products
export const createProduct = async (req, res) => {
  try {
    const { categoryId, name, basePrice, hasVariant, variants } = req.body;
    const image = req.file ? `/uploads/products/${req.file.filename}` : "";

    const product = await Product.create({
      categoryId,
      name,
      image,
      basePrice,
      hasVariant,
      variants: hasVariant ? JSON.parse(variants || "[]") : [],
    });

    res.status(201).json(product);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// @desc    Update product
// @route   PUT /api/products/:id
export const updateProduct = async (req, res) => {
  try {
    const product = await Product.findById(req.params.id);
    if (!product) {
      return res.status(404).json({ message: "Product not found" });
    }

    const { categoryId, name, basePrice, hasVariant, variants } = req.body;

    if (req.file) {
      deleteFileImage(product.image);
      product.image = `/uploads/products/${req.file.filename}`;
    }

    product.categoryId = categoryId || product.categoryId;
    product.name = name || product.name;
    product.basePrice = basePrice ?? product.basePrice;
    product.hasVariant = hasVariant ?? product.hasVariant;
    product.variants = hasVariant ? JSON.parse(variants || "[]") : [];

    await product.save();
    res.json(product);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// @desc    Delete product
// @route   DELETE /api/products/:id
export const deleteProduct = async (req, res) => {
  try {
    const product = await Product.findById(req.params.id);
    if (!product) {
      return res.status(404).json({ message: "Product not found" });
    }
    deleteFileImage(product.image);
    await Product.findByIdAndDelete(req.params.id);
    res.json({ message: "Product deleted" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
