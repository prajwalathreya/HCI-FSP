
import 'package:flutter/material.dart';
import 'package:fsp/MapPage.dart';

class NavigationPage extends StatefulWidget {
  @override
  _NavigationPageState createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  String _selectedItem = "Long and Straight Roads"; // Initialize with a default value

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Navigation Page"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Start Location",
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "End Location",
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MapPage()),
                );
                // Handle navigation or other logic when the button is pressed.
              },
              child: Text("Navigate"),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: _selectedItem,
              items: [
                DropdownMenuItem<String>(
                  value: "Long and Straight Roads",
                  child: Text("Long and Straight Roads"),
                ),
                DropdownMenuItem<String>(
                  value: "Calm Roads",
                  child: Text("Calm Roads"),
                ),
                DropdownMenuItem<String>(
                  value: "Public Transport Locator",
                  child: Text("Public Transport Locator"),
                ),
              ],
              onChanged: (String? value) {
                if (value != null){
                  setState(() {
                    _selectedItem = value;
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

