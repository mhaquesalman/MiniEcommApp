import 'dart:convert';

import 'package:ecommerce_clone/screens/products_screen.dart';
import 'package:ecommerce_clone/screens/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  String _email, _password;
  bool _isSubmitting, _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text("Login")),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text(
                    'Login',
                    style: Theme.of(context).textTheme.headline2,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: emailTextForm(
                      title: "Email",
                      hintText: "Enter email",
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: passwordTextForm(
                      title: "Password",
                      hintText: "Enter password",
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Column(
                        children: [
                      _isSubmitting == true
                          ? CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(
                                  Theme.of(context).primaryColor),
                            )
                          : Container(
                            margin: EdgeInsets.symmetric(horizontal: 10),
                            child: RaisedButton(
                                child: Text(
                                  "Submit",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      .copyWith(color: Colors.black),
                                ),
                                elevation: 8,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                color: Theme.of(context).accentColor,
                                onPressed: _submit,
                              ),
                          ),
                      FlatButton(
                        child: Text("New user? Register", style: TextStyle(fontSize: 16),),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RegisterScreen()));
                        },
                      )
                    ]),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    FormState form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      _login();
    }
  }

  void _login() async {
    final url = Uri.parse("http://192.168.1.3:1337/auth/local");
    setState(() => _isSubmitting = true);
    Response response =
        await post(url, body: {"identifier": _email, "password": _password});
    var responseData = json.decode(response.body);
    if (response.statusCode == 200) {
      setState(() => _isSubmitting = false);
      _storeUserData(responseData);
      _showSuccessSnackBar();
      _redirectUser();
      // print("Login: " + response.body);
    } else {
      setState(() => _isSubmitting = false);
      final errorMsg = responseData['message'][0]['messages'][0]['message'];
      print("Login Error: " + response.body);
      _showFailureSnackBar(errorMsg);
    }
  }

  void _showSuccessSnackBar() {
    final snackBar = SnackBar(
        content: Text(
      "User logged in",
      style: TextStyle(color: Colors.green),
    ));
    _scaffoldKey.currentState.showSnackBar(snackBar);
    _formKey.currentState.reset();
  }

/*  void _redirectUser() => Future.delayed(
      Duration(seconds: 1),
      () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProductsScreen()),
          ));*/

    void _redirectUser() => Future.delayed(
      Duration(seconds: 2),
      () => Navigator.pushReplacementNamed(context, '/'));

  void _showFailureSnackBar(String errorMsg) {
    final snackBar = SnackBar(
        content: Text(
      errorMsg,
      style: TextStyle(color: Colors.red),
    ));
    _scaffoldKey.currentState.showSnackBar(snackBar);
    throw Exception("Error: $errorMsg");
  }

  Widget emailTextForm({String title, String hintText}) {
    return TextFormField(
      onSaved: (val) => _email = val,
      validator: (val) {
        if (isEmailValid(val))
          return null;
        else
          return "Email must contain valid address";
      },
      decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: title,
          hintText: hintText,
          icon: Icon(Icons.face, color: Colors.grey)),
    );
  }

  Widget passwordTextForm({String title, String hintText}) {
    return TextFormField(
      onSaved: (val) => _password = val,
      validator: (val) {
        if (isPasswordValid(val))
          return null;
        else
          return "Password length must be at least 6";
      },
      obscureText: _obscureText,
      decoration: InputDecoration(
          suffixIcon: GestureDetector(
            onTap: () {
              setState(() => _obscureText = !_obscureText);
            },
            child: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
          ),
          border: OutlineInputBorder(),
          labelText: title,
          hintText: hintText,
          icon: Icon(Icons.lock_outlined, color: Colors.grey)),
    );
  }

  bool isEmailValid(String email) {
    if (email.isEmpty) return false;
    String pattern = r'\w+@\w+\.\w+';
    RegExp regExp = RegExp(pattern);
    if (!regExp.hasMatch(email)) return false;
    return true;
  }

  bool isPasswordValid(String password) => password.length >= 6;

  void _storeUserData(responseData) async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> user = responseData['user'];
    user.putIfAbsent("jwt", () => responseData['jwt']);
    prefs.setString("user", json.encode(user));
  }
}
