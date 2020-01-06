import 'package:flutter/material.dart';
import 'resources/routes/ContactsRoute.dart';


// main app init
void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FlatApp: contacts',
      home: new ContactsRoute(),
    );
  }
}
