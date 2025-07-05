import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart' as cs;
import 'package:do_an_mobile_nc/Layout/masterlayout.dart';

class HomeScreen extends StatelessWidget {
  final List<String> bannerImages = [
    'https://upload.wikimedia.org/wikipedia/commons/e/e4/Latte_and_dark_coffee.jpg',
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT0RyiFla98L-B6yXCLbOiELZktX5jHkwQdZw&s',
    'https://enjoycoffee.vn/wp-content/uploads/2020/01/coffee.2-810x524-1.jpg',
  ];
  
  @override
  Widget build(BuildContext context) {
    return MasterLayout(
      currentIndex: 0,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBanner(),
            _buildSectionWithFilter(context, 'Sản phẩm bán chạy'),
            _buildProductSection(context, 'Bạc xỉu', '40000 đ', '4.6', Colors.brown, 'Trà sen vàng', '36000 đ', '4.5', Colors.brown),
            _buildSectionWithFilter(context, 'Ưu đãi hot'),
            _buildProductSection(context, 'Bạc xỉu', '20000 đ', '4.4', Colors.red, 'Freeze sô-cô-la', '36000 đ', '4.8', Colors.brown),
          ],
        ),
      ),
    );
  }

  Widget _buildBanner() {
    return cs.CarouselSlider(
      options: cs.CarouselOptions(height: 180.0, autoPlay: true),
      items: bannerImages.map((url) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.symmetric(horizontal: 5.0),
              decoration: BoxDecoration(color: Colors.amber),
              child: Image.network(url, fit: BoxFit.cover),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildSectionWithFilter(BuildContext context, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, title),
        _buildFilterButtons(context),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.brown[800],
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushReplacementNamed(context, '/products');
            },
            child: Text(
              'Tất cả',
              style: TextStyle(
                fontSize: 14,
                color: Colors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductSection(BuildContext context, String name1, String price1, String rating1, Color color1, String name2, String price2, String rating2, Color color2) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildProductCard(name1, price1, rating1, color1),
              _buildProductCard(name2, price2, rating2, color2),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text('<1, 2, 3>', style: TextStyle(color: Colors.grey)),
        ),
      ],
    );
  }

  Widget _buildProductCard(String name, String price, String rating, Color color) {
    return Card(
      child: Column(
        children: [
          Image.asset('assets/${name.toLowerCase().replaceAll(' ', '_')}.jpg', height: 100, fit: BoxFit.cover),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
                Text(price, style: TextStyle(color: Colors.green)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star, color: Colors.yellow, size: 16),
                    Text(rating),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          OutlinedButton(
            onPressed: () {
              // Add filter logic here
            },
            child: Text('Tất cả sản phẩm', style: TextStyle(color: Colors.brown[700])),
          ),
          SizedBox(width: 8),
          OutlinedButton(
            onPressed: () {
              // Add filter logic here
            },
            child: Text('Cà phê', style: TextStyle(color: Colors.brown[700])),
          ),
          SizedBox(width: 8),
          OutlinedButton(
            onPressed: () {
              // Add filter logic here
            },
            child: Text('Bánh ngọt', style: TextStyle(color: Colors.brown[700])),
          ),
        ],
      ),
    );
  }
}