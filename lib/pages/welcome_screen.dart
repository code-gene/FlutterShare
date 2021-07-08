import 'package:flutter/material.dart';

import 'home.dart';

class WelcomeScreen extends StatefulWidget {

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Theme
                  .of(context)
                  .accentColor,
              Theme
                  .of(context)
                  .primaryColor,
            ],
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'FlutterShare',
              style: TextStyle(
                fontFamily: "Signatra",
                fontSize: 90.0,
                color: Colors.white,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Home()));
              },
              child: Container(
                width: 225,
                height: 45,
                color: Colors.blue,
                child: Center(
                    child: Text(
                        'Get Started',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
