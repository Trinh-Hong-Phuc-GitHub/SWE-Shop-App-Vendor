import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

class VendorOrdersScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String formattedDate(date) {
    final outputDateFormat = DateFormat("dd/MM/yyyy");
    final outputDate = outputDateFormat.format(date);
    return outputDate;
  }

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> _ordersStream = FirebaseFirestore.instance
        .collection('orders')
        .where('vendorId', isEqualTo: _auth.currentUser!.uid)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Orders',
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
                            onPressed: (context) async {
                              await _firestore
                                  .collection('orders')
                                  .doc(data['orderId'])
                                  .update({'accepted': false});
                            },
                            backgroundColor: Color(0xFFFE4A49),
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            label: 'Reject',
                          ),
                          SlidableAction(
                            onPressed: (context) async {
                              await _firestore
                                  .collection('orders')
                                  .doc(data['orderId'])
                                  .update({'accepted': true});
                            },
                            backgroundColor: Color(0xFF21B7CA),
                            foregroundColor: Colors.white,
                            icon: Icons.check,
                            label: 'Accept',
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
                  'Accepted',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                )
              : Text(
                  'Not Accepted',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
          trailing: Text(
            "\$${data['price'].toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        ExpansionTile(
          title: Text(
            'Order Details',
            style: TextStyle(
              color: Colors.pink.shade900,
            ),
          ),
          subtitle: Text(
            'View Order Details',
          ),
          children: [
            ListTile(
              leading: CircleAvatar(
                child: Image.network(
                  data['productImage'][0],
                ),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['productName'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        'Quantity',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        data['quantity'].toString(),
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
                        data['productSize'],
                        style: TextStyle(
                          color: Colors.pink.shade900,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Buyer Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
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
                      'Order Date: ' +
                          formattedDate(data['orderDate'].toDate()),
                      style: TextStyle(
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  if (data['accepted'] == true)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Order Status: ' + data['orderStatus'],
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  if (data['accepted'] == true &&
                      data['orderStatus'] == 'Packing')
                    ElevatedButton(
                      onPressed: () async {
                        final result = await showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('Have you finished packing?'),
                              content: Text(
                                  'Do you want to change order status to shipping?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(false);
                                  },
                                  child: Text('No'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(true);
                                  },
                                  child: Text('Change'),
                                ),
                              ],
                            );
                          },
                        );
                        if (result == true) {
                          await _firestore
                              .collection('orders')
                              .doc(data['orderId'])
                              .update({'orderStatus': 'Shipping'});
                        }
                      },
                      child: Text('Mark as Shipping'),
                    ),
                  if (data['accepted'] == true &&
                      data['orderStatus'] == 'Shipping')
                    ElevatedButton(
                      onPressed: () async {
                        final result = await showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text(
                                  'Order delivered successfully or failed?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop('failed');
                                  },
                                  child: Text('Failed'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop('successful');
                                  },
                                  child: Text('Successful'),
                                ),
                              ],
                            );
                          },
                        );
                        if (result == 'successful') {
                          await _firestore
                              .collection('orders')
                              .doc(data['orderId'])
                              .update(
                                  {'orderStatus': 'Delivered Successfully'});
                        } else if (result == 'failed') {
                          await _firestore
                              .collection('orders')
                              .doc(data['orderId'])
                              .update(
                                  {'orderStatus': 'Delivered Unsuccessfully'});
                        }
                      },
                      child: Text('Change Shipping Status'),
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
