import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "Welcome to EventTrack",
          style: TextStyle(color: Colors.black),
        ),
      ),
    );
  }
}
