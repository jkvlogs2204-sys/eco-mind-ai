import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/rfid_tag.dart';
import '../models/product.dart';
import '../services/scan_service.dart';
import '../theme/app_theme.dart';

class RFIDManagementScreen extends StatefulWidget {
  const RFIDManagementScreen({super.key});

  @override
  State<RFIDManagementScreen> createState() => _RFIDManagementScreenState();
}

class _RFIDManagementScreenState extends State<RFIDManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _newUidController = TextEditingController();
  List<RFIDTagModel> _tags = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchTags();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _newUidController.dispose();
    super.dispose();
  }

  Future<void> _fetchTags({String? query}) async {
    setState(() {
      _isLoading = true;
    });
    final apiService = Provider.of<ScanService>(context, listen: false).apiService;
    final list = await apiService.getRFIDTags(query: query);
    setState(() {
      _tags = list;
      _isLoading = false;
    });
  }

  void _showAssignDialog(RFIDTagModel tag) async {
    final apiService = Provider.of<ScanService>(context, listen: false).apiService;
    final products = await apiService.getProducts();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        ProductModel? selectedProduct = products.isNotEmpty ? products.first : null;
        return AlertDialog(
          title: Text("Assign RFID Tag (${tag.rfidUid})"),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              if (products.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Text(
                    "No products available in catalog.\nPlease create a product in the Products tab first.",
                    style: TextStyle(color: Colors.red, fontSize: 13),
                  ),
                );
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Select product to assign to this RFID tag:"),
                  const SizedBox(height: 12),
                  DropdownButton<ProductModel>(
                    isExpanded: true,
                    hint: const Text("Select Product"),
                    value: selectedProduct,
                    items: products.map((p) {
                      return DropdownMenuItem<ProductModel>(
                        value: p,
                        child: Text("${p.name} (${p.category})"),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setDialogState(() {
                        selectedProduct = val;
                      });
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("CANCEL"),
            ),
            if (products.isNotEmpty)
              ElevatedButton(
                onPressed: () async {
                  if (selectedProduct != null) {
                    final ok = await apiService.assignRFIDTag(tag.rfidUid, selectedProduct!.id);
                    if (mounted) {
                      Navigator.pop(context);
                      if (ok) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Assigned ${tag.rfidUid} to ${selectedProduct!.name}")),
                        );
                        _fetchTags();
                      }
                    }
                  }
                },
                child: const Text("ASSIGN"),
              ),
          ],
        );
      },
    );
  }

  void _showRegisterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Register New RFID Tag"),
          content: TextField(
            controller: _newUidController,
            decoration: const InputDecoration(
              hintText: "Enter RFID UID (e.g. A1B2C3D4)",
              labelText: "RFID UID",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("CANCEL"),
            ),
            ElevatedButton(
              onPressed: () async {
                final uid = _newUidController.text.trim();
                if (uid.isNotEmpty) {
                  final apiService = Provider.of<ScanService>(context, listen: false).apiService;
                  final res = await apiService.registerRFIDTag(uid);
                  if (mounted) {
                    Navigator.pop(context);
                    _newUidController.clear();
                    if (res['success'] == true) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Registered RFID Tag $uid")),
                      );
                      _fetchTags();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(res['error'] ?? 'Registration failed'), backgroundColor: Colors.red),
                      );
                    }
                  }
                }
              },
              child: const Text("REGISTER"),
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
        title: const Text("RFID Tag Management"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showRegisterDialog,
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
                          hintText: "Search RFID Tags by UID...",
                          border: InputBorder.none,
                        ),
                        onChanged: (val) => _fetchTags(query: val),
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
                  "Registered Tags",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: _showRegisterDialog,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text("REGISTER TAG"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // RFID Tags List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen))
                  : _tags.isEmpty
                      ? const Center(
                          child: Text(
                            "No RFID tags found.",
                            style: TextStyle(color: Colors.black54),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _tags.length,
                          itemBuilder: (context, index) {
                            final tag = _tags[index];
                            final isAssigned = tag.status == "ASSIGNED";

                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: isAssigned ? AppTheme.lightSage : Colors.grey.shade200,
                                  child: Icon(
                                    Icons.nfc,
                                    color: isAssigned ? AppTheme.primaryGreen : Colors.grey,
                                  ),
                                ),
                                title: Text(
                                  tag.rfidUid,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  isAssigned
                                      ? "Assigned: ${tag.productName ?? 'Unknown'}"
                                      : "Not Assigned to any product",
                                  style: TextStyle(
                                    color: isAssigned ? Colors.black87 : Colors.orange.shade800,
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isAssigned ? Colors.green.shade100 : Colors.orange.shade100,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        tag.status,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: isAssigned ? Colors.green.shade900 : Colors.orange.shade900,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        isAssigned ? Icons.edit_note : Icons.link,
                                        color: AppTheme.primaryGreen,
                                      ),
                                      onPressed: () => _showAssignDialog(tag),
                                    ),
                                  ],
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
