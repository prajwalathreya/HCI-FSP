import 'package:flutter/material.dart';
import 'package:fsp/MapPage.dart';
import 'package:fsp/PreviewMap.dart';
import 'package:google_place/google_place.dart';

class NavigationPage extends StatefulWidget {
  @override
  _NavigationPageState createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  String _selectedItem =
      "Long and Straight Roads"; // Initialize with a default value

  final _startSearchFieldController = TextEditingController();
  final _endSearchFieldController = TextEditingController();

  String _startLocation = "";
  DetailsResult? startPosition;
  DetailsResult? endPosition;

  late FocusNode startFocusNode;
  late FocusNode endFocusNode;

  late GooglePlace googlePlace;
  List<AutocompletePrediction> predictions = [];

  void autoCompleteSearch(String value) async {
    var result = await googlePlace.autocomplete.get(value);
    if (result != null && result.predictions != null && mounted) {
      print(result.predictions!.first.description);
      setState(() {
        predictions = result.predictions!;
      });
    } else {
      print("Response ERROR!");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    String apiKey = 'AIzaSyDkKbK_K-0WJuhGvvSbmSL5pEoCiBSWNqY';
    googlePlace = GooglePlace(apiKey);

    startFocusNode = FocusNode();
    endFocusNode = FocusNode();
  }

  @override
  void dispose() {
    super.dispose();
    startFocusNode.dispose();
    endFocusNode.dispose();
  }

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
              controller: _startSearchFieldController,
              autofocus: false,
              focusNode: startFocusNode,
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Start Location",
                  suffixIcon: _startSearchFieldController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            setState(() {
                              predictions = [];
                              _startSearchFieldController.clear();
                            });
                          },
                          icon: Icon(Icons.clear_outlined),
                        )
                      : null),
              onChanged: (text) {
                _startLocation = text;
                if (text.isNotEmpty && text.length > 3) {
                  //places api
                  autoCompleteSearch(text);
                } else {
                  //clear out the results
                  setState(() {
                    predictions = [];
                    startPosition = null;
                  });
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _endSearchFieldController,
              autofocus: false,
              focusNode: endFocusNode,
              enabled: _startSearchFieldController.text.isNotEmpty &&
                  startPosition != null,
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "End Location",
                  suffixIcon: _endSearchFieldController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            setState(() {
                              predictions = [];
                              _endSearchFieldController.clear();
                            });
                          },
                          icon: Icon(Icons.clear_outlined),
                        )
                      : null),
              onChanged: (text) {
                _startLocation = text;
                if (text.isNotEmpty && text.length > 3) {
                  //places api
                  autoCompleteSearch(text);
                } else {
                  //clear out the results
                  setState(() {
                    predictions = [];
                  });
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MapPage()),
                    );
                    // Handle navigation or other logic for "Routes" button.
                  },
                  child: Text("Routes"),
                ),
                SizedBox(width: 8.0), // Add spacing between the buttons
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PreviewScreen(
                              startPosition: startPosition,
                              endPosition: endPosition)),
                    );
                  },
                  child: Text("Preview"),
                ),
              ],
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
                if (value != null) {
                  setState(() {
                    _selectedItem = value;
                  });
                }
              },
            ),
          ),
          ListView.builder(
              shrinkWrap: true,
              itemCount: predictions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    child: Icon(
                      Icons.pin_drop,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    predictions[index].description.toString(),
                  ),
                  onTap: () async {
                    final placeId = predictions[index].placeId!;
                    final details = await googlePlace.details.get(placeId);
                    if (details != null && details.result != null && mounted) {
                      if (startFocusNode.hasFocus) {
                        setState(() {
                          startPosition = details.result;
                          _startSearchFieldController.text =
                              details.result!.name!;
                          predictions = [];
                        });
                      } else {
                        setState(() {
                          endPosition = details.result;
                          _endSearchFieldController.text =
                              details.result!.name!;
                          predictions = [];
                        });
                      }
                    }
                  },
                );
              })
        ],
      ),
    );
  }
}
