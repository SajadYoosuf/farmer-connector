import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:customer_app/providers/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

import 'package:geocoding/geocoding.dart';

class FarmerVerification extends StatefulWidget {
  const FarmerVerification({super.key});

  @override
  State<FarmerVerification> createState() => _FarmerVerificationState();
}

class _FarmerVerificationState extends State<FarmerVerification> {
  final ImagePicker _picker = ImagePicker();
  File? _aadharImage;
  File? _farmerIDImage;
  final TextEditingController _locationController = TextEditingController();
  bool _isSubmitting = false;
  bool _isLocating = false;

  Future<void> _getCurrentLocation() async {
    setState(() => _isLocating = true);
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Location services are disabled.'),
              action: SnackBarAction(
                label: 'Enable',
                onPressed: () => Geolocator.openLocationSettings(),
              ),
            ),
          );
        }
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied';
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied';
      } 

      Position position = await Geolocator.getCurrentPosition();
      
      // Converting coordinates to address string
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          setState(() {
            _locationController.text = "${place.subLocality}, ${place.locality}, ${place.administrativeArea} ${place.postalCode}";
          });
        }
      } catch (e) {
        // Fallback to coordinates if geocoding fails
        setState(() {
          _locationController.text = "${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}";
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location fetched successfully!")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  Future<void> _pickImage(bool isAadhar) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        if (isAadhar) {
          _aadharImage = File(image.path);
        } else {
          _farmerIDImage = File(image.path);
        }
      });
    }
  }

  Future<void> _submitVerification() async {
    if (_aadharImage == null || _farmerIDImage == null || _locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload all required documents and enter location')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final auth = context.read<AuthProvider>();
      final user = auth.currentUser;
      
      if (user != null) {
        // Here you would upload files to Firebase Storage and get URLs.
        // Update user status to 'pending' so next time they see the status screen
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'status': 'pending', 
          'verificationStatus': 'submitted',
          'landLocation': _locationController.text,
          'verificationSubmittedAt': FieldValue.serverTimestamp(),
          'aadharPath': _aadharImage!.path,
          'farmerIDPath': _farmerIDImage!.path,
        });
        
        if (mounted) {
          Navigator.popUntil(context, (r) => r.isFirst);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(154, 240, 85, 1),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 60),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Verification",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                    color: Color.fromRGBO(15, 87, 0, 1),
                  ),
                ),
                const Text(
                  "Upload documents for identity check",
                  style: TextStyle(
                    color: Color.fromRGBO(15, 87, 0, 1),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(25),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(50)),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    
                    _buildUploadTile(
                      title: "Aadhar Card",
                      subtitle: "Front & back scan recommended",
                      image: _aadharImage,
                      onTap: () => _pickImage(true),
                    ),
                    
                    const SizedBox(height: 25),
                    
                    _buildUploadTile(
                      title: "Farmer ID Card",
                      subtitle: "Government issued farmer identity",
                      image: _farmerIDImage,
                      onTap: () => _pickImage(false),
                    ),
                    
                    const SizedBox(height: 25),
                    
                    const Text(
                      "Land Location",
                      style: TextStyle(
                        color: Color.fromRGBO(165, 165, 165, 1),
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                      ),
                    ),
                    TextField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        hintText: "Enter village, pincode or coordinates",
                        hintStyle: const TextStyle(color: Color.fromRGBO(50, 54, 67, 1)),
                        prefixIcon: const Icon(Icons.location_on, color: Colors.green),
                        suffixIcon: _isLocating 
                          ? const SizedBox(width: 20, height: 20, child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2)))
                          : IconButton(
                              icon: const Icon(Icons.my_location, color: Colors.blue),
                              onPressed: _getCurrentLocation,
                              tooltip: "Fetch current location",
                            ),
                        border: const UnderlineInputBorder(),
                      ),
                    ),
                    
                    const SizedBox(height: 50),
                    
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(15, 87, 0, 1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _isSubmitting ? null : _submitVerification,
                        child: _isSubmitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "SUBMIT FOR VERIFICATION",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadTile({
    required String title,
    required String subtitle,
    File? image,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        Text(
          subtitle,
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey[300]!, width: 1),
            ),
            child: image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.file(image, fit: BoxFit.cover),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_upload_outlined, size: 40, color: Colors.green[700]),
                      const SizedBox(height: 8),
                      const Text("Tap to select image", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
