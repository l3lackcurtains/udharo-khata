import 'dart:convert';
import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:udharokhata/blocs/businessBloc.dart';
import 'package:udharokhata/blocs/customerBloc.dart';
import 'package:udharokhata/blocs/transactionBloc.dart';
import 'package:udharokhata/models/business.dart';
import 'package:udharokhata/models/customer.dart';
import 'package:udharokhata/models/transaction.dart';

Future<Uint8List> generateCustomerTransactionPdf(int customerId) async {
  PdfPageFormat pageFormat = PdfPageFormat.a4;
  final CustomerBloc customerBloc = CustomerBloc();
  final TransactionBloc transactionBloc = TransactionBloc();
  final BusinessBloc businessBloc = BusinessBloc();

  Customer customer = await customerBloc.getCustomer(customerId);
  List<Transaction> transactions =
      await transactionBloc.getTransactionsByCustomerId(customerId);

  double transactionTotal =
      await transactionBloc.getCustomerTransactionsTotal(customerId);

  Business businessInfo = Business();

  final prefs = await SharedPreferences.getInstance();
  String currency = prefs.getString("currency");

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

  final invoice = Invoice(
    invoiceNumber: '1',
    transactions: transactions,
    customer: customer,
    businessInfo: businessInfo,
    total: transactionTotal,
    baseColor: PdfColors.teal,
    accentColor: PdfColors.blueGrey900,
    currency: currency,
    redColor: PdfColors.red700,
  );

  return await invoice.buildPdf(pageFormat);
}

class Invoice {
  Invoice({
    this.transactions,
    this.customer,
    this.businessInfo,
    this.invoiceNumber,
    this.total,
    this.baseColor,
    this.accentColor,
    this.currency,
    this.redColor,
  });

  final List<Transaction> transactions;
  final Customer customer;
  final Business businessInfo;
  final String invoiceNumber;
  final double total;
  final PdfColor baseColor;
  final PdfColor accentColor;
  final PdfColor redColor;
  final String currency;

  static const _darkColor = PdfColors.blueGrey800;
  static const _lightColor = PdfColors.white;

  PdfColor get _baseTextColor =>
      baseColor.luminance < 0.5 ? _lightColor : _darkColor;

  PdfColor get _accentTextColor =>
      baseColor.luminance < 0.5 ? _lightColor : _darkColor;

  double get _grandTotal => total;

  PdfImage _logo;

  Future<Uint8List> buildPdf(PdfPageFormat pageFormat) async {
    // Create a PDF document.
    final doc = pw.Document();

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
        ),
        header: _buildHeader,
        footer: _buildFooter,
        build: (context) => [
          _contentHeader(context),
          _contentTable(context),
          pw.SizedBox(height: 20),
          _contentFooter(context),
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
                    height: 50,
                    padding: pw.EdgeInsets.only(left: 20),
                    alignment: pw.Alignment.centerLeft,
                    child: pw.Text(
                      'TRANSACTION STATEMENT',
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
                    height: 50,
                    child: pw.DefaultTextStyle(
                      style: pw.TextStyle(
                        color: _accentTextColor,
                        fontSize: 12,
                      ),
                      child: pw.GridView(
                        crossAxisCount: 2,
                        children: [
                          pw.Text('For'),
                          pw.Text(customer.name),
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

  pw.PageTheme _buildTheme(PdfPageFormat pageFormat) {
    return pw.PageTheme(
      pageFormat: pageFormat,
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
            height: 70,
            child: pw.FittedBox(
              child: pw.Text(
                'Total: ${_formatCurrency(_grandTotal)}',
                style: pw.TextStyle(
                    color: _grandTotal.isNegative ? redColor : baseColor,
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 14),
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
        pw.Container(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Thank you for your business',
                style: pw.TextStyle(
                  color: _darkColor,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        pw.Expanded(
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
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Text('Total: '),
                    pw.Text(
                      _formatCurrency(_grandTotal),
                      style: pw.TextStyle(
                        color: _grandTotal.isNegative ? redColor : baseColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _contentTable(pw.Context context) {
    List<String> tableHeaders = [
      'ID',
      'Date',
      'Description',
      'Credit',
      'Debit'
    ];

    return pw.Table.fromTextArray(
      border: null,
      cellAlignment: pw.Alignment.centerLeft,
      headerDecoration: pw.BoxDecoration(
        borderRadius: 2,
        color: baseColor,
      ),
      headerHeight: 30,
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerLeft,
        3: pw.Alignment.center,
        4: pw.Alignment.centerRight,
      },
      headerStyle: pw.TextStyle(
        color: _baseTextColor,
        fontSize: 10,
        fontWeight: pw.FontWeight.bold,
      ),
      cellStyle: pw.TextStyle(
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
        transactions.length,
        (row) {
          return [
            transactions[row].id.toString(),
            _formatDate(transactions[row].date).toString(),
            transactions[row].comment,
            transactions[row].ttype == "credit"
                ? _formatCurrency(transactions[row].amount).toString()
                : "",
            transactions[row].ttype == "payment"
                ? _formatCurrency(transactions[row].amount).toString()
                : ""
          ];
        },
      ),
    );
  }

  String _formatCurrency(double amount) {
    String neg = "";
    if (amount.isNegative) {
      neg = "-";
    }
    return neg + " " + currency + ' ${amount.abs().toStringAsFixed(2)}';
  }

  String _formatDate(DateTime date) {
    final format = DateFormat.yMd('en_US');
    return format.format(date);
  }
}
