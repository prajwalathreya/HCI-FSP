
// import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:fsp/NavigationPage.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Bike Navigation System',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  // var current = WordPair.random();
  void getNext() {
    // current = WordPair.random();
    notifyListeners();
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600; // Adjust the threshold as needed

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/black-grey-chicago-city-area-background-map-vector-37821140.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: Text(
                      "Bike Navigation System\n Welcome Bikers",
                      // "Welcome Bikers",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isSmallScreen ? 20.0 : 24.0,
                      ),
                    ),
                  ),
                  // Text(
                    // appState.current.asPascalCase,
                    // style: TextStyle(
                      // color: Colors.white,
                      // fontSize: isSmallScreen ? 16.0 : 20.0,
                  //   // ),
                  // ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => NavigationPage()),
                      );
                      print("Hello, you pressed this button");
                    },
                    child: Text("Start", textAlign: TextAlign.center),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 50.0,
            right: 20.0,
            child: ElevatedButton(
              onPressed: () {
                // Add your logic for the circular button here
              },
              style: ElevatedButton.styleFrom(
                shape: CircleBorder(),
                padding: EdgeInsets.all(35),
                primary: Colors.red,
              ),
              child: Text(
                'SOS',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}