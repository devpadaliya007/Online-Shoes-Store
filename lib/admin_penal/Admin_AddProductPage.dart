import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final TextEditingController _Name=TextEditingController();
  final TextEditingController _price=TextEditingController();
  final TextEditingController _description=TextEditingController();
  final FirebaseFirestore _firestore =FirebaseFirestore.instance;
  File? _productImage;
  String? _selectBrand;
  bool _isUploding=false;
  List<String> _sizes=[];
  List<String> sizeOptions=['1','2','3','4','5','6','7','8','9','10','11','12'];


  void dispose(){
    _Name.dispose();
    _price.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> PicImage(ImageSource source) async{
    final picker=ImagePicker();
    final picfile=await picker.pickImage(source:source);
    if(picfile!=null){
      setState(() {
        _productImage=File(picfile.path);
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

  Future<List<String>> fetchBrand() async{
    final snapshot=await _firestore.collection('Brands').get();
    return snapshot.docs.map((doc)=>doc['Name'] as String).toList();
  }

  Future<void> addProuduct() async{
    final name=_Name.text.trim();
    final price=_price.text.trim();
    final description=_description.text.trim();
    if(name.isEmpty||price.isEmpty||description.isEmpty||_selectBrand==null||_sizes.isEmpty||_productImage==null){
      Get.snackbar("Something went wrong","Please Fill All The Fields",colorText: Colors.red);
      return;
    }
    setState(() {
      _isUploding=true;
    });
    try{
      final imageUrl=await UploadImageToCloudinary(_productImage!);
      if(imageUrl==null) return;
      final PorductData={
        'Name':name,
        'Price':price,
        'Description':description,
        'Brand':_selectBrand,
        'Sizes':_sizes,
        'imageUrl':imageUrl,
        'createdAt':FieldValue.serverTimestamp(),
      };
      await _firestore.collection('Products').add(PorductData);
      Get.snackbar("Successful Product Add","Successful Product Add In Firebase",colorText: Colors.green);
      _Name.clear();
      _price.clear();
      _description.clear();
      _sizes.clear();
      setState(() {
        _selectBrand=null;
        _productImage=null;
      });
    }
    catch(e){
      Get.snackbar("Something went wrong","Product Not Add",colorText: Colors.red);
    }
    finally{
      setState(() {
        _isUploding=false;
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
          'Add Product',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: Padding(padding: EdgeInsets.all(8),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Product Image", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
              SizedBox(height: 15,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 20),
                  if(_productImage!=null)
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: FileImage(_productImage!),
                    )
                  else
                    GestureDetector(
                      onTap: showImagePickerOption,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: _productImage!=null?FileImage(_productImage!):null,
                        child: _productImage==null?Icon(Icons.camera_alt,size: 40,):null,
                      ),
                    ),
                  SizedBox(width: 15,),
                  // ElevatedButton.icon(
                  //   icon: Icon(Icons.photo_library),
                  //     onPressed: () {
                  //
                  //     },
                  //     label: Text("Pick Product Image"),
                  // )
                ],
              ),
              SizedBox(height: 10,),
              Text("Product Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              buildTextField(_Name, 'Product Name'),
              const SizedBox(height: 15),
              buildTextField(_price, 'Product Price',keyboardType: TextInputType.phone,),
              const SizedBox(height: 15),
              buildTextField(_description, 'Product Description', maxLines: 3),
              SizedBox(height: 15,),

              Text("Select Brand", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              SizedBox(height: 10,),

              FutureBuilder<List<String>>(
                future: fetchBrand(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return  CircularProgressIndicator();
                  if (!snapshot.hasData || snapshot.data!.isEmpty) return Text("No Product Available");

                  return DropdownButtonFormField<String>(
                    value: _selectBrand,
                    decoration:  InputDecoration(filled: true, // Enable filling
                        fillColor: Colors.white,border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(20),))),
                    hint:  Text("Choose Brand"),
                    items: snapshot.data!.map((brand) {
                      return DropdownMenuItem(value: brand, child: Text(brand));
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectBrand = value);
                    },
                  );
                },
              ),

              SizedBox(height: 15,),
              Text("Available Sizes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              SizedBox(height: 10,),
              Wrap(
                spacing: 10,
                children:
                  sizeOptions.map((size)
                  {
                    return ChoiceChip(
                        label: Text(size),
                        selected: _sizes.contains(size),
                      onSelected: (selected){
                          setState(() {
                            if(selected){
                              _sizes.add(size);
                            }
                            else{
                              _sizes.remove(size);
                            }
                          });
                      },
                    );
                  }).toList(),
              ),
              SizedBox(height: 20,),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: _isUploding ? null : addProuduct,
                  child: _isUploding
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Add Product", style: TextStyle(fontSize: 16,color: Colors.white)),
                ),
              ),
            ],
          ),
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