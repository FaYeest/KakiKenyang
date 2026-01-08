// lib/services/image_picker_services.dart
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ImagePickerServices {
  static final ImagePicker _picker = ImagePicker();
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final _auth = FirebaseAuth.instance;

  /// Pick multiple images from gallery
  static Future<List<File>> pickImages(BuildContext context) async {
    final picked = await _picker.pickMultiImage(imageQuality: 90);

    if (picked.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak ada gambar yang dipilih')),
        );
      }
      return [];
    }
    return picked.map((x) => File(x.path)).toList();
  }

  /// Upload list of [images] and return their download URLs
  static Future<List<String>> uploadImages({
    required BuildContext context,
    required List<File> images,
  }) async {
    if (images.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak ada gambar yang dipilih.')),
        );
      }
      return [];
    }

    final List<String> urls = [];
    final String uid = _auth.currentUser!.uid;

    for (final file in images) {
      try {
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(1000)}.jpg';

        final ref = _storage
            .ref()
            .child('buyers/$uid/banners/$fileName'); // ← sesuaikan folder

        final UploadTask task = ref.putFile(file);
        final url = await (await task).ref.getDownloadURL();
        urls.add(url);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal upload 1 gambar: $e')),
          );
        }
      }
    }
    return urls;
  }

  /// (Opsional) pick single image
  static Future<File?> pickSingleImage() async {
    final x = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    return x == null ? null : File(x.path);
  }
}

