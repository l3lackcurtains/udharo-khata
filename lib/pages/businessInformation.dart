import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading/indicator/ball_beat_indicator.dart';
import 'package:loading/loading.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:udharokhata/blocs/businessBloc.dart';
import 'package:udharokhata/database/businessRepo.dart';
import 'package:udharokhata/helpers/appLocalizations.dart';
import 'package:udharokhata/helpers/constants.dart';
import 'package:udharokhata/models/business.dart';

class BusinessInformation extends StatefulWidget {
  @override
  _BusinessInformationState createState() => _BusinessInformationState();
}

class _BusinessInformationState extends State<BusinessInformation> {
  final BusinessBloc businessBloc = BusinessBloc();

  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Business _businessInfo = Business();
  Future<Business> _businessFuture;
  final _businessRepository = BusinessRepository();
  final picker = ImagePicker();

  bool _savingCompany = false;

  @override
  void initState() {
    super.initState();
    initBusinessCard();
  }

  void downloadPdf() async {
    await buildPDF();
    final dir = await getExternalStorageDirectory();
    final file = File(dir.path + "/business_card.pdf");
    OpenFile.open(file.path);
  }

  void initBusinessCard() async {
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    int selectedBusinessId = prefs.getInt('selected_business') ?? 0;

    _businessFuture = _businessRepository.getBusiness(selectedBusinessId);

    Business businessz = await businessBloc.getBusiness(selectedBusinessId);

    if (businessz != null) {
      setState(() {
        _businessInfo = businessz;
      });
    }
  }

  Future<void> buildPDF() async {
    if (!mounted) return;
    await businessCardMaker();
  }

