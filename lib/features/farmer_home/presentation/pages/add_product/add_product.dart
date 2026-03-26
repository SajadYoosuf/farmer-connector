import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:customer_app/features/auth/presentation/providers/auth_provider.dart';

class FarmerAddProduct extends StatefulWidget {
  final Map<String, dynamic>? productData;
  final String? productId;

  const FarmerAddProduct({super.key, this.productData, this.productId});

  @override
  State<FarmerAddProduct> createState() => _FarmerAddProductState();
}

class _FarmerAddProductState extends State<FarmerAddProduct> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _category = 'Fruits';
  double _price = 0;
  String _unit = '/kg';
  double _stock = 0;
  String _demand = 'Normal';
  bool _isLoading = false;
  File? _image;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.productData != null) {
      _name = widget.productData!['name'] ?? '';
      _category = widget.productData!['category'] ?? 'Fruits';
      _price = (widget.productData!['price'] ?? 0).toDouble();
      _unit = widget.productData!['unit'] ?? '/kg';
      _stock = (widget.productData!['stock'] ?? 0).toDouble();
      _demand = widget.productData!['demand'] ?? 'Normal';
    }
  }

  Future<void> _pickImage() async {
    final XFile? selected = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (selected != null) {
      setState(() {
        _image = File(selected.path);
      });
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (_image == null && widget.productId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a product image"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;

    try {
      final Map<String, dynamic> data = {
        'name': _name,
        'category': _category,
        'price': _price,
        'unit': _unit,
        'stock': _stock,
        'demand': _demand,
        'farmerId': user.uid,
        'farmerName': user.fullName ?? user.email,
        'isActive': true,
      };

      if (_image != null) {
        data['imageUrl'] = _image!.path;
      }

      if (widget.productId != null) {
        // UPDATE
        await FirebaseFirestore.instance.collection('products').doc(widget.productId).update(data);
      } else {
        // ADD NEW
        data['createdAt'] = FieldValue.serverTimestamp();
        await FirebaseFirestore.instance.collection('products').add(data);
      }

      // Log Activity
      await FirebaseFirestore.instance.collection('activities').add({
        'title': widget.productId != null ? 'Product Updated' : 'New Product Added',
        'description': '${user.fullName} ${widget.productId != null ? 'updated' : 'added'} $_name ${widget.productId != null ? 'details' : 'to their listings'}.',
        'type': 'product_update',
        'timestamp': FieldValue.serverTimestamp(),
        'userId': user.uid,
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Product ${widget.productId != null ? 'updated' : 'added'} successfully!")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error adding product: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.productId != null ? "Edit Product" : "Add New Product",
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color.fromRGBO(15, 87, 0, 1),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // IMAGE PICKER SECTION
                    const Text(
                      "Product Image",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 180,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.black.withOpacity(0.05),
                          ),
                        ),
                        child: _image != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.file(_image!, fit: BoxFit.contain),
                              )
                            : (widget.productData?['imageUrl'] != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: widget.productData!['imageUrl']
                                            .startsWith('http')
                                        ? Image.network(
                                            widget.productData!['imageUrl'],
                                            fit: BoxFit.contain)
                                        : Image.file(
                                            File(
                                                widget.productData!['imageUrl']),
                                            fit: BoxFit.contain),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_photo_alternate_outlined,
                                        size: 50,
                                        color: Colors.green.shade400,
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        "Tap to select image",
                                        style: TextStyle(color: Colors.black45),
                                      ),
                                    ],
                                  )),
                      ),
                    ),

                    const SizedBox(height: 30),
                    const Text(
                      "Basic Details",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildTextField("Product Name", (val) => _name = val!, initial: _name),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      value: _category,
                      decoration: _inputDecoration("Category"),
                      items:
                          [
                                "Category",
                                "Fruits",
                                "Vegetables",
                                "Meat",
                                "Home Made",
                                "Dairy",
                              ]
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
                              )
                              .toList(),
                      onChanged: (val) => _category = val!,
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            "Price (₹)",
                            (val) => _price = double.parse(val!),
                            isNumber: true,
                            initial: _price.toString(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _unit,
                            decoration: _inputDecoration("Unit"),
                            items:
                                ["/kg", "/gram", "/quintal", "/liter", "/piece"]
                                    .map(
                                      (e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(e),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (val) => _unit = val!,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      "Available Stock",
                      (val) => _stock = double.parse(val!),
                      isNumber: true,
                      initial: _stock.toString(),
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      value: _demand,
                      decoration: _inputDecoration("Estimated Demand"),
                      items: ["Normal", "High Demand", "Scarce"]
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      onChanged: (val) => _demand = val!,
                    ),
                    const SizedBox(height: 40),

                    ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff99f251),
                        foregroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 55),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        widget.productId != null ? "Update Listing" : "Save & Publish Listing",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black54),
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xff99f251), width: 2),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    Function(String?) onSave, {
    bool isNumber = false,
    String? initial,
  }) {
    return TextFormField(
      initialValue: initial,
      decoration: _inputDecoration(label),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      validator: (val) => val == null || val.isEmpty ? "Required" : null,
      onSaved: onSave,
    );
  }
}
