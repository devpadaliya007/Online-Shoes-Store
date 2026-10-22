import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../admin_penal/Admin_login.dart';
import 'homepage.dart';
import 'loginpage.dart';
import 'dart:async';
import 'package:get/get.dart';

class register extends StatefulWidget {
  const register({super.key});

  @override
  State<register> createState() => _registerState();
}

class _registerState extends State<register> {
  final TextEditingController _Name=TextEditingController();
  final TextEditingController _Email=TextEditingController();
  final TextEditingController _MobileNumber=TextEditingController();
  final TextEditingController _Password=TextEditingController();
  final TextEditingController profileImage=TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();


  Future<void> registernow() async {
    try {
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: _Email.text, password: _Password.text);

      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'name': _Name.text,
        'email': _Email.text,
        'mobile': _MobileNumber.text,
        'Password':_Password.text,
        'profileImage':profileImage.text,
      });

      Get.snackbar("Registaration Successful","Welcome a Elegance Footware!",colorText: Colors.green);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomePage()),
      );
    }
    on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        Get.snackbar("Email already exists","please Login Your Account!",colorText: Colors.red);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => loginpage()),
        );
      } else {
        Get.snackbar("Something went wrong","please Check Your detalis!",colorText: Colors.red);
      }
    } catch (e) {
      Get.snackbar("Unexpected error occurred","please Check Your detalis!",colorText: Colors.red);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: formKey,
        child: Container(
            width: double.maxFinite,
            padding:  EdgeInsets.all(24),
            decoration: BoxDecoration(color: Color(0xFFE2D9FB),
            ),

          child: Center(
            child: SingleChildScrollView(
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 20,),
                Text(
                  'Create Your Account!!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),

                //Name
                SizedBox(height: 20,),
                TextFormField(
                  textCapitalization: TextCapitalization.words,
                  controller:_Name,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your name';
                    }
                    if (!RegExp(r"^[a-zA-Z\s]+$").hasMatch(value)) {
                      return 'Please enter a valid name';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    prefixIcon: Icon(Icons.person),
                    labelText: 'Enter Name',
                    hintText: 'Enter your Name',
                  ),
                ),

                //Email
                SizedBox(height: 20,),
                TextFormField(
                  controller: _Email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Please enter your email";
                    }
                    if (!RegExp(r'^[\w.]+@[\w]+\.[\w]{2,4}$').hasMatch(value)) {
                      return "Please enter a valid email ";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25)
                    ),
                    prefixIcon: Icon(Icons.email_rounded),
                    labelText: 'Enter Email',
                    hintText: 'Enter your Email',
                  ),
                ),
                SizedBox(height: 20,),

                //Mobilnumber
                TextFormField(
                  controller: _MobileNumber,
                  maxLength: 10,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your mobile number';
                    } else if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                      return 'Mobile number must be exactly 10 digits';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                    ),
                    prefixIcon: Icon(Icons.phone),
                    labelText: 'Enter Mobile Number',
                    hintText: 'Enter your Mobile Number',
                    counterText: '',
                  ),

                ),

                //Password
                SizedBox(height: 20,),
                TextFormField(
                  controller: _Password,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Please enter your Password";
                    }
                    if (value.length < 6) {
                      return "Please enter a 6 digit Password";
                    }
                    return null;
                  },
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25)
                    ),
                    prefixIcon: Icon(Icons.password_outlined),
                    labelText: 'Enter Password',
                    hintText: 'Enter your Password',
                  ),
                ),
                SizedBox(height: 20,),

                ElevatedButton(
                    onPressed: (){
                      if(formKey.currentState!.validate()){
                        // registernow().then((value) => Navigator.push(context,MaterialPageRoute(builder: (_) => homepage()),));
                        registernow();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.deepPurple,
                    ),
                    child:Text('Register')
                ),
                SizedBox(height: 10,),


                TextButton(onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => loginpage()),
                  );
                }, child: Text('Login')),

                SizedBox(height: 10,),
                TextButton(onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AdminLogin()),
                  );
                }, child: Text('Admin Login'))
              ],
                       ),
            ),
          ),
        ),
      ),
    );
  }
}