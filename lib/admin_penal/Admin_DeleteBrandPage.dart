import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class DeleteBrandPage extends StatefulWidget {
  const DeleteBrandPage({super.key});

  @override
  State<DeleteBrandPage> createState() => _DeleteBrandPageState();
}

class _DeleteBrandPageState extends State<DeleteBrandPage> {
  List<QueryDocumentSnapshot> _brands = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchBrands();
  }

  Future<void> _fetchBrands() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('Brands').get();
      setState(() {
        _brands = snapshot.docs;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _deleteBrand(String brandId) async {
    setState(() {
      isLoading = true;
    });
    try {
      final batch = FirebaseFirestore.instance.batch();

      final brandRef = FirebaseFirestore.instance.collection('Brands').doc(brandId);
      batch.delete(brandRef);

      final productsSnapshot = await FirebaseFirestore.instance.collection('Products').where('brandId', isEqualTo: brandId).get();

      for (final product in productsSnapshot.docs) {
        final productRef = FirebaseFirestore.instance
            .collection('products')
            .doc(product.id);
        batch.delete(productRef);
      }

      await batch.commit();
      Get.snackbar("Successfully Delecte", "Brand successfully Deleted", colorText: Colors.green);

      await _fetchBrands();
    } catch (e) {
      Get.snackbar("Something went wrong","Please Show Data",colorText: Colors.red);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Delete Brand')),

      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : _brands.isEmpty
          ? Center(child: Text(
        'No Brands Available',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ))
          : ListView.builder(
        itemCount: _brands.length,
        padding: EdgeInsets.all(12),
        itemBuilder: (context, index) {
          final brand = _brands[index];
          final brandData = brand.data() as Map<String, dynamic>;
          final brandName = brandData['Name'] ?? 'Unnamed Brand';
          final logoUrl = brandData['imageUrl'];

          return Card(
            elevation: 3,
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              contentPadding:  EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                radius: 25,
                backgroundImage: logoUrl != null
                    ? NetworkImage(logoUrl)
                    : AssetImage('assets/default_logo.png') as ImageProvider,
              ),
              title: Text(
                brandName,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.redAccent),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Delete Brand'),
                      content: Text('Are you sure you want to delete this brand?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child:  Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: TextButton.styleFrom(
                            foregroundColor: Theme.of(context).colorScheme.error,
                          ),
                          child: Text('Delete'),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    await _deleteBrand(brand.id);
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }
}