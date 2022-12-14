import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'HomePage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginDemo(),
    );
  }
}

class LoginDemo extends StatefulWidget {
  @override
  _LoginDemoState createState() => _LoginDemoState();
}

class _LoginDemoState extends State<LoginDemo> {
   Dio _dio = Dio();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 250.0),
              child: Center(
                child: Container(
                    width: 200,
                    height: 200,
                    /*decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(50.0)),*/
                    child: Image.asset("assets/images/MGUlogo.jpg")),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.alternate_email , color: Colors.blue),
                    border: OutlineInputBorder( borderRadius: BorderRadius.all(Radius.circular(20.0)),
                        borderSide: BorderSide(color: Colors.cyan, width: 1)),
                    labelText: 'Email',
                    hintText: 'Enter valid email'),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(
                  left: 15.0, right: 15.0, top: 15, bottom: 0),
              child: TextField(
                obscureText: true,
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.password_outlined, color: Colors.blue),
                    border: OutlineInputBorder( borderRadius: BorderRadius.all(Radius.circular(20.0)),
                        borderSide: BorderSide(color: Colors.cyan, width: 1)),
                    labelText: 'Password',
                    hintText: 'Enter secure password'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 0.0, right: 0, top: 0, bottom: 0),
              child: MaterialButton(
                onPressed: (){
                  //TODO FORGOT PASSWORD SCREEN GOES HERE
                },
                child: const Text(
                  'Forgot Password',
                  style: TextStyle(color: Colors.blue, fontSize: 13),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 0.0, right: 0, top: 0, bottom: 0),
              child: Container(
                height: 35,
                width: 170,
                decoration: BoxDecoration(
                    color: Colors.orangeAccent, borderRadius: BorderRadius.circular(20)),
                child: MaterialButton(
                  onPressed: () async {
                    // final response = await _dio.get('https://google.com');
                    // print(response.data);
                     Navigator.push(
                         context, MaterialPageRoute(builder: (_) => HomePage()));
                   },
                  child: const Text(
                    'Login',
                    style: TextStyle(color: Colors.white, fontSize: 20),
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