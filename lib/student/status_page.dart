import 'package:flutter/material.dart';

class StatusPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Leave Request Status'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Text(
          'This is the status page.',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
