import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_animate/flutter_animate.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  File? _selectedImage;
  bool _isLoading = false;
  final user = FirebaseAuth.instance.currentUser;
  final firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserData();
  }

  Future<void> _loadCurrentUserData() async {
    final userData = await firestore.collection('users').doc(user?.uid).get();
    if (userData.exists) {
      setState(() {
        _nameController.text = userData.data()?['name'] ?? user?.displayName ?? '';
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name cannot be empty')),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      // Update Firestore
      await firestore.collection('users').doc(user?.uid).update({
        'name': _nameController.text,
        'username': _nameController.text.toLowerCase().replaceAll(' ', '_'),
      });

      // Update Firebase Auth profile
      await user?.updateDisplayName(_nameController.text);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.indigo[900]!,
              Colors.purple[900]!,
              Colors.blue[900]!,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back Button and Title
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        'Edit Profile',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30.h),

                  // Profile Image Display (read-only for now)
                  Center(
                    child: Container(
                      width: 120.w,
                      height: 120.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue[400]!,
                            Colors.purple[400]!,
                          ],
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(3.r),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: user?.photoURL != null
                                  ? NetworkImage(user!.photoURL!) as ImageProvider
                                  : const AssetImage('assets/images/default_avatar.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30.h),
                  
                  // Email Field (Read-only)
                  TextField(
                    enabled: false,
                    controller: TextEditingController(text: user?.email ?? ''),
                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16.sp),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.r),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.r),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  
                  // Name TextField
                  TextField(
                    controller: _nameController,
                    style: TextStyle(color: Colors.white, fontSize: 16.sp),
                    decoration: InputDecoration(
                      labelText: 'Name',
                      labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.r),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.r),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                      helperText: 'This will be used as your display name and username',
                      helperStyle: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                  SizedBox(height: 30.h),
                  
                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 55.h,
                    child: Stack(
                      children: [
                        // Animated gradient background
                        Animate(
                          effects: [
                            ShimmerEffect(
                              duration: const Duration(seconds: 2),
                              color: Colors.white.withOpacity(0.2),
                              curve: Curves.easeInOut,
                            ),
                          ],
                          onPlay: (controller) => controller.repeat(),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.blue[600]!,
                                  Colors.purple[600]!,
                                  Colors.blue[600]!,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(15.r),
                              boxShadow: [
                                // Inner glow
                                BoxShadow(
                                  color: Colors.blue[400]!.withOpacity(0.5),
                                  blurRadius: 15,
                                  spreadRadius: -3,
                                  offset: const Offset(0, 0),
                                ),
                                // Outer glow
                                BoxShadow(
                                  color: Colors.purple[400]!.withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 0,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        // Button with glass effect
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _isLoading ? null : _saveProfile,
                            borderRadius: BorderRadius.circular(15.r),
                            splashColor: Colors.white.withOpacity(0.2),
                            highlightColor: Colors.transparent,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15.r),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                ),
                              ),
                              child: Center(
                                child: _isLoading
                                    ? SizedBox(
                                        height: 24.h,
                                        width: 24.h,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                          backgroundColor: Colors.white.withOpacity(0.2),
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'SAVE CHANGES',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1.2,
                                            ),
                                          ).animate(onPlay: (controller) => controller.repeat())
                                           .shimmer(
                                             duration: const Duration(seconds: 2),
                                             color: Colors.white.withOpacity(0.2),
                                           ),
                                          SizedBox(width: 8.w),
                                          Icon(
                                            Icons.save_rounded,
                                            color: Colors.white,
                                            size: 20.sp,
                                          ).animate(onPlay: (controller) => controller.repeat())
                                           .shimmer(
                                             duration: const Duration(seconds: 2),
                                             color: Colors.white.withOpacity(0.2),
                                           ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
} 