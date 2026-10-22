import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'OrderDetalisPage.dart';

class OrderPage extends StatelessWidget {
  const OrderPage({super.key});

  String get _userId=>FirebaseAuth.instance.currentUser?.uid??"Guest User";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE2D9FB),
      appBar: AppBar(
        title:  Text('🛒 My Orders'),
        backgroundColor: Color(0xFFE2D9FB),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Orders')
            .where('userId', isEqualTo: _userId)
            .orderBy('TimeStamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 80,),
                  SizedBox(height: 12),
                  Text('No Orders Found', style: TextStyle(fontSize: 18)),
                ],
              ),
            );
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.all(12),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final data = orders[index].data() as Map<String, dynamic>;

              return Card(
                elevation: 5,
                margin: EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Icon(Icons.shopping_cart, color: Colors.deepPurple),
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Order Id: #${data['orderId']}', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                    ],
                  ),
                  subtitle: Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: RichText(
                      text: TextSpan(
                        style: DefaultTextStyle.of(context).style,
                        children: [
                          TextSpan(text: 'Total: '),
                          TextSpan(
                            text: '₹${data['TotalAmount']}\n',
                            style: TextStyle(color: Colors.green),
                          ),
                          TextSpan(text: 'Status: '),
                          TextSpan(
                            text: '${data['Status']}',
                            style: TextStyle(
                              color: data['Status'] == 'Approved' ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OrderDetalisPage(orderData: data),
                      ),
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
