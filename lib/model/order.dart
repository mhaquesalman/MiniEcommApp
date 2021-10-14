import 'dart:convert';

class Order {
  int amount;
  DateTime createdAt;
  List<dynamic> products;

  Order({this.amount, this.createdAt, this.products});

  factory Order.fromJson(json) => Order(
    amount: json['amount'],
    createdAt: DateTime.parse(json['createdAt']),
    products: jsonDecode(json['products'])
  );
}