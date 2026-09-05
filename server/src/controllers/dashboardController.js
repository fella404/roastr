import Transaction from "../models/Transaction.js";

const getDateRange = (filter) => {
  const now = new Date();
  let start, end;

  switch (filter) {
    case "today":
      start = new Date(now.getFullYear(), now.getMonth(), now.getDate());
      end = new Date(now.getFullYear(), now.getMonth(), now.getDate() + 1);
      break;
    case "thisWeek":
      const dayOfWeek = now.getDay();
      start = new Date(now);
      start.setDate(now.getDate() - dayOfWeek);
      start.setHours(0, 0, 0, 0);
      end = new Date(start);
      end.setDate(start.getDate() + 7);
      break;
    case "thisMonth":
      start = new Date(now.getFullYear(), now.getMonth(), 1);
      end = new Date(now.getFullYear(), now.getMonth() + 1, 1);
      break;
    default:
      start = new Date(now.getFullYear(), now.getMonth(), now.getDate());
      end = new Date(now.getFullYear(), now.getMonth(), now.getDate() + 1);
  }

  return { start, end };
};

export const getKeyMetrics = async (req, res) => {
  try {
    const now = new Date();
    const startOfDay = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const endOfDay = new Date(now.getFullYear(), now.getMonth(), now.getDate() + 1);

    const todayTransactions = await Transaction.find({
      createdAt: { $gte: startOfDay, $lt: endOfDay },
    });

    const totalRevenue = todayTransactions.reduce(
      (sum, t) => sum + t.totalPrice,
      0
    );
    const totalTransactions = todayTransactions.length;
    const aov = totalTransactions > 0 ? totalRevenue / totalTransactions : 0;

    res.json({
      todayRevenue: totalRevenue,
      todayTransactions: totalTransactions,
      averageOrderValue: Math.round(aov),
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

export const getSalesTrend = async (req, res) => {
  try {
    const { filter = "today" } = req.query;
    const { start, end } = getDateRange(filter);

    const transactions = await Transaction.find({
      createdAt: { $gte: start, $lt: end },
    }).sort({ createdAt: 1 });

    const groupedData = {};

    transactions.forEach((t) => {
      let key;
      if (filter === "today") {
        key = t.createdAt.getHours().toString().padStart(2, "0") + ":00";
      } else if (filter === "thisWeek") {
        const days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
        key = days[t.createdAt.getDay()];
      } else {
        key = t.createdAt.getDate().toString();
      }

      if (!groupedData[key]) {
        groupedData[key] = 0;
      }
      groupedData[key] += t.totalPrice;
    });

    const labels = Object.keys(groupedData);
    const data = Object.values(groupedData);

    res.json({ labels, data });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

export const getOrderTypeComposition = async (req, res) => {
  try {
    const { filter = "today" } = req.query;
    const { start, end } = getDateRange(filter);

    const result = await Transaction.aggregate([
      { $match: { createdAt: { $gte: start, $lt: end } } },
      { $group: { _id: "$orderType", count: { $sum: 1 } } },
    ]);

    const composition = { DINE_IN: 0, TAKEAWAY: 0 };
    result.forEach((r) => {
      composition[r._id] = r.count;
    });

    res.json(composition);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

export const getTopProducts = async (req, res) => {
  try {
    const { filter = "today" } = req.query;
    const { start, end } = getDateRange(filter);

    const topProducts = await Transaction.aggregate([
      { $match: { createdAt: { $gte: start, $lt: end } } },
      { $unwind: "$orderItems" },
      {
        $group: {
          _id: {
            productId: "$orderItems.productId",
            productName: "$orderItems.productName",
          },
          totalQuantity: { $sum: "$orderItems.quantity" },
          totalRevenue: { $sum: "$orderItems.subTotal" },
        },
      },
      { $sort: { totalQuantity: -1 } },
      { $limit: 5 },
      {
        $lookup: {
          from: "products",
          localField: "_id.productId",
          foreignField: "_id",
          as: "product",
        },
      },
      { $unwind: { path: "$product", preserveNullAndEmptyArrays: true } },
      {
        $lookup: {
          from: "categories",
          localField: "product.categoryId",
          foreignField: "_id",
          as: "category",
        },
      },
      { $unwind: { path: "$category", preserveNullAndEmptyArrays: true } },
      {
        $project: {
          _id: 0,
          productName: "$_id.productName",
          categoryName: "$category.name",
          totalQuantity: 1,
          totalRevenue: 1,
        },
      },
    ]);

    res.json(topProducts);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
