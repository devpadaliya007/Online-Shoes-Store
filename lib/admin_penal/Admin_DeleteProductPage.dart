import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class DeleteProductPage extends StatefulWidget {
  const DeleteProductPage({super.key});

  @override
  State<DeleteProductPage> createState() => _DeleteProductPageState();
}

class _DeleteProductPageState extends State<DeleteProductPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _deleteProduct(String productId) async {
    try {
      await _firestore.collection('Products').doc(productId).delete();
      Get.snackbar("Successfully Delecte", "Product successfully Deleted", colorText: Colors.green);

    } catch (e) {
      Get.snackbar("Something went wrong","Please Show Data",colorText: Colors.red);
    }
  }

  void _showDeleteDialog(String productId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Product"),
        content: Text("Are you sure you want to delete this product?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              //call
              _deleteProduct(productId);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        title: Text("All Products"),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('Products').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          var products = snapshot.data!.docs;
          if (products.isEmpty) {
            return Center(child: Text("No products available"));
          }

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              var product = products[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: product['imageUrl'] != null && product['imageUrl'].isNotEmpty ? NetworkImage(product['imageUrl']) : null,
                    child: product['imageUrl'] == null || product['imageUrl'].isEmpty ? Icon(Icons.image, size: 28, color: Colors.grey) : null,
                  ),
                  title: Text(product['Name'] ?? 'Unnamed Product'),
                  subtitle: Text("Price: ₹${product['Price'] ?? '0'}"),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _showDeleteDialog(product.id),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
