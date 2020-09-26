import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:udharokhata/blocs/businessBloc.dart';
import 'package:udharokhata/blocs/customerBloc.dart';
import 'package:udharokhata/blocs/transactionBloc.dart';
import 'package:udharokhata/models/business.dart';
import 'package:udharokhata/models/customer.dart';

Future<Uint8List> generateCustomerPdf() async {
  PdfPageFormat pageFormat = PdfPageFormat.a4;

  final CustomerBloc customerBloc = CustomerBloc();
  final TransactionBloc transactionBloc = TransactionBloc();
  final BusinessBloc businessBloc = BusinessBloc();

  List<Customer> customersList = await customerBloc.getCustomers();

  List<Map<String, dynamic>> customers = [];

  customersList.forEach((c) async {
    double amt = await transactionBloc.getCustomerTransactionsTotal(c.id);
    Map<String, dynamic> customer = {
      'amount': amt,
      'id': c.id,
      'name': c.name,
      'phone': c.phone,
      'address': c.address,
    };
    customers.add(customer);
  });

  Business businessInfo = Business();

  businessInfo.id = 0;
  businessInfo.name = "";
  businessInfo.phone = "";
  businessInfo.email = "";
  businessInfo.address = "";
  businessInfo.logo = "";
  businessInfo.website = "";
  businessInfo.role = "";
  businessInfo.companyName = "";

  Business business = await businessBloc.getBusiness(0);
  if (business != null) {
    businessInfo = business;
  }

  final invoice = CustomersList(
    customers: customers,
    businessInfo: businessInfo,
    baseColor: PdfColors.teal,
    accentColor: PdfColors.purple800,
  );

  return await invoice.buildPdf(pageFormat);
}

class CustomersList {
  CustomersList({
    this.customers,
    this.businessInfo,
    this.baseColor,
    this.accentColor,
  });

  final List<Map<String, dynamic>> customers;
  final Business businessInfo;
  final PdfColor baseColor;
  final PdfColor accentColor;

  static const _darkColor = PdfColors.blueGrey800;
  static const _lightColor = PdfColors.white;

  PdfColor get _baseTextColor =>
      baseColor.luminance < 0.5 ? _lightColor : _darkColor;

  PdfColor get _accentTextColor =>
      baseColor.luminance < 0.5 ? _lightColor : _darkColor;

  double get _total => customers.length > 0
      ? customers.map((p) => p['amount']).reduce((a, b) => a + b)
      : 0;

  double get _grandTotal => _total;

  PdfImage _logo;

  Future<Uint8List> buildPdf(PdfPageFormat pageFormat) async {
    // Create a PDF document.
    final doc = pw.Document();

    final font1 = await rootBundle.load('assets/fonts/Poppins/Poppins-Regular.ttf');
    final font2 = await rootBundle.load('assets/fonts/Poppins/Poppins-Regular.ttf');
    final font3 = await rootBundle.load('assets/fonts/Poppins/Poppins-Regular.ttf');

    if (businessInfo.logo.length > 0) {
      Uint8List logo = Base64Decoder().convert(businessInfo.logo);
      _logo = PdfImage.file(
        doc.document,
        bytes: logo,
      );
    }

    // Add page to the PDF
    doc.addPage(
      pw.MultiPage(
        pageTheme: _buildTheme(
          pageFormat,
          font1 != null ? pw.Font.ttf(font1) : null,
          font2 != null ? pw.Font.ttf(font2) : null,
          font3 != null ? pw.Font.ttf(font3) : null,
        ),
        header: _buildHeader,
        footer: _buildFooter,
        build: (context) => [
          _contentHeader(context),
          _contentTable(context),
          pw.SizedBox(height: 20),
          _contentFooter(context),
          pw.SizedBox(height: 20),
        ],
      ),
    );

    // Return the PDF file content
    return doc.save();
  }

