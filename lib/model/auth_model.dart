// To parse this JSON data, do
//
//     final authModel = authModelFromJson(jsonString);

import 'dart:convert';

AuthModel authModelFromJson(String str) => AuthModel.fromJson(json.decode(str));

String authModelToJson(AuthModel data) => json.encode(data.toJson());

class AuthModel {
  AuthModel({
    this.statusCode,
    this.error,
    this.message,
    this.data,
  });

  int statusCode;
  String error;
  List<Data> message;
  List<Data> data;

  factory AuthModel.fromJson(Map<String, dynamic> json) => AuthModel(
    statusCode: json["statusCode"],
    error: json["error"],
    message: List<Data>.from(json["message"].map((x) => Data.fromJson(x))),
    data: List<Data>.from(json["data"].map((x) => Data.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "statusCode": statusCode,
    "error": error,
    "message": List<dynamic>.from(message.map((x) => x.toJson())),
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Data {
  Data({
    this.messages,
  });

  List<Message> messages;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    messages: List<Message>.from(json["messages"].map((x) => Message.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "messages": List<dynamic>.from(messages.map((x) => x.toJson())),
  };
}

class Message {
  Message({
    this.id,
    this.message,
  });

  String id;
  String message;

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    id: json["id"],
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "message": message,
  };
}
