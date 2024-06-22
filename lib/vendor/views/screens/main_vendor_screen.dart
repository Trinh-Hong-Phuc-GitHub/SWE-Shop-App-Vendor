import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uber_shop_vendor_app/vendor/views/screens/earning_screen.dart';
import 'package:uber_shop_vendor_app/vendor/views/screens/edit_screen.dart';
import 'package:uber_shop_vendor_app/vendor/views/screens/logout_screen.dart';
import 'package:uber_shop_vendor_app/vendor/views/screens/upload_screen.dart';
import 'package:uber_shop_vendor_app/vendor/views/screens/vendor_message_screen.dart';
import 'package:uber_shop_vendor_app/vendor/views/screens/vendor_orders_screen.dart';

class MainVendorScreen extends StatefulWidget {
  const MainVendorScreen({super.key});

  @override
  State<MainVendorScreen> createState() => _MainVendorScreenState();
}

class _MainVendorScreenState extends State<MainVendorScreen> {
  int _paperIndex = 0;

  List<Widget> _pages = [
    EarningScreen(),
    UploadScreen(),
    EditProductScreen(),
    VendorOrdersScreen(),
    VendorMessageScreen(),
    LogoutScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _paperIndex,
        onTap: (value) {
          setState(() {
            _paperIndex = value;
          });
        },
        type: BottomNavigationBarType.fixed,
        unselectedItemColor: Colors.black,
        selectedItemColor: Colors.pink,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              CupertinoIcons.money_dollar,
            ),
            label: 'Earnings',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.upload,
            ),
            label: 'Upload',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.edit,
            ),
            label: 'Edit',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.shop,
            ),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.message,
            ),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.logout,
            ),
            label: 'Logout',
          ),
        ],
      ),
      body: _pages[_paperIndex],
    );
  }
}
