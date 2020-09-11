import 'package:udharokhata/blocs/businessBloc.dart';
import 'package:udharokhata/models/business.dart';

void loadBusinessInfo() async {
  Business _businessInfo = Business();
  final BusinessBloc businessBloc = BusinessBloc();

  _businessInfo.id = 0;
  _businessInfo.name = "YOUR NAME";
  _businessInfo.phone = "+000 0000000000";
  _businessInfo.email = "info@udharokhata.com";
  _businessInfo.address = "Malepatan, Pokhara, Nepal";
  _businessInfo.logo = "";
  _businessInfo.website = "https://udharokhata.com";
  _businessInfo.role = "Accountant";
  _businessInfo.companyName = "YOUR COMPANY";

  final getBusinessInfo = await businessBloc.getBusiness(0);
  if (getBusinessInfo == null) {
    await businessBloc.addBusiness(_businessInfo);
  } else {
    await businessBloc.updateBusiness(_businessInfo);
  }
}
