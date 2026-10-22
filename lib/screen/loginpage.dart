import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../admin_penal/Admin_login.dart';
import 'homepage.dart';
import 'package:get/get.dart';

import 'register.dart';

class loginpage extends StatefulWidget {
  const loginpage({super.key});

  @override
  State<loginpage> createState() => _loginpageState();
}


class _loginpageState extends State<loginpage> {

  final TextEditingController _Email=TextEditingController();
  final TextEditingController _Password=TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth=FirebaseAuth.instance;
  final FirebaseFirestore _firebaseStore=FirebaseFirestore.instance;


  Future<void> loginnow() async {
    try {
      UserCredential userCredential=await _auth.signInWithEmailAndPassword(email: _Email.text.trim(), password: _Password.text.trim());
      String usersid=userCredential.user!.uid;
      DocumentSnapshot userdoc=await _firebaseStore.collection('users').doc(usersid).get();
      if(!userdoc.exists){
        throw Exception("User Record Not Found");
      }
      Map<String,dynamic> userdata=userdoc.data() as Map<String,dynamic>;
      String usersStatus=userdata['status']??'Active';
      if(usersStatus=='Blocked'){
        await _auth.signOut();
        Get.snackbar("Account Blocked","Your Account Is Blocked",colorText: Colors.red);
        return;
      }
      Get.snackbar("Login Successful","Welcome back to your dashboard!",colorText: Colors.green);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) =>  HomePage()),
      );
    } catch (e) {
      print("Login Error: $e");
      Get.snackbar("Login Failed","Something went wrong",colorText: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Center(
        child: Container(
          width: double.maxFinite,
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(color: Color(0xFFE2D9FB),),
          child: Center(
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 80,
                      backgroundImage:AssetImage("assets/img/shoe.png"),
                    ),
                    SizedBox(height: 20,),
                    Text(
                      'Welcome Back!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),

                    SizedBox(height: 20,),
                    TextFormField(
                      controller: _Email,
                      // textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter your email";
                        }
                        if (!RegExp(r'^[\w.]+@[\w]+\.[\w]{2,4}$').hasMatch(value)) {
                          return "Please enter a valid email ";
                        }
                        return null;
                      },
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        prefixIcon: Icon(Icons.mail_outline_outlined),
                        labelText: 'Email',
                        hintText: 'Enter your email',
                      ),
                    ),

                    SizedBox(height: 20,),
                    TextFormField(
                      controller: _Password,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25)
                        ),
                        prefixIcon: Icon(Icons.password_outlined),
                        labelText: 'Password',
                        hintText: 'Enter your Password',
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter your Password";
                        }
                        if (value.length < 6) {
                          return "Please enter a 6 digit Password";
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => AdminLogin()),
                            );
                          },
                          child: Text(
                            'Admin Login',
                            style: TextStyle(color: Colors.deepPurple),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10,),
                    ElevatedButton(onPressed: (){
                      if(formKey.currentState!.validate()){
                        loginnow();
                      }
                    },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.deepPurple,
                        ),
                        child:Text('Login')
                    ),
                    SizedBox(height: 10,),

                    TextButton(onPressed: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => register()),
                      );
                    }, child: Text('Register new account')),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}