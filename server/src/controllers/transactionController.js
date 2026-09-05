import Transaction from "../models/Transaction.js";
import Product from "../models/Product.js";
import { sendEmail } from "../lib/emailHandler.js";
import { receiptTemplate } from "../lib/emailTemplates.js";

// @desc    Create new transaction (checkout)
// @route   POST /api/transactions
export const createTransaction = async (req, res) => {
  try {
    const { orderType, customerName, customerEmail, cashGiven, orderItems } =
      req.body;

    if (!orderType || !customerName || cashGiven == null || !orderItems?.length) {
      return res.status(400).json({ message: "Missing required fields" });
    }

    const productIds = [...new Set(orderItems.map((i) => i.productId))];
    const products = await Product.find({ _id: { $in: productIds } });
    const productMap = new Map(products.map((p) => [p._id.toString(), p]));

    let totalPrice = 0;
    const items = [];

    for (const item of orderItems) {
      const product = productMap.get(item.productId);
      if (!product) {
        return res
          .status(400)
          .json({ message: `Product not found: ${item.productId}` });
      }

      let unitPrice;
      if (item.variantName && product.hasVariant) {
        const variant = product.variants.find(
          (v) => v.name === item.variantName
        );
        if (!variant) {
          return res
            .status(400)
            .json({ message: `Variant not found: ${item.variantName}` });
        }
        unitPrice = variant.price;
      } else {
        unitPrice = product.basePrice;
      }

      const subTotal = unitPrice * item.quantity;
      totalPrice += subTotal;

      items.push({
        productId: product._id,
        productName: product.name,
        variantName: item.variantName || null,
        quantity: item.quantity,
        unitPrice,
        subTotal,
      });
    }

    if (cashGiven < totalPrice) {
      return res
        .status(400)
        .json({ message: "Cash given is less than total price" });
    }

    const transaction = await Transaction.create({
      cashierId: req.user._id,
      orderType,
      customerName,
      customerEmail: customerEmail || null,
      totalPrice,
      cashGiven,
      changeAmount: cashGiven - totalPrice,
      orderItems: items,
    });

    if (customerEmail) {
      sendEmail({
        to: customerEmail,
        subject: `Struk Roastr - ${customerName}`,
        html: receiptTemplate(transaction),
      }).catch(() => {});
    }

    res.status(201).json(transaction);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// @desc    Get all transactions (paginated)
// @route   GET /api/transactions?page=1&limit=10&orderType=DINE_IN
export const getTransactions = async (req, res) => {
  try {
    const page = Math.max(1, parseInt(req.query.page) || 1);
    const limit = Math.min(100, Math.max(1, parseInt(req.query.limit) || 10));
    const skip = (page - 1) * limit;

    const filter = {};
    if (req.query.orderType) {
      filter.orderType = req.query.orderType;
    }

    const [transactions, total] = await Promise.all([
      Transaction.find(filter)
        .populate("cashierId", "name")
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limit),
      Transaction.countDocuments(filter),
    ]);

    res.json({
      data: transactions,
      pagination: { page, limit, total, totalPages: Math.ceil(total / limit) },
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    Get single transaction
// @route   GET /api/transactions/:id
export const getTransaction = async (req, res) => {
  try {
    const transaction = await Transaction.findById(req.params.id).populate(
      "cashierId",
      "name"
    );
    if (!transaction) {
      return res.status(404).json({ message: "Transaction not found" });
    }
    res.json(transaction);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
