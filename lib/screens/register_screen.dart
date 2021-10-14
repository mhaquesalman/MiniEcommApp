import 'dart:convert';

import 'package:ecommerce_clone/model/auth_model.dart';
import 'package:ecommerce_clone/screens/products_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

const localHost = "localhost:1337";
class RegisterScreen extends StatefulWidget {

  RegisterScreen({Key key}) : super(key: key);

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  String _username, _email, _password;
  bool _obscureText = true;
  bool _isSubmitting;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text("Register")),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text(
                    'Register',
                    style: Theme.of(context).textTheme.headline2,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: usernameTextForm(
                      title: "Username",
                      hintText: "Enter an username, min length 5",
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: emailTextForm(
                      title: "Email",
                      hintText: "Enter a valid email",
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: passwordTextForm(
                      title: "Password",
                      hintText: "Enter the password, min length 6",
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
                                color: Theme.of(context).primaryColor,
                                onPressed: _submit,
                              ),
                          ),
                      FlatButton(
                        child: Text("Existing user? Login", style: TextStyle(fontSize: 16),),
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginScreen()
                            )),
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
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      _register();
    }
  }

  void _register() async {
    // final url = Uri.parse("http://localhost:1337/auth/local/register");
    setState(() => _isSubmitting = true);
    final url = Uri.parse("http://$localHost/auth/local/register");
    Response cartResponse = await post(Uri.parse("http://$localHost/carts"));
    var cartData = json.decode(cartResponse.body);
    Response response = await post(
        url,
        body: {"username": _username, "email": _email, "password": _password, "cart_id": cartData['id']});
    var responseData = json.decode(response.body);
    print("Registration: " + response.body);
    if (response.statusCode == 200) {
      setState(() => _isSubmitting = false);
      _storeUserData(responseData);
      _showSuccessSnackBar();
      _redirectUser();
    } else {
      setState(() => _isSubmitting = false);
      final errorMsg = responseData['message'][0]['messages'][0]['message'];
      _showFailureSnackBar(errorMsg);
    }
  }

  void _showSuccessSnackBar() {
    final snackBar = SnackBar(
        content: Text(
      "User $_username successfully created",
      style: TextStyle(color: Colors.green),
    ));
    _scaffoldKey.currentState.showSnackBar(snackBar);
    _formKey.currentState.reset();
  }

/*  void _redirectUser() => Future.delayed(
      Duration(seconds: 2),
      () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ProductsScreen()
            ),
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

  void _storeUserData(responseData) async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> user = responseData['user'];
    user.putIfAbsent("jwt", () => responseData['jwt']);
    prefs.setString("user", json.encode(user));
  }

  Widget usernameTextForm({String title, String hintText}) {
    return TextFormField(
      onSaved: (val) => _username = val,
      validator: (val) {
        if (isUsernameValid(val))
          return null;
        else
          return 'Username length must be at least 5';
      },
      decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: title,
          hintText: hintText,
          icon: Icon(Icons.face, color: Colors.grey)),
    );
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
          icon: Icon(Icons.mail, color: Colors.grey)),
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

  bool isUsernameValid(String username) {
    if (username.isEmpty) return false;
    if (username.length < 5) return false;
    return true;
  }

  bool isEmailValid(String email) {
    if (email.isEmpty) return false;
    String pattern = r'\w+@\w+\.\w+';
    RegExp regExp = RegExp(pattern);
    if (!regExp.hasMatch(email)) return false;
    return true;
  }

  bool isPasswordValid(String password) => password.length >= 6;
}
