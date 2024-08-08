import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../vendor_product_details/vendor_product_detail_screen.dart';

class PublishedTab extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String searchQuery;

  PublishedTab({required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> _vendorProductStream = FirebaseFirestore
        .instance
        .collection('products')
        .where('vendorId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .where('approved', isEqualTo: true)
        .snapshots();
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: _vendorProductStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Colors.pink.shade900,
              ),
            );
          }

          var products = snapshot.data!.docs.where((product) {
            return product['productName']
                .toString()
                .toLowerCase()
                .contains(searchQuery);
          }).toList();

          if (products.isEmpty) {
            return Center(
              child: Text(
                'Không có sản phẩm nào',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            itemCount: products.length,
            itemBuilder: ((context, index) {
              final vendorProductData = products[index];
              return Slidable(
                child: InkWell(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                          return VendorProductDetailScreen(
                            productData: vendorProductData,
                          );
                        }));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        Container(
                          height: 80,
                          width: 80,
                          child: Image.network(
                              vendorProductData['productImage'][0]),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                vendorProductData['productName'],
                                style: TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              Text(
                                    vendorProductData['productPrice']
                                        .toStringAsFixed(0) + ' đ',
                                style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.pink.shade900),
                              ),
                              Text(
                                'Số lượng: ' +
                                    vendorProductData['productQuantity']
                                        .toString(),
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                key: ValueKey(vendorProductData['productId']),
                startActionPane: ActionPane(
                  motion: ScrollMotion(),
                  children: [
                    SlidableAction(
                      flex: 2,
                      onPressed: (context) async {
                        await _firestore
                            .collection('products')
                            .doc(vendorProductData['productId'])
                            .update({
                          'approved': false,
                        });
                      },
                      backgroundColor: Color(0xFF21B7CA),
                      foregroundColor: Colors.white,
                      icon: Icons.approval_rounded,
                      label: 'Riêng Tư',
                    ),
                    SlidableAction(
                      flex: 2,
                      onPressed: (context) async {
                        await _firestore
                            .collection('products')
                            .doc(vendorProductData['productId'])
                            .delete();
                      },
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: 'Xóa',
                    ),
                  ],
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
