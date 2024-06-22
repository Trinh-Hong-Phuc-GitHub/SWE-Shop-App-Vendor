import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VendorChatDetail extends StatefulWidget {
  final String buyerId;
  final String sellerId;
  final String productId;
  final dynamic data;

  const VendorChatDetail({super.key,
    required this.buyerId,
    required this.sellerId,
    required this.productId,
    required this.data});

  @override
  State<VendorChatDetail> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<VendorChatDetail> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();
  late Stream<QuerySnapshot> _chatsStream;

  @override
  void initState() {
    super.initState();
    _chatsStream = _firestore
        .collection('chats')
        .where('buyerId', isEqualTo: widget.buyerId)
        .where('sellerId', isEqualTo: widget.sellerId)
        .where('productId', isEqualTo: widget.productId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  void _sendMessage() async {
    DocumentSnapshot vendorDoc =
    await _firestore.collection('vendors').doc(widget.sellerId).get();

    DocumentSnapshot buyerDoc =
    await _firestore.collection('buyers').doc(widget.buyerId).get();

    String message = _messageController.text.trim();
    if (message.isNotEmpty) {
      await _firestore.collection('chats').add({
        'productId': widget.productId,
        'buyerName': (buyerDoc.data() as Map<String, dynamic>)['fullName'],
        'buyerPhoto': (buyerDoc.data() as Map<String, dynamic>)['profileImage'],
        'sellerPhoto': (vendorDoc.data() as Map<String, dynamic>)['storeImage'],
        'buyerId': widget.buyerId,
        'sellerId': widget.sellerId,
        'message': message,
        'senderId': FirebaseAuth.instance.currentUser!.uid,
        'timestamp': DateTime.now(),
      });
      setState(() {
        _messageController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chat Screen',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            letterSpacing: 3,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _chatsStream,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                return ListView(
                  reverse: true,
                  children:
                  snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                    document.data()! as Map<String, dynamic>;

                    String senderId = data['senderId'];

                    bool isBuyer = senderId == widget.buyerId;

                    String senderType = isBuyer ? "Buyer" : "Seller";

                    bool isSellerrMessage =
                        senderId == FirebaseAuth.instance.currentUser!.uid;

                    return ListTile(
                      leading: isSellerrMessage
                          ? CircleAvatar(
                        child: Image.network(
                          data['sellerPhoto'],
                        ),
                      )
                          : CircleAvatar(
                        child: Image.network(
                          data['buyerPhoto'],
                        ),
                      ),
                      title: Text(data['message']),
                      subtitle: Text('Sent by $senderType', style: TextStyle(
                        color: Colors.pink.shade900,
                      ),),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _sendMessage,
                  icon: Icon(
                    Icons.send,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
