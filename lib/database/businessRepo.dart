import 'package:udharokhata/database/businessDao.dart';
import 'package:udharokhata/models/business.dart';

class BusinessRepository {
  final businessDao = BusinessDao();

  Future getAllBusinesss({String query, int page}) =>
      businessDao.getBusinesss(query: query, page: page);

  Future getBusiness(int id) => businessDao.getBusiness(id);

  Future insertBusiness(Business business) =>
      businessDao.createBusiness(business);

  Future updateBusiness(Business business) =>
      businessDao.updateBusiness(business);

  Future deleteBusinessById(int id) => businessDao.deleteBusiness(id);
}
