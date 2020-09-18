import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:udharokhata/blocs/businessBloc.dart';
import 'package:udharokhata/helpers/stateNotifier.dart';
import 'package:udharokhata/models/business.dart';

class AddBusiness extends StatefulWidget {
  final Function() notifyParent;
  AddBusiness(this.notifyParent, {Key key}) : super(key: key);
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
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Add Company',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(
          color: Colors.black, //change your color here
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          addCompany();
        },
        icon: Icon(Icons.check),
        label: Text('Add Company'),
      ),
      body: Container(
          decoration: BoxDecoration(color: Colors.white),
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                customerImageWidget(),
                TextFormField(
                  decoration: InputDecoration(
                    icon: Icon(Icons.person),
                    hintText: 'What is your company name?',
                    labelText: 'Company Name *',
                  ),
                  autovalidate: false,
                  validator: (input) {
                    if (input.isEmpty) {
                      return 'Please type customer name';
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
    );
  }

  Widget customerImageWidget() {
    return Row(
      children: <Widget>[
        Center(
          child: _logo == null
              ? Image(
                  image: AssetImage('images/noimage_person.png'),
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
            child: Text('Upload Company Logo'),
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

  void addCompany() async {
    final formState = _formKey.currentState;

    if (formState.validate()) {
      formState.save();

      // More Validation
      if (_logo != null && _logo.lengthSync() > 2000000) {
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

      _business.companyName = _companyName;
      _business.logo = null;

      // check image and its size (1MB)
      if (_logo != null) {
        String base64Image = base64Encode(_logo.readAsBytesSync());
        _business.logo = base64Image;
      }

      List<Business> businessesList = await _businessBloc.getBusinesss();
      _business.id = businessesList.length;

      await _businessBloc.addBusiness(_business);
      changeSelectedBusiness(context, _business.id);
      widget.notifyParent();
      Navigator.pop(context);
    }
  }
}
