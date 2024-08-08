import 'package:country_state_city_picker/country_state_city_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uber_shop_vendor_app/vendor/controller/vendor_controller.dart';

class VendorRegistrationScreen extends StatefulWidget {
  @override
  State<VendorRegistrationScreen> createState() =>
      _VendorRegistrationScreenState();
}

class _VendorRegistrationScreenState extends State<VendorRegistrationScreen> {
  final VendorController _vendorController = VendorController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Uint8List? _image;

  late String countryValue;

  late String stateValue;

  late String cityValue;

  late String businessName;

  late String emailAddress;

  late String address;

  late String phoneNumber;

  selectGalleryImage() async {
    Uint8List im = await _vendorController.pickStoreImage(ImageSource.gallery);

    setState(() {
      _image = im;
    });
  }

  selectCameraImage() async {
    Uint8List im = await _vendorController.pickStoreImage(ImageSource.camera);

    setState(() {
      _image = im;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // Ensures bottom overflow error does not occur
      appBar: AppBar(
        backgroundColor: Colors.pink,
        toolbarHeight: 200,
        flexibleSpace: LayoutBuilder(builder: ((context, constraints) {
          return FlexibleSpaceBar(
            background: Center(
              child: Container(
                height: 90,
                width: 90,
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: _image != null
                    ? Image.memory(_image!)
                    : IconButton(
                  onPressed: () {
                    selectGalleryImage();
                  },
                  icon: Icon(
                    CupertinoIcons.photo,
                  ),
                ),
              ),
            ),
          );
        })),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Vui lòng nhập tên cửa hàng';
                    } else {
                      return null;
                    }
                  },
                  onChanged: (value) {
                    businessName = value;
                  },
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                    labelText: 'Tên cửa hàng',
                    hintText: 'Tên cửa hàng',
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Vui lòng nập địa chỉ email';
                    } else {
                      return null;
                    }
                  },
                  onChanged: (value) {
                    emailAddress = value;
                  },
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Email',
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Vui lòng nhập số điện thoại';
                    } else {
                      return null;
                    }
                  },
                  onChanged: (value) {
                    phoneNumber = value;
                  },
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Số điện thoại',
                    hintText: 'Số điện thoại',
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                SelectState(
                  onCountryChanged: (value) {
                    setState(() {
                      countryValue = value;
                    });
                  },
                  onStateChanged: (value) {
                    setState(() {
                      stateValue = value;
                    });
                  },
                  onCityChanged: (value) {
                    setState(() {
                      cityValue = value;
                    });
                  },
                ),
                TextFormField(
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Vui lòng nhập địa chỉ cụ thể';
                    } else {
                      return null;
                    }
                  },
                  onChanged: (value) {
                    address = value;
                  },
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                    labelText: 'Địa chỉ cụ thể',
                    hintText: 'Địa chỉ cụ thể',
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(
          onTap: () {
            if (_formKey.currentState!.validate()) {
              EasyLoading.show(status: 'Vui lòng chờ!');
              _vendorController.vendorRegistrationForm(
                businessName,
                emailAddress,
                phoneNumber,
                countryValue,
                stateValue,
                cityValue,
                address,
                _image,
              ).whenComplete(() {
                EasyLoading.dismiss();
              });
            } else {
              print('False');
            }
          },
          child: Container(
            height: 50,
            width: MediaQuery.of(context).size.width - 40,
            decoration: BoxDecoration(
              color: Colors.pink,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                'Lưu',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 4,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
