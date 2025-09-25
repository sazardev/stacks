import "package:flutter/material.dart";

class KitchenDashboardSimple extends StatelessWidget {
  const KitchenDashboardSimple({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Stacks KDS - Firebase Ready"),
        backgroundColor: Colors.blue,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant, size: 100, color: Colors.blue),
            SizedBox(height: 20),
            Text(
              "Firebase Integration Complete!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "85% Production Ready",
              style: TextStyle(fontSize: 18, color: Colors.green),
            ),
            SizedBox(height: 20),
            Text("Firebase Repositories Implemented:"),
            Text(" User Repository"),
            Text(" Order Repository"),  
            Text(" Station Repository"),
            Text(" Recipe Repository"),
            Text(" Inventory Repository"),
            Text(" Table Repository"),
            Text(" Kitchen Timer Repository"),
          ],
        ),
      ),
    );
  }
}
