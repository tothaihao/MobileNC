import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/product_provider.dart';
import '../../models/product_model.dart';
import '../../theme/colors.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);
    final favoriteIds = favoritesProvider.favoriteProductIds;
    // Ensure products are loaded
    if (productProvider.filteredProducts.isEmpty && !productProvider.isLoading) {
      productProvider.fetchProducts();
    }
    // Use all products for favorites
    final allProducts = productProvider.filteredProducts.isNotEmpty
        ? productProvider.filteredProducts
        : [];
    final favoriteProducts = allProducts.where((p) => favoriteIds.contains(p.id)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sản phẩm yêu thích'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: favoriteProducts.isEmpty
          ? const Center(child: Text('Bạn chưa có sản phẩm yêu thích nào.'))
          : ListView.builder(
              itemCount: favoriteProducts.length,
              itemBuilder: (context, index) {
                final product = favoriteProducts[index];
                return ListTile(
                  leading: Image.network(product.image, width: 48, height: 48, fit: BoxFit.cover),
                  title: Text(product.title),
                  subtitle: Text('${product.price} VNĐ'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: AppColors.error),
                    onPressed: () => favoritesProvider.removeFavorite(product.id),
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, '/products');
                  },
                );
              },
            ),
    );
  }
} 