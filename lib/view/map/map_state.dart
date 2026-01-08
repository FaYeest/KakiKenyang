import 'package:flutter/material.dart';

/// Menyimpan ownerId yang dipilih dari mana pun (Search / Home).
class MapState with ChangeNotifier {
  String? _ownerId;

  void setOwner(String id) {
    _ownerId = id;
    notifyListeners();
  }

  void clear() {
    _ownerId = null;
    notifyListeners();
  }

  // ✅ Tambahkan ini biar bisa dipanggil pakai .ownerId
  String? get ownerId => _ownerId;
}

