import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uber_shop_vendor_app/vendor/views/screens/inner_screens/vendor_chat_detail.dart';

class VendorMessageScreen extends StatelessWidget {
  const VendorMessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> _vendorChatStream = FirebaseFirestore.instance
        .collection('chats')
        .where('sellerId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Messages',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 5,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _vendorChatStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          Map<String,String> lastProductByBuyerId = {};
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot documentSnapshot = snapshot.data!.docs[index];

              Map<String, dynamic> data = documentSnapshot.data()! as Map<String,dynamic>;

              String message = data['message'].toString();

              String senderId = data['senderId'].toString();

              String productId = data['productId'].toString();

              String productName = data['productName'].toString();

              String buyerName = data['buyerName'].toString();

              /// Check if the message is from the seller
              bool isSellerMessage = senderId == FirebaseAuth.instance.currentUser!.uid;

              if(!isSellerMessage) {
                String key = senderId + "_" + productId;
                if(!lastProductByBuyerId.containsKey(key)){
                  lastProductByBuyerId[key] = productId;

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return VendorChatDetail(
                          buyerId: data['buyerId'],
                          sellerId: FirebaseAuth.instance.currentUser!.uid,
                          productId: productId,
                          productName: productName,
                          data: data,
                        );
                      },));
                    },
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(data['buyerPhoto']),
                      ),
                      title: Text(message),
                      subtitle: Text('Sender By Buyer $buyerName'),
                    ),
                  );
                }
              }
              return SizedBox.shrink();
          },);
        },
      ),
    );
  }
}
