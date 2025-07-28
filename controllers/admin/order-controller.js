const Order = require("../../models/Order");
const OrderContext = require("../../models/OrderContext");

const getAllOrdersOfAllUsers = async (req, res) => {
  try {
    const orders = await Order.find({})
      .populate('userId', 'userName email') // ✅ Lấy thông tin user
      .populate('addressId') // ✅ Lấy thông tin địa chỉ
      .populate('cartItems.productId', 'title image price') // ✅ Lấy thông tin sản phẩm
      .sort({ orderDate: -1 }); // ✅ Sắp xếp theo ngày mới nhất

    if (!orders.length) {
      return res.status(404).json({
        success: false,
        message: "No orders found!",
      });
    }

    // ✅ Thêm thống kê nhanh
    const stats = {
      total: orders.length,
      pending: orders.filter(o => o.orderStatus === 'pending').length,
      confirmed: orders.filter(o => o.orderStatus === 'confirmed').length,
      delivered: orders.filter(o => o.orderStatus === 'delivered').length,
      rejected: orders.filter(o => o.orderStatus === 'rejected').length,
      totalRevenue: orders.reduce((sum, o) => sum + o.totalAmount, 0)
    };

    res.status(200).json({
      success: true,
      data: orders,
      stats: stats, // ✅ Thêm thống kê cho admin dashboard
    });
  } catch (e) {
    console.log(e);
    res.status(500).json({
      success: false,
      message: "Some error occured!",
    });
  }
};

const getOrderDetailsForAdmin = async (req, res) => {
  try {
    const { id } = req.params;

    const order = await Order.findById(id)
      .populate("addressId")               // ✅ lấy chi tiết địa chỉ
      .populate("cartItems.productId");    // (tuỳ chọn) lấy chi tiết sản phẩm nếu cần

    if (!order) {
      return res.status(404).json({
        success: false,
        message: "Order not found!",
      });
    }

    res.status(200).json({
      success: true,
      data: order,
    });
  } catch (e) {
    console.log(e);
    res.status(500).json({
      success: false,
      message: "Some error occurred!",
    });
  }
};


const updateOrderStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const { orderStatus } = req.body;

    const order = await Order.findById(id);
    if (!order) {
      return res.status(404).json({ success: false, message: "Order not found!" });
    }

    const orderContext = new OrderContext(order);
    const result = orderContext.updateStatus(orderStatus);

    if (!result.success) {
      return res.status(400).json(result);
    }

    await order.save();

    res.status(200).json(result);
  } catch (e) {
    console.log(e);
    res.status(500).json({ success: false, message: "Some error occurred!" });
  }
};
const getTotalOrders = async (req, res) => {
  try {
    const totalOrders = await Order.countDocuments();
    res.status(200).json({ totalOrders });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};
const getTotalRevenue = async (req, res) => {
  try {
    const totalRevenue = await Order.aggregate([
      { $group: { _id: null, total: { $sum: "$totalAmount" } } }
    ]);
    res.status(200).json({ totalRevenue: totalRevenue[0]?.total || 0 });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};
const getSalesPerMonth = async (req, res) => {
  try {
    const orders = await Order.find();

    const salesPerMonth = orders.reduce((acc, order) => {
      const monthIndex = new Date(order.createdAt).getMonth();
      acc[monthIndex] = (acc[monthIndex] || 0) + order.totalAmount;
      return acc;
    }, {});

    const graphData = Array.from({ length: 12 }, (_, i) => {
      const month = new Intl.DateTimeFormat('en-US', { month: 'short' }).format(new Date(0, i));
      console.log(`Month: ${month}, Sales: ${salesPerMonth[i] || 0}`); // Log sales per month
      return { name: month, sales: Math.floor(Math.random() * 10) };
    });

    res.status(200).json({ success: true, data: graphData });
  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, message: "Some error occurred!" });
  }
};

// ✅ Thêm method lọc đơn hàng theo trạng thái
const getOrdersByStatus = async (req, res) => {
  try {
    const { status } = req.params;
    const validStatuses = ['pending', 'confirmed', 'delivered', 'rejected', 'inShipping'];
    
    if (!validStatuses.includes(status)) {
      return res.status(400).json({
        success: false,
        message: "Invalid order status!",
      });
    }

    const orders = await Order.find({ orderStatus: status })
      .populate('userId', 'userName email')
      .populate('addressId')
      .populate('cartItems.productId', 'title image price')
      .sort({ orderDate: -1 });

    res.status(200).json({
      success: true,
      data: orders,
    });
  } catch (e) {
    console.log(e);
    res.status(500).json({
      success: false,
      message: "Some error occurred!",
    });
  }
};

// ✅ Thêm method lọc đơn hàng theo payment method
const getOrdersByPaymentMethod = async (req, res) => {
  try {
    const { method } = req.params;
    const validMethods = ['paypal', 'momo', 'cash'];
    
    if (!validMethods.includes(method)) {
      return res.status(400).json({
        success: false,
        message: "Invalid payment method!",
      });
    }

    const orders = await Order.find({ paymentMethod: method })
      .populate('userId', 'userName email')
      .populate('addressId')
      .populate('cartItems.productId', 'title image price')
      .sort({ orderDate: -1 });

    res.status(200).json({
      success: true,
      data: orders,
    });
  } catch (e) {
    console.log(e);
    res.status(500).json({
      success: false,
      message: "Some error occurred!",
    });
  }
};

module.exports = {
  getAllOrdersOfAllUsers,
  getOrderDetailsForAdmin,
  updateOrderStatus,
  getOrdersByStatus, // ✅ Thêm export
  getOrdersByPaymentMethod, // ✅ Thêm export
  getTotalOrders,
  getTotalRevenue,
  getSalesPerMonth,
};
