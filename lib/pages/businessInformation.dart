import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:udharokhata/blocs/businessBloc.dart';
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
  Business _businessInfo = Business();
  String _name = "YOUR NAME";
  String _phone = "+000 0000000000";
  String _email = "info@udharokhata.com";
  String _address = "Malepatan, Pokhara, Nepal";
  String _logo = "";
  String _website = "https://udharokhata.com";
  String _role = "Accountant";
  String _companyName = "YOUR COMPANY";

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
    if (this.mounted) {
      Business bs = await businessBloc.getBusiness(0);

      setState(() {
        if (bs != null) {
          _businessInfo = bs;
        } else {
          _businessInfo.id = 0;
          _businessInfo.name = _name;
          _businessInfo.phone = _phone;
          _businessInfo.email = _email;
          _businessInfo.address = _address;
          _businessInfo.logo = _logo;
          _businessInfo.website = _website;
          _businessInfo.role = _role;
          _businessInfo.companyName = _companyName;
        }

        _pdfLoaded = false;
      });

      await businessCardMaker();
      final dir = await getExternalStorageDirectory();
      setState(() {
        _pathPDF = dir.path + "/business_card.pdf";
        _pdfLoaded = true;
      });
    }
  }

  void buildPDF() async {
    if (this.mounted) {
      setState(() {
        _pdfLoaded = false;
        _businessInfo.id = 0;
        _businessInfo.name = _name;
        _businessInfo.phone = _phone;
        _businessInfo.email = _email;
        _businessInfo.address = _address;
        _businessInfo.logo = _logo;
        _businessInfo.website = _website;
        _businessInfo.role = _role;
        _businessInfo.companyName = _companyName;
      });

      await businessCardMaker();
      final dir = await getExternalStorageDirectory();

      setState(() {
        _pathPDF = dir.path + "/business_card.pdf";
        _pdfLoaded = true;
      });
    }
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
                padding: pw.EdgeInsets.fromLTRB(0, 240, 80, 0),
                alignment: pw.Alignment(0.0, 0.0),
                child: pw.Row(
                  children: [
                    pw.Container(
                      width: 700,
                      child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            pw.Text(_businessInfo.companyName,
                                style: pw.TextStyle(
                                    fontSize: 40, color: semiWhiteColor)),
                            pw.SizedBox(height: 24),
                            pw.RichText(
                              text: pw.TextSpan(
                                text: _businessInfo.name.split(" ")[0],
                                style: pw.TextStyle(
                                  fontSize: 54,
                                  color: whiteColor,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                                children: <pw.TextSpan>[
                                  pw.TextSpan(
                                      text:
                                          " ${_businessInfo.name.split(" ")[1]}",
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
                    pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Row(children: [
                            pw.Image(phoneImage, height: 30),
                            pw.SizedBox(width: 20),
                            pw.Text(_businessInfo.phone,
                                style: pw.TextStyle(
                                    fontSize: 32, color: semiWhiteColor)),
                          ]),
                          pw.SizedBox(height: 36),
                          pw.Row(children: [
                            pw.Image(locationImage, height: 30),
                            pw.SizedBox(width: 20),
                            pw.Text(_businessInfo.address,
                                style: pw.TextStyle(
                                    fontSize: 32, color: semiWhiteColor)),
                          ]),
                          pw.SizedBox(height: 36),
                          pw.Row(children: [
                            pw.Image(emailImage, height: 30),
                            pw.SizedBox(width: 20),
                            pw.Text(_businessInfo.email,
                                style: pw.TextStyle(
                                    fontSize: 32, color: semiWhiteColor)),
                          ]),
                          pw.SizedBox(height: 36),
                          pw.Row(children: [
                            pw.Image(websiteImage, height: 30),
                            pw.SizedBox(width: 20),
                            pw.Text(_businessInfo.website,
                                style: pw.TextStyle(
                                    fontSize: 32, color: semiWhiteColor)),
                          ]),
                        ]),
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

  void updateBusinessInformation() {
    final formState = _formKey.currentState;
    if (formState.validate()) {
      formState.save();
      businessBloc.updateBusiness(_businessInfo);
      Navigator.pop(context);
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
              child: FutureBuilder(
                  future: businessBloc.getBusiness(0),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    Business businessItem = snapshot.data;
                    print(snapshot.hasData);
                    if (snapshot.hasData) {
                      businessItem = _businessInfo;
                    } else {
                      businessItem.id = 0;
                      businessItem.name = _name;
                      businessItem.phone = _phone;
                      businessItem.email = _email;
                      businessItem.address = _address;
                      businessItem.logo = _logo;
                      businessItem.website = _website;
                      businessItem.role = _role;
                      businessItem.companyName = _companyName;
                    }
                    return Form(
                        key: _formKey,
                        child: Column(
                          children: <Widget>[
                            Focus(
                              child: TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Name *',
                                ),
                                initialValue: businessItem.name,
                                keyboardType: TextInputType.text,
                                onChanged: (String val) {
                                  if (mounted) {
                                    setState(() {
                                      _name = val;
                                    });
                                  }
                                },
                                onSaved: (String val) {
                                  if (mounted) {
                                    setState(() {
                                      _name = val;
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
                                  labelText: 'Company Name *',
                                ),
                                initialValue: businessItem.companyName,
                                keyboardType: TextInputType.text,
                                onChanged: (String val) {
                                  if (mounted) {
                                    setState(() {
                                      _companyName = val;
                                    });
                                  }
                                },
                                onSaved: (String val) {
                                  if (mounted) {
                                    setState(() {
                                      _companyName = val;
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
                                  labelText: 'Company Role *',
                                ),
                                initialValue: businessItem.role,
                                keyboardType: TextInputType.text,
                                onChanged: (String val) {
                                  if (mounted) {
                                    setState(() {
                                      _role = val;
                                    });
                                  }
                                },
                                onSaved: (String val) {
                                  if (mounted) {
                                    setState(() {
                                      _role = val;
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
                                      _address = val;
                                    });
                                  }
                                },
                                onSaved: (String val) {
                                  if (mounted) {
                                    setState(() {
                                      _address = val;
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
                                      _phone = val;
                                    });
                                  }
                                },
                                onSaved: (String val) {
                                  if (mounted) {
                                    setState(() {
                                      _phone = val;
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
                                      _email = val;
                                    });
                                  }
                                },
                                onSaved: (String val) {
                                  if (mounted) {
                                    setState(() {
                                      _email = val;
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
                                      _website = val;
                                    });
                                  }
                                },
                                onSaved: (String val) {
                                  if (mounted) {
                                    setState(() {
                                      _website = val;
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
}
