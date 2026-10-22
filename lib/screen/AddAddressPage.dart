import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class AddAddressPage extends StatefulWidget {
  const AddAddressPage({super.key});

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _userId;
  String? _defaultAddressId;

  void initState() {
    _userId = _auth.currentUser?.uid;
  }

  Future<void> _addNewAddress(BuildContext context) async {
    final _formKey = GlobalKey<FormState>();

    TextEditingController name = TextEditingController();
    TextEditingController address = TextEditingController();
    TextEditingController city = TextEditingController();
    TextEditingController state = TextEditingController();
    TextEditingController country = TextEditingController();
    TextEditingController pinCode = TextEditingController();
    TextEditingController mobileNumber = TextEditingController();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_on, size: 50, color: Colors.deepPurple),
                  SizedBox(height: 10),
                  Text(
                    "Add New Address",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _fancyInput(name, "Full Name", Icons.person),
                        _fancyInput(address, "Address", Icons.home),
                        _fancyInput(city, "City", Icons.location_city),
                        _fancyInput(state, "State", Icons.map),
                        _fancyInput(country, "Country", Icons.flag),
                        _fancyInput(pinCode, "Pin Code", Icons.pin,
                            keyboardType: TextInputType.number),
                        _fancyInput(mobileNumber, "Mobile Number", Icons.phone,
                            keyboardType: TextInputType.phone),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () => Navigator.pop(context),
                        label: Text("Cancel"),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        label: Text("Save"),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final doc = await _firestore.collection('Addresses').add({
                              'userId': _userId,
                              'Name': name.text,
                              'Address': address.text,
                              'City': city.text,
                              'State': state.text,
                              'County': country.text,
                              'PinCode': pinCode.text,
                              'MoblieNumber': mobileNumber.text,
                              'IsDefault': false,
                            });

                            if (_defaultAddressId == null) {
                              _setDefaultAddress(doc.id);
                            }

                            Navigator.pop(context);
                            Get.snackbar("Address Added", "Address added successfully", colorText: Colors.green, margin: EdgeInsets.all(12),);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }


  Widget _fancyInput(
      TextEditingController controller,
      String label,
      IconData icon, {
        TextInputType keyboardType = TextInputType.text,
      }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          labelText: label,
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
        validator: (value) =>
        value == null || value.trim().isEmpty ? 'Enter $label' : null,
      ),
    );
  }


  Future<void> _setDefaultAddress(String addressId) async {
    if (_defaultAddressId != null) {
      await _firestore.collection('Addresses').doc(_defaultAddressId).update({
        'isDefault': false,
      });
    }
    await _firestore.collection('Addresses').doc(addressId).update({
      'isDefault': true,
    });
  }

  Future<void> _setFirestAddressAsDefault() async {
    QuerySnapshot Query = await _firestore
        .collection('Addresses')
        .where('userId', isEqualTo: _userId)
        .get();
    if (Query.docs.isNotEmpty) {
      _setDefaultAddress(Query.docs.first.id);
    }
  }


  Future<void> _deleteAddress(String addressId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Address"),
        content: Text("Are you sure you want to delete this address?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
            child: Text("Delete", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await _firestore.collection('Addresses').doc(addressId).delete();

      if (_defaultAddressId == addressId) {
        _defaultAddressId = null;
        _setFirestAddressAsDefault();
      }

      Get.snackbar("Address Deleted", "Address Deleted successfully", colorText: Colors.green, margin: EdgeInsets.all(12),);

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Address'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('Addresses')
            .where('userId', isEqualTo: _userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          final addresses = snapshot.data?.docs ?? [];

          if (addresses.isEmpty) {
            Future.delayed(Duration.zero, () => _addNewAddress(context));
            return Center(child: Text("Please Add a New Address"));
          }

          return ListView.builder(
            itemCount: addresses.length,
            itemBuilder: (context, index) {
              final Address = addresses[index].data() as Map<String, dynamic>;
              final addressId = addresses[index].id;
              final isDefault = Address['isDefault'] ?? false;
              if (isDefault) _defaultAddressId = addressId;
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 5,
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.blueAccent,
                            child: Icon(Icons.person),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '${Address['Name']}',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                          ),
                          if (isDefault)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Default',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text(
                        '${Address['Address']},\n${Address['City']}, ${Address['State']}',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        '${Address['County']}, ${Address['PinCode']}',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.phone, size: 18, color: Colors.grey[700]),
                          SizedBox(width: 4),
                          Text('Mobile: ${Address['MoblieNumber']}'),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: () => _setDefaultAddress(addressId),
                            icon: Icon(
                              isDefault ? Icons.check_circle : Icons.radio_button_unchecked,
                              color: isDefault ? Colors.green : Colors.grey,
                            ),
                          ),
                          IconButton(
                            onPressed: () => _deleteAddress(addressId),
                            icon: Icon(Icons.delete, color: Colors.redAccent),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: ()=> _addNewAddress(context),
        child: Icon(Icons.add),
      ),
    );
  }
}
