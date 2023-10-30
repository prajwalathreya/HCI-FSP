
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
  var current = WordPair.random();
  void getNext(){
    current = WordPair.random();
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
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/black-grey-chicago-city-area-background-map-vector-37821140.jpg'), // Replace with your image path
            fit: BoxFit.cover, // Adjust the fit to your preference
          ),
        ),
        child: Center(
          child: Column(
            // SizedBox(height: 30),
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.topCenter,
                
                child: Text(
                  "Bike Navigation System",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white, // Text color on top of the image
                    fontSize: isSmallScreen ? 20.0 : 24.0, // Adjust font size
                  )
                ),
                
              ),
              // spacer(),
              Text(
                appState.current.asPascalCase,
                style: TextStyle(
                  color: Colors.white, // Text color on top of the image
                  fontSize: isSmallScreen ? 16.0 : 20.0, // Adjust font size
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  print("Hello, you pressed this button");
                },
                child: Text("Start Navigation", textAlign: TextAlign.center),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
