import 'package:flutter/material.dart';
import 'package:udharokhata/blocs/businessBloc.dart';
import 'package:udharokhata/models/business.dart';
import 'package:udharokhata/pages/addBusiness.dart';

class DeleteBusiness extends StatefulWidget {
  DeleteBusiness({Key key}) : super(key: key);
  @override
  _DeleteBusinessState createState() => _DeleteBusinessState();
}

class _DeleteBusinessState extends State<DeleteBusiness> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final BusinessBloc _businessBloc = BusinessBloc();

  List<Business> _businesses = [];

  int _radioValue = 0;

  @override
  void initState() {
    super.initState();
    loadBusinesses();
  }

  void loadBusinesses() async {
    if (!mounted) return;
    List<Business> bs = await _businessBloc.getBusinesss();

    setState(() {
      _businesses = bs;
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
          'Delete Company',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(
          color: Colors.black, //change your color here
        ),
        actions: <Widget>[
          FlatButton.icon(
            label: Text(
              "Delete Companies",
              style: TextStyle(fontSize: 12),
            ),
            icon: Icon(Icons.delete, size: 20.0, color: Colors.red),
            onPressed: () {},
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          deleteCompany();
        },
        icon: Icon(
          Icons.check,
        ),
        label: Text('Delete Company'),
      ),
      body: Container(
        decoration: BoxDecoration(color: Colors.white),
        padding: EdgeInsets.all(20),
        child: ListView.builder(
            itemCount: _businesses.length,
            itemBuilder: (context, index) {
              final business = _businesses[index];
              return RadioListTile(
                title: Text(
                  business.companyName,
                ),
                value: index,
                groupValue: _radioValue,
                activeColor: Color(0xFF6200EE),
                onChanged: (val) {
                  setState(() {
                    _radioValue = val;
                  });
                },
              );
            }),
      ),
    );
  }

  void deleteCompany() async {
    int id = _businesses[_radioValue].id;
    await _businessBloc.deleteBusinessById(id);
    Navigator.of(context).pop();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => AddBusiness(),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
