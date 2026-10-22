import 'package:flutter/material.dart';
import 'AddAddressPage.dart';
import 'AddToCart_Page.dart';
import 'ProductDescriptionPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'UserProfilePage.dart';
import 'UserScarchScreen.dart';
import 'WishListScreen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    ProductGridScreen(),
    Userscarchscreen(),
    Wishlistscreen(),
    AddtocartPage(),
    UserProfilePage(),
  ];

  String? userName;
  String? userEmail;
  String? proImage;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
        setState(() {
          userName = userDoc['name'];
          userEmail = userDoc['email'];
          proImage = userDoc['profileImage'];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE2D9FB),
      appBar: AppBar(
        backgroundColor: Color(0xFFE2D9FB),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Footware Store',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3436),
            fontSize: 22,
          ),
        ),
        iconTheme: IconThemeData(color: Color(0xFF2D3436)),
      ),
    drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              currentAccountPicture: CircleAvatar(backgroundImage:  AssetImage('assets/img/pic-2.png') as ImageProvider,child: proImage==Null?Icon(Icons.person,size: 40,): null),
              accountName: Text(userName ?? 'Loding.....😒'),
              accountEmail: Text(userEmail ?? 'Loding......😒'),
            ),
            ListTile(
              leading: Icon(Icons.search),
              title: Text("Search"),
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (_)=>Userscarchscreen()));
              },
            ),
            ListTile(
              leading: Icon(Icons.favorite_border),
              title: Text("Wish List"),
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (_)=>Wishlistscreen()));
              },
            ),
            ListTile(
              leading: Icon(Icons.location_on),
              title: Text("Add Address"),
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (_)=>AddAddressPage()));
              },
            ),
          ],
        ),
      ),

      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFF6C5CE7),
          unselectedItemColor: Color(0xFF95A5A6),
          elevation: 0,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
            BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'WishList'),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

class ProductGridScreen extends StatefulWidget {
  ProductGridScreen({super.key});

  @override
  State<ProductGridScreen> createState() => _ProductGridScreenState();
}

class _ProductGridScreenState extends State<ProductGridScreen> {
  final List<String> brandNames = [
    'Nike',
    'Adidas',
    'Puma',
    'Reebok',
    'Skechers',
    'Converse',
    'New Balance'
  ];

  final List<String> sortOptions = [
    'Sort',
    'Recommended',
    'Price: Low to High',
    'Price: High to Low',
    'Newest',
    'Name: A-Z',
    'Name: Z-A'
  ];

  String selectedSort = 'Sort';
  List<String> selectedBrands = [];

  void _showBrandFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Icon(Icons.filter_list, color: Color(0xFF6C5CE7)),
                  SizedBox(width: 8),
                  Text(
                    'Filter by Brand',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3436),
                    ),
                  ),
                ],
              ),
              content: Container(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: brandNames.map((brand) {
                      bool isSelected = selectedBrands.contains(brand);
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: isSelected ? Color(0xFF6C5CE7): Colors.grey[50],
                        ),
                        child: CheckboxListTile(
                          title: Text(
                            brand,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              color: isSelected ? Color(0xFF6C5CE7) : Color(0xFF2D3436),
                            ),
                          ),
                          value: isSelected,
                          activeColor: Color(0xFF6C5CE7),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                selectedBrands.add(brand);
                              } else {
                                selectedBrands.remove(brand);
                              }
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedBrands.clear();
                    });
                  },
                  child: Text(
                    'Clear All',
                    style: TextStyle(color: Color(0xFF636E72)),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    this.setState(() {});
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFE2D9FB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('Apply', style: TextStyle(color: Colors.black87)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  List<QueryDocumentSnapshot> _sortProducts(List<QueryDocumentSnapshot> products) {
    List<QueryDocumentSnapshot> sortedProducts = List.from(products);

    switch (selectedSort) {
      case 'Price: Low to High':
        sortedProducts.sort((a, b) {
          double priceA = double.tryParse(a['Price'].toString()) ?? 0;
          double priceB = double.tryParse(b['Price'].toString()) ?? 0;
          return priceA.compareTo(priceB);
        });
        break;
      case 'Price: High to Low':
        sortedProducts.sort((a, b) {
          double priceA = double.tryParse(a['Price'].toString()) ?? 0;
          double priceB = double.tryParse(b['Price'].toString()) ?? 0;
          return priceB.compareTo(priceA);
        });
        break;
      case 'Name: A-Z':
        sortedProducts.sort((a, b) => a['Name'].toString().toLowerCase().compareTo(b['Name'].toString().toLowerCase()));
        break;
      case 'Name: Z-A':
        sortedProducts.sort((a, b) => b['Name'].toString().toLowerCase().compareTo(a['Name'].toString().toLowerCase()));
        break;
      default:
        break;
    }
    return sortedProducts;
  }

  List<QueryDocumentSnapshot> _filterByBrand(List<QueryDocumentSnapshot> products) {
    if (selectedBrands.isEmpty) {
      return products;
    }
    return products.where((product) {
      String productBrand = product['Brand']?.toString() ?? '';
      return selectedBrands.any((brand) => productBrand.toLowerCase().contains(brand.toLowerCase()));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFE2D9FB),
      ),
      child: Column(
        children: [
          // Sort and Filter Controls
          Container(
            margin: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: 8),
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedSort,
                        isExpanded: true,
                        icon: Icon(Icons.keyboard_arrow_down, color: Color(0xFF6C5CE7)),
                        items: sortOptions.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(
                                color: Color(0xFF2D3436),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedSort = newValue ?? 'Recommended';
                          });
                        },
                      ),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF6C5CE7).withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: _showBrandFilterDialog,
                    icon: Icon(Icons.tune, color: Colors.white),
                    label: Text(
                      selectedBrands.isEmpty
                          ? 'Brands'
                          : '${selectedBrands.length} selected',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Active Brand Filters
          if (selectedBrands.isNotEmpty)
            Container(
              height: 50,
              margin: EdgeInsets.only(bottom: 16),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16),
                children: selectedBrands.map((brand) => Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Chip(
                    label: Text('Brand: $brand'),
                    deleteIcon: Icon(Icons.close, size: 18),
                    backgroundColor: Color(0xFFFEBC2C).withOpacity(0.1),
                    labelStyle: TextStyle(
                      color: Color(0xFFE17055),
                      fontWeight: FontWeight.w600,
                    ),
                    onDeleted: () {
                      setState(() {
                        selectedBrands.remove(brand);
                      });
                    },
                  ),
                )).toList(),
              ),
            ),

          // Product Grid
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('Products').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C5CE7)),
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined,
                            size: 80, color: Colors.grey[400]),
                        SizedBox(height: 16),
                        Text(
                          'No Products Available',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                List<QueryDocumentSnapshot> products = snapshot.data!.docs;

                // Apply filters and sorting
                products = _filterByBrand(products);
                products = _sortProducts(products);

                if (products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
                        SizedBox(height: 16),
                        Text(
                          'No products found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Try adjusting your filters',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              selectedBrands.clear();
                              selectedSort = 'Recommended';
                            });
                          },
                          icon: Icon(Icons.clear_all, color: Colors.white),
                          label: Text('Clear Filters',
                              style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF6C5CE7),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: EdgeInsets.all(16.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductDescriptionPage(
                              productId: product.id,
                              name: product['Name'],
                              imageUrl: product['imageUrl'],
                              price: double.parse(product['Price'].toString()),
                              description: product['Description'],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 4,
                              child: ClipRRect(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20)),
                                child: Stack(
                                  children: [
                                    Image.network(
                                      product['imageUrl'],
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          color: Colors.grey[200],
                                          child: Icon(
                                            Icons.image_not_supported,
                                            size: 50,
                                            color: Colors.grey[400],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Padding(
                                padding: EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product['Name'],
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF2D3436),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 4),
                                        if (product['Brand'] != null)
                                          Text(
                                            product['Brand'],
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "₹${product['Price']}",
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Color(0xFF00B894),
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}