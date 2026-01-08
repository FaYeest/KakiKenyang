// lib/view/home/home_screen.dart
// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:kakikenyang/utils/colors.dart';
import 'package:kakikenyang/utils/text_styles.dart';
import 'package:kakikenyang/view/account/edit_profile.dart';
import 'package:kakikenyang/view/map/map_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  final Function(int)? onFeatureTap;
  const HomeScreen({super.key, this.onFeatureTap});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
/* -------------------------------------------------------------------------- */
/*  ➤  DATA STATIC                                                            */
  final List<Map<String, dynamic>> _features = [
    {'icon': Icons.map,    'label': 'Map'},
    {'icon': Icons.search, 'label': 'Cari Makanan'},
    {'icon': Icons.settings,'label': 'Settings'},
  ];

  List<VoidCallback> get _featureTaps => [
        () => widget.onFeatureTap?.call(2),
        () => widget.onFeatureTap?.call(1),
        () => widget.onFeatureTap?.call(3),
      ];

  // 3 asset bawaan ‑‑ dipakai saat Firestore belum punya data
  final List<String> _fallbackBanners = [
    'assets/images/banner1.jpg',
    'assets/images/banner2.jpg',
    'assets/images/banner3.jpg',
  ];

/* -------------------------------------------------------------------------- */
/*  ➤  STATE / CONTROLLER                                                    */
  List<String> _bannerUrls = [];                      // hasil Firestore
  StreamSubscription<QuerySnapshot>? _bannerSub;

  int _currentBanner = 0;
  final PageController   _bannerPageController = PageController(viewportFraction: .85);
  final ScrollController _scroll               = ScrollController();

/* -------------------------------------------------------------------------- */

  @override
  void initState() {
    super.initState();
    _listenBanners();                                 // ← start stream banner
  }

  @override
  void dispose() {
    _bannerSub?.cancel();                             //  stop stream
    _bannerPageController.dispose();
    _scroll.dispose();
    super.dispose();
  }

/* -------------------------------------------------------------------------- */
/*  ➤  FIRESTORE BANNER LISTENER                                              */
  void _listenBanners() {
    _bannerSub = FirebaseFirestore.instance
        .collection('banners')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .listen((snap) {
          final urls = snap.docs
              .map((d) => d['imageUrl'] as String?)
              .whereType<String>()
              .toList();
          setState(() => _bannerUrls = urls);
        });
  }

/* -------------------------------------------------------------------------- */
/*  ➤  STREAM FOTO PROFIL BUYER                                               */
  Stream<String?> _photoUrlStream() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Stream.empty();
    return FirebaseFirestore.instance
        .collection('buyers')
        .doc(uid)
        .snapshots()
        .map((d) => d.data()?['photoURL'] as String?);
  }

/* ========================================================================== */
/*                                BUILD UI                                    */
  @override
  Widget build(BuildContext context) {
    final isDark     = Theme.of(context).brightness == Brightness.dark;
    final background = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: background,
      body: CustomScrollView(
        controller: _scroll,
        slivers: [
          /* ------------------ APPBAR ------------------ */
          SliverAppBar(
            title: const Text('KakiKenyang'),
            centerTitle: true,
            floating: true,
            snap: true,
            elevation: 4,
            backgroundColor: background,
            actions: [
              StreamBuilder<String?>(
                stream: _photoUrlStream(),
                builder: (_, snap) {
                  final url = snap.data;
                  return IconButton(
                    icon: url != null && url.isNotEmpty
                        ? CircleAvatar(backgroundImage: NetworkImage(url), radius: 16)
                        : const Icon(Icons.account_circle_rounded, size: 28),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                    ),
                  );
                },
              ),
            ],
          ),

          /* ------------------ HEADER (fitur + banner) ------------------ */
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildFeatureRow(isDark),
                  const SizedBox(height: 24),
                  _buildBannerSlider(isDark),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          /* ------------------ TITLE ------------------ */
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Rekomendasi Jajanan',
                style: AppTextStyles.body16.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),

          /* ------------------ GRID MENU ------------------ */
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('menuItems').snapshots(),
            builder: (_, snap) {
              if (!snap.hasData) {
                return const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final docs = snap.data!.docs;
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: .75,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                      final d = docs[i].data() as Map<String, dynamic>;
                      return _buildMenuCard(
                        name    : d['name'] ?? '',
                        price   : (d['price'] as num?)?.toInt() ?? 0,
                        imageUrl: d['imageUrl'] ?? '',
                        ownerId : d['ownerId'] ?? d['tenantId'] ?? '',
                        isDark  : isDark,
                      );
                    },
                    childCount: docs.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

/* -------------------------------------------------------------------------- */
/*  ➤  WIDGET HELPER                                                          */
  Widget _buildFeatureRow(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(_features.length, (i) {
        final f = _features[i];
        return Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: _featureTaps[i],
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.orange.withValues(alpha: .2) : orange.withValues(alpha: 25 / 255),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(f['icon'], size: 32, color: isDark ? Colors.orange : orange),
                ),
                const SizedBox(height: 8),
                Text(f['label'],
                    style: AppTextStyles.body14.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    )),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildBannerSlider(bool isDark) {
    final list = _bannerUrls.isNotEmpty ? _bannerUrls : _fallbackBanners;

    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _bannerPageController,
            itemCount: list.length,
            onPageChanged: (i) => setState(() => _currentBanner = i),
            itemBuilder: (_, idx) => AnimatedBuilder(
              animation: _bannerPageController,
              builder: (_, _) {
                double scale = 1;
                if (_bannerPageController.position.haveDimensions) {
                  scale = (_bannerPageController.page ?? 0) - idx;
                  scale = (1 - (scale.abs() * .15)).clamp(.85, 1.0);
                }
                return Center(
                  child: Transform.scale(
                    scale: scale,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: list[idx].startsWith('http')
                            ? Image.network(
                                list[idx],
                                fit: BoxFit.cover,
                                height: 140,
                                width: double.infinity,
                                errorBuilder: (_, _, _) => _bannerPlaceholder(isDark),
                              )
                            : Image.asset(
                                list[idx],
                                fit: BoxFit.cover,
                                height: 140,
                                width: double.infinity,
                                errorBuilder: (_, _, _) => _bannerPlaceholder(isDark),
                              ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            list.length,
            (i) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentBanner == i
                    ? (isDark ? Colors.orange : orange)
                    : Colors.grey[400],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _bannerPlaceholder(bool isDark) => Container(
        height: 140,
        color: isDark ? Colors.grey[800] : Colors.grey[300],
        alignment: Alignment.center,
        child: Text('Banner', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
      );

  Widget _buildMenuCard({
    required String name,
    required int price,
    required String imageUrl,
    required String ownerId,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: ownerId.isEmpty
          ? null
          : () {
              context.read<MapState>().setOwner(ownerId);
              widget.onFeatureTap?.call(2);   // pindah ke tab Map
            },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black26 : orange.withValues(alpha: 25 / 255),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                imageUrl,
                height: 90,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  height: 90,
                  color: Colors.grey[200],
                  alignment: Alignment.center,
                  child: const Icon(Icons.fastfood),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: AppTextStyles.body14.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black)),
                  const SizedBox(height: 4),
                  Text('Rp $price',
                      style: AppTextStyles.body14
                          .copyWith(color: isDark ? Colors.orange[300] : orange)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

