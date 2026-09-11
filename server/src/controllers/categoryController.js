import Category from "../models/Category.js";

const categoryAggregate = (filter = {}) => [
  {
    $lookup: {
      from: "products",
      localField: "_id",
      foreignField: "categoryId",
      as: "products",
    },
  },
  {
    $addFields: {
      totalProducts: { $size: "$products" },
    },
  },
  { $project: { products: 0 } },
  ...(filter.name
    ? [{ $match: { name: { $regex: filter.name, $options: "i" } } }]
    : []),
];

// @desc    Get all categories (paginated)
// @route   GET /api/categories?page=1&limit=10
export const getCategories = async (req, res) => {
  try {
    const page = Math.max(1, parseInt(req.query.page) || 1);
    const limit = Math.min(100, Math.max(1, parseInt(req.query.limit) || 10));
    const skip = (page - 1) * limit;

    const pipeline = categoryAggregate();

    const countPipeline = [...pipeline, { $count: "total" }];
    const dataPipeline = [...pipeline, { $skip: skip }, { $limit: limit }];

    const [countResult, categories] = await Promise.all([
      Category.aggregate(countPipeline),
      Category.aggregate(dataPipeline),
    ]);

    const total = countResult[0]?.total || 0;

    res.json({
      data: categories,
      pagination: { page, limit, total, totalPages: Math.ceil(total / limit) },
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    Get single category
// @route   GET /api/categories/:id
export const getCategory = async (req, res) => {
  try {
    const category = await Category.findById(req.params.id);
    if (!category) {
      return res.status(404).json({ message: "Category not found" });
    }
    res.json(category);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    Create category
// @route   POST /api/categories
export const createCategory = async (req, res) => {
  try {
    const { name, icon } = req.body;

    const exists = await Category.findOne({ name });
    if (exists) {
      return res.status(400).json({ message: "Category already exists" });
    }

    const category = await Category.create({ name, icon });
    res.status(201).json(category);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// @desc    Update category
// @route   PUT /api/categories/:id
export const updateCategory = async (req, res) => {
  try {
    const { name, icon } = req.body;

    const category = await Category.findById(req.params.id);
    if (!category) {
      return res.status(404).json({ message: "Category not found" });
    }

    if (name && name !== category.name) {
      const exists = await Category.findOne({ name });
      if (exists) {
        return res.status(400).json({ message: "Category already exists" });
      }
    }

    category.name = name || category.name;
    category.icon = icon || category.icon;

    await category.save();
    res.json(category);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// @desc    Delete category
// @route   DELETE /api/categories/:id
export const deleteCategory = async (req, res) => {
  try {
    const category = await Category.findByIdAndDelete(req.params.id);
    if (!category) {
      return res.status(404).json({ message: "Category not found" });
    }
    res.json({ message: "Category deleted" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    Search categories by name
// @route   GET /api/categories/search?search=coffee&page=1&limit=10
export const searchCategories = async (req, res) => {
  try {
    const page = Math.max(1, parseInt(req.query.page) || 1);
    const limit = Math.min(100, Math.max(1, parseInt(req.query.limit) || 10));
    const skip = (page - 1) * limit;
    const search = req.query.search || "";

    const pipeline = categoryAggregate(search ? { name: search } : {});

    const countPipeline = [...pipeline, { $count: "total" }];
    const dataPipeline = [...pipeline, { $skip: skip }, { $limit: limit }];

    const [countResult, categories] = await Promise.all([
      Category.aggregate(countPipeline),
      Category.aggregate(dataPipeline),
    ]);

    const total = countResult[0]?.total || 0;

    res.json({
      data: categories,
      pagination: { page, limit, total, totalPages: Math.ceil(total / limit) },
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
