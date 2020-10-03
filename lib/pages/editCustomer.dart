import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:udharokhata/blocs/customerBloc.dart';
import 'package:udharokhata/helpers/appLocalizations.dart';
import 'package:udharokhata/models/customer.dart';
import 'package:udharokhata/pages/singleCustomer.dart';

class EditCustomer extends StatefulWidget {
  final Customer customer;
  EditCustomer(this.customer, {Key key}) : super(key: key);
  @override
  _EditCustomerState createState() => _EditCustomerState();
}

class _EditCustomerState extends State<EditCustomer> {
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

    if (image == null) return;

    ImageProperties properties =
        await FlutterNativeImage.getImageProperties(image.path);
    File rawImage = await FlutterNativeImage.compressImage(image.path,
        quality: 80,
        targetWidth: 512,
        targetHeight: (properties.height * 512 / properties.width).round());

    if (rawImage != null && rawImage.lengthSync() > 200000) {
      final snackBar = SnackBar(
          content: Row(children: <Widget>[
        Icon(
          Icons.warning,
          color: Colors.redAccent,
        ),
        Padding(
            padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
            child:
                Text(AppLocalizations.of(context).translate('imageSizeError')))
      ]));
      _scaffoldKey.currentState.showSnackBar(snackBar);
      return;
    }

    if (rawImage != null) {
      setState(() {
        _image = rawImage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Customer customer = widget.customer;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        title: Text(
          AppLocalizations.of(context).translate('editCustomer'),
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(
          color: Colors.black, //change your color here
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            updateCustomer(customer);
          },
          icon: Icon(Icons.check),
          label: Text(AppLocalizations.of(context).translate('editCustomer')),
          heroTag: "payment"),
      body: SingleChildScrollView(
        child: Container(
            margin: EdgeInsets.fromLTRB(0, 0, 0, 48),
            padding: EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  customerImageWidget(customer.image),
                  TextFormField(
                    initialValue: customer.name,
                    decoration: InputDecoration(
                      icon: Icon(Icons.person),
                      hintText: AppLocalizations.of(context)
                          .translate('customerNameLabelMeta'),
                      labelText: AppLocalizations.of(context)
                          .translate('customerNameLabel'),
                    ),
                    autovalidate: false,
                    validator: (input) {
                      if (input.isEmpty) {
                        return AppLocalizations.of(context)
                            .translate('customerNameError');
                      }
                      return null;
                    },
                    onSaved: (input) => _name = input,
                  ),
                  TextFormField(
                    initialValue: customer.phone,
                    decoration: InputDecoration(
                      icon: Icon(Icons.call_missed_outgoing),
                      hintText: AppLocalizations.of(context)
                          .translate('customerPhoneLabelMeta'),
                      labelText: AppLocalizations.of(context)
                          .translate('customerPhoneLabel'),
                    ),
                    autovalidate: false,
                    validator: (input) {
                      if (input.isEmpty) {
                        return AppLocalizations.of(context)
                            .translate('customerPhoneError');
                      }
                      return null;
                    },
                    onSaved: (input) => _phone = input,
                  ),
                  TextFormField(
                    initialValue: customer.address,
                    decoration: InputDecoration(
                      icon: Icon(Icons.location_city),
                      hintText: AppLocalizations.of(context)
                          .translate('customerAddressLabelMeta'),
                      labelText: AppLocalizations.of(context)
                          .translate('customerAddressLabel'),
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
                      image: AssetImage('assets/images/noimage_person.png'),
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
            child: Text(
                AppLocalizations.of(context).translate('customerImageLabel')),
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
          title: Text(
              AppLocalizations.of(context).translate('customerImageLabel')),
          children: <Widget>[
            SimpleDialogOption(
              child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(AppLocalizations.of(context)
                      .translate('uploadFromCamera'))),
              onPressed: () {
                Navigator.of(context).pop();
                getImageFrom('camera');
              },
            ),
            SimpleDialogOption(
              child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(AppLocalizations.of(context)
                      .translate('uploadFromGallery'))),
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

  void updateCustomer(Customer customer) async {
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
              child: Text(
                  AppLocalizations.of(context).translate('imageSizeError')))
        ]));
        _scaffoldKey.currentState.showSnackBar(snackBar);
        return;
      }

      customer.name = _name;
      customer.phone = _phone;
      customer.address = _address;

      if (_image != null) {
        String base64Image = base64Encode(_image.readAsBytesSync());
        customer.image = base64Image;
      }
      await customerBloc.updateCustomer(customer);
      Navigator.of(context).pop();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SingleCustomer(customer.id),
        ),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
