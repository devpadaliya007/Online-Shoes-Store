import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;


class UpdateBrandPage extends StatefulWidget {
  const UpdateBrandPage({super.key});

  @override
  State<UpdateBrandPage> createState() => _UpdateBrandPageState();
}

class _UpdateBrandPageState extends State<UpdateBrandPage> {
  final _fromkey = GlobalKey<FormState>();
  String? _SelectBrandID;
  Map<String,dynamic>? _selectBrandData;
  List<QueryDocumentSnapshot> _brands=[];
  late TextEditingController _name;
  late TextEditingController _description;
  late TextEditingController _contact;
  File? _imageFile;
  bool _isLoding=false;

  @override

  void initState(){
    _name=TextEditingController();
    _description=TextEditingController();
    _contact=TextEditingController();
    _fetchBrands();
  }

  Future<void> _fetchBrands() async{
    try{
      final snapshot=await FirebaseFirestore.instance.collection('Brands').get();
      setState(() {
        _brands=snapshot.docs;
      });
    }
    catch(e){
      Get.snackbar("Something went wrong","Please Fill All The Fields",colorText: Colors.red);
    }
  }

  void _onBrandsSelect(String? BrandID){
    if(BrandID!=null){
      final selectBrand=_brands.firstWhere((brand)=>brand.id==BrandID).data();
      setState(() {
          _SelectBrandID=BrandID;
          _selectBrandData=selectBrand as Map<String,dynamic>;
          _name.text=_selectBrandData!['Name']??"";
          _description.text=_selectBrandData!['Description']??"";
          _contact.text=_selectBrandData!['Contact']??"";
      });
  }
}

  Future<String?> _picImage(ImageSource source) async {
    final picImage = await ImagePicker().pickImage(source: source);
    if (picImage != null) {
      setState(() {
        _imageFile = File(picImage.path);
      });
      return picImage.path;
    }
    return null;
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

  Future<void> _updateBrand() async {
    if (_fromkey.currentState!.validate() && _SelectBrandID != null) {
      setState(() {
        _isLoding = true;
      });

      try {
        String? imageUrl = _selectBrandData?['imageUrl'];
        if (_imageFile != null) {
          imageUrl = await _uploadImageToCloudinary(_imageFile!);
        }

        await FirebaseFirestore.instance.collection('Brands').doc(_SelectBrandID).update({
          'Name': _name.text,
          'Description': _description.text,
          'Contact': _contact.text,
          if (imageUrl != null) 'imageUrl': imageUrl,
        });
        Get.snackbar("Successfully", "Brand updated successfully", colorText: Colors.green);
        Navigator.pop(context);
      } catch (e) {
        Get.snackbar("Update Error", "Something went wrong: ${e.toString()}", colorText: Colors.red);
      } finally {
        setState(() {
          _isLoding = false;
        });
      }
    } else {
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
          'Update Brand',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoding?Center(child: CircularProgressIndicator(),):
      Padding(padding: EdgeInsets.all(16),
        child: Form(key:_fromkey,
            child: ListView(
              children: [
                SizedBox(height: 20,),
                DropdownButtonFormField<String>(
                  value: _SelectBrandID,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                  ),
                  hint: const Text("Choose Brand"),
                  items: [
                    ..._brands.map((brand) {
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
                      _SelectBrandID = value;
                      _onBrandsSelect(value);
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
                        _selectBrandData?['imageUrl']!=null?
                        NetworkImage(_selectBrandData!['imageUrl'])as ImageProvider:AssetImage('img.png'),
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
                buildTextField(_name, 'Brand Name'),
                SizedBox(height: 15),
                buildTextField(_description, 'Brand Description', maxLines: 3),
                SizedBox(height: 15),
                buildTextField(_contact, 'Brand Contact',keyboardType: TextInputType.emailAddress,),
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
                    onPressed: _updateBrand,
                    child: Text('Update Brand',style: TextStyle(fontSize: 16,color: Colors.white),
                  ),
                ),
                ),
          ]
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
                  await _picImage(ImageSource.camera);
                  Navigator.pop(context);
                }

            ),
            ListTile(
              leading: Icon(Icons.photo),
              title: Text('Gallery'),
              onTap: () {
                _picImage(ImageSource.gallery);
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
        labelStyle: const TextStyle(fontWeight: FontWeight.w500),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}



