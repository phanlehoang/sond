import 'package:bloc_app/presentation/screens/0_home_screens/choose_patient.dart';
import 'package:flutter/material.dart';
import '../../widgets/export_widgets.dart';

class HomeScreen extends StatelessWidget {
  final String title;
  final Color color;
  const HomeScreen({
    Key? key,
    required this.title,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext homeScreenContext) {
    // setFirebase();
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: <Widget>[
          InternetCheck(),
          CreatePatientButton(),
          ChoosePatientAction(),   
        ],
      ),
      bottomNavigationBar: BottomNavigatorBar(),
    );
  }
}




