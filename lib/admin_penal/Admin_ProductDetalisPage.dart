import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductDetalisPage extends StatelessWidget {
  final QueryDocumentSnapshot product;
  const ProductDetalisPage({Key?Key,required this.product});


  @override
  Widget build(BuildContext context) {
    final productData = product.data() as Map<String, dynamic>;

    final name = productData['Name'] ?? 'Unnamed Product';
    final imageUrl = productData['imageUrl'] ?? '';
    final brand = productData['Brand'] ?? 'No Brand Info';
    final price = productData['Price']?.toString() ?? '0';
    final sizes = (productData['Sizes'] as List?)?.join(', ') ?? 'N/A';
    final description = productData['Description'] ?? 'No Description';

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(title: Text(product['Name'],style: TextStyle(fontWeight: FontWeight.bold),),backgroundColor: Colors.grey.shade100,centerTitle: true,),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style:  TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                   SizedBox(height: 10),
                  Row(
                    children: [
                       Icon(Icons.local_offer, color: Colors.green),
                       SizedBox(width: 5),
                      Text('₹$price', style:  TextStyle(fontSize: 20, color: Colors.green)),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text('Brand:', style:  TextStyle(fontSize: 16,fontWeight: FontWeight.w600)),
                  Text(brand,style: TextStyle(fontSize: 15)),
                  SizedBox(height: 10),
                  Text('Available Sizes:', style:  TextStyle(fontSize: 16,fontWeight: FontWeight.w600)),
                  Text(sizes,style: TextStyle(fontSize: 15)),
                  Divider(height: 30),
                  Text('Product Description:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  SizedBox(height: 5),
                  Text(description, style: TextStyle(fontSize: 15)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