  Future<void> businessCardMaker() async {
    final doc = pw.Document();
    final PdfImage backgroundImage = PdfImage.file(
      doc.document,
      bytes: (await rootBundle.load('assets/images/cv_template.png'))
          .buffer
          .asUint8List(),
    );
    final PdfImage phoneImage = PdfImage.file(
      doc.document,
      bytes: (await rootBundle.load('assets/images/cv/phone.png'))
          .buffer
          .asUint8List(),
    );
    final PdfImage emailImage = PdfImage.file(
      doc.document,
      bytes: (await rootBundle.load('assets/images/cv/email.png'))
          .buffer
          .asUint8List(),
    );
    final PdfImage locationImage = PdfImage.file(
      doc.document,
      bytes: (await rootBundle.load('assets/images/cv/location.png'))
          .buffer
          .asUint8List(),
    );
    final PdfImage websiteImage = PdfImage.file(
      doc.document,
      bytes: (await rootBundle.load('assets/images/cv/website.png'))
          .buffer
          .asUint8List(),
    );
    const PdfColor whiteColor = PdfColor.fromInt(0xffffffff);
    const PdfColor semiWhiteColor = PdfColor.fromInt(0xfff1f1f1);

    PdfImage businessLogo;

    if (_businessInfo.logo != "") {
      Uint8List logo = Base64Decoder().convert(_businessInfo.logo);
      businessLogo = PdfImage.file(
        doc.document,
        bytes: logo,
      );
    }

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(1200, 680),
        build: (pw.Context context) => pw.Container(
          child: pw.Stack(
            children: [
              pw.Container(
                alignment: pw.Alignment(0.0, 0.0),
                height: 700,
                child: pw.Image(backgroundImage, height: 700),
              ),
              pw.Container(
                height: 700,
                padding: pw.EdgeInsets.fromLTRB(0, 140, 80, 0),
                alignment: pw.Alignment(0.0, 0.0),
                child: pw.Row(
                  children: [
                    pw.Container(
                      width: 700,
                      child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            businessLogo != null
                                ? pw.Image(businessLogo, height: 80)
                                : pw.SizedBox(height: 80),
                            pw.SizedBox(height: 24),
                            pw.Text(
                              _businessInfo.companyName ?? "COMPANY NAME",
                              style: pw.TextStyle(
                                  fontSize: 36, color: semiWhiteColor),
                            ),
                            pw.SizedBox(height: 32),
                            pw.RichText(
                              text: pw.TextSpan(
                                text: _businessInfo.name != null
                                    ? _businessInfo.name.split(" ")[0]
                                    : "",
                                style: pw.TextStyle(
                                  fontSize: 54,
                                  color: whiteColor,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                                children: <pw.TextSpan>[
                                  pw.TextSpan(
                                      text: _businessInfo.name != null
                                          ? " ${_businessInfo.name.split(" ").length > 1 ? _businessInfo.name.split(" ")[1] : ""}"
                                          : "",
                                      style: pw.TextStyle(
                                        fontSize: 54,
                                        color: whiteColor,
                                        fontWeight: pw.FontWeight.normal,
                                      )),
                                ],
                              ),
                            ),
                            pw.SizedBox(height: 24),
                            pw.Text(_businessInfo.role,
                                style: pw.TextStyle(
                                    fontSize: 36, color: semiWhiteColor)),
                          ]),
                    ),
                    pw.Spacer(),
                    pw.Container(
                      padding: pw.EdgeInsets.fromLTRB(0, 80, 0, 0),
                      child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            _businessInfo.phone.length > 0
                                ? pw.Row(children: [
                                    pw.Image(phoneImage, height: 30),
                                    pw.SizedBox(width: 20),
                                    pw.Text(_businessInfo.phone,
                                        style: pw.TextStyle(
                                            fontSize: 32,
                                            color: semiWhiteColor)),
                                  ])
                                : pw.Container(),
                            pw.SizedBox(height: 36),
                            _businessInfo.address.length > 0
                                ? pw.Row(children: [
                                    pw.Image(locationImage, height: 30),
                                    pw.SizedBox(width: 20),
                                    pw.Text(_businessInfo.address,
                                        style: pw.TextStyle(
                                            fontSize: 32,
                                            color: semiWhiteColor)),
                                  ])
                                : pw.Container(),
                            pw.SizedBox(height: 36),
                            _businessInfo.email.length > 0
                                ? pw.Row(children: [
                                    pw.Image(emailImage, height: 30),
                                    pw.SizedBox(width: 20),
                                    pw.Text(_businessInfo.email,
                                        style: pw.TextStyle(
                                            fontSize: 32,
                                            color: semiWhiteColor)),
                                  ])
                                : pw.Container(),
                            pw.SizedBox(height: 36),
                            _businessInfo.website.length > 0
                                ? pw.Row(children: [
                                    pw.Image(websiteImage, height: 30),
                                    pw.SizedBox(width: 20),
                                    pw.Text(_businessInfo.website,
                                        style: pw.TextStyle(
                                            fontSize: 32,
                                            color: semiWhiteColor)),
                                  ])
                                : pw.Container(),
                          ]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    final dir = await getExternalStorageDirectory();
    final file = File(dir.path + "/business_card.pdf");
    file.writeAsBytesSync(doc.save());
  }

  void updateBusinessInformation() async {
    if (!mounted) return;

    setState(() {
      _savingCompany = true;
    });

    final formState = _formKey.currentState;
    if (formState.validate()) {
      final getBusinessInfo = await businessBloc.getBusiness(0);
      if (getBusinessInfo == null) {
        await businessBloc.addBusiness(_businessInfo);
      } else {
        await businessBloc.updateBusiness(_businessInfo);
      }
    }

    Timer(Duration(seconds: 1), () {
      setState(() {
        _savingCompany = false;
      });
    });
  }

  Future getImageFrom(String from) async {
    if (!mounted) return;

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

    if (rawImage != null && rawImage.lengthSync() > 2000000) {
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
      String base64Image = base64Encode(rawImage.readAsBytesSync());
      setState(() {
        _businessInfo.logo = base64Image;
      });
      buildPDF();
    }
  }

  @override
  void dispose() {
    super.dispose();
    businessBloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('businessInfo'),
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                fontFamily: 'Poppins')),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0,
        backgroundColor: Colors.grey.shade100,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              alignment: Alignment.center,
              color: Colors.black87,
              height: 230,
              child: businessCardBox(),
            ),
            Container(
              padding: EdgeInsets.all(24),
              child: FutureBuilder<Business>(
                  future: _businessFuture,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    Business businessItem = Business();
                    if (snapshot.hasData && !_savingCompany) {
                      businessItem = snapshot.data;
                      return businessCardForm(businessItem);
                    }
                    return Center(
                      child: Container(
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width,
                        height: 280,
                        child: Loading(
                            indicator: BallBeatIndicator(),
                            size: 60.0,
                            color: Theme.of(context).accentColor),
                      ),
                    );
                  }),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          decoration: BoxDecoration(color: Colors.white10),
          height: 60,
          padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Expanded(
                child: RaisedButton(
                  color: Theme.of(context).primaryColor,
                  onPressed: () {
                    updateBusinessInformation();
                  },
                  child: Text(
                    AppLocalizations.of(context).translate('saveCompany'),
                    style: TextStyle(color: xLightWhite),
                  ),
                ),
              ),
              SizedBox(
                width: 24,
              ),
              Expanded(
                child: FlatButton(
                  onPressed: () {
                    downloadPdf();
                  },
                  child: Text(
                    AppLocalizations.of(context).translate('downloadCard'),
                    style: TextStyle(color: Theme.of(context).accentColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget businessCardBox() {
    Uint8List businessLogo;
    if (_businessInfo.logo != null && _businessInfo.logo.length > 0) {
      businessLogo = Base64Decoder().convert(_businessInfo.logo);
    }

    return Container(
      height: 700,
      padding: EdgeInsets.fromLTRB(40, 45, 30, 10),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/cv_template.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 130,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  businessLogo != null
                      ? Image.memory(
                          businessLogo,
                          height: 25,
                        )
                      : SizedBox(height: 30),
                  SizedBox(height: 8),
                  Text(
                    _businessInfo.companyName ?? "",
                    style: TextStyle(fontSize: 12, color: Color(0xFFF1F1F1)),
                  ),
                  SizedBox(height: 12),
                  _businessInfo.name != null
                      ? RichText(
                          text: TextSpan(
                            text: _businessInfo.name?.split(" ")[0],
                            style: TextStyle(
                              fontSize: 18,
                              color: Color(0xFFFFFFFF),
                              fontWeight: FontWeight.bold,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                  text:
                                      " ${_businessInfo.name.split(" ").length > 1 ? _businessInfo.name?.split(" ")[1] : ""}",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Color(0xFFFFFFFF),
                                    fontWeight: FontWeight.normal,
                                  )),
                            ],
                          ),
                        )
                      : Container(),
                  SizedBox(height: 8),
                  _businessInfo.role != null
                      ? Text(_businessInfo.role,
                          style:
                              TextStyle(fontSize: 12, color: Color(0xFFF1F1F1)))
                      : Container()
                ]),
          ),
          Spacer(),
          Container(
            padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _businessInfo.phone != null && _businessInfo.phone.length > 0
                  ? Row(children: [
                      Image.asset("assets/images/cv/phone.png", height: 10),
                      SizedBox(width: 8),
                      Text(_businessInfo.phone,
                          style: TextStyle(
                              fontSize: 12, color: Color(0xFFF1F1F1))),
                    ])
                  : Container(),
              SizedBox(height: 12),
              _businessInfo.address != null && _businessInfo.address.length > 0
                  ? Row(children: [
                      Image.asset("assets/images/cv/location.png", height: 10),
                      SizedBox(width: 10),
                      Text(_businessInfo.address,
                          style: TextStyle(
                              fontSize: 12, color: Color(0xFFF1F1F1))),
                    ])
                  : Container(),
              SizedBox(height: 12),
              _businessInfo.email != null && _businessInfo.email.length > 0
                  ? Row(children: [
                      Image.asset("assets/images/cv/email.png", height: 10),
                      SizedBox(width: 8),
                      Text(_businessInfo.email,
                          style: TextStyle(
                              fontSize: 12, color: Color(0xFFF1F1F1))),
                    ])
                  : Container(),
              SizedBox(height: 12),
              _businessInfo.website != null && _businessInfo.website.length > 0
                  ? Row(children: [
                      Image.asset("assets/images/cv/website.png", height: 10),
                      SizedBox(width: 8),
                      Text(_businessInfo.website,
                          style: TextStyle(
                              fontSize: 12, color: Color(0xFFF1F1F1))),
                    ])
                  : Container(),
            ]),
          ),
        ],
      ),
    );
  }

  Widget businessCardForm(Business businessItem) {
    return Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            companyImageWidget(),
            Focus(
              child: TextFormField(
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)
                        .translate('companyNameLabel'),
                    hintText: AppLocalizations.of(context)
                        .translate('companyNameLabelMeta')),
                initialValue: businessItem.companyName,
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value.isEmpty) {
                    return AppLocalizations.of(context)
                        .translate('companyNameError');
                  }
                  return null;
                },
                onChanged: (String val) {
                  if (mounted) {
                    setState(() {
                      _businessInfo.companyName = val;
                    });
                  }
                },
              ),
            ),
            Focus(
              child: TextFormField(
                decoration: InputDecoration(
                    labelText:
                        AppLocalizations.of(context).translate('userNameLabel'),
                    hintText: AppLocalizations.of(context)
                        .translate('userNameLabelMeta')),
                initialValue: businessItem.name,
                keyboardType: TextInputType.text,
                onChanged: (String val) {
                  if (mounted) {
                    setState(() {
                      _businessInfo.name = val;
                    });
                  }
                },
              ),
            ),
            Focus(
              child: TextFormField(
                decoration: InputDecoration(
                    labelText:
                        AppLocalizations.of(context).translate('userRoleLabel'),
                    hintText: AppLocalizations.of(context)
                        .translate('userRoleLabelMeta')),
                initialValue: businessItem.role,
                keyboardType: TextInputType.text,
                onChanged: (String val) {
                  if (mounted) {
                    setState(() {
                      _businessInfo.role = val;
                    });
                  }
                },
              ),
            ),
            Focus(
              child: TextFormField(
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)
                        .translate('companyAddressLabel'),
                    hintText: AppLocalizations.of(context)
                        .translate('companyAddressLabelMeta')),
                initialValue: businessItem.address,
                keyboardType: TextInputType.text,
                onChanged: (String val) {
                  if (mounted) {
                    setState(() {
                      _businessInfo.address = val;
                    });
                  }
                },
              ),
            ),
            Focus(
              child: TextFormField(
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)
                        .translate('companyPhoneLabel'),
                    hintText: AppLocalizations.of(context)
                        .translate('companyPhoneLabelMeta')),
                initialValue: businessItem.phone,
                keyboardType: TextInputType.phone,
                onChanged: (String val) {
                  if (mounted) {
                    setState(() {
                      _businessInfo.phone = val;
                    });
                  }
                },
              ),
            ),
            Focus(
              child: TextFormField(
                keyboardType: TextInputType.emailAddress,
                initialValue: businessItem.email,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)
                        .translate('companyEmailLabel'),
                    hintText: AppLocalizations.of(context)
                        .translate('companyEmailLabelMeta')),
                onChanged: (String val) {
                  if (mounted) {
                    setState(() {
                      _businessInfo.email = val;
                    });
                  }
                },
              ),
            ),
            Focus(
              child: TextFormField(
                keyboardType: TextInputType.text,
                initialValue: businessItem.website,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)
                        .translate('companyWebsiteLabel'),
                    hintText: AppLocalizations.of(context)
                        .translate('companyWebsiteLabelMeta')),
                onChanged: (String val) async {
                  if (mounted) {
                    setState(() {
                      _businessInfo.website = val;
                    });
                  }
                },
              ),
            ),
          ],
        ) // Build this out in the next steps.
        );
  }

  Widget companyImageWidget() {
    Uint8List companyImage;
    if (_businessInfo.logo != null && _businessInfo.logo.length > 0) {
      companyImage = Base64Decoder().convert(_businessInfo.logo);
    }
    return Row(
      children: <Widget>[
        Center(
          child: companyImage == null
              ? Image(
                  image: AssetImage('assets/images/noimage_person.png'),
                  width: 60,
                )
              : Image.memory(
                  companyImage,
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
}
