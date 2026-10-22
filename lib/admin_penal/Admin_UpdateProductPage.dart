import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class UpdateProductPage extends StatefulWidget {
  const UpdateProductPage({super.key});

  @override
  State<UpdateProductPage> createState() => _UpdateProductPageState();
}

class _UpdateProductPageState extends State<UpdateProductPage> {
  final _formKey=GlobalKey<FormState>();
  String? _selectProductId;
  Map<String,dynamic>? _selectProductData;
  List<QueryDocumentSnapshot> _products=[];
  late TextEditingController _name;
  late TextEditingController _description;
  late TextEditingController _price;
  File? _imageFile;
  bool _isLoding=false;

  @override
  void initState(){
    super.initState();
    _name=TextEditingController();
    _description=TextEditingController();
    _price=TextEditingController();
    _fetchProducts();
  }
  Future<void> _fetchProducts() async{
    try{
      final snapshot=await FirebaseFirestore.instance.collection('Products').get();
      setState(() {
        _products=snapshot.docs;
      });
    }
    catch(e){
      Get.snackbar("Something went wrong","Please Show Data",colorText: Colors.red);
    }
  }
  void _onProductSelected(String? productId){
    if(productId!=null){
      final selectedProduct=_products.firstWhere((product)=>product.id==productId);
      setState(() {
        _selectProductId=productId;
        _selectProductData=selectedProduct.data() as Map<String,dynamic>;
        _name.text=_selectProductData!['Name'];
        _description.text=_selectProductData!['Description'];
        _price.text=_selectProductData!['Price'].toString();

      });
    }
  }
  Future<String?> _pickImage(ImageSource source) async {
    final picImage = await ImagePicker().pickImage(source: source);
    if (picImage != null) {
      setState(() {
        _imageFile = File(picImage.path);
      });
    }
  }

  Future<String?> _uploadImageToCloudinary(File imageFile) async {
    const String cloudinaryUrl = "https://api.cloudinary.com/v1_1/dshsjt8vz/image/upload";
    const String cloudinaryPreset = 'shoe_app';

    final request = http.MultipartRequest('POST', Uri.parse(cloudinaryUrl))
      ..fields['upload_preset'] = cloudinaryPreset
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = jsonDecode(responseBody);
      return jsonResponse['secure_url'];
    } else {
      Get.snackbar("Upload Failed", "Image upload to Cloudinary failed", colorText: Colors.red);
      return null;
    }
  }

  Future<void> _updateProduct() async{
    if(_formKey.currentState!.validate()&&_selectProductId!=null){
      setState(() {
        _isLoding=true;
      });
      try{
        String? imageUrl=_selectProductData?['imageUrl'];
        if(_imageFile!=null){
          imageUrl=await _uploadImageToCloudinary(_imageFile!);
        }
        await FirebaseFirestore.instance.collection('Products').doc(_selectProductId).update({
          'Name':_name.text,
          'Description':_description.text,
          'Price':double.parse(_price.text).toString(),
          if(imageUrl!=null) 'imageUrl':imageUrl,
        });
        Get.snackbar("Successfully", "Product updated successfully", colorText: Colors.green);
        Navigator.pop(context);
      }
      catch (e) {
        Get.snackbar("Update Error", "Something went wrong: ${e.toString()}", colorText: Colors.red);
      } finally {
        setState(() {
          _isLoding = false;
        });
      }
    }
    else {
      Get.snackbar("Something went wrong","Please Fill  The Fields",colorText: Colors.red);
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
          'Update Product',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoding?Center(child: CircularProgressIndicator()):
      Padding(padding: EdgeInsets.all(16),
      child: Form(
        key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: _selectProductId,
                decoration:  InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                ),
                hint: Text("Choose Brand"),
                items: [
                  ..._products.map((brand) {
                    final data = brand.data() as Map<String, dynamic>;
                    final brandName = data['Name'] ?? 'Unnamed Brand';
                    return DropdownMenuItem(
                      value: brand.id,
                      child: Text(brandName),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectProductId = value;
                    _onProductSelected(value);
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a brand';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20,),
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: _imageFile!=null?
                      FileImage(_imageFile!):
                      _selectProductData?['imageUrl']!=null?
                      NetworkImage(_selectProductData!['imageUrl'])as ImageProvider:AssetImage('img.png'),
                    ),
                    Positioned(
                        bottom: 0,
                        right: 0,
                        child:IconButton(onPressed: (){
                          showModalBottomSheet(context: context, builder: (context)=>_imagePickerOptions());
                        }, icon: Icon(Icons.camera_alt)) )
                  ],
                ),
              ),
              SizedBox(height: 20),
              buildTextField(_name, 'Product Name'),
              SizedBox(height: 15),
              buildTextField(_description, 'Product Description', maxLines: 3),
              SizedBox(height: 15),
              buildTextField(_price, 'Product Price',keyboardType: TextInputType.number,),
              SizedBox(height: 15),
              SizedBox(height: 20,),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: _updateProduct,
                  child: Text('Update Product',style: TextStyle(fontSize: 16,color: Colors.white),
                  ),
                ),
              ),
            ],
          )),
      ),
    );
  }
  Widget _imagePickerOptions(){
    return SafeArea(
        child: Wrap(
          children: [
            ListTile(
                leading: Icon(Icons.camera),
                title: Text('Camera'),
                onTap: () async {
                  await _pickImage(ImageSource.camera);
                  Navigator.pop(context);
                }

            ),
            ListTile(
              leading: Icon(Icons.photo),
              title: Text('Gallery'),
              onTap: () {
                _pickImage(ImageSource.gallery);
                Navigator.pop(context);
              },
            )
          ],
        ));
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
        labelStyle: TextStyle(fontWeight: FontWeight.w500),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}