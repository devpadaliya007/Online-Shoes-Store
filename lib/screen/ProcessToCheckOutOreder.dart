import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class ProcessToCheckOutOreder extends StatefulWidget {
  const ProcessToCheckOutOreder({super.key});

  @override
  State<ProcessToCheckOutOreder> createState() =>
      _ProcessToCheckOutOrederState();
}

class _ProcessToCheckOutOrederState extends State<ProcessToCheckOutOreder> {
  String get _userId => FirebaseAuth.instance.currentUser?.uid ?? '';
  Map<String, dynamic>? _defaultAddress;
  double _totalAmount = 0.0;
  List<Map<String, dynamic>> _cartItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await Future.wait([
        _fetchDefaultAddress(),
        _fetchCartItem(),
      ]);
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchDefaultAddress() async {
    try {
      if (_userId.isEmpty) return;

      final snapshot = await FirebaseFirestore.instance
          .collection('Addresses')
          .where('userId', isEqualTo: _userId)
          .where('isDefault', isEqualTo: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty && mounted) {
        setState(() {
          _defaultAddress = snapshot.docs.first.data();
        });
      }
    } catch (e) {
      print('Error fetching address: $e');
    }
  }

  Future<void> _fetchCartItem() async {
    try {
      if (_userId.isEmpty) return;

      final snapshot = await FirebaseFirestore.instance
          .collection('Cart')
          .where('userId', isEqualTo: _userId)
          .get();

      if (snapshot.docs.isNotEmpty) {
        double total = 0;
        List<Map<String, dynamic>> items = [];

        for (var doc in snapshot.docs) {
          final data = doc.data();
          final price = (data['Price'] ?? data['price'] ?? 0).toDouble();
          final quantity = (data['quantity'] ?? 1).toInt();

          total += price * quantity;
          items.add({
            'productName': data['productName'] ?? 'Unknown Product',
            'quantity': quantity,
            'Price': price,
          });
        }

        if (mounted) {
          setState(() {
            _totalAmount = total;
            _cartItems = items;
          });
        }
      }
    } catch (e) {
      print('Error fetching cart items: $e');
    }
  }

  Future<void> _placeOrder() async {
    if (_userId.isEmpty) {
      Get.snackbar(
        "Error",
        "User not authenticated",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: EdgeInsets.all(12),
      );
      return;
    }

    if (_defaultAddress == null || _cartItems.isEmpty) {
      Get.snackbar(
        "Error",
        _defaultAddress == null
            ? "Please select a delivery address"
            : "Your cart is empty",
        colorText: Colors.red,
        margin:  EdgeInsets.all(12),
      );
      return;
    }

    try {
      final orderId = FirebaseFirestore.instance.collection('Orders').doc().id;

      await FirebaseFirestore.instance.collection('Orders').doc(orderId).set({
        'orderId': orderId,
        'userId': _userId,
        'CustomerName': _defaultAddress!['Name'] ?? 'Unknown',
        'City': _defaultAddress!['City'] ?? '',
        'State': _defaultAddress!['State'] ?? '',
        'Country': _defaultAddress!['County'] ?? '',
        'PinCode': _defaultAddress!['PinCode'] ?? '',
        'MobileNumber': _defaultAddress!['MoblieNumber'] ?? '',
        'Products': _cartItems,
        'TotalAmount': _totalAmount,
        'Status': "Pending",
        'TimeStamp': FieldValue.serverTimestamp(),
      });

      // Clear cart after successful order
      final cartDocs = await FirebaseFirestore.instance
          .collection('Cart')
          .where('userId', isEqualTo: _userId)
          .get();

      final batch = FirebaseFirestore.instance.batch();
      for (var doc in cartDocs.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      Get.snackbar(
        "Successfully Ordered",
        "Order placed successfully!",
        colorText: Colors.green,
        margin: EdgeInsets.all(12),
      );

      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      print('Error placing order: $e');
      Get.snackbar(
        "Error",
        "Failed to place order. Please try again.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: EdgeInsets.all(12),
      );
    }
  }


  Widget _buildAddressRow(IconData icon, String label, dynamic value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: Text(value?.toString() ?? 'N/A'),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Color(0xFFE2D9FB),
      appBar: AppBar(
        backgroundColor: Color(0xFFE2D9FB),
        centerTitle: true,
        title: Text(
          'Place Order',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _userId.isEmpty
          ? Center(
        child: Text(
          'Please login to place an order',
          style: TextStyle(fontSize: 16),
        ),
      )
          : Padding(
        padding:  EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text(
              'Shipping Address',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
             SizedBox(height: 10),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: _defaultAddress == null
                    ? Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.red),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'No default address found. Please add an address.',
                        style: TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    ),
                  ],
                )
                    : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, color: Colors.deepPurple),
                        SizedBox(width: 8),
                        Text(
                          'Shipping Address',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ],
                    ),
                    Divider(thickness: 1, height: 20),
                    SizedBox(height: 4),
                    _buildAddressRow(Icons.person, 'Name', _defaultAddress!['Name']),
                    _buildAddressRow(Icons.location_city, 'City', _defaultAddress!['City']),
                    _buildAddressRow(Icons.map, 'State', _defaultAddress!['State']),
                    _buildAddressRow(Icons.flag, 'Country', _defaultAddress!['Country'] ?? _defaultAddress!['County']),
                    _buildAddressRow(Icons.pin, 'PinCode', _defaultAddress!['PinCode']),
                    _buildAddressRow(Icons.phone, 'Mobile', _defaultAddress!['MobileNumber'] ?? _defaultAddress!['MoblieNumber']),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            Text(
              'Order Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: _cartItems.isEmpty
                  ? Center(
                child: Text(
                  'No items in cart',
                  style: TextStyle(fontSize: 16),
                ),
              )
                  : ListView.builder(
                itemCount: _cartItems.length,
                itemBuilder: (context, index) {
                  final item = _cartItems[index];

                  final String name = item['productName'] ?? 'Unknown Product';
                  final int qty = item['quantity'] ?? 1;
                  final double price = (item['Price'] ?? 0).toDouble();

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 6),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      title: Text(
                        name,
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        'Qty: $qty , ₹${price.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 13,
                        ),
                      ),
                      trailing: Text(
                        '₹${(qty * price).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                          fontSize: 15,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            Divider(thickness: 2),
            Text(
              'Total Amount: ₹${_totalAmount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text("Confirm Order"),
                      content: Text("Are you sure you want to place this order?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text("Cancel"),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                          ),
                          child: Text("Confirm"),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    _placeOrder(); // Your existing method to place order
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 4,
                ),
                child: Text(
                  'Confirm Order',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            SizedBox(height: 20,),
          ],
        ),
      ),
    );
  }
}