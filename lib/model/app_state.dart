import 'package:ecommerce_clone/model/order.dart';
import 'package:ecommerce_clone/model/product.dart';
import 'package:ecommerce_clone/model/user.dart';
import 'package:flutter/material.dart';

class AppState {
  final User user;
  final List<Product> products;
  final List<Product> cartProducts;
  final List<dynamic> cards;
  final List<Order> orders;
  final String cardToken;

  AppState({@required this.user,
    @required this.products,
    @required this.cartProducts,
    @required this.cards,
    @required this.orders,
    @required this.cardToken});


  factory AppState.initial() {
    return AppState(
      user: null,
      products: [],
      cartProducts: [],
      cards: [],
      orders: [],
      cardToken: ""
    );
  }
}