
import 'dart:convert';

import 'package:ecommerce_clone/model/app_state.dart';
import 'package:ecommerce_clone/model/order.dart';
import 'package:ecommerce_clone/model/product.dart';
import 'package:ecommerce_clone/model/user.dart';
import 'package:ecommerce_clone/screens/register_screen.dart';
import 'package:http/http.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:redux/redux.dart';
import 'package:shared_preferences/shared_preferences.dart';


ThunkAction<AppState> getUserAction = (Store<AppState> store) async {
  final prefs = await SharedPreferences.getInstance();
  final storedUser = prefs.getString("user");
  final user = storedUser != null ? User.fromJson(json.decode(storedUser)) : null;
  print("stored user: ${user.username}");
  store.dispatch(GetUserAction(user));
};


class GetUserAction {
  final User _user;

  User get user => _user;

  GetUserAction(this._user);
}

/* Products action */

ThunkAction<AppState> getProductsAction = (Store<AppState> store) async {
  final response = await get(Uri.parse("http://192.168.1.3:1337/products"));
  final responseData = json.decode(response.body);
  List<Product> products = [];
  responseData.forEach((productData) {
    Product product = Product.fromJson(productData);
    products.add(product);
  });
  store.dispatch(GetProductsAction(products));
};

class GetProductsAction {
  final List<Product> _products;
  
  get products => _products;
  
  GetProductsAction(this._products);
}


/* User logout action */

ThunkAction<AppState> getUserLogoutAction = (Store<AppState> store) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove("user");
  User user;
  store.dispatch(GetUserLogoutAction(user));
};

class GetUserLogoutAction {
  final User _user;

  get user => _user;

  GetUserLogoutAction(this._user);
}


/* cart product action */

ThunkAction<AppState> toggleCartProductAction(Product cartProduct) {
  return (Store<AppState> store) async {
    final List<Product> cartProducts = store.state.cartProducts;
    final User user = store.state.user;
    final int index = cartProducts.indexWhere((product) => product.id == cartProduct.id);
    bool isInCart = index > -1 == true;
    List<Product> updatedCartProducts = List.from(cartProducts);
    if(isInCart) {
      updatedCartProducts.removeAt(index);
    } else {
      updatedCartProducts.add(cartProduct);
    }
    final cartProductsIds = updatedCartProducts.map((product) => product.id).toList();
    await put(
        Uri.parse("http://$localHost/carts/${user.cartId}"),
        headers: {
          'Authorization': 'Bearer ${user.jwt}'
        },
        body: {
          'products': json.encode(cartProductsIds)
        });
    store.dispatch(ToggleCartProductsAction(updatedCartProducts));
  };
}

ThunkAction<AppState> getCartProductsAction = (Store<AppState> store) async {
  final prefs = await SharedPreferences.getInstance();
  final storedUser = prefs.getString("user");
  if (storedUser == null) {
    return;
  }
  final user = User.fromJson(json.decode(storedUser));
  final Response response = await get(Uri.parse("http://$localHost/carts/${user.cartId}"), headers: {
    'Authorization': 'Bearer ${user.jwt}'
  });
  final responseData = json.decode(response.body)['products'];
  List<Product> cartProducts = [];
  responseData.forEach((productData) {
    Product product = Product.fromJson(productData);
    cartProducts.add(product);
  });
  store.dispatch(GetCartProductsAction(cartProducts));
};

ThunkAction<AppState> clearCartProductsAction = (Store <AppState> store) async {
  User user = store.state.user;
  await put(Uri.parse("http://$localHost/carts/${user.cartId}"), body: {
    "products": jsonEncode([])
  }, headers: {
    "Authorization": "Bearer ${user.jwt}"
  });
  store.dispatch(ClearCartProductsAction(List(0)));
};

class ToggleCartProductsAction {
  final List<Product> _cartProducts;

  get cartProducts => _cartProducts;

  ToggleCartProductsAction(this._cartProducts);
}

class GetCartProductsAction {
  final List<Product> _cartProducts;

  get cartProducts => _cartProducts;

  GetCartProductsAction(this._cartProducts);
}

class ClearCartProductsAction {
  final List<Product> _cartProducts;

  get cartProducts => _cartProducts;

  ClearCartProductsAction(this._cartProducts);
}

/* cards & order action */

ThunkAction<AppState> getCardsAction = (Store<AppState> store) async {
  final customerId = store.state.user.customerId;
  Response response = await get(Uri.parse("http://$localHost/card?$customerId"));
  final responseData = jsonDecode(response.body);
  print("cardId: ${responseData['data'][0]['id']}");
  store.dispatch(GetCardsAction(responseData['data']));
};

ThunkAction<AppState> getCardTokenAction = (Store<AppState> store) async {
  final jwt = store.state.user.jwt;
  Response response = await get(Uri.parse("http://$localHost/users/me"), headers: {
    'Authorization': 'Bearer $jwt'
  });
  List<Order> orders = [];
  final responseData = json.decode(response.body);
  String cardToken = responseData['card_token'];
  final List<dynamic> orderResponse = responseData['orders'];
  orderResponse.forEach((orderData) {
    Order order = Order.fromJson(orderData);
    orders.add(order);
  });
  print("cardToken: $cardToken");
  print("orders: ${responseData['orders']}");
  store.dispatch(GetCardTokenAction(cardToken));
  store.dispatch(GetOrdersAction(orders));
};

class GetCardsAction {
  final List<dynamic> _cards;

  List<dynamic> get cards => _cards;

  GetCardsAction(this._cards);

}

class AddCardAction {
  final dynamic _card;

  dynamic get card => _card;

  AddCardAction(this._card);

}

class UpdateCardTokenAction {
  final String _cardToken;

  String get cardToken => _cardToken;

  UpdateCardTokenAction(this._cardToken);

}

class GetCardTokenAction {
  final String _cardToken;

  String get cardToken => _cardToken;

  GetCardTokenAction(this._cardToken);
}

class GetOrdersAction {
  final List<Order> _orders;

  List<Order> get orders => _orders;

  GetOrdersAction(this._orders);
}

class AddOrderAction {
  final Order _order;

  Order get order => _order;

  AddOrderAction(this._order);
}