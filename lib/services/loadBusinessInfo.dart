import 'package:flutter/cupertino.dart';
import 'package:udharokhata/blocs/businessBloc.dart';
import 'package:udharokhata/helpers/stateNotifier.dart';
import 'package:udharokhata/models/business.dart';

Future<void> loadBusinessInfo(BuildContext context) async {
  Business _businessInfo = Business();
  final BusinessBloc businessBloc = BusinessBloc();
  _businessInfo.id = 0;
  _businessInfo.name = "";
  _businessInfo.phone = "";
  _businessInfo.email = "";
  _businessInfo.address = "";
  _businessInfo.logo = "";
  _businessInfo.website = "";
  _businessInfo.role = "";
  _businessInfo.companyName = "MY COMPANY";
  await businessBloc.addBusiness(_businessInfo);
  changeSelectedBusiness(context, 0);
}
