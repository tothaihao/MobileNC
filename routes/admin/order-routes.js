const express = require("express");

const {
  getAllOrdersOfAllUsers,
  getOrderDetailsForAdmin,
  updateOrderStatus,
  getOrdersByStatus,
  getOrdersByPaymentMethod,
  getTotalOrders,
  getTotalRevenue,
  getSalesPerMonth
} = require("../../controllers/admin/order-controller.js");

const router = express.Router();

router.get("/get", getAllOrdersOfAllUsers);
router.get("/details/:id", getOrderDetailsForAdmin);
router.put("/update/:id", updateOrderStatus);
router.get("/filter/status/:status", getOrdersByStatus); // ✅ Lọc theo trạng thái
router.get("/filter/payment/:method", getOrdersByPaymentMethod); // ✅ Lọc theo payment method
router.get('/total-orders', getTotalOrders); 
router.get('/total-revenue', getTotalRevenue);
router.get('/sales-per-month', getSalesPerMonth);

module.exports = router;
