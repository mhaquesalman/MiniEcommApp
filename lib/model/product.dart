import 'package:flutter/material.dart';

class Product {
  String id;
  String name;
  String description;
  num price;
  Map<String, dynamic> picture;


  Product({
    this.id,
    this.name,
    this.description,
    this.price,
    this.picture
});

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['_id'],
    name: json['name'],
    description: json['description'],
    price: json['price'],
    picture: json['image']
  );


  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "description": description,
      "price": price,
      "image": picture
    };
  }

}