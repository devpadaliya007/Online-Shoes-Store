import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../product/product.dart';


class HomeController extends GetxController{

  FirebaseFirestore firebase = FirebaseFirestore.instance;
  // late CollectionReference productCollection;

  final CollectionReference productCollection = FirebaseFirestore.instance.collection('products');


  TextEditingController productNameCtrl = TextEditingController();
  TextEditingController productDescriptionCtrl = TextEditingController();
  TextEditingController productImgCtrl = TextEditingController();
  TextEditingController productPriceCtrl = TextEditingController();

  String category = 'general';
  String brand = 'un-branded';
  bool offer = false;

  List<Product> products = [];

  FirebaseFirestore get firestore => firebase;


  @override
  // Future<void> onInit() async {
  //   productCollection = firestore.collection('products');  // productCollection -> for remove,delete,update,add....
  //   await fetchProducts();
  //   super.onInit();
  // }

  Future<void> onInit() async {
    await fetchProducts();
    super.onInit();
  }

  addProduct() {
    // DocumentReference doc = productCollection.doc();
    DocumentReference doc = productCollection.doc();
    try {
      Product product= Product(
        id:doc.id,
        name: productNameCtrl.text,
        category: category,
        description: productDescriptionCtrl.text,
        price: double.tryParse(productPriceCtrl.text),
        brand: brand,
        image: productImgCtrl.text,
        offer: offer,
      );
      final productJson = product.toJson();
      doc.set(productJson);
      //Get.snackbar('Success', 'Prouduct added successfully' , colorText: Colors.green);
      setValuesDefault();
    } catch (e) {
      Get.snackbar('Error', e.toString() , colorText: Colors.red);
      print(e);
    }
  }

  fetchProducts() async {
    try {
      QuerySnapshot productSnapshot = await productCollection.get();

      final List<Product> retrevedProducts = productSnapshot.docs.map((doc) =>
          Product.fromJson(doc.data() as Map<String,dynamic>)).toList();
      products.clear();
      products.assignAll(retrevedProducts);
      //Get.snackbar('Success', 'Product fetch Successfully', colorText: Colors.green);
    } catch (e) {
      Get.snackbar('Error', e.toString(), colorText: Colors.red);
      print(e);
    }finally{
      update();
    }
  }

  deleteProduct(String id) async {
    try {
      await productCollection.doc(id).delete();
      fetchProducts();
    } catch (e) {
      Get.snackbar('Error', e.toString() , colorText: Colors.red);
      print(e);
    }
  }

  setValuesDefault(){
    productNameCtrl.clear();
    productPriceCtrl.clear();
    productDescriptionCtrl.clear();
    productImgCtrl.clear();

    category = 'general';
    brand = 'un-branded';
    offer = false;
    update();
  }

}