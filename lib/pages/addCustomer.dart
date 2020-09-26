import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:udharokhata/blocs/customerBloc.dart';
import 'package:udharokhata/main.dart';
import 'package:udharokhata/models/customer.dart';
import 'package:udharokhata/pages/importContacts.dart';

class AddCustomer extends StatefulWidget {
  AddCustomer({Key key}) : super(key: key);
  @override
  _AddCustomerState createState() => _AddCustomerState();
}

class _AddCustomerState extends State<AddCustomer> {
  final CustomerBloc customerBloc = CustomerBloc();

  String _name, _phone, _address;
  File _image;
  final picker = ImagePicker();

  Customer customer = Customer();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Future getImageFrom(String from) async {
    var image;
    if (from == 'camera') {
      image = await picker.getImage(source: ImageSource.camera);
    } else {
      image = await picker.getImage(source: ImageSource.gallery);
    }
    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Add Customer',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(
          color: Colors.black, //change your color here
        ),
        actions: <Widget>[
          FlatButton.icon(
            label: Text(
              "Import Contacts",
              style: TextStyle(fontSize: 12),
            ),
            icon: Icon(Icons.control_point, size: 20.0, color: Colors.blue),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ImportContacts(),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          addCustomer();
        },
        icon: Icon(Icons.check),
        label: Text('Add Customer'),
      ),
      body: SingleChildScrollView(
        child: Container(
            margin: EdgeInsets.fromLTRB(0, 0, 0, 48),
            padding: EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  customerImageWidget(),
                  TextFormField(
                    decoration: InputDecoration(
                      icon: Icon(Icons.person),
                      hintText: 'What is your customer name?',
                      labelText: 'Name *',
                    ),
                    autovalidate: false,
                    validator: (input) {
                      if (input.isEmpty) {
                        return 'Please type customer name';
                      }
                      return null;
                    },
                    onSaved: (input) => _name = input,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      icon: Icon(Icons.call_missed_outgoing),
                      hintText: 'Contact Number of customer.',
                      labelText: 'Phone Number *',
                    ),
                    autovalidate: false,
                    validator: (input) {
                      if (input.isEmpty) {
                        return 'Please type customer phone number';
                      }
                      return null;
                    },
                    onSaved: (input) => _phone = input,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      icon: Icon(Icons.location_city),
                      hintText: 'Where your customer resides.',
                      labelText: 'Physical Address',
                    ),
                    autovalidate: false,
                    validator: null,
                    onSaved: (input) => _address = input,
                  ),
                  Padding(
                    padding: EdgeInsets.all(36),
                  ),
                ],
              ),
            )),
      ),
    );
  }

  Widget customerImageWidget() {
    return Row(
      children: <Widget>[
        Center(
          child: _image == null
              ? Image(
                  image: AssetImage('assets/images/noimage_person.png'),
                  width: 60,
                )
              : Image.file(
                  _image,
                  width: 60,
                ),
        ),
        Padding(
          padding: EdgeInsets.all(16),
          child: FlatButton(
            onPressed: () {
              showUploadDialog();
            },
            child: Text('Upload Customer Image'),
          ),
        )
      ],
    );
  }

  void showUploadDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('Upload Customer Image'),
          children: <Widget>[
            SimpleDialogOption(
              child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('Upload from Camera')),
              onPressed: () {
                Navigator.of(context).pop();
                getImageFrom('camera');
              },
            ),
            SimpleDialogOption(
              child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('Upload from Gallery')),
              onPressed: () {
                Navigator.of(context).pop();
                getImageFrom('gallery');
              },
            ),
          ],
        );
      },
    );
  }

  void addCustomer() async {
    final formState = _formKey.currentState;

    if (formState.validate()) {
      formState.save();

      // More Validation
      if (_image != null && _image.lengthSync() > 2000000) {
        final snackBar = SnackBar(
            content: Row(children: <Widget>[
          Icon(
            Icons.warning,
            color: Colors.redAccent,
          ),
          Padding(
              padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
              child: Text('Image size is too big. (Max size 2MB)'))
        ]));
        _scaffoldKey.currentState.showSnackBar(snackBar);
        return;
      }

      customer.name = _name;
      customer.phone = _phone;
      customer.address = _address;
      customer.image = null;

      // Associate current business
      final prefs = await SharedPreferences.getInstance();
      int selectedBusinessId = prefs.getInt('selected_business');

      customer.businessId = selectedBusinessId;

      // check image and its size (1MB)
      if (_image != null) {
        String base64Image = base64Encode(_image.readAsBytesSync());
        customer.image = base64Image;
      }

      await customerBloc.addCustomer(customer);

      Navigator.of(context).pop();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MyHomePage(),
        ),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
