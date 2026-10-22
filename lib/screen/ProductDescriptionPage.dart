import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'ReviewandComment.dart';


class ProductDescriptionPage extends StatefulWidget {
  final String productId;
  final String name;
  final String imageUrl;
  final double price;
  final String description;

  const ProductDescriptionPage({
    super.key,
    required this.productId,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.description,
  });

  @override
  State<ProductDescriptionPage> createState() => _ProductDescriptionPageState();
}

class _ProductDescriptionPageState extends State<ProductDescriptionPage> {
  int _quantity = 1;
  bool _isWishlist = false;
  List<String> _sizes=[];
  String? _selectSizes;
  bool _isLoading = false;


  double get _finalPrice => widget.price * _quantity;
  String get _userId{
    final user=FirebaseAuth.instance.currentUser;
    return user?.uid??'guestUser';
  }

  void initState(){
    _checkWishlistStatus();
    _fetchProductSizes();
  }

  Future<void> _fetchProductSizes() async{
    final productDoc=await FirebaseFirestore.instance.collection('Products').doc(widget.productId).get();
    if(productDoc.exists&&productDoc.data()?['Sizes']!=null){
      setState(() {
        _sizes=List<String>.from(productDoc.data()?['Sizes']);
        if(_sizes.isNotEmpty){
          _selectSizes=_sizes.first;
        }
      });
    }
  }

  Future<void> _checkWishlistStatus() async {
    final wishlistRef = FirebaseFirestore.instance.collection('WishList');
    final snapshot = await wishlistRef
        .where('productId', isEqualTo: widget.productId)
        .where('userId', isEqualTo: _userId)
        .get();

    setState(() {
      _isWishlist = snapshot.docs.isNotEmpty;
    });
  }


  Future<void> _toggleWishList() async {
    final wishlistRef = FirebaseFirestore.instance.collection('WishList');

    if (_isWishlist) {
      final snapshot = await wishlistRef
          .where('productId', isEqualTo: widget.productId)
          .where('userId', isEqualTo: _userId)
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }

      setState(() => _isWishlist = false);

      Get.snackbar(
        "Wishlist Updated",
        "${widget.name} removed from wishlist!",
        colorText: Colors.red,
        margin: EdgeInsets.all(12),
        duration: Duration(seconds: 2),
        icon: Icon(Icons.favorite_border, color: Colors.grey),
      );
    } else {
      await wishlistRef.add({
        'productId': widget.productId,
        'productName': widget.name,
        'userId': _userId,
        'createdAt': Timestamp.now(),
      });

      setState(() => _isWishlist = true);

      Get.snackbar(
        "Wishlist Updated",
        "${widget.name} added to wishlist!",
        colorText: Colors.green,
        margin: EdgeInsets.all(12),
        duration: Duration(seconds: 2),
        icon: Icon(Icons.favorite, color: Colors.red),
      );
    }
  }


  void _incrementQuantity() => setState(() => _quantity++);
  void _decrementQuantity() {
    if (_quantity > 1) setState(() => _quantity--);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE2D9FB),

      floatingActionButton: FloatingActionButton(

        onPressed: _toggleWishList,
        backgroundColor: Colors.white,
        child: Icon(
          _isWishlist ? Icons.favorite : Icons.favorite_border,
          color: _isWishlist ? Colors.red : Colors.grey,
        ),
      ),
      appBar: AppBar(
        backgroundColor: Color(0xFFE2D9FB),
        elevation: 0,
        centerTitle: true,
        title: Text(widget.name, style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black, fontSize: 20,),),
      ),
      body: ListView(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
            child: Image.network(
              widget.imageUrl,
              height: 380,
              width: 10,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stackTrace) => Center(child: Icon(Icons.broken_image)),
            ),
          ),

          SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //name
                Text(widget.name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),


                //description
                SizedBox(height: 8),
                Text("Description:",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17),),
                SizedBox(height: 5),
                Text(widget.description, style: TextStyle(fontSize: 16, height: 1.5)),

                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 5,
                        color: Colors.grey.shade300,
                        offset: Offset(0, 2),
                      )
                    ],
                  ),

                  //Price
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Price: ₹${widget.price.toStringAsFixed(2)}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                      Text('Total: ₹${_finalPrice.toStringAsFixed(2)}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo)),
                    ],
                  ),
                ),

                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: _decrementQuantity,
                      icon: Icon(Icons.remove_circle_outline, color: Colors.red),
                    ),
                    Text('$_quantity',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    IconButton(
                      onPressed: _incrementQuantity,
                      icon: Icon(Icons.add_circle_outline, color: Colors.green),
                    ),
                  ],
                ),

                //size
                if (_sizes.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text("Select Size",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _sizes.map((size) {
                      return ChoiceChip(
                        label: Text(size),
                        selected: _selectSizes == size,
                        onSelected: (_) {
                          setState(() => _selectSizes = size);
                        },
                        selectedColor: Colors.deepPurple,
                        labelStyle: TextStyle(
                            color: _selectSizes == size
                                ? Colors.white
                                : Colors.black),
                      );
                    }).toList(),
                  ),
                ],

                //addtocart
                SizedBox(height: 30),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: Icon(Icons.shopping_cart_outlined, color: Colors.white),
                  label: _isLoading
                      ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : Text(
                    "Add to Cart",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  onPressed: _isLoading
                      ? null
                      : () async {
                    if (_selectSizes == null && _sizes.isNotEmpty) {
                      Get.snackbar(
                        "Size Required",
                        "Please select a size before adding to cart.",
                        colorText: Colors.red,
                        margin: EdgeInsets.all(12),
                      );
                      return;
                    }

                    setState(() {
                      _isLoading = true;
                    });

                    try {
                      await FirebaseFirestore.instance.collection('Cart').add({
                        'userId': _userId,
                        'productId': widget.productId,
                        'productName': widget.name,
                        'imageUrl': widget.imageUrl,
                        'price': widget.price,
                        'quantity': _quantity,
                        'Size': _selectSizes,
                        'createAt': Timestamp.now(),
                      });

                      Get.snackbar(
                        "Cart Updated",
                        "${widget.name} added to cart.",
                        colorText: Colors.green,
                        margin: EdgeInsets.all(12),
                      );
                    } catch (e) {
                      Get.snackbar(
                        "Error",
                        "Failed to add to cart. Please try again.",
                        colorText: Colors.red,
                        margin: EdgeInsets.all(12),
                      );
                    } finally {
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  },
                ),
                SizedBox(height: 30),
                Divider(thickness: 1),
                SizedBox(height: 10),
                Text("Customer Reviews", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                ReviewandComment(productId: widget.productId),
              ],
            ),
          ),
          // SizedBox(height: 28),
          // ReviewandComment(productId:widget.productId),
        ],
      ),
    );
  }
}



