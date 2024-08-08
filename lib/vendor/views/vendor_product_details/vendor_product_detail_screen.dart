import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:uber_shop_vendor_app/vendor/views/screens/edit_product_screen.dart';

class VendorProductDetailScreen extends StatefulWidget {
  final dynamic productData;

  const VendorProductDetailScreen({Key? key, required this.productData})
      : super(key: key);

  @override
  State<VendorProductDetailScreen> createState() =>
      _VendorProductDetailScreenState();
}

class _VendorProductDetailScreenState extends State<VendorProductDetailScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _brandNameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _productPriceController = TextEditingController();
  final TextEditingController _productDescriptionController =
  TextEditingController();
  final TextEditingController _categoryNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _productNameController.text = widget.productData['productName'];
    _brandNameController.text = widget.productData['brandName'];
    _quantityController.text = widget.productData['productQuantity'].toString();
    _productPriceController.text =
        widget.productData['productPrice'].toString();
    _productDescriptionController.text = widget.productData['description'];
    _categoryNameController.text = widget.productData['category'];
  }

  double? productPrice;
  int? productQuantity;

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: Duration(seconds: 2),
    ));
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(widget.productData['productName']),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TextFormField(
                controller: _productNameController,
                decoration: InputDecoration(labelText: 'Tên sản phẩm'),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _brandNameController,
                decoration: InputDecoration(labelText: 'Thương hiệu'),
              ),
              SizedBox(height: 20),
              TextFormField(
                onChanged: (value) {
                  productQuantity = int.tryParse(value);
                },
                controller: _quantityController,
                decoration: InputDecoration(labelText: 'Số lượng'),
              ),
              SizedBox(height: 20),
              TextFormField(
                onChanged: (value) {
                  productPrice = double.tryParse(value);
                },
                controller: _productPriceController,
                decoration: InputDecoration(labelText: 'Đơn giá'),
              ),
              SizedBox(height: 20),
              TextFormField(
                maxLines: 3,
                controller: _productDescriptionController,
                decoration: InputDecoration(labelText: 'Mô tả'),
              ),
              SizedBox(height: 20),
              TextFormField(
                enabled: false,
                controller: _categoryNameController,
                decoration: InputDecoration(labelText: 'Phân loại'),
              ),
            ],
          ),
        ),
      ),
      bottomSheet: Padding(
        padding: const EdgeInsets.all(12.0),
        child: InkWell(
          onTap: () async {
            if (productPrice != null && productQuantity != null) {
                await _firestore
                    .collection('products')
                    .doc(widget.productData['productId'])
                    .update({
                  'productName': _productNameController.text,
                  'brandName': _brandNameController.text,
                  'productQuantity': productQuantity,
                  'productPrice': productPrice,
                  'description': _productDescriptionController.text,
                  'category': _categoryNameController.text,
                });
                EasyLoading.showSuccess('Sửa thành công!');
            } else {
              _showDialog('Lỗi', 'Cần cập nhật giá và số lượng');
            }
          },
          child: Container(
            height: 40,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Colors.pink.shade900,
              borderRadius: BorderRadius.circular(
                10,
              ),
            ),
            child: Center(
                child: Text(
                  "CẬP NHẬT",
                  style: TextStyle(
                    fontSize: 18,
                    letterSpacing: 6,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                )),
          ),
        ),
      ),
    );
  }
}
