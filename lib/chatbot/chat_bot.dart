import 'package:flutter/material.dart';
import 'package:do_an_mobile_nc/services/chatbot_service.dart';
import 'package:do_an_mobile_nc/services/auth_service.dart';
import 'package:do_an_mobile_nc/models/product_model.dart';
import 'package:do_an_mobile_nc/models/voucher_model.dart';
import 'package:do_an_mobile_nc/models/order_model.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({Key? key}) : super(key: key);

  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final DataService _dataService = DataService();
  final AuthService _authService = AuthService();

  // Ánh xạ danh mục từ tên tiếng Việt sang mã danh mục
  final Map<String, String> categoryMap = {
    'tất cả': '',
    'cà phê': 'caPhe',
    'trà sữa': 'traSua',
    'bánh ngọt': 'banhNgot',
    'đá xay': 'daXay',
  };

  void _handleUserMessage(String message) async {
    setState(() {
      _messages.add({'sender': 'user', 'text': message});
    });

    // Hiển thị "Đang nhập..." trong thời gian delay
    setState(() {
      _messages.add({'sender': 'bot', 'text': 'Đang nhập...'});
    });

    // Thêm độ trễ ngẫu nhiên từ 2 đến 3 giây
    await Future.delayed(Duration(milliseconds: 2000 + (DateTime.now().millisecond % 1000)));

    String response = await _processMessage(message.toLowerCase());

    setState(() {
      _messages.removeLast(); // Xóa "Đang nhập..."
      _messages.add({'sender': 'bot', 'text': response});
    });

    _controller.clear();
  }

  Future<String> _processMessage(String message) async {
    try {
      // Phân tích ý định và thực thể từ câu hỏi
      final intent = _detectIntent(message);
      final entities = _extractEntities(message);

      // Xử lý theo ý định
      switch (intent) {
        case 'list_products':
          return 'Xin lỗi, danh sách sản phẩm quá dài! Bạn có thể hỏi cụ thể như "cà phê nào ngon" hoặc "trà sữa dưới 50k".';
        case 'voucher':
          final vouchers = await _dataService.getVouchers();
          if (vouchers.isEmpty) {
            return 'Hiện tại không có voucher nào. Bạn muốn xem sản phẩm thay không?';
          }
          return 'Danh sách voucher đang hoạt động:\n${vouchers.where((v) => v.isActive).map((v) => "${v.code} - ${v.displayValue}").join("\n")}';
        case 'order':
          final isLoggedIn = await _authService.isLoggedIn();
          if (!isLoggedIn) {
            return 'Vui lòng đăng nhập để xem lịch sử đơn hàng. Bạn có thể đăng nhập qua mục Cá nhân.';
          }
          final userData = await _authService.getSavedUser();
          if (userData == null || userData['_id'] == null) {
            return 'Không thể lấy thông tin người dùng. Vui lòng đăng nhập lại.';
          }
          final userId = userData['_id'] as String;
          final orders = await _dataService.getOrderHistory(userId);
          if (orders.isEmpty) {
            return 'Bạn chưa có đơn hàng nào. Thử đặt món gì ngon tại Fresh Drinks nhé!';
          }
          return 'Lịch sử đơn hàng của bạn:\n${orders.map((o) => "Đơn #${o.id} - ${o.orderStatus} - ${o.totalAmount} VNĐ").join("\n")}';
        case 'search_product':
          List<Product> products = [];
          if (entities['category'] != null) {
            products = await _dataService.searchProductsByCategory(entities['category']!);
          } else if (entities['keywords'] != null) {
            products = await _dataService.searchProducts(entities['keywords']!);
          }

          // Lọc thêm theo giá hoặc tồn kho nếu có
          if (entities['maxPrice'] != null) {
            products = products.where((p) => p.price <= entities['maxPrice']!).toList();
          }
          if (entities['inStock'] == true) {
            products = products.where((p) => p.stockStatus == 'Còn hàng').toList();
          }

          if (products.isEmpty) {
            String suggestion = entities['category'] != null
                ? 'Không tìm thấy sản phẩm nào trong danh mục ${entities["categoryKey"]}. Bạn muốn xem danh mục khác như Trà sữa hoặc Bánh ngọt?'
                : 'Không tìm thấy sản phẩm nào với từ khóa "${message}". Thử "Cà phê sữa đá" hoặc "Trà sữa trân châu" nhé!';
            return suggestion;
          }

          // Tạo câu trả lời tự nhiên
          String response = 'Dưới đây là các sản phẩm phù hợp:\n';
          for (var product in products.take(3)) { // Giới hạn 3 sản phẩm để tránh dài
            response +=
                '- ${product.title}: ${product.price} VNĐ, ${product.stockStatus.toLowerCase()}. ${product.description ?? ''}\n';
          }
          if (products.length > 3) {
            response += 'Còn ${products.length - 3} sản phẩm khác. Bạn muốn xem thêm không?';
          }
          return response;
        case 'greeting':
          return 'Chào bạn! Mình là chatbot của Fresh Drinks, sẵn sàng giúp bạn tìm món ngon. Hôm nay bạn muốn thử cà phê, trà sữa hay bánh ngọt?';
        case 'help':
          return 'Mình có thể giúp bạn:\n'
                 '- Tìm sản phẩm (ví dụ: "cà phê dưới 40k", "trà sữa còn hàng")\n'
                 '- Xem voucher đang hoạt động\n'
                 '- Xem lịch sử đơn hàng (cần đăng nhập)\n'
                 'Hãy thử hỏi mình nhé!';
        default:
          return 'Mình chưa hiểu lắm! Bạn có thể hỏi về sản phẩm, voucher, hoặc đơn hàng. Ví dụ: "Cà phê nào dưới 40k?"';
      }
    } catch (e) {
      return 'Oops, có lỗi xảy ra: ${e.toString()}. Bạn thử hỏi lại nhé!';
    }
  }

  // Phát hiện ý định từ câu hỏi
  String _detectIntent(String message) {
    if (message.contains('product') || message.contains('sản phẩm')) {
      return 'list_products';
    } else if (message.contains('voucher')) {
      return 'voucher';
    } else if (message.contains('order') || message.contains('đơn hàng')) {
      return 'order';
    } else if (message.contains('hello') || message.contains('xin chào') || message.contains('chào bạn')) {
      return 'greeting';
    } else if (message.contains('help') || message.contains('giúp đỡ')) {
      return 'help';
    } else {
      // Kiểm tra danh mục hoặc từ khóa để xác định tìm kiếm sản phẩm
      for (var key in categoryMap.keys) {
        if (message.contains(key.toLowerCase())) {
          return 'search_product';
        }
      }
      if (message.split(' ').any((word) => word.length > 2)) {
        return 'search_product';
      }
      return 'unknown';
    }
  }

  // Trích xuất thực thể từ câu hỏi
  Map<String, dynamic> _extractEntities(String message) {
    final entities = <String, dynamic>{};

    // Trích xuất danh mục
    for (var key in categoryMap.keys) {
      if (message.contains(key.toLowerCase())) {
        entities['category'] = categoryMap[key];
        entities['categoryKey'] = key;
        break;
      }
    }

    // Trích xuất từ khóa
    final keywords = message.split(' ').where((word) => word.length > 2).toList();
    if (keywords.isNotEmpty) {
      entities['keywords'] = keywords;
    }

    // Trích xuất giá tối đa (ví dụ: "dưới 40k", "nhỏ hơn 50000")
    final priceMatch = RegExp(r'(dưới|nhỏ hơn)\s*(\d+)\s*(k|nghìn|vnđ)?').firstMatch(message);
    if (priceMatch != null) {
      final price = int.parse(priceMatch.group(2)!);
      entities['maxPrice'] = priceMatch.group(3) == 'k' ? price * 1000 : price;
    }

    // Trích xuất yêu cầu tồn kho (ví dụ: "còn hàng", "có sẵn")
    if (message.contains('còn hàng') || message.contains('có sẵn')) {
      entities['inStock'] = true;
    }

    return entities;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chatbot')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['sender'] == 'user';
                return ListTile(
                  title: Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: isUser ? Colors.blue[100] : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(message['text']!),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Nhập tin nhắn...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: _handleUserMessage,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      _handleUserMessage(_controller.text);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}