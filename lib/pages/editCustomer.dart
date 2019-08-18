import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simple_khata/blocs/customerBloc.dart';
import 'package:simple_khata/models/customer.dart';
import 'package:simple_khata/pages/singleCustomer.dart';

class EditCustomer extends StatefulWidget {
  @override
  _EditCustomerState createState() => _EditCustomerState();
}

class _EditCustomerState extends State<EditCustomer> {
  final CustomerBloc customerBloc = CustomerBloc();

  String _name, _phone, _address;
  File _image;

  Customer customer = Customer();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Future getImageFromGallery() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image;
    });
  }

  Future getImageFromCamera() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      _image = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    final EditCustomerScreenArguments args =
        ModalRoute.of(context).settings.arguments;
    Customer argCustomer = args.customer;

    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Edit Customer',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(
          color: Colors.black, //change your color here
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          updateCustomer(argCustomer.id);
        },
        icon: Icon(Icons.check),
        label: Text('Update Customer'),
      ),
      body: Container(
          decoration: BoxDecoration(color: Colors.white),
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                customerImageWidget(argCustomer.image),
                TextFormField(
                  initialValue: argCustomer.name,
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
                  initialValue: argCustomer.phone,
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
                  initialValue: argCustomer.address,
                  decoration: InputDecoration(
                    icon: Icon(Icons.location_city),
                    hintText: 'Where your customer resides.',
                    labelText: 'Physical Address',
                  ),
                  autovalidate: false,
                  validator: null,
                  onSaved: (input) => _address = input,
                ),
              ],
            ),
          )),
    );
  }

  Widget customerImageWidget(String image) {
    Uint8List customerImage;
    if (image != null) {
      customerImage = Base64Decoder().convert(image);
    }

    return Row(
      children: <Widget>[
        Center(
          child: _image == null
              ? customerImage == null
                  ? Image(
                      image: AssetImage('images/noimage_person.png'),
                      width: 60,
                    )
                  : Image.memory(
                      customerImage,
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
                getImageFromCamera();
              },
            ),
            SimpleDialogOption(
              child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('Upload from Gallery')),
              onPressed: () {
                Navigator.of(context).pop();
                getImageFromGallery();
              },
            ),
          ],
        );
      },
    );
  }

  void updateCustomer(int id) {
    final formState = _formKey.currentState;

    if (formState.validate()) {
      formState.save();
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

      customer.id = id;
      customer.name = _name;
      customer.phone = _phone;
      customer.address = _address;

      if (_image != null) {
        String base64Image = base64Encode(_image.readAsBytesSync());
        customer.image = base64Image;
      }

      customerBloc.updateCustomer(customer);

      Navigator.pop(context);
    }
  }
}
