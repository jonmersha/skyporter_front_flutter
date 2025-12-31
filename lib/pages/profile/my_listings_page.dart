import 'package:flutter/material.dart';

class MyListingsPage extends StatelessWidget {
  const MyListingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Posts & Listings")),
      body: Center(child: Text("Here you will see your posted trips and item requests.")),
    );
  }
}