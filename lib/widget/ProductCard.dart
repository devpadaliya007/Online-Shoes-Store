import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class ProductCard extends StatelessWidget {
  final String name;
  final String imageUrl;
  final double price;
  final String offerTag;
  final VoidCallback onTap;
  const ProductCard({super.key, required this.name, required this.imageUrl, required this.price, required this.offerTag,required this.onTap,});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child:Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(7.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              'https://tse3.mm.bing.net/th/id/OIP.nflAMd8rFgyQ-Dc-PzpFCwHaHa?pid=Api&P=0&h=180',
              fit: BoxFit.cover,
              width: double.maxFinite,
              height: 120,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.image_not_supported, size: 300);
              },
            ),
            SizedBox(height: 9),
            Text(
              name,
              style: TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,),
            SizedBox(height: 9),
            Text(
              'Rs : $price',
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Color(0xFFCE93D8),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                offerTag,
                style: const TextStyle(color: Color(0xFFAB47BC), fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}