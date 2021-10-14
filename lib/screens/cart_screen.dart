import 'dart:convert';

import 'package:ecommerce_clone/model/app_state.dart';
import 'package:ecommerce_clone/model/order.dart';
import 'package:ecommerce_clone/model/product.dart';
import 'package:ecommerce_clone/model/user.dart';
import 'package:ecommerce_clone/payment_service.dart';
import 'package:ecommerce_clone/redux/actions.dart';
import 'package:ecommerce_clone/screens/register_screen.dart';
import 'package:ecommerce_clone/widgets/product_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class CartScreen extends StatefulWidget {
  final Function onInit;

  CartScreen({this.onInit});

  @override
  CartScreenState createState() => CartScreenState();
}

class CartScreenState extends State<CartScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    widget.onInit();
    StripeService.init();

  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
      converter: (store) => store.state,
      builder: (context, state) {
        return ModalProgressHUD(
          inAsyncCall: _isSubmitting,
          child: DefaultTabController(
            length: 3,
            initialIndex: 0,
            child: Scaffold(
              key: _scaffoldKey,
              floatingActionButton: state.cartProducts.length > 0
                  ? FloatingActionButton(
                child: Icon(Icons.local_atm_rounded),
                onPressed: () => _showCheckoutDialog(state),
              ) : Text(''),
              appBar: AppBar(
                backgroundColor: Theme.of(context).primaryColor,
                centerTitle: true,
                title: Text("Summary: ${state.cartProducts.length} Items - \$${calculateTotalPrice(state.cartProducts)}"),
                bottom: TabBar(
                    labelColor: Colors.deepOrange[600],
                    unselectedLabelColor: Colors.deepOrange[900],
                    tabs: [
                      Tab(icon: Icon(Icons.shopping_cart)),
                      Tab(icon: Icon(Icons.credit_card)),
                      Tab(icon: Icon(Icons.receipt)),
                    ]
                ),
              ),
              body: TabBarView(
                  children: [
                    _cartTab(state),
                    _cardsTab(state),
                    _orderTab(state),
                  ]
              ),
            ),
          ),
        );
      }
    );
  }

  Widget _cartTab(AppState state) {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Column(
      children: [
        Expanded(
          child: SafeArea(
            top: false,
            bottom: false,
            child: GridView.builder(
                itemCount: state.cartProducts.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: orientation == Orientation.portrait ? 2 : 3,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                    childAspectRatio: orientation == Orientation.portrait ? 1.0 : 1.3),
                itemBuilder: (context, index) {
                  return ProductItemWidget(
                    item: state.cartProducts[index],
                  );
                }),
          ),
        )
      ],
    );
  }

  Widget _cardsTab(AppState state) {

    Future<dynamic> _addCard(String cardToken) async {
      User user = state.user;
      // update user's data to include cardToken (PUT/users/:id)
      await put(Uri.parse("http://$localHost/users/${user.id}"), body: {
        "card_token": cardToken
      }, headers: {
        "Authorization": "Bearer ${user.jwt}"
      });
      // associate cardToken (added card) with Stripe customers (POST/card/add)
      Response response = await post(
          Uri.parse("http://$localHost/card/add"), body: {
        "source": cardToken,
        "customer": user.customerId
      });
      final responseData = jsonDecode(response.body);
      return responseData;
    }
    return Column(
      children: [
        Padding(padding: EdgeInsets.only(top: 10),),
        RaisedButton(
          elevation: 8,
          child: Text("Add Card"),
          onPressed: () async {
            String cardToken = await StripeService.addNewCard();
            final card = await _addCard(cardToken);
            // action to AddCard
            StoreProvider.of<AppState>(context).dispatch(AddCardAction(card));
            // action to update cardToken
            StoreProvider.of<AppState>(context).dispatch(UpdateCardTokenAction(card['id']));
            // show snackBar
            final snackBar = SnackBar(
                content: Text(
                  "Card Added!", style: TextStyle(color: Colors.green),)
            );
            _scaffoldKey.currentState.showSnackBar(snackBar);
          },
        ),
        Expanded(
            child: ListView(
              children: state.cards.map<Widget>((card) => _cardsItemWidget(card, state.cardToken)).toList(),
            )
        )
      ],
    );
  }

  Widget _orderTab(AppState state) {
    return ListView(
      children: state.orders.length > 0
          ? state.orders.map<Widget>((order) => ListTile(
       title: Text("\$${order.amount}"),
        subtitle: Text(DateFormat("MMMM dd, yyyy - hh:mm a").format(order.createdAt)),
        leading: CircleAvatar(
          backgroundColor: Colors.green,
          child: Icon(Icons.attach_money, color: Colors.white),
        ),
      )).toList()
          : [
        Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.close, size: 60),
              Text("No orders yet", style: Theme.of(context).textTheme.caption,)
            ],
          ),
        )
      ]
    );
  }

  Widget _cardsItemWidget(dynamic card, String cardToken) => ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.deepOrange,
          child: Icon(Icons.credit_card, color: Colors.white),
        ),
        title: Text(
            "${card['card']['exp_month']}/${card['card']['exp_year']}, ${card['card']['last4']}" ?? "N/A"),
        subtitle: Text(card['card']['brand'] ?? "N/A"),
        trailing: cardToken == card['id']
            ? Chip(
                avatar: CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Icon(Icons.check_circle, color: Colors.white,),
                ),
                label: Text("Primary Card"),)
            : FlatButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0))),
                color: Colors.pink,
                child: Text(
                  'Set as Primary',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
                onPressed: () {
                  // action to update cardToken
                  StoreProvider.of<AppState>(context).dispatch(UpdateCardTokenAction(card['id']));
                },
              ),
      );


  Future _showCheckoutDialog(AppState state) {
    return showDialog(
        context: context,
        builder: (context) {
          print("cards len: ${state.cards.length}");
          if (state.cards.length == 0) {
            return AlertDialog(
              title: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 10.0),
                    child: Text('Add Card')
                  ),
                  Icon(Icons.credit_card, size: 40)
                ],
              ),
              content: SingleChildScrollView(
                child: ListBody(
                  children: [
                    Text("Provide a credit card before checking out", style: Theme.of(context).textTheme.bodyText1)
                  ],
                ),
              ),
            );
          }
          String cartSummary = "";
          state.cartProducts.forEach((cartProduct) {
            cartSummary += ". ${cartProduct.name}, \$${cartProduct.price}\n";
          });
          final primaryCard = state.cards.singleWhere((card) { return card['id'] == state.cardToken; })['card'];
          return AlertDialog(
            title: Text("Checkout"),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  Text("CART ITEMS (${state.cards.length})\n",
                      style: Theme.of(context).textTheme.bodyText1),
                  Text("--------------------"),
                  Text("$cartSummary", style: Theme.of(context).textTheme.bodyText1),
                  Text("CARD DETAILS\n", style: Theme.of(context).textTheme.bodyText1),
                  Text("--------------------"),
                  Text("Brand: ${primaryCard['brand']}", style: Theme.of(context).textTheme.bodyText1),
                  Text("Card Number: ${primaryCard['last4']}", style: Theme.of(context).textTheme.bodyText1),
                  Text("Expires On: ${primaryCard['exp_month']}/${primaryCard['exp_year']}\n",
                      style: Theme.of(context).textTheme.bodyText1),
                  Text("ORDER TOTAL: \$${calculateTotalPrice(state.cartProducts)}")
                ],
              ),
            ),
            actions: [
              FlatButton(
                onPressed: () => Navigator.pop(context, false),
                color: Colors.red,
                child: Text("Close", style: TextStyle(color: Colors.white),),
              ),
              FlatButton(
                onPressed: () => Navigator.pop(context, true),
                color: Colors.green,
                child: Text("Checkout", style: TextStyle(color: Colors.white),),
              ),
            ],
          );
        }
    ).then((value) async {

      Future<dynamic> _checkoutCartProducts() async {
        // create new order in strapi
        Response response = await post(Uri.parse("http://$localHost/orders"), body: {
          "amount": calculateTotalPrice(state.cartProducts),
          "products": jsonEncode(state.cartProducts),
          "customer": state.user.customerId,
          "source": state.cardToken
        }, headers: {
          "Authorization": "Bearer ${state.user.jwt}"
        });
        final responseData = jsonDecode(response.body);
        return responseData;
      }

      if (value == true) {
        // show loading spinner
        setState(() => _isSubmitting = true);
        // checkout cart products (create new order in strapi/charge card with stripe)
        final newOrderData = await _checkoutCartProducts();
        // create order instance
        Order newOrder = Order.fromJson(newOrderData);
        // pass order instance to a new action
        StoreProvider.of<AppState>(context).dispatch(AddOrderAction(newOrder));
        // clear out cart products
        StoreProvider.of<AppState>(context).dispatch(clearCartProductsAction);
        // hide loading spinner
        setState(() => _isSubmitting = false);
        // show success dialog
        _showSuccessDialog();
      }
    });
  }

  Future _showSuccessDialog() {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text("Success!"),
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text("Order successful!\n\nCheck your email for a receipt of your purchase!\n\n"
                    "Order summary will appear in your orders tab",
                  style: Theme.of(context).textTheme.bodyText1,),
              )
            ],
          );
        });
  }

  String calculateTotalPrice(List<Product> cartProducts) {
    double totalPrice = 0.0;
    cartProducts.forEach((cartProduct) {
      totalPrice += cartProduct.price;
    });
  return totalPrice.toStringAsFixed(2);
  }
}
