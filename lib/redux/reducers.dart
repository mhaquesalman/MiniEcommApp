import 'package:ecommerce_clone/model/app_state.dart';
import 'package:ecommerce_clone/model/order.dart';
import 'package:ecommerce_clone/model/product.dart';
import 'package:ecommerce_clone/model/user.dart';
import 'package:ecommerce_clone/redux/actions.dart';

AppState appReducers(AppState state, dynamic action) {
  return AppState(
    user: userReducer(state.user, action),
    products: productReducer(state.products, action),
    cartProducts: cartProductsReducer(state.cartProducts, action),
    cards: cardsReducer(state.cards, action),
    orders: ordersReducer(state.orders, action),
    cardToken: cardTokenReducer(state.cardToken, action)
  );

}

User userReducer(User user, dynamic action) {
  if (action is GetUserAction) {
    return action.user;
  } else if (action is GetUserLogoutAction) {
    return action.user;
  }
  return user;
}

List<Product> productReducer(List<Product> products, dynamic action) {
  if (action is GetProductsAction) {
    return action.products;
  }
  return products;
}

List<Product> cartProductsReducer(List<Product> cartProducts, dynamic action) {
  if (action is GetCartProductsAction) {
    return action.cartProducts;
  } else if (action is ToggleCartProductsAction) {
    return action.cartProducts;
  } else if (action is ClearCartProductsAction) {
    return action.cartProducts;
  }
  return cartProducts;
}

List<dynamic> cardsReducer(List<dynamic> cards, dynamic action) {
  if (action is GetCardsAction) {
    return action.cards;
  } else if (action is AddCardAction) {
    return List.from(cards)..add(action.card);
  }
  return cards;
}

List<Order> ordersReducer(List<Order> orders, dynamic action) {
  if (action is GetOrdersAction) {
    return action.orders;
  } else if (action is AddOrderAction) {
    return List.from(orders)..add(action.order);
  }
  return orders;
}

String cardTokenReducer(String cardToken, dynamic action) {
  if (action is GetCardTokenAction) {
    return action.cardToken;
  } else if (action is UpdateCardTokenAction) {
    return action.cardToken;
  }
  return cardToken;
}