  pw.Widget _buildHeader(pw.Context context) {
    return pw.Column(
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Column(
                children: [
                  pw.Container(
                    height: 40,
                    padding: pw.EdgeInsets.only(left: 20),
                    alignment: pw.Alignment.centerLeft,
                    child: pw.Text(
                      'CUSTOMERS',
                      style: pw.TextStyle(
                        color: baseColor,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  pw.Container(
                    decoration: pw.BoxDecoration(
                      borderRadius: 2,
                      color: accentColor,
                    ),
                    padding: pw.EdgeInsets.only(
                        left: 40, top: 10, bottom: 10, right: 20),
                    alignment: pw.Alignment.centerLeft,
                    height: 40,
                    child: pw.DefaultTextStyle(
                      style: pw.TextStyle(
                        color: _accentTextColor,
                        fontSize: 12,
                      ),
                      child: pw.GridView(
                        crossAxisCount: 2,
                        children: [
                          pw.Text('Date:'),
                          pw.Text(_formatDate(DateTime.now()).split(",")[0]),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            pw.Expanded(
              child: pw.Column(
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  pw.Container(
                    alignment: pw.Alignment.topRight,
                    padding: pw.EdgeInsets.only(bottom: 8, left: 0),
                    height: 72,
                    child: _logo != null ? pw.Image(_logo) : pw.Container(),
                  ),
                ],
              ),
            ),
          ],
        ),
        (context.pageNumber > 1) ? pw.SizedBox(height: 20) : pw.Container()
      ],
    );
  }

  pw.Widget _buildFooter(pw.Context context) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Text(
          'PDF generated by Udharo Khata',
          style: pw.TextStyle(
            fontSize: 12,
            color: PdfColors.grey,
          ),
        ),
        pw.Text(
          'Page ${context.pageNumber} of ${context.pagesCount}',
          style: pw.TextStyle(
            fontSize: 12,
            color: PdfColors.grey,
          ),
        ),
      ],
    );
  }

  pw.PageTheme _buildTheme(
      PdfPageFormat pageFormat, pw.Font base, pw.Font bold, pw.Font italic) {
    return pw.PageTheme(
      pageFormat: pageFormat,
      theme: pw.ThemeData.withFont(
        base: base,
        bold: bold,
        italic: italic,
      ),
      buildBackground: (context) => pw.FullPage(
        ignoreMargins: true,
        child: pw.Stack(
          children: [
            pw.Positioned(
              bottom: 0,
              left: 0,
              child: pw.Container(
                height: 20,
                width: pageFormat.width / 2,
                decoration: pw.BoxDecoration(
                  gradient: pw.LinearGradient(
                    colors: [baseColor, PdfColors.white],
                  ),
                ),
              ),
            ),
            pw.Positioned(
              bottom: 20,
              left: 0,
              child: pw.Container(
                height: 20,
                width: pageFormat.width / 4,
                decoration: pw.BoxDecoration(
                  gradient: pw.LinearGradient(
                    colors: [accentColor, PdfColors.white],
                  ),
                ),
              ),
            ),
            pw.Positioned(
              top: pageFormat.marginTop + 72,
              left: 0,
              right: 0,
              child: pw.Container(
                height: 3,
                color: baseColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget _contentHeader(pw.Context context) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Container(
            margin: pw.EdgeInsets.symmetric(horizontal: 20),
            height: 70,
            child: pw.FittedBox(
              child: pw.Text(
                'Total: ${_formatCurrency(_grandTotal)}',
                style: pw.TextStyle(
                  color: baseColor,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
            ),
          ),
        ),
        pw.Expanded(
          child: pw.Row(
            children: [
              pw.SizedBox(width: 120),
              pw.Container(
                height: 80,
                child: pw.RichText(
                    text: pw.TextSpan(
                        text: '${businessInfo.companyName}\n',
                        style: pw.TextStyle(
                          color: _darkColor,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 14,
                        ),
                        children: [
                      pw.TextSpan(
                        text: '\n',
                        style: pw.TextStyle(
                          fontSize: 5,
                        ),
                      ),
                      pw.TextSpan(
                        text: businessInfo.address,
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.normal,
                          fontSize: 10,
                        ),
                      ),
                      pw.TextSpan(
                        text: '\n',
                        style: pw.TextStyle(
                          fontSize: 5,
                        ),
                      ),
                      pw.TextSpan(
                        text: businessInfo.phone,
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.normal,
                          fontSize: 10,
                        ),
                      ),
                      pw.TextSpan(
                        text: '\n',
                        style: pw.TextStyle(
                          fontSize: 5,
                        ),
                      ),
                      pw.TextSpan(
                        text: businessInfo.email,
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.normal,
                          fontSize: 10,
                        ),
                      ),
                    ])),
              ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _contentFooter(pw.Context context) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          flex: 2,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [],
          ),
        ),
        pw.Expanded(
          flex: 1,
          child: pw.DefaultTextStyle(
            style: const pw.TextStyle(
              fontSize: 10,
              color: _darkColor,
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.DefaultTextStyle(
                  style: pw.TextStyle(
                    color: baseColor,
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Total:'),
                      pw.Text(_formatCurrency(_grandTotal)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  pw.Widget _contentTable(pw.Context context) {
    const tableHeaders = ['ID', 'Name', 'Phone', 'Address', 'Total'];

    return pw.Table.fromTextArray(
      border: null,
      cellAlignment: pw.Alignment.centerLeft,
      headerDecoration: pw.BoxDecoration(
        borderRadius: 2,
        color: baseColor,
      ),
      headerHeight: 25,
      cellHeight: 40,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.center,
        2: pw.Alignment.center,
        3: pw.Alignment.center,
        4: pw.Alignment.center,
      },
      headerStyle: pw.TextStyle(
        color: _baseTextColor,
        fontSize: 10,
        fontWeight: pw.FontWeight.bold,
      ),
      cellStyle: const pw.TextStyle(
        color: _darkColor,
        fontSize: 10,
      ),
      rowDecoration: pw.BoxDecoration(
        border: pw.BoxBorder(
          bottom: true,
          color: accentColor,
          width: .5,
        ),
      ),
      headers: List<String>.generate(
        tableHeaders.length,
        (col) => tableHeaders[col],
      ),
      data: List<List<String>>.generate(
        customers.length,
        (row) {
          return [
            customers[row]['id'].toString(),
            customers[row]['name'],
            customers[row]['phone'],
            customers[row]['address'],
            _formatCurrency(customers[row]['amount'])
          ];
        },
      ),
    );
  }
}

String _formatCurrency(double amount) {
  return '${amount.toStringAsFixed(2)}\$';
}

String _formatDate(DateTime date) {
  final format = DateFormat.yMd('en_US');
  return format.format(date);
}
