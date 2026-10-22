import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminOrderManagePage extends StatefulWidget {
  const AdminOrderManagePage({super.key});

  @override
  State<AdminOrderManagePage> createState() => _AdminOrderManagePageState();
}

class _AdminOrderManagePageState extends State<AdminOrderManagePage> {
  void approveOrder(String orderId) async{
    await FirebaseFirestore.instance.collection('Orders').doc(orderId).update({
      'Status':'Approved',
      'AdminApprovedAt':FieldValue.serverTimestamp(),
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE2D9FB),
      appBar: AppBar(
        title: Text("Order Dashboard"),
        backgroundColor: Color(0xFFE2D9FB),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('Orders').orderBy('TimeStamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No orders found", style: TextStyle(fontSize: 18),),);
          }

          return ListView.separated(
            padding: EdgeInsets.all(16),
            separatorBuilder: (_, __) => SizedBox(height: 12),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final isApproved = data['Status'] == "Approved";

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    )
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.shopping_bag_outlined, color: Colors.deepPurple),
                          SizedBox(width: 8),
                          Text(
                            "Order Id:\n${data['orderId']}",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text("Total: ₹${data['TotalAmount']}",
                          style: TextStyle(fontSize: 16)),
                      Text("Status: ${data['Status']}",
                          style: TextStyle(
                            fontSize: 14,
                            color: isApproved ? Colors.green : Colors.orange,
                            fontWeight: FontWeight.w600,
                          )),
                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Chip(
                            avatar: Icon(
                              isApproved ? Icons.check_circle : Icons.access_time,
                              color: isApproved ? Colors.green : Colors.red,
                            ),
                            label: Text(
                              isApproved ? "Approved" : "Pending",
                              style: TextStyle(
                                color: isApproved ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            backgroundColor:
                            isApproved ? Colors.green.shade50 : Colors.red.shade50,
                          ),

                          if (!isApproved)
                            ElevatedButton.icon(
                              onPressed: () => approveOrder(doc.id),
                              icon: Icon(Icons.check, color: Colors.white),
                              label: Text(
                                "Approve",
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurpleAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
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
