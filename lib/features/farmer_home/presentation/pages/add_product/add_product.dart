import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:customer_app/features/auth/presentation/providers/auth_provider.dart';

class FarmerAddProduct extends StatefulWidget {
  const FarmerAddProduct({super.key});

  @override
  State<FarmerAddProduct> createState() => _FarmerAddProductState();
}

class _FarmerAddProductState extends State<FarmerAddProduct> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _category = 'Fresh Crops';
  double _price = 0;
  String _unit = '/kg';
  double _stock = 0;
  String _demand = 'Normal';
  bool _isLoading = false;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance.collection('products').add({
        'name': _name,
        'category': _category,
        'price': _price,
        'unit': _unit,
        'stock': _stock,
        'demand': _demand,
        'farmerId': user.uid,
        'farmerName': user.fullName ?? user.email,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      // Log Activity
      await FirebaseFirestore.instance.collection('activities').add({
         'title': 'New Product Added',
         'description': '${user.fullName} added $_name to their listings.',
         'type': 'product_update',
         'timestamp': FieldValue.serverTimestamp(),
         'userId': user.uid,
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Product added successfully!")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error adding product: $e")),
        );
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
        title: const Text("Add New Product", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                   const Text("Basic Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                   const SizedBox(height: 20),
                   
                   _buildTextField("Product Name", (val) => _name = val!),
                   const SizedBox(height: 16),
                   
                   DropdownButtonFormField<String>(
                     value: _category,
                     decoration: _inputDecoration("Category"),
                     items: ["Fresh Crops", "Cereals", "Fruits", "Vegetables", "Spices"]
                        .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                     onChanged: (val) => _category = val!,
                   ),
                   const SizedBox(height: 16),
                   
                   Row(
                     children: [
                       Expanded(child: _buildTextField("Price (₹)", (val) => _price = double.parse(val!), isNumber: true)),
                       const SizedBox(width: 12),
                       Expanded(
                         child: DropdownButtonFormField<String>(
                           value: _unit,
                           decoration: _inputDecoration("Unit"),
                           items: ["/kg", "/gram", "/quintal", "/liter", "/piece"]
                              .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                           onChanged: (val) => _unit = val!,
                         ),
                       ),
                     ],
                   ),
                   const SizedBox(height: 16),
                   
                   _buildTextField("Available Stock", (val) => _stock = double.parse(val!), isNumber: true),
                   const SizedBox(height: 16),
                   
                   DropdownButtonFormField<String>(
                     value: _demand,
                     decoration: _inputDecoration("Estimated Demand"),
                     items: ["Normal", "High Demand", "Scarce"]
                        .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                     onChanged: (val) => _demand = val!,
                   ),
                   const SizedBox(height: 40),
                   
                   ElevatedButton(
                     onPressed: _submit,
                     style: ElevatedButton.styleFrom(
                       backgroundColor: const Color.fromRGBO(102, 255, 0, 1),
                       foregroundColor: Colors.black,
                       minimumSize: const Size(double.infinity, 55),
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                     ),
                     child: const Text("Save & Publish", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                   ),
                ],
              ),
            ),
          ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _buildTextField(String label, Function(String?) onSave, {bool isNumber = false}) {
    return TextFormField(
      decoration: _inputDecoration(label),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      validator: (val) => val == null || val.isEmpty ? "Required" : null,
      onSaved: onSave,
    );
  }
}
