import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:udharokhata/blocs/businessBloc.dart';
import 'package:udharokhata/database/businessRepo.dart';
import 'package:udharokhata/models/business.dart';

class BusinessInformation extends StatefulWidget {
  @override
  _BusinessInformationState createState() => _BusinessInformationState();
}

class _BusinessInformationState extends State<BusinessInformation> {
  final BusinessBloc businessBloc = BusinessBloc();

  String _pathPDF = "";
  bool _pdfLoaded = false;

  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Business _businessInfo = Business();
  Future<Business> _businessFuture;
  final _businessRepository = BusinessRepository();
  final picker = ImagePicker();
  @override
  void initState() {
    super.initState();
    initBusinessCard();
  }

  void downloadPdf() async {
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
        _pdfLoaded = false;
      });
    }

    buildPDF();
    final dir = await getExternalStorageDirectory();
    setState(() {
      _pathPDF = dir.path + "/business_card.pdf";
      _pdfLoaded = true;
    });
  }

  void buildPDF() async {
    if (!mounted) return;

    setState(() {
      _pdfLoaded = false;
    });

    await businessCardMaker();
    final dir = await getExternalStorageDirectory();

    setState(() {
      _pathPDF = dir.path + "/business_card.pdf";
      _pdfLoaded = true;
    });
  }

  Future<void> businessCardMaker() async {
    final doc = pw.Document();
    final PdfImage backgroundImage = PdfImage.file(
      doc.document,
      bytes: (await rootBundle.load('images/cv_template.png'))
          .buffer
          .asUint8List(),
    );
    final PdfImage phoneImage = PdfImage.file(
      doc.document,
      bytes:
          (await rootBundle.load('images/cv/phone.png')).buffer.asUint8List(),
    );
    final PdfImage emailImage = PdfImage.file(
      doc.document,
      bytes:
          (await rootBundle.load('images/cv/email.png')).buffer.asUint8List(),
    );
    final PdfImage locationImage = PdfImage.file(
      doc.document,
      bytes: (await rootBundle.load('images/cv/location.png'))
          .buffer
          .asUint8List(),
    );
    final PdfImage websiteImage = PdfImage.file(
      doc.document,
      bytes:
          (await rootBundle.load('images/cv/website.png')).buffer.asUint8List(),
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
                                ? pw.Image(businessLogo, width: 100)
                                : pw.SizedBox(height: 60),
                            pw.SizedBox(height: 24),
                            pw.Text(
                              _businessInfo.companyName ?? "COMPANY NAME",
                              style: pw.TextStyle(
                                  fontSize: 36, color: semiWhiteColor),
                            ),
                            pw.SizedBox(height: 36),
                            pw.RichText(
                              text: pw.TextSpan(
                                text: _businessInfo.name.length > 0
                                    ? _businessInfo.name.split(" ")[0]
                                    : "",
                                style: pw.TextStyle(
                                  fontSize: 54,
                                  color: whiteColor,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                                children: <pw.TextSpan>[
                                  pw.TextSpan(
                                      text: _businessInfo.name.length > 0
                                          ? _businessInfo.name.split(" ")[1]
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
    final formState = _formKey.currentState;
    formState.save();
    final getBusinessInfo = await businessBloc.getBusiness(0);
    if (getBusinessInfo == null) {
      await businessBloc.addBusiness(_businessInfo);
    } else {
      await businessBloc.updateBusiness(_businessInfo);
    }
  }

  Future getImageFrom(String from) async {
    if (!mounted) return;

    var image;
    if (from == 'camera') {
      image = await picker.getImage(source: ImageSource.camera);
    } else {
      image = await picker.getImage(source: ImageSource.gallery);
    }

    File rawImage = File(image.path);

    if (rawImage != null && rawImage.lengthSync() > 2000000) {
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
        title: Text('Khata',
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 24,
                fontFamily: 'Poppins')),
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
              child: _pdfLoaded
                  ? PDFView(filePath: _pathPDF, defaultPage: 0)
                  : CircularProgressIndicator(),
            ),
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(24),
              child: FutureBuilder<Business>(
                  future: _businessFuture,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    Business businessItem = Business();
                    if (snapshot.hasData) {
                      businessItem = snapshot.data;
                      return businessCardForm(businessItem);
                    }
                    return CircularProgressIndicator();
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
                  onPressed: () {
                    updateBusinessInformation();
                  },
                  child: Text("Save"),
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
                  child: Text("Download Card"),
                ),
              ),
            ],
          ),
        ),
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
                  labelText: 'Company Name',
                ),
                initialValue: businessItem.companyName,
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Company Name mustn\'t be empty. ';
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
              onFocusChange: (hasFocus) {
                if (!hasFocus) {
                  buildPDF();
                }
              },
            ),
            Focus(
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Your Name',
                ),
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
              onFocusChange: (hasFocus) {
                if (!hasFocus) {
                  buildPDF();
                }
              },
            ),
            Focus(
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Your Company Role',
                ),
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
              onFocusChange: (hasFocus) {
                if (!hasFocus) {
                  buildPDF();
                }
              },
            ),
            Focus(
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Company Address',
                ),
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
              onFocusChange: (hasFocus) {
                if (!hasFocus) {
                  buildPDF();
                }
              },
            ),
            Focus(
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Phone',
                ),
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
              onFocusChange: (hasFocus) {
                if (!hasFocus) {
                  buildPDF();
                }
              },
            ),
            Focus(
              child: TextFormField(
                keyboardType: TextInputType.emailAddress,
                initialValue: businessItem.email,
                decoration: InputDecoration(
                  labelText: 'Email',
                ),
                onChanged: (String val) {
                  if (mounted) {
                    setState(() {
                      _businessInfo.email = val;
                    });
                  }
                },
              ),
              onFocusChange: (hasFocus) {
                if (!hasFocus) {
                  buildPDF();
                }
              },
            ),
            Focus(
              child: TextFormField(
                keyboardType: TextInputType.text,
                initialValue: businessItem.website,
                decoration: InputDecoration(
                  labelText: 'Website',
                ),
                onChanged: (String val) async {
                  if (mounted) {
                    setState(() {
                      _businessInfo.website = val;
                    });
                  }
                },
              ),
              onFocusChange: (hasFocus) {
                if (!hasFocus) {
                  buildPDF();
                }
              },
            ),
          ],
        ) // Build this out in the next steps.
        );
  }

  Widget companyImageWidget() {
    Uint8List companyImage;
    if (_businessInfo.logo != null) {
      companyImage = Base64Decoder().convert(_businessInfo.logo);
    }
    return Row(
      children: <Widget>[
        Center(
          child: companyImage == null
              ? Image(
                  image: AssetImage('images/noimage_person.png'),
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
          title: Text('Upload Company Logo'),
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
}
