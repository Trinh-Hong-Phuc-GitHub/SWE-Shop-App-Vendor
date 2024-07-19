import 'package:flutter/material.dart';
import 'package:uber_shop_vendor_app/vendor/models/vendor_user_model.dart';
import 'package:uber_shop_vendor_app/vendor/views/auth/vendor_registration_screen.dart';
import 'package:uber_shop_vendor_app/vendor/views/screens/main_vendor_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LandingScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final CollectionReference _vendorStream =
    FirebaseFirestore.instance.collection('vendors');
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: _vendorStream.doc(_auth.currentUser!.uid).snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!snapshot.data!.exists) {
            return VendorRegistrationScreen();
          }

          VendorUserModel vendorUserModel = VendorUserModel.fromJson(
              snapshot.data!.data() as Map<String, dynamic>);
          if (vendorUserModel.approved == true) {
            return MainVendorScreen();
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Image.network(
                    vendorUserModel.storeImage,
                    width: 90,
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Text(
                  vendorUserModel.businessName,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Text(
                  'Your Application, has been sent to shop admin\nadmin will get back to you soon',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                // TextButton(
                //   onPressed: () async {
                //     // Navigate to edit screen
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //         builder: (context) => EditVendorInfoScreen(),
                //       ),
                //     );
                //   },
                //   child: Text('Edit Profile'),
                // ),
                TextButton(
                  onPressed: () async {
                    await _auth.signOut();
                  },
                  child: Text(
                    'Sign out',
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
