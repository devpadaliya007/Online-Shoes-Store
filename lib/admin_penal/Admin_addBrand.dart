import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class AddBrand extends StatefulWidget {
  const AddBrand({super.key});

  @override
  State<AddBrand> createState() => _AddBrandState();
}

class _AddBrandState extends State<AddBrand> {
  TextEditingController _BName=TextEditingController();
  TextEditingController _BContact=TextEditingController();
  TextEditingController _BDescription=TextEditingController();
  TextEditingController _BCountry=TextEditingController();
  File? _selectImage;
  final ImagePicker _picker=ImagePicker();

  bool _isuploding=false;

  final FirebaseFirestore _firestore =FirebaseFirestore.instance;
  void dispose(){
    _BName.dispose();
    _BContact.dispose();
    _BDescription.dispose();
    _BCountry.dispose();
  }

  Future<void> PicImage(ImageSource source) async{
    final picker=ImagePicker();
    final picfile=await picker.pickImage(source:source);
    if(picfile!=null){
      setState(() {
        _selectImage=File(picfile.path);
      });
    }
  }

  void showImagePickerOption(){
    showModalBottomSheet(
        context: context,
        builder: (context)=>SafeArea(child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text("Tack a Photo"),
              onTap: (){
                Navigator.pop(context);
                PicImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_album),
              title:Text("Pick Image from Gallery"),
              onTap: (){
                Navigator.pop(context);
                PicImage(ImageSource.gallery);
              },
            )
          ],
        )));
  }

  Future<String?> UploadImageToCloudinary(File ImageFile) async{
    const cloudinaryUrl="https://api.cloudinary.com/v1_1/dshsjt8vz/image/upload";
    const cloudinaryPreset='shoe_app';
    final request=http.MultipartRequest('POST',Uri.parse(cloudinaryUrl))
    ..fields['upload_preset']=cloudinaryPreset
    ..files.add(await http.MultipartFile.fromPath('file', ImageFile.path));
    final response=await request.send();
    if(response.statusCode==200){
      final responseData=json.decode(await response.stream.bytesToString());
      return responseData['secure_url'];
    }
    else{
      Get.snackbar("Upload Image","Image Upload In Clodinary",colorText: Colors.green);
      return null;
    }
  }

  Future<void> addBrand() async{
    final Name=_BName.text.trim();
    final Contact=_BContact.text.trim();
    final Description=_BDescription.text.trim();
    final Country=_BCountry.text.trim();
    if(Name.isEmpty||Contact.isEmpty||Description.isEmpty||Country.isEmpty||_selectImage==null){
      Get.snackbar("Something went wrong","Please Fill All The Fields",colorText: Colors.red);
      return;
    }
    setState(() {
      _isuploding=true;
    });
    try{
      final imageUrl=await UploadImageToCloudinary(_selectImage!);
      if(imageUrl==null) return;
      final brandData={
        'Name':Name,
        'Contact':Contact,
        'Description':Description,
        'Country':Country,
        'imageUrl':imageUrl,
        'createdAt':FieldValue.serverTimestamp(),
      };
      await _firestore.collection('Brands').add(brandData);
      Get.snackbar("Successful Brand Add","Successful Brand Add In Firebase",colorText: Colors.green);
      _BName.clear();
      _BContact.clear();
      _BDescription.clear();
      _BCountry.clear();
      setState(() {
        _selectImage=null;
      });
    }
    catch(e){
      Get.snackbar("Something went wrong","Brand Not Add",colorText: Colors.red);
    }
    finally{
      setState(() {
        _isuploding=false;
      });
    }

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.grey.shade100,
        title: const Text(
          'Upload Brand',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(height: 10,),
            GestureDetector(
              onTap: showImagePickerOption,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.deepPurple.shade100,
                backgroundImage: _selectImage!=null?FileImage(_selectImage!):null,
                child: _selectImage==null?Icon(Icons.camera_alt,size: 40,):null,
              ),
            ),
            SizedBox(height: 20),
            buildTextField(_BName, 'Brand Name'),
            SizedBox(height: 15),
            buildTextField(_BContact, 'Brand Contact',keyboardType: TextInputType.number,),
            SizedBox(height: 15),
            buildTextField(_BDescription, 'Brand Description', maxLines: 3),
            SizedBox(height: 15),
            buildTextField(_BCountry, 'Brand Country'),
            SizedBox(height: 20),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: _isuploding ? null : addBrand,
                child: _isuploding
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("Add Brand", style: TextStyle(fontSize: 16,color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
Widget buildTextField(TextEditingController controller, String label,
    {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
  return TextField(
    controller: controller,
    maxLines: maxLines,
    keyboardType: keyboardType,
    decoration: InputDecoration(
      labelText: label,
      hintText: 'Enter your $label',
      filled: true,
      fillColor: Colors.white,
      labelStyle: const TextStyle(fontWeight: FontWeight.w500),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
    ),
  );
  }
}