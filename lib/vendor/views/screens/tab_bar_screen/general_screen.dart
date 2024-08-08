import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uber_shop_vendor_app/vendor/provider/product_provider.dart';

class GeneralScreen extends StatefulWidget {
  @override
  State<GeneralScreen> createState() => _GeneralScreenState();
}

class _GeneralScreenState extends State<GeneralScreen> with AutomaticKeepAliveClientMixin{
  @override
  bool get wantKeepAlive => true;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<String> _categoryList = [];

  _getCategories() {
    return _firestore.collection('categories').get().then(
      (QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          setState(() {
            _categoryList.add(doc['categoryName']);
          });
        });
      },
    );
  }

  @override
  void initState() {
    _getCategories();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final ProductProvider _productProvider = Provider.of<ProductProvider>(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                validator: (value) {
                  if(value!.isEmpty) {
                    return'Nhập tên sản phẩm';
                  } else {
                    return null;
                  }
                },
                onChanged: (value) {
                  _productProvider.getFormData(productName: value);
                },
                decoration: InputDecoration(
                  hintText: 'Nhập tên sản phẩm',
                  labelText: 'Nhập tên sản phẩm',
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                validator: (value) {
                  if(value!.isEmpty) {
                    return'Nhập giá sản phẩm';
                  } else {
                    return null;
                  }
                },
                onChanged: (value) {
                  _productProvider.getFormData(productPrice: double.parse(value));
                },
                decoration: InputDecoration(
                  hintText: 'Nhập giá sản phẩm',
                  labelText: 'Nhập giá sản phẩm',
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                validator: (value) {
                  if(value!.isEmpty) {
                    return'Nhập số lượng sản phẩm';
                  } else {
                    return null;
                  }
                },
                onChanged: (value) {
                  _productProvider.getFormData(productQuantity: int.parse(value));
                },
                decoration: InputDecoration(
                  hintText: 'Nhập số lượng sản phẩm',
                  labelText: 'Nhập số lượng sản phẩm',
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              DropdownButtonFormField(
                hint: Text(
                  'Phân loại',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                ),
                items: _categoryList.map<DropdownMenuItem<dynamic>>((e) {
                  return DropdownMenuItem(
                    value: e,
                    child: Text(e),
                  );
                }).toList(),
                onChanged: (value) {
                  _productProvider.getFormData(category: value);
                },
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                validator: (value) {
                  if(value!.isEmpty) {
                    return'Nhập mô tả sản phẩm';
                  } else {
                    return null;
                  }
                },
                onChanged: (value) {
                  _productProvider.getFormData(description: value);
                },
                maxLines: 10,
                minLines: 3,
                decoration: InputDecoration(
                  hintText: 'Nhập mô tả sản phẩm',
                  labelText: 'Nhập mô tả sản phẩm',
                ),
              ),
              SizedBox(
                height: 100,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
