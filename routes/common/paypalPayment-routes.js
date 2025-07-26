const express = require("express");
const paypal = require("../../helpers/paypal");

const router = express.Router();

// Create PayPal payment
router.post("/create", async (req, res) => {
  try {
    const { amount, currency = "USD", description } = req.body;

    if (!amount || amount <= 0) {
      return res.status(400).json({
        success: false,
        message: "Invalid amount"
      });
    }

    const create_payment_json = {
      intent: "sale",
      payer: {
        payment_method: "paypal",
      },
      redirect_urls: {
        return_url: "http://localhost:5173/shop/payment/paypal/success",
        cancel_url: "http://localhost:5173/shop/payment/paypal/cancel",
      },
      transactions: [
        {
          amount: {
            currency: currency,
            total: amount.toString(),
          },
          description: description || "Coffee Shop Payment",
        },
      ],
    };

    paypal.payment.create(create_payment_json, (error, payment) => {
      if (error) {
        console.error("❌ PayPal create payment error:", error);
        return res.status(500).json({
          success: false,
          message: "Failed to create PayPal payment",
          error: error.message
        });
      }

      const approvalUrl = payment.links.find((link) => link.rel === "approval_url")?.href;

      if (!approvalUrl) {
        return res.status(500).json({
          success: false,
          message: "No approval URL found in PayPal response"
        });
      }

      res.status(200).json({
        success: true,
        approvalUrl: approvalUrl,
        paymentId: payment.id,
      });
    });
  } catch (error) {
    console.error("❌ PayPal create error:", error);
    res.status(500).json({
      success: false,
      message: "Server error creating PayPal payment",
      error: error.message
    });
  }
});

// Capture/Execute PayPal payment
router.post("/capture", async (req, res) => {
  try {
    const { paymentId, payerId } = req.body;

    if (!paymentId || !payerId) {
      return res.status(400).json({
        success: false,
        message: "Payment ID and Payer ID are required"
      });
    }

    const execute_payment_json = {
      payer_id: payerId,
    };

    paypal.payment.execute(paymentId, execute_payment_json, (error, payment) => {
      if (error) {
        console.error("❌ PayPal execute payment error:", error);
        return res.status(500).json({
          success: false,
          message: "Failed to execute PayPal payment",
          error: error.message
        });
      }

      if (payment.state === "approved") {
        res.status(200).json({
          success: true,
          message: "Payment executed successfully",
          payment: payment
        });
      } else {
        res.status(400).json({
          success: false,
          message: "Payment not approved",
          state: payment.state
        });
      }
    });
  } catch (error) {
    console.error("❌ PayPal capture error:", error);
    res.status(500).json({
      success: false,
      message: "Server error capturing PayPal payment",
      error: error.message
    });
  }
});

// Get payment details
router.get("/details/:paymentId", async (req, res) => {
  try {
    const { paymentId } = req.params;

    paypal.payment.get(paymentId, (error, payment) => {
      if (error) {
        console.error("❌ PayPal get payment error:", error);
        return res.status(500).json({
          success: false,
          message: "Failed to get PayPal payment details",
          error: error.message
        });
      }

      res.status(200).json({
        success: true,
        payment: payment
      });
    });
  } catch (error) {
    console.error("❌ PayPal details error:", error);
    res.status(500).json({
      success: false,
      message: "Server error getting PayPal payment details",
      error: error.message
    });
  }
});

module.exports = router;
