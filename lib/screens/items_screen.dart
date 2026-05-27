import 'package:flutter/material.dart';
import '../models/item.dart';
import '../services/api_service.dart';

class ItemsScreen extends StatefulWidget {
  const ItemsScreen({super.key});

  @override
  State<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  List<Item> _items = [];
  bool _isLoading = true;
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() => _isLoading = true);
    final items = await ApiService.getItems();
    setState(() {
      _items = items;
      _isLoading = false;
    });
  }

  void _showForm({Item? item}) {
    if (item != null) {
      _nameCtrl.text = item.name;
      _descCtrl.text = item.description;
    } else {
      _nameCtrl.clear();
      _descCtrl.clear();
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(item == null ? 'Add Item' : 'Edit Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descCtrl,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_nameCtrl.text.isEmpty) return;
              if (item == null) {
                await ApiService.createItem(_nameCtrl.text, _descCtrl.text);
              } else {
                await ApiService.updateItem(item.id, _nameCtrl.text, _descCtrl.text);
              }
              Navigator.pop(context);
              _loadItems();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Item item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete "${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await ApiService.deleteItem(item.id);
              Navigator.pop(context);
              _loadItems();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Items'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? const Center(child: Text('No items yet. Tap + to add one.'))
              : ListView.builder(
                  itemCount: _items.length,
                  itemBuilder: (_, i) {
                    final item = _items[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: ListTile(
                        title: Text(
                          item.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(item.description),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.indigo),
                              onPressed: () => _showForm(item: item),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmDelete(item),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}