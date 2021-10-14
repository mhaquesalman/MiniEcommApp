import 'dart:convert';

import 'package:badges/badges.dart';
import 'package:ecommerce_clone/model/app_state.dart';
import 'package:ecommerce_clone/redux/actions.dart';
import 'package:ecommerce_clone/screens/register_screen.dart';
import 'package:ecommerce_clone/widgets/gradient_background.dart';
import 'package:ecommerce_clone/widgets/product_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductsScreen extends StatefulWidget {
  final Function onInit;

  ProductsScreen ({this.onInit});

  @override
  ProductsScreenState createState() => ProductsScreenState();
}

class ProductsScreenState extends State<ProductsScreen> {

  @override
  void initState() {
    super.initState();
    widget.onInit();
  }


  final _appBar = PreferredSize(
    preferredSize: Size.fromHeight(60),
    child: StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) {
          print("user: ${state.user.username}");
          return AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            centerTitle: true,
            title: SizedBox(
              child: state.user != null
                  ? Text(state.user.username ?? "S")
                  : FlatButton(
                  child: Text(
                    "Register Here",
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RegisterScreen())
                    );
                  }
              ),
            ),
            leading: state.user != null
                ? BadgeIconButton(
              badgeColor: Colors.lime,
              badgeTextColor: Colors.black,
              icon: Icon(Icons.store),
              onPressed: () => Navigator.pushReplacementNamed(context, '/cart'),
            )
                : Text(""),
            actions: [
              Padding(
                padding: EdgeInsets.only(right: 12),
                child: StoreConnector<AppState, VoidCallback>(
                  converter: (store) {
                    return () => store.dispatch(getUserLogoutAction);
                  },
                  builder: (context, callback) {
                    return state.user != null
                        ? IconButton(
                      icon: Icon(Icons.exit_to_app),
                      onPressed: callback,
                    )
                        : Text('');
                  },
                ),
              )
            ],
          );
        }),
  );

  void _getUser() async {
    final prefs = await SharedPreferences.getInstance();
    var user = prefs.getString("user");
    print(json.decode(user));
  }


  @override
  Widget build(BuildContext context) {
    final Orientation orientation = MediaQuery.of(context).orientation;

    return Scaffold(
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(60),
            child: StoreConnector<AppState, AppState>(
              converter: (store) => store.state,
              builder: (_, state) {
                return AppBar(
                    backgroundColor: Theme.of(context).primaryColor,
                    centerTitle: true,
                    title: SizedBox(
                      child: state.user != null
                          ? Text(state.user.username ?? "N/A")
                          : FlatButton(
                          child: Text(
                            "Register Here",
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => RegisterScreen())
                            );
                          }
                      ),
                    ),
                    leading: state.user != null
                        ? BadgeIconButton(
                            itemCount: state.cartProducts.length,
                            badgeColor: Colors.lime,
                            badgeTextColor: Colors.black,
                            icon: Icon(Icons.store),
                            onPressed: () => Navigator.pushNamed(context, '/cart'),
                          )
                        : Text(""),
                    actions: [
                      Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: StoreConnector<AppState, VoidCallback>(
                          converter: (store) {
                            return () => store.dispatch(getUserLogoutAction);
                          },
                          builder: (context, callback) {
                            return state.user != null
                                ? IconButton(
                                    icon: Icon(Icons.exit_to_app),
                                    onPressed: callback,
                                  )
                                : Text('');
                          },
                        ),
                      )
                    ]);
              },
            )
        ),
        body: Container(
            decoration: gradientBackground,
            child: StoreConnector<AppState, AppState>(
              converter: (store) => store.state,
              builder: (context, state) {
                print("products: ${state.products.length}");
                return Column(
                  children: [
                    state.products.length > 0
                        ? Expanded(
                            child: SafeArea(
                            top: false,
                            bottom: false,
                            child: GridView.builder(
                                itemCount: state.products.length,
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: orientation == Orientation.portrait ? 2 : 3,
                                        crossAxisSpacing: 4,
                                        mainAxisSpacing: 4,
                                        childAspectRatio: orientation == Orientation.portrait ? 1.0 : 1.3
                                ),
                                itemBuilder: (context, index) {
                                  return ProductItemWidget(
                                    item: state.products[index],
                                  );
                                }
                                ),
                            )
                    ) : Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ],
                );
              },
            )
        )
    );
  }

  void _redirectToRegister() => Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => RegisterScreen())
  );

}
