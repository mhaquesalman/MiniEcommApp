import 'package:flutter/cupertino.dart';

class User {
  String id;
  String username;
  String email;
  String jwt;
  String cartId;
  String customerId;

  User({
    this.id,
    this.username,
    this.email,
    this.jwt,
    this.cartId,
    this.customerId});


  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['_id'],
    username: json['username'],
    email: json['email'],
    jwt: json['jwt'],
    cartId: json['cart_id'],
    customerId: json['customer_id']
  );

}

