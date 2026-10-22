import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class Wishlistscreen extends StatefulWidget {
  const Wishlistscreen({super.key});

  @override
  State<Wishlistscreen> createState() => _WishlistscreenState();
}

class _WishlistscreenState extends State<Wishlistscreen> {

  Future<void> _removedFromWishList(String decId) async{
    await FirebaseFirestore.instance.collection('WishList').doc(decId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE2D9FB),
      appBar: AppBar(
        backgroundColor: Color(0xFFE2D9FB),
        elevation: 0,
        title: Text(
          'WishList',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.deepPurpleAccent,
            fontSize: 22,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('WishList').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children:  [
                  Icon(Icons.star_border, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    "Your Wish List Is Empty",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Start adding favorites now!",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final wishListItems = snapshot.data!.docs;
          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: wishListItems.length,
            itemBuilder: (context, index) {
              final item = wishListItems[index];

              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Icon(Icons.favorite, color: Colors.purpleAccent),
                  title: Text(
                    item['productName'],
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  trailing: IconButton(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Delete Wishlist Item'),
                          content: Text('Are you sure you want to remove "${item['productName']}" from your wishlist?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await _removedFromWishList(item.id);
                        Get.snackbar(
                          "Wishlist Deleted",
                          "${item['productName']} has been removed",
                          icon: Icon(Icons.delete_forever, color: Colors.red),
                          colorText: Colors.red,
                          snackPosition: SnackPosition.TOP,
                          margin: EdgeInsets.all(12),
                          duration: Duration(seconds: 3),
                        );
                      }
                    },
                    icon: Icon(Icons.delete_forever, color: Colors.redAccent),
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
