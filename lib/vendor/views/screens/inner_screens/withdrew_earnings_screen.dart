import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:uuid/uuid.dart';

class WithdrewEarningsScreen extends StatefulWidget {
  @override
  State<WithdrewEarningsScreen> createState() => _WithdrewEarningsScreenState();
}

class _WithdrewEarningsScreenState extends State<WithdrewEarningsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  late String bankName;

  late String accountName;

  late String accountNumber;

  late String amount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Withdrew Earnings'),
        iconTheme: IconThemeData(
          color: Colors.pink,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextFormField(
                  onChanged: (value) {
                    bankName = value;
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please Fill In This Field';
                    } else {
                      return null;
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Bank Name',
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 5,
                    ),
                    hintText: 'Enter Bank Name',
                    hintStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  onChanged: (value) {
                    accountName = value;
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please Fill In This Field';
                    } else {
                      return null;
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Account Name',
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 5,
                    ),
                    hintText: 'Enter Account Name',
                    hintStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  onChanged: (value) {
                    accountNumber = value;
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please Fill In This Field';
                    } else {
                      return null;
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Account Number',
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 5,
                    ),
                    hintText: 'Enter Account Number',
                    hintStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  onChanged: (value) {
                    amount = value;
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please Fill In This Field';
                    } else {
                      return null;
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 5,
                    ),
                    hintText: 'Enter Amount',
                    hintStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                SizedBox(
                  height: 25,
                ),
                InkWell(
                  onTap: () async {
                    DocumentSnapshot userDoc = await _firestore
                        .collection('vendors')
                        .doc(_auth.currentUser!.uid)
                        .get();
                    if (_formKey.currentState!.validate()) {
                      final withDrewId = Uuid().v4();
                      EasyLoading.show();
                      await _firestore
                          .collection('withdrewal')
                          .doc(withDrewId)
                          .set({
                        'businessName': (userDoc.data()
                            as Map<String, dynamic>)['businessName'],
                        'bankName': bankName,
                        'accountAccount': accountName,
                        'accountNumber': accountNumber,
                        'amount': amount,
                      }).whenComplete((){
                        EasyLoading.dismiss();
                      });
                    } else {
                      print('bad');
                    }
                  },
                  child: Container(
                    height: 40,
                    width: MediaQuery.of(context).size.width - 40,
                    decoration: BoxDecoration(
                      color: Colors.pink,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        'Get Cash',
                        style: TextStyle(
                          color: Colors.white,
                          letterSpacing: 2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
