import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Admin_AddProductPage.dart';
import 'Admin_DeleteBrandPage.dart';
import 'Admin_DeleteProductPage.dart';
import 'Admin_OrderManagePage.dart';
import 'Admin_PorductViewPage.dart';
import 'Admin_ProductDetalisPage.dart';
import 'Admin_UpdateBrandPage.dart';
import 'Admin_UpdateProductPage.dart';
import 'Admin_VeiwBrandpage.dart';
import 'Admin_addBrand.dart';
import 'Admin_userslist.dart';

class AdminHomepage extends StatefulWidget {
  const AdminHomepage({super.key});

  @override
  State<AdminHomepage> createState() => _AdminHomepageState();
}

class _AdminHomepageState extends State<AdminHomepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE2D9FB),
      appBar: AppBar(
        backgroundColor: Color(0xFFE2D9FB),
        centerTitle: true,
        title: Text(
          'Admin Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.deepPurple.shade100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.deepPurple,
                    child: Icon(Icons.admin_panel_settings, size: 30, color: Colors.white),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Welcome Admin",
                    style: TextStyle(
                      color: Colors.deepPurple.shade900,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),

            _buildSectionTitle("User Management"),
            _buildListTile(Icons.person, "All Users", () => UserList()),

            _buildSectionTitle("Brand Management"),
            _buildListTile(Icons.add_business, "Add Brand", () => AddBrand()),
            _buildListTile(Icons.store, "View All Brand", () => Veiwbrand()),
            _buildListTile(Icons.update_rounded, "Update Brand", () => UpdateBrandPage()),
            _buildListTile(Icons.delete, "Delete Brand", () => DeleteBrandPage()),

            _buildSectionTitle("Product Management"),
            _buildListTile(Icons.shopping_bag, "Add New Product", () => AddProductPage()),
            _buildListTile(Icons.storefront, "View Product", () => ViewProductPage()),
            _buildListTile(Icons.update_rounded, "Update Product", () => UpdateProductPage()),
            _buildListTile(Icons.delete, "Delete Product", () => DeleteProductPage()),

            _buildSectionTitle("Orders"),
            _buildListTile(Icons.receipt_long, "Order Update", () => AdminOrderManagePage()),

            Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text("Logout", style: TextStyle(color: Colors.red)),
              onTap: () async {
                bool? confirm = await showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text("Confirm Logout"),
                    content: Text("Are you sure you want to logout?"),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: Text("Cancel")),
                      TextButton(onPressed: () => Navigator.pop(context, true), child: Text("Logout")),
                    ],
                  ),
                );
                if (confirm == true) {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacementNamed(context, '/');
                }
              },
            ),
            SizedBox(height: 20),
          ],
        ),
      ),

      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Product List', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Expanded(

              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('Products').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No Product Available'));
                  }

                  final products = snapshot.data!.docs;
                  return GridView.builder(
                    padding: EdgeInsets.all(12.0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12.0,
                      mainAxisSpacing: 12.0,
                      childAspectRatio: 0.68, // Slightly taller cards
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductDetalisPage(product: product)
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Image Section
                              ClipRRect(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
                                child: AspectRatio(
                                  aspectRatio: 1.2,
                                  child: Image.network(
                                    product['imageUrl'],
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    loadingBuilder: (context, child, progress) {
                                      if (progress == null) return child;
                                      return Center(child: CircularProgressIndicator());
                                    },
                                    errorBuilder: (context, error, stackTrace) => Center(child: Icon(Icons.broken_image)),
                                  ),
                                ),
                              ),

                              // Text Section
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product['Name'],
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 6),
                                      Text(
                                        "₹${product['Price']}",
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.green.shade700,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => AddProductPage()));
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }

  Widget _buildListTile(IconData icon, String title, Widget Function() pageBuilder) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(title),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => pageBuilder()));
      },
    );
  }
}