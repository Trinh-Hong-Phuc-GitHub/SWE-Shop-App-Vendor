import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:uber_shop_vendor_app/vendor/provider/product_provider.dart';
import 'package:uber_shop_vendor_app/vendor/views/screens/tab_bar_screen/attributes_screen.dart';
import 'package:uber_shop_vendor_app/vendor/views/screens/tab_bar_screen/general_screen.dart';
import 'package:uber_shop_vendor_app/vendor/views/screens/tab_bar_screen/images_screen.dart';
import 'package:uber_shop_vendor_app/vendor/views/screens/tab_bar_screen/shipping_screen.dart';
import 'package:uuid/uuid.dart';

class UploadScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final ProductProvider _productProvider =
        Provider.of<ProductProvider>(context);
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          // backgroundColor: Colors.yellow.shade900,
          title: Text(
            'Upload Products',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
            ),
          ),
          bottom: TabBar(
            tabs: [
              Tab(
                child: Text('General'),
              ),
              Tab(
                child: Text('Shipping'),
              ),
              Tab(
                child: Text('Attribute'),
              ),
              Tab(
                child: Text('Image'),
              ),
            ],
          ),
        ),
        body: Form(
          key: _formKey,
          child: TabBarView(
            children: [
              GeneralScreen(),
              ShippingScreen(),
              AttributesScreen(),
              ImagesScreen(),
            ],
          ),
        ),
        bottomSheet: Padding(
          padding: const EdgeInsets.all(15.0),
          child: InkWell(
            onTap: () async {
              DocumentSnapshot userDoc = await _firestore
                  .collection('vendors')
                  .doc(_auth.currentUser!.uid)
                  .get();
              final productId = Uuid().v4();
              if (_formKey.currentState!.validate()) {
                EasyLoading.show(status: 'Uploading');
                await _firestore.collection('products').doc(productId).set({
                  'productId': productId,
                  'productName': _productProvider.productData['productName'],
                  'productPrice': _productProvider.productData['productPrice'],
                  'productQuantity':
                      _productProvider.productData['productQuantity'],
                  'category': _productProvider.productData['category'],
                  'description': _productProvider.productData['description'],
                  'chargeShipping':
                      _productProvider.productData['chargeShipping'],
                  'shippingCharge':
                      _productProvider.productData['shippingCharge'],
                  'brandName': _productProvider.productData['brandName'],
                  'sizeList': _productProvider.productData['sizeList'],
                  'productImage': _productProvider.productData['imageUrlList'],
                  'businessName':
                      (userDoc.data() as Map<String, dynamic>)['businessName'],
                  'storeImage':
                      (userDoc.data() as Map<String, dynamic>)['storeImage'],
                  'countryValue':
                      (userDoc.data() as Map<String, dynamic>)['countryValue'],
                  'cityValue':
                      (userDoc.data() as Map<String, dynamic>)['cityValue'],
                  'stateValue':
                      (userDoc.data() as Map<String, dynamic>)['stateValue'],
                  'phoneNumber':
                      (userDoc.data() as Map<String, dynamic>)['phoneNumber'],
                  'vendorId': _auth.currentUser!.uid,
                  'rating': 0,
                  'totalReviews': 0,
                  'approved': false,
                }).whenComplete(() {
                  EasyLoading.dismiss();
                  EasyLoading.showSuccess('Upload Successful!');
                  _productProvider.clearData();
                });
              } else {
                print('Not Valid');
              }
            },
            child: Container(
              height: 50,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.pink,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Center(
                child: Text(
                  'Upload Product',
                  style: TextStyle(
                    color: Colors.white,
                    letterSpacing: 5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
