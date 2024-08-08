import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

class VendorOrdersScreen extends StatefulWidget {
  @override
  _VendorOrdersScreenState createState() => _VendorOrdersScreenState();
}

class _VendorOrdersScreenState extends State<VendorOrdersScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  String formatedDate(date) {
    final outputDateFormat = DateFormat("dd/MM/yyyy");
    final outputDate = outputDateFormat.format(date);
    return outputDate;
  }

  Future<void> updateOrderStatus(
      BuildContext context, String orderId, String status) async {
    await _firestore.collection('orders').doc(orderId).update({
      'orderStatus': status,
    });
  }

  Future<void> handleAcceptOrder(
      BuildContext context, Map<String, dynamic> data) async {
    final orderProducts = data['products'] as List<dynamic>;

    // Create a map to sum quantities by productId
    final Map<String, int> productQuantities = {};

    for (var product in orderProducts) {
      final productId = product['productId'] as String;
      final quantity = (product['quantity'] as num).toInt(); // Ensure quantity is int

      if (productQuantities.containsKey(productId)) {
        productQuantities[productId] = productQuantities[productId]! + quantity;
      } else {
        productQuantities[productId] = quantity;
      }
    }

    // Check product quantities
    bool canAcceptOrder = true;

    for (var productId in productQuantities.keys) {
      final productSnapshot = await _firestore.collection('products').doc(productId).get();
      final productData = productSnapshot.data() as Map<String, dynamic>;

      final productStockQuantity = (productData['productQuantity'] as num).toInt(); // Ensure stock quantity is int
      final orderedQuantity = productQuantities[productId]!;

      if (productStockQuantity < orderedQuantity) {
        canAcceptOrder = false;
        break;
      }
    }

    if (canAcceptOrder) {
      // Accept the order
      await _firestore.collection('orders').doc(data['orderId']).update({
        'accepted': true,
        // 'title': 'Xác nhận',
      });

      // Update product quantities
      for (var productId in productQuantities.keys) {
        final productSnapshot = await _firestore.collection('products').doc(productId).get();
        final productData = productSnapshot.data() as Map<String, dynamic>;

        final updatedQuantity = (productData['productQuantity'] as num).toInt() - productQuantities[productId]!;
        await _firestore.collection('products').doc(productId).update({
          'productQuantity': updatedQuantity,
        });
      }
    } else {
      // Show alert if the condition is not met
      if (mounted) {
        showDialog(
          context: _navigatorKey.currentContext!,
          builder: (context) {
            return AlertDialog(
              title: Text('Cảnh Báo'),
              content: Text('Không đủ số lượng trong kho để xác nhận đơn hàng này'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
  }


  Future<void> handleRejectOrder(
      BuildContext context, Map<String, dynamic> data) async {
    await _firestore.collection('orders').doc(data['orderId']).update({
      'accepted': false,
      // 'title': 'Từ chối'
    });
  }

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> _ordersStream = FirebaseFirestore.instance
        .collection('orders')
        .where('vendorId', isEqualTo: _auth.currentUser!.uid)
        .snapshots();

    return Scaffold(
      key: _navigatorKey, // Set the key here
      appBar: AppBar(
        title: Text(
          'Đơn Hàng',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 5,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _ordersStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
              document.data()! as Map<String, dynamic>;

              return data['accepted'] == false
                  ? Slidable(
                key: ValueKey(data['orderId']),
                startActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  dismissible: DismissiblePane(onDismissed: () {}),
                  children: [
                    SlidableAction(
                      onPressed: (context) {
                        handleRejectOrder(context, data);
                      },
                      backgroundColor: Color(0xFFFE4A49),
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: 'Từ Chối',
                    ),
                    SlidableAction(
                      onPressed: (context) {
                        handleAcceptOrder(context, data);
                      },
                      backgroundColor: Color(0xFF21B7CA),
                      foregroundColor: Colors.white,
                      icon: Icons.check,
                      label: 'Xác Nhận',
                    ),
                  ],
                ),
                child: buildOrderListItem(context, data),
              )
                  : buildOrderListItem(context, data);
            }).toList(),
          );
        },
      ),
    );
  }

  Widget buildOrderListItem(BuildContext context, Map<String, dynamic> data) {
    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.white,
            radius: 14,
            child: data['accepted'] == true
                ? Icon(Icons.delivery_dining)
                : Icon(Icons.access_time),
          ),
          title: data['accepted'] == true
              ? Text(
            'Xác Nhận',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          )
              : Text(
            'Chưa Xác Nhận',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          trailing: Text(
            "${data['totalPrice'].toStringAsFixed(0)}" +" đ",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        ExpansionTile(
          title: Text(
            'Mô Tả Đơn Hàng',
            style: TextStyle(
              color: Colors.pink.shade900,
            ),
          ),
          subtitle: Text(
            'Xem Chi Tiết',
          ),
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: data['products'].length,
              itemBuilder: (context, index) {
                final product = data['products'][index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Image.network(
                      product['productImage'][0],
                    ),
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product['productName'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            'Số Lượng',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            product['quantity'].toString(),
                            style: TextStyle(
                              color: Colors.pink.shade900,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            'Size',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            product['productSize'],
                            style: TextStyle(
                              color: Colors.pink.shade900,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            'Giá',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            product['price'].toStringAsFixed(0) + ' đ',
                            style: TextStyle(
                              color: Colors.pink.shade900,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            ListTile(
              title: Text(
                'Thông Tin Người Mua',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['fullName'],
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    data['email'],
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    data['address'],
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    data['phoneNumber'],
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Thời Gian Đặt:' +
                          " " +
                          formatedDate(
                            data['orderDate'].toDate(),
                          ),
                      style: TextStyle(
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  if (data['accepted'] == true)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Trạng Thái:' + ' ' + data['orderStatus'],
                        style: TextStyle(
                          color: Colors.green,
                        ),
                      ),
                    ),
                  if (data['accepted'] == false)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Trạng Thái:' + ' ' + 'Chưa Xác Nhận',
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ),
                  if (data['accepted'] == true &&
                      data['orderStatus'] == 'Đang Đóng Gói')
                    ElevatedButton(
                      onPressed: () async {
                        final result = await showDialog(
                          context: _navigatorKey.currentContext!,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('Thay đổi trạng thái thành đang vận chuyển?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(false);
                                  },
                                  child: Text('Trở về'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(true);
                                  },
                                  child: Text('Thay đổi'),
                                ),
                              ],
                            );
                          },
                        );
                        if (result == true && mounted) {
                          await updateOrderStatus(context, data['orderId'], 'Đang Vận Chuyển');
                        }
                      },
                      child: Text('Đánh Dấu Là Vận Chuyển'),
                    ),
                  if (data['accepted'] == true &&
                      data['orderStatus'] == 'Đang Vận Chuyển')
                    ElevatedButton(
                      onPressed: () async {
                        final result = await showDialog(
                          context: _navigatorKey.currentContext!,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('Đơn hàng được giao thành công hay thất bại?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop('failed');
                                  },
                                  child: Text('Thất bại'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop('successful');
                                  },
                                  child: Text('Thành công'),
                                ),
                              ],
                            );
                          },
                        );
                        if (result == 'successful' && mounted) {
                          await updateOrderStatus(context, data['orderId'], 'Giao Thành Công');
                        } else if (result == 'failed' && mounted) {
                          await updateOrderStatus(context, data['orderId'], 'Giao Thất Bại');

                          // Update product quantities if delivery failed
                          final List<dynamic> products = data['products'] as List<dynamic>;

                          // Create a map to aggregate quantities by productId
                          final Map<String, int> productQuantities = {};

                          for (var product in products) {
                            final productId = product['productId'] as String;
                            final quantity = (product['quantity'] as num).toInt(); // Ensure quantity is int

                            if (productQuantities.containsKey(productId)) {
                              productQuantities[productId] = productQuantities[productId]! + quantity;
                            } else {
                              productQuantities[productId] = quantity;
                            }
                          }

                          // Update product quantities in Firestore
                          for (var productId in productQuantities.keys) {
                            final productSnapshot = await _firestore.collection('products').doc(productId).get();
                            final productData = productSnapshot.data() as Map<String, dynamic>;

                            final currentQuantity = (productData['productQuantity'] as num).toInt(); // Ensure current quantity is int
                            final updatedQuantity = currentQuantity + productQuantities[productId]!;

                            await _firestore.collection('products').doc(productId).update({
                              'productQuantity': updatedQuantity,
                            });
                          }
                        }
                      },
                      child: Text('Thay Đổi Trạng Thái Giao Hàng'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}