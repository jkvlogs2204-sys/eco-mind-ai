import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../services/scan_service.dart';
import '../theme/app_theme.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<ProductModel> _products = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchProducts({String? query}) async {
    setState(() {
      _isLoading = true;
    });
    final apiService = Provider.of<ScanService>(context, listen: false).apiService;
    final list = await apiService.getProducts(query: query);
    setState(() {
      _products = list;
      _isLoading = false;
    });
  }

  void _showAddProductDialog() {
    final nameCtrl = TextEditingController();
    final brandCtrl = TextEditingController();
    final categoryCtrl = TextEditingController(text: "General");
    final materialCtrl = TextEditingController();
    final carbonCtrl = TextEditingController(text: "0.15");
    final waterCtrl = TextEditingController(text: "1.0");
    final pkgCtrl = TextEditingController(text: "Cardboard Box");
    final recycCtrl = TextEditingController(text: "85");
    final reuseCtrl = TextEditingController(text: "75");
    final lifespanCtrl = TextEditingController(text: "365");

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add New Environmental Product"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Product Name")),
                TextField(controller: brandCtrl, decoration: const InputDecoration(labelText: "Brand")),
                TextField(controller: categoryCtrl, decoration: const InputDecoration(labelText: "Category")),
                TextField(controller: materialCtrl, decoration: const InputDecoration(labelText: "Material")),
                TextField(controller: carbonCtrl, decoration: const InputDecoration(labelText: "Carbon Footprint (kg CO2e)"), keyboardType: TextInputType.number),
                TextField(controller: waterCtrl, decoration: const InputDecoration(labelText: "Water Footprint (litres)"), keyboardType: TextInputType.number),
                TextField(controller: pkgCtrl, decoration: const InputDecoration(labelText: "Packaging")),
                TextField(controller: recycCtrl, decoration: const InputDecoration(labelText: "Recyclability (%)"), keyboardType: TextInputType.number),
                TextField(controller: reuseCtrl, decoration: const InputDecoration(labelText: "Reuse Potential (%)"), keyboardType: TextInputType.number),
                TextField(controller: lifespanCtrl, decoration: const InputDecoration(labelText: "Lifespan (days)"), keyboardType: TextInputType.number),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("CANCEL"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.isNotEmpty && brandCtrl.text.isNotEmpty) {
                  final payload = {
                    "product_name": nameCtrl.text.trim(),
                    "brand": brandCtrl.text.trim(),
                    "category": categoryCtrl.text.trim(),
                    "material": materialCtrl.text.trim(),
                    "packaging": pkgCtrl.text.trim(),
                    "carbon_footprint": double.tryParse(carbonCtrl.text) ?? 0.1,
                    "water_footprint": double.tryParse(waterCtrl.text) ?? 1.0,
                    "recyclability": double.tryParse(recycCtrl.text) ?? 80.0,
                    "reuse_potential": double.tryParse(reuseCtrl.text) ?? 70.0,
                    "lifespan": int.tryParse(lifespanCtrl.text) ?? 365,
                    "data_status": "DEMO DATA"
                  };

                  final apiService = Provider.of<ScanService>(context, listen: false).apiService;
                  final ok = await apiService.createProduct(payload);
                  if (mounted) {
                    Navigator.pop(context);
                    if (ok) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Created product ${nameCtrl.text}")),
                      );
                      _fetchProducts();
                    }
                  }
                }
              },
              child: const Text("SAVE PRODUCT"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Product Catalog Management"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddProductDialog,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.black45),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: "Search products by name, brand or category...",
                          border: InputBorder.none,
                        ),
                        onChanged: (val) => _fetchProducts(query: val),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Product Catalog",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: _showAddProductDialog,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text("ADD PRODUCT"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Products List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen))
                  : _products.isEmpty
                      ? const Center(
                          child: Text(
                            "No products found.",
                            style: TextStyle(color: Colors.black54),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _products.length,
                          itemBuilder: (context, index) {
                            final prod = _products[index];

                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                leading: const CircleAvatar(
                                  backgroundColor: AppTheme.lightSage,
                                  child: Icon(Icons.inventory_2, color: AppTheme.primaryGreen),
                                ),
                                title: Text(
                                  prod.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text("${prod.brand} • ${prod.category} (${prod.material})"),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  onPressed: () async {
                                    final apiService = Provider.of<ScanService>(context, listen: false).apiService;
                                    final ok = await apiService.deleteProduct(prod.id);
                                    if (ok && mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text("Deleted ${prod.name}")),
                                      );
                                      _fetchProducts();
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
