import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class UserList extends StatefulWidget {
  const UserList({super.key});


  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList> {

  final FirebaseFirestore _firestore=FirebaseFirestore.instance;
  Future<void> blocklistuser(String usersid) async{
    try{
      await _firestore.collection('users').doc(usersid).update({'status':'Blocked'});
      Get.snackbar("User Blocked","User Successful Blocked",colorText: Colors.green);
    }
    catch(e){
      Get.snackbar("User Not Blocked","User Not Blocked",colorText: Colors.red);
    }
  }

  Future<void> Unblocklistuser(String usersid) async{
    try{
      await _firestore.collection('users').doc(usersid).update({'status':'Active'});
      Get.snackbar("User Un-Blocked","User Successful Un-Blocked",colorText: Colors.green);
    }
    catch(e){
      Get.snackbar("User Not Blocked","User Not Blocked",colorText: Colors.red);
    }
  }

  Widget buildUsersList() {
    return StreamBuilder(
      stream: _firestore.collection('users').snapshots(),
      builder: (context, snapshots) {
        if (snapshots.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshots.hasError || !snapshots.hasData || snapshots.data!.docs.isEmpty) {
          return const Center(child: Text('No Users Found'));
        }

        final users = snapshots.data!.docs;
        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            final userId = user.id;
            final userData = user.data() as Map<String, dynamic>;
            final userStatus = userData['status'] ?? 'Active';

            return Card(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding:  EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: userData['profileImage'] != null &&
                          userData['profileImage'].toString().isNotEmpty
                          ? NetworkImage(userData['profileImage'])
                          :  AssetImage('assets/img/pic-2.png') as ImageProvider,
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userData['name'] ?? 'Unknown User',
                            style:TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            userData['email'] ?? 'No email',
                            style:TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          Text(
                            'Status: $userStatus',
                            style:TextStyle(
                              fontSize: 12,
                              color: userStatus == 'Blocked' ? Colors.red : Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        userStatus == "Blocked" ? Icons.lock_open : Icons.lock,
                        color: userStatus == "Blocked" ? Colors.red : Colors.green,
                      ),
                      onPressed: () {
                        userStatus == "Blocked"
                            ? Unblocklistuser(userId)
                            : blocklistuser(userId);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        centerTitle: true,
        title: const Text(
          'Users List All',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: buildUsersList(),
    );
  }
}
