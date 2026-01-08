// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:kakikenyang/controller/services/imageServices/image_picker_services.dart';
import 'package:kakikenyang/controller/services/userServices/user_services.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final user = FirebaseAuth.instance.currentUser!;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  File? _newAvatar;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = user.displayName ?? '';
    _emailController.text = user.email ?? '';
    _phoneController.text = user.phoneNumber ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final file = await ImagePickerServices.pickSingleImage();
    if (file != null) {
      setState(() {
        _newAvatar = file;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      String? avatarUrl = user.photoURL;

      // Upload avatar jika ada perubahan
      if (_newAvatar != null) {
        final uploadedUrls = await ImagePickerServices.uploadImages(
          context: context,
          images: [_newAvatar!],
        );
        if (uploadedUrls.isNotEmpty) {
          avatarUrl = uploadedUrls.first;
        }
      }

      // Update FirebaseAuth
      await user.updateDisplayName(_nameController.text.trim());
      if (avatarUrl != null) {
        await user.updatePhotoURL(avatarUrl);
      }

      // Update Firestore
      await FirebaseFirestore.instance
          .collection('buyers')
          .doc(user.uid)
          .set({
        'displayName': _nameController.text.trim(),
        'photoURL': avatarUrl ?? '',
        'email': user.email ?? '',
        'phoneNumber': user.phoneNumber ?? '',
      }, SetOptions(merge: true));

      // (Opsional) sync ulang profile ke cache lokal
      await UserServices.initBuyerProfile();

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui!')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui profil: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;
    if (_newAvatar != null) {
      imageProvider = FileImage(_newAvatar!);
    } else if (user.photoURL != null && user.photoURL!.isNotEmpty) {
      imageProvider = NetworkImage(user.photoURL!);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 24),
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: Colors.amber.shade700,
                      backgroundImage: imageProvider,
                      child: imageProvider == null
                          ? const Icon(Icons.person, size: 60, color: Colors.white)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black12, blurRadius: 4),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.amber),
                          onPressed: _pickAvatar,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                enabled: false,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _phoneController,
                enabled: false,
                decoration: const InputDecoration(
                  labelText: 'No. Telepon',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Simpan Perubahan',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

