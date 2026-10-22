import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Admin_Homepage.dart';

class AdminLogin extends StatefulWidget {
  const AdminLogin({super.key});

  @override
  State<AdminLogin> createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  final TextEditingController _AdminEmail=TextEditingController();
  final TextEditingController _AdminPassword=TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();


  Future<bool> AdminLoginpage(String email,String Password) async {
    try {
      final QuerySnapshot adminSanpshot =await FirebaseFirestore.instance.collection('admin').where('email',isEqualTo:email).limit(1).get();
      if(adminSanpshot.docs.isEmpty) return false;
      final adminData =adminSanpshot.docs.first.data() as Map<String,dynamic>;
      return adminData['Password']==Password;
    } catch (e) {
      print("Login Error: $e");
      Get.snackbar("Login Failed","Something went wrong",colorText: Colors.red);
      return false;
    }
  }

  Future<void> LoginpageAsAdmin() async{
    final email=_AdminEmail.text.trim();
    final Password=_AdminPassword.text.trim();

    if(email.isEmpty||Password.isEmpty){
      Get.snackbar("Login Failed","Something went wrong",colorText: Colors.red);
      return;
    }
    try{
      final isAdminValid=await AdminLoginpage(email,Password);
      if(isAdminValid){
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AdminHomepage()),
        );
        Get.snackbar("Admin Login Successful","Welcome back to your Admin dashboard!",colorText: Colors.green);
      }
      else{
        Get.snackbar("Login Failed","Something went wrong",colorText: Colors.red);
      }
    }
    catch (e) {
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
          padding: const EdgeInsets.all(24),
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
                    const Text(
                      'Welcome To Admin Penal!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),

                    SizedBox(height: 20,),
                    TextFormField(
                      controller: _AdminEmail,
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
                      controller: _AdminPassword,
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
                        if (value.length < 10) {
                          return "Please enter a 6 digit Password";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20,),
                    ElevatedButton(onPressed: LoginpageAsAdmin,
                      // if(formKey.currentState!.validate()){
                      //   //loginnow().then((value) => Navigator.push(context,MaterialPageRoute(builder: (_) => HomePage()),));
                      //   // loginnow();
                      // }
                    // },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.deepPurple,
                        ),
                        child:Text('Login Admin')
                    ),
                    SizedBox(height: 10,),

                    // TextButton(onPressed: (){
                    //   Navigator.push(
                    //     context,
                    //     MaterialPageRoute(builder: (_) => AdminHomepage()),
                    //   );
                    // }, child: Text('Register new account'))
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
