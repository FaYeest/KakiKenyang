import 'dart:convert';

import 'package:kakikenyang/view/map/map_state.dart';
import 'package:kakikenyang/view/navigationBar/nav_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/colors.dart';
import '../../utils/text_styles.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _ctrl = TextEditingController();
  final _historyKey = 'menu_history';

  List<Map<String, dynamic>> _history = [];
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs.getStringList(_historyKey) ?? [];
    _history = raw
        .map((e) => jsonDecode(e) as Map<String, dynamic>)
        .toList(growable: true);
    setState(() {});
  }

  Future<void> _addToHistory(Map<String, dynamic> menu) async {
    // Buat salinan untuk diubah
    final safeMenu = Map<String, dynamic>.from(menu);

    // Hapus field yang gak bisa diencode ke JSON
    safeMenu.removeWhere((key, value) => value is Timestamp);

    _history.removeWhere(
      (m) =>
          (m['name'] == safeMenu['name']) ||
          (m['id'] != null && m['id'] == safeMenu['id']),
    );
    _history.insert(0, safeMenu);
    if (_history.length > 10) _history = _history.sublist(0, 10);

    final encoded = _history.map((e) => jsonEncode(e)).toList();
    await _prefs.setStringList(_historyKey, encoded);
    setState(() {});
  }

  Widget _menuCard({
    required String name,
    required int price,
    required String imageUrl,
    required String ownerId,
    Map<String, dynamic>? originalData,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor = isDark ? Colors.grey[900] : Colors.white;
    final shadowColor = isDark ? Colors.black26 : orange.withValues(alpha: 30 / 255);
    final priceColor = isDark ? Colors.amberAccent : Colors.orange;

    return GestureDetector(
      onTap: () {
        if (ownerId.isNotEmpty) {
          if (originalData != null) _addToHistory(originalData);
          context.read<MapState>().setOwner(ownerId);
          globalNavController.jumpToTab(2); // Index ke-2 adalah Map
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Image.network(
                imageUrl,
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  height: 100,
                  color: isDark ? Colors.grey[800] : Colors.grey[200],
                  alignment: Alignment.center,
                  child: const Icon(Icons.fastfood, size: 32),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body14.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rp $price',
                    style: AppTextStyles.body14.copyWith(color: priceColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? Colors.black : Colors.white;

    return Scaffold(
      appBar: AppBar(title: const Text('Cari Menu'), centerTitle: true),
      body: Container(
        color: bg,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _ctrl,
              decoration: InputDecoration(
                hintText: 'Cari menu...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _ctrl.text.isEmpty
                  ? _buildHistoryList()
                  : _buildSearchResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList() {
    if (_history.isEmpty) {
      return const Center(child: Text('Belum ada riwayat'));
    }
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: .75,
      ),
      itemCount: _history.length,
      itemBuilder: (_, i) {
        final d = _history[i];
        return _menuCard(
          name: d['name'] ?? '',
          price: (d['price'] as num?)?.toInt() ?? 0,
          imageUrl: d['imageUrl'] ?? '',
          ownerId: d['ownerId'] ?? '',
          originalData: d,
        );
      },
    );
  }

  Widget _buildSearchResults() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('menuItems').snapshots(),
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snap.hasData || snap.data!.docs.isEmpty) {
          return const Center(child: Text('Tidak ada data menu'));
        }

        final docs = snap.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final name = data['name']?.toString().toLowerCase() ?? '';
          return name.contains(_ctrl.text.trim().toLowerCase());
        }).toList();

        if (docs.isEmpty) {
          return const Center(child: Text('Tidak ada hasil pencarian'));
        }

        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: .75,
          ),
          itemCount: docs.length,
          itemBuilder: (_, i) {
            final d = docs[i].data() as Map<String, dynamic>;
            d['id'] = docs[i].id;
            return _menuCard(
              name: d['name'] ?? '',
              price: (d['price'] as num?)?.toInt() ?? 0,
              imageUrl: d['imageUrl'] ?? '',
              ownerId: d['ownerId'] ?? '',
              originalData: d,
            );
          },
        );
      },
    );
  }
}

