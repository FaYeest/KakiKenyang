// lib/view/map/map_screen.dart
import 'dart:async';

import 'package:kakikenyang/utils/colors.dart';
import 'package:kakikenyang/view/map/map_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key}); // ← ownerId DIHAPUS

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  /* ───────── controller & pos user ───────── */
  GoogleMapController? _ctrl;
  LatLng? _myPos;

  /* ───────── marker & data cache ───────── */
  final Map<String, Marker> _liveMarkers = {};
  final Map<String, Map<String, dynamic>> _tenantInfo = {};

  StreamSubscription<QuerySnapshot>? _sub;

  /* uid tenant yg “menunggu” difokuskan */
  String? _pendingOwner;

  /* ───────── dark‑style json ───────── */
  static const _darkStyle = '''
  [
    {"elementType":"geometry","stylers":[{"color":"#202124"}]},
    {"elementType":"labels.text.fill","stylers":[{"color":"#9aa0a6"}]},
    {"elementType":"labels.text.stroke","stylers":[{"color":"#202124"}]},
    {"featureType":"poi","stylers":[{"visibility":"off"}]},
    {"featureType":"road","elementType":"geometry","stylers":[{"color":"#3c4043"}]},
    {"featureType":"transit","stylers":[{"visibility":"off"}]},
    {"featureType":"water","elementType":"geometry","stylers":[{"color":"#0f252e"}]}
  ]
  ''';

  /* =================================================================== */
  /*                            LIFECYCLE                                */
  /* =================================================================== */
  @override
  void initState() {
    super.initState();
    _initMe();
    _listenLive();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // tangkap ownerId terbaru dari MapState
    final owner = context.watch<MapState>().ownerId;
    if (owner != null && owner != _pendingOwner) {
      _pendingOwner = owner;
      _focusOnTenant(owner);
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  /* =================================================================== */
  /*                           LOCATION + STREAM                         */
  /* =================================================================== */
  Future<void> _initMe() async {
    final p = await Permission.location.request();
    if (p.isDenied || p.isPermanentlyDenied) return;

    final pos = await Geolocator.getCurrentPosition();
    setState(() => _myPos = LatLng(pos.latitude, pos.longitude));
  }

  void _listenLive() {
    _sub = FirebaseFirestore.instance
        .collection('live_locations')
        .snapshots()
        .listen((snap) async {
          for (final doc in snap.docs) {
            final data = doc.data();
            final uid = doc.id;
            final lat = (data['latitude'] as num?)?.toDouble();
            final lng = (data['longitude'] as num?)?.toDouble();
            if (lat == null || lng == null) continue;

            _liveMarkers[uid] = Marker(
              markerId: MarkerId(uid),
              position: LatLng(lat, lng),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueOrange,
              ),
              onTap: () => _showSheet(uid),
            );

            // cache tenant hanya sekali
            if (!_tenantInfo.containsKey(uid)) {
              final t = await FirebaseFirestore.instance
                  .collection('tenants')
                  .doc(uid)
                  .get();
              if (t.exists) _tenantInfo[uid] = t.data()!;
            }
          }
          if (mounted) setState(() {});

          // kalau setelah stream marker baru muncul & masih ada pending
          if (_pendingOwner != null) _focusOnTenant(_pendingOwner!);
        });
  }

  /* =================================================================== */
  /*                            FOCUS LOGIC                              */
  /* =================================================================== */
  void _focusOnTenant(String uid) {
    final marker = _liveMarkers[uid];
    if (marker != null && _ctrl != null) {
      _ctrl!
          .animateCamera(CameraUpdate.newLatLngZoom(marker.position, 16))
          .then((_) => _showSheet(uid));

      // clear setelah build selesai
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<MapState>().clear();
      });

      _pendingOwner = null;
    }
  }

  /* =================================================================== */
  /*                       UI & BOTTOM‑SHEET                             */
  /* =================================================================== */
  void _showSheet(String uid) {
    final ten = _tenantInfo[uid];
    if (ten == null) return;

    final pos = _liveMarkers[uid]?.position;
    final dark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: dark ? Colors.grey[900] : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _TenantSheet(
        ten: ten,
        dark: dark,
        lat: pos?.latitude,
        lng: pos?.longitude,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Peta UMKM'),
        backgroundColor: dark ? Colors.black : Colors.white,
        foregroundColor: dark ? Colors.white : Colors.black,
      ),
      body: GoogleMap(
        style: dark ? _darkStyle : null,
        initialCameraPosition: CameraPosition(
          target: _myPos ?? const LatLng(-6.9, 107.6),
          zoom: 14,
        ),
        markers: _liveMarkers.values.toSet()
          ..addAll({
            if (_myPos != null)
              Marker(
                markerId: const MarkerId('me'),
                position: _myPos!,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  dark ? BitmapDescriptor.hueCyan : BitmapDescriptor.hueAzure,
                ),
              ),
          }),
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        onMapCreated: (c) {
          _ctrl = c;
        },
      ),
      floatingActionButton: PhysicalModel(
        elevation: 6,
        shape: BoxShape.circle,
        color: Colors.transparent,
        child: FloatingActionButton(
          backgroundColor: buttonColor,
          foregroundColor: white,
          onPressed: () {
            if (_myPos != null) {
              _ctrl?.animateCamera(CameraUpdate.newLatLngZoom(_myPos!, 15));
            }
          },
          child: const Icon(Icons.my_location),
        ),
      ),
    );
  }
}

/* ─────────── bottom sheet (tidak berubah) ─────────── */
class _TenantSheet extends StatelessWidget {
  final Map<String, dynamic> ten;
  final bool dark;
  final double? lat, lng;
  const _TenantSheet({
    required this.ten,
    required this.dark,
    this.lat,
    this.lng,
  });

  @override
  Widget build(BuildContext context) {
    final tc = dark ? Colors.white : Colors.black87;
    // ... isi sama seperti versi Anda ...
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          if (ten['bannerUrl'] != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                ten['bannerUrl'],
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          const SizedBox(height: 12),
          Text(
            ten['name'] ?? 'UMKM',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: tc,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            ten['description'] ?? 'Tidak ada deskripsi',
            style: TextStyle(color: tc.withValues(alpha: .8)),
          ),
          const SizedBox(height: 8),
          if (ten['address'] != null)
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 20,
                  color: Colors.redAccent.shade200,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(ten['address'], style: TextStyle(color: tc)),
                ),
              ],
            ),
          const SizedBox(height: 4),
          if (ten['phone'] != null)
            Row(
              children: [
                Icon(Icons.phone, size: 20, color: Colors.green.shade300),
                const SizedBox(width: 4),
                Text(ten['phone'], style: TextStyle(color: tc)),
              ],
            ),
          const SizedBox(height: 16),
          if (lat != null && lng != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.directions),
                label: const Text('Arahkan ke lokasi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  final uri = Uri.parse(
                    'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
                  );
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                },
              ),
            ),
        ],
      ),
    );
  }
}

