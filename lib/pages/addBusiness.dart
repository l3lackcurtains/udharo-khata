import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:udharokhata/blocs/businessBloc.dart';
import 'package:udharokhata/helpers/appLocalizations.dart';
import 'package:udharokhata/helpers/stateNotifier.dart';
import 'package:udharokhata/models/business.dart';
import 'package:udharokhata/pages/deleteBusiness.dart';

import '../main.dart';

class AddBusiness extends StatefulWidget {
  AddBusiness({Key key}) : super(key: key);
  @override
  _AddBusinessState createState() => _AddBusinessState();
}

class _AddBusinessState extends State<AddBusiness> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final BusinessBloc _businessBloc = BusinessBloc();

  String _companyName;
  File _logo;
  final picker = ImagePicker();

  Business _business = Business();

  Future getImageFromGallery() async {
    var image = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      _logo = File(image.path);
    });
  }

  Future getImageFromCamera() async {
    var image = await picker.getImage(source: ImageSource.camera);

    setState(() {
      _logo = File(image.path);
    });
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
          AppLocalizations.of(context).translate('addCompany'),
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(
          color: Colors.black, //change your color here
        ),
        actions: <Widget>[
          FlatButton.icon(
            label: Text(
              AppLocalizations.of(context).translate('deleteCompany'),
              style: TextStyle(fontSize: 12),
            ),
            icon: Icon(Icons.delete, size: 20.0, color: Colors.red),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DeleteBusiness(),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          addCompany();
        },
        icon: Icon(Icons.check),
        label: Text(AppLocalizations.of(context).translate('addCompany')),
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
                      hintText: AppLocalizations.of(context)
                          .translate('companyNameLabelMeta'),
                      labelText: AppLocalizations.of(context)
                          .translate('companyNameLabel'),
                    ),
                    autovalidate: false,
                    validator: (input) {
                      if (input.isEmpty) {
                        return AppLocalizations.of(context)
                            .translate('companyNameLabelError');
                      }
                      return null;
                    },
                    onSaved: (input) => _companyName = input,
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
          child: _logo == null
              ? Image(
                  image: AssetImage('assets/images/noimage_person.png'),
                  width: 60,
                )
              : Image.file(
                  _logo,
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
                AppLocalizations.of(context).translate('companyImageLabel')),
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
          title:
              Text(AppLocalizations.of(context).translate('companyImageLabel')),
          children: <Widget>[
            SimpleDialogOption(
              child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(AppLocalizations.of(context)
                      .translate('uploadFromCamera'))),
              onPressed: () {
                Navigator.of(context).pop();
                getImageFromCamera();
              },
            ),
            SimpleDialogOption(
              child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(AppLocalizations.of(context)
                      .translate('uploadFromGallery'))),
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

  void addCompany() async {
    final formState = _formKey.currentState;

    if (formState.validate()) {
      formState.save();

      // check image and its size (1MB)
      if (_logo != null && _logo.lengthSync() > 2000000) {
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

      _business.companyName = _companyName;
      _business.name = "";
      _business.phone = "";
      _business.email = "";
      _business.address = "";
      _business.logo = "";
      _business.website = "";
      _business.role = "";

      if (_logo != null) {
        String base64Image = base64Encode(_logo.readAsBytesSync());
        _business.logo = base64Image;
      }

      List<Business> businessesList = await _businessBloc.getBusinesss();
      _business.id = businessesList.length;

      await _businessBloc.addBusiness(_business);
      changeSelectedBusiness(context, _business.id);
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
