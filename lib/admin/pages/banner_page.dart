import 'package:flutter/material.dart';
import '../services/banner_service.dart';
import '../../models/feature_model.dart';

class BannerPage extends StatefulWidget {
  const BannerPage({Key? key}) : super(key: key);

  @override
  State<BannerPage> createState() => _BannerPageState();
}

class _BannerPageState extends State<BannerPage> {
  List<Feature> banners = [];
  bool isLoading = true;
  final TextEditingController _imageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchBanners();
  }

  Future<void> fetchBanners() async {
    setState(() => isLoading = true);
    banners = await BannerService.getBanners();
    setState(() => isLoading = false);
  }

  Future<void> addBanner() async {
    final imageUrl = _imageController.text.trim();
    if (imageUrl.isEmpty) return;
    final success = await BannerService.addBanner(imageUrl);
    if (success) {
      _imageController.clear();
      fetchBanners();
    }
  }

  Future<void> deleteBanner(String id) async {
    final success = await BannerService.deleteBanner(id);
    if (success) fetchBanners();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý Banner')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _imageController,
                          decoration: const InputDecoration(
                            labelText: 'URL ảnh banner',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: addBanner,
                        child: const Text('Thêm Banner'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: banners.length,
                    itemBuilder: (context, index) {
                      final banner = banners[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: banner.image.isNotEmpty
                              ? Image.network(banner.image, width: 60, height: 60, fit: BoxFit.cover)
                              : const Icon(Icons.image),
                          title: Text(banner.image),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => deleteBanner(banner.id),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
} 