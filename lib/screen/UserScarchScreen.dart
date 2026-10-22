import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ProductDescriptionPage.dart';

class Userscarchscreen extends StatefulWidget {
  const Userscarchscreen({super.key});

  @override
  State<Userscarchscreen> createState() => _UserscarchscreenState();
}

class _UserscarchscreenState extends State<Userscarchscreen> {
  final TextEditingController _searchController = TextEditingController();
  List<QueryDocumentSnapshot> _searchResult = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResult = []);
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance.collection('Products').get();
      setState(() {
        _searchResult = snapshot.docs
            .where((product) => product['Name']
            .toString()
            .toLowerCase()
            .contains(query.toLowerCase()))
            .toList();
      });
    } catch (e) {
      print("Search error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE2D9FB),
      appBar: AppBar(
        backgroundColor: Color(0xFFE2D9FB),
        title: Text(
          'Search Products',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.deepPurpleAccent,
            fontSize: 22,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _performSearch,
              decoration: InputDecoration(
                hintText: 'Search for amazing products...',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: Color(0xFF6B73FF),
                  size: 24,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: _searchResult.isEmpty
                ?  Center(
              child: Text(
                '🔎 Start typing to search products',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
                : ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 12),
              itemCount: _searchResult.length,
              itemBuilder: (context, index) {
                final product = _searchResult[index];
                final price =
                    double.tryParse(product['Price'].toString()) ?? 0.0;

                return Card(
                  margin:  EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 6,
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            product['imageUrl'],
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product['Name'] ?? 'Unnamed',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '₹ ${price.toStringAsFixed(2)}',
                                style: TextStyle(
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.w500),
                              ),
                              SizedBox(height: 4),
                              Text(
                                product['Description'] ?? '',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 13, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 12),
                        IconButton(
                          icon: Icon(Icons.arrow_forward_ios),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ProductDescriptionPage(
                                      productId: product.id,
                                      name: product['Name'],
                                      imageUrl: product['imageUrl'],
                                      price: price,
                                      description: product['Description'],
                                    ),
                              ),
                            );
                          },
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}