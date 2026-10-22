import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Admin_ProductDetalisPage.dart';
import 'package:intl/intl.dart';

class ViewProductPage extends StatefulWidget {
  const ViewProductPage({super.key});

  @override
  State<ViewProductPage> createState() => _ViewProductPageState();
}

class _ViewProductPageState extends State<ViewProductPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String formatPrice(String priceString) {
    try {
      final price = double.parse(priceString);
      final formatCurrency = NumberFormat.simpleCurrency(locale: 'en_IN');
      return formatCurrency.format(price);
    }
    catch (e) {
      return priceString.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.grey.shade100,
        elevation: 0,
        title:Text('View Products', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('Products').orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshots) {
          if (snapshots.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshots.hasData || snapshots.data!.docs.isEmpty) {
            return Center(
              child: Text('No Products Available', style: TextStyle(fontSize: 18),),
            );
          }

          final products = snapshots.data!.docs;

          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 8),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12),),
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                elevation: 3,
                child: ListTile(
                  contentPadding: EdgeInsets.all(10),
                  leading: Hero(
                    tag: product['imageUrl'],
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.network(
                        product['imageUrl'],
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image),
                      ),
                    ),
                  ),
                  title: Text(product['Name'] ?? '',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  subtitle: Text(formatPrice(product['Price'].toString()),
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, size: 18),
                  onTap: () {
                    Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ProductDetalisPage(product: product),),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
