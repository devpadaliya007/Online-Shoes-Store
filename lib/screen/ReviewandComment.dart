import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'ViewProductsComments.dart';

class ReviewandComment extends StatefulWidget {
  final String productId;
  const ReviewandComment({super.key, required this.productId});

  @override
  State<ReviewandComment> createState() => _ReviewandCommentState();
}

class _ReviewandCommentState extends State<ReviewandComment> {
  double _rating=0;
  String _review="";
  String? _productName="";



  final FirebaseAuth _auth=FirebaseAuth.instance;
  final FirebaseFirestore _firestore=FirebaseFirestore.instance;

  void initState(){
    _fetchProductName();
  }

  Future<void> _fetchProductName() async{
    try{
      DocumentSnapshot productSnapshot=await _firestore.collection('Products').doc(widget.productId).get();
      if(productSnapshot.exists){
        setState(() {
          _productName=productSnapshot['Name']??'Not product';
        });
      }
    }
    catch(e){
      Get.snackbar("Login Failed","Something went wrong",colorText: Colors.red);
      setState(() {
        _productName="Unknown Product";
      });
    }
  }

  Future<void> _submitReview() async{
    if(_rating>0&&_review.isNotEmpty){
      try{
        await _firestore.collection('FeedBack').add({
          'productId':widget.productId,
          'productName':_productName,
          'userId':_auth.currentUser?.uid??'Guest User',
          'rating':_rating,
          'review':_review,
          'CreatedAt':FieldValue.serverTimestamp(),
        });
        Get.snackbar("Successfully Submited","Review Submitted Done!",colorText: Colors.green);
        setState(() {
          _review="";
          _rating=0;
        });
      }
      catch(e){
        Get.snackbar("Not Submited","Review Not Submitted!",colorText: Colors.red);
      }
    }
  }


  @override
  Widget build(BuildContext context) {

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        // color: Color(0xFFE2D9FB),
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            blurRadius: 5,
            color: Colors.grey.shade300,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📝 Write Your Review',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),

          // Review Text Field
          TextField(
            onChanged: (value) => _review = value,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Share your experience...',
              filled: true,
              fillColor: Color(0xFFF6F4FF),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),

          SizedBox(height: 16),
          // Rating Dropdown
          Text(
            '⭐ Select Rating',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 8),
          DropdownButtonFormField<double>(
            value: _rating > 0 ? _rating : null,
            decoration: InputDecoration(
              filled: true,
              fillColor: Color(0xFFF6F4FF),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            hint: Text("Choose between 1 to 5 stars"),
            items: [1, 2, 3, 4, 5].map((rate) {
              return DropdownMenuItem(
                value: rate.toDouble(),
                child: Row(
                  children: List.generate(rate, (index) =>
                      Icon(Icons.star, color: Colors.amber, size: 20)),
                ),
              );
            }).toList(),
            onChanged: (newvalue) {
              if (newvalue != null) {
                setState(() => _rating = newvalue);
              }
            },
          ),
          SizedBox(height: 30),
          // Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _submitReview,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: Icon(Icons.send, color: Colors.white),
              label: Text('Submit Review', style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ),

          //review
          SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (_)=>ViewProductsComments(productId: widget.productId,)));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: Icon(Icons.rate_review, color: Colors.white),
              label: Text('Review', style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
