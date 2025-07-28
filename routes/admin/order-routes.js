const express = require("express");

const {
  getAllOrdersOfAllUsers,
  getOrderDetailsForAdmin,
  updateOrderStatus,
  getOrdersByStatus,
  getOrdersByPaymentMethod,
  getTotalOrders,
  getTotalRevenue,
  getSalesPerMonth,
  getDashboardStats, // ✅ Thêm import
  getOrdersByDateRange, // ✅ API mới
  getUsersWithOrderCount, // ✅ API mới  
  getOrdersByUserId, // ✅ API mới
} = require("../../controllers/admin/order-controller.js");

const router = express.Router();

router.get("/get", getAllOrdersOfAllUsers);
router.get("/details/:id", getOrderDetailsForAdmin);
router.put("/update/:id", updateOrderStatus);
router.get("/filter/status/:status", getOrdersByStatus); // ✅ Lọc theo trạng thái
router.get("/filter/payment/:method", getOrdersByPaymentMethod); // ✅ Lọc theo payment method
router.get("/filter/date-range", getOrdersByDateRange); // ✅ API mới - lọc theo ngày
router.get("/filter/user/:userId", getOrdersByUserId); // ✅ API mới - đơn hàng theo user
router.get("/users-with-orders", getUsersWithOrderCount); // ✅ API mới - danh sách user có đơn hàng
router.get('/total-orders', getTotalOrders); 
router.get('/total-revenue', getTotalRevenue);
router.get('/sales-per-month', getSalesPerMonth);
router.get('/dashboard-stats', getDashboardStats); // ✅ Thêm route mới

module.exports = router;
