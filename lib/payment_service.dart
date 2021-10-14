import 'dart:convert';

import 'package:http/http.dart';
import 'package:stripe_payment/stripe_payment.dart';

class StripeTransactionResponse {
  String message;
  bool success;

  StripeTransactionResponse({this.message, this.success});

}

class StripeService {
  static String _apiBase = "https://api.stripe.com//v1";
  static String _paymentApiUrl = '${_apiBase}/payment_intents';
  static String _secretKey =
      "SECRET_KEY";
  static String _publishKey =
      "PUBLISH_KEY";

  static Map<String, String> _headers = {
    'Authorization': 'Bearer ${_secretKey}',
    'Content_Type': 'application/x-www-form-urlencoded'
  };

  static init() {
    StripePayment.setOptions(
        StripeOptions(
            publishableKey: _publishKey,
            merchantId: "Test",
            androidPayMode: "test"
        )
    );
  }

  static Future<String> addNewCard() async {
    try {
      final paymentMethod = await StripePayment.paymentRequestWithCardForm(CardFormPaymentRequest());
      final paymentData = jsonEncode(paymentMethod);
      print("paymentData: " + paymentData);
      return paymentMethod.id;
    } catch (err) {
      print("paymentData error: $err");
    }
    return null;
  }

  static Future<Map<String, dynamic>> createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        "amount": amount,
        "currency": currency,
        "payment_method_types[]": "card"
      };
      final response = await post(
        Uri.parse(_paymentApiUrl),
        body: body,
        headers: _headers
      );
      final responseData = jsonDecode(response.body);
      // print("createPaymentIntentData: ${responseData}");
      return responseData;
    } catch (err) {
      print("createPaymentIntent error: " + err);
    }
    return null;
  }

  static Future<StripeTransactionResponse> payWithNewCard({String amount, String currency}) async {
    try {
      final paymentIntent = await StripeService.createPaymentIntent(
          amount, currency);
      final paymentMethodId = await StripeService.addNewCard();
      final response = await StripePayment.confirmPaymentIntent(
          PaymentIntent(
              clientSecret: paymentIntent['client_secret'],
              paymentMethodId: paymentMethodId
          )
      );
      if (response.status == 'succeeded') {
        return StripeTransactionResponse(
            message: "Transaction successful",
            success: true
        );
      } else {
        return StripeTransactionResponse(
            message: "Transaction failed",
            success: false
        );
      }
    } catch (err) {
      return StripeTransactionResponse(
          message: "Transaction failed: $err",
          success: false
      );
    }
  }

}