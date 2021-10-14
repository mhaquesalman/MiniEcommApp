import 'package:ecommerce_clone/model/app_state.dart';
import 'package:ecommerce_clone/model/product.dart';
import 'package:ecommerce_clone/redux/actions.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce_clone/widgets/gradient_background.dart';
import 'package:flutter_redux/flutter_redux.dart';

class ProductDetailsScreen extends StatelessWidget {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final Product item;

  ProductDetailsScreen({this.item});

  @override
  Widget build(BuildContext context) {
    final Orientation orientation = MediaQuery.of(context).orientation;
    final pictureUrl = "http://192.168.1.3:1337${item.picture['url']}";



    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(item.name ?? "N/A"),
      ),
      body: Container(
        decoration: gradientBackground,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Hero(
                tag: item,
                child: Image.network(pictureUrl,
                    width: orientation == Orientation.portrait ? 600 : 250,
                    height: orientation == Orientation.portrait ? 400 : 200,
                    fit: BoxFit.cover),
              ),
            ),
            Text(item.name, style: Theme.of(context).textTheme.caption),
            Text("\$${item.price}",
                style: Theme.of(context).textTheme.bodyText1),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
              child: StoreConnector<AppState, AppState>(
                  converter: (store) => store.state,
                  builder: (context, state) {
                    return state.user != null
                        ? IconButton(
                            icon: Icon(Icons.shopping_cart),
                            color: _isInCart(state, item.id)
                                ? Colors.cyan[700]
                                : Colors.white,
                            onPressed: () {
                              StoreProvider.of<AppState>(context)
                                  .dispatch(toggleCartProductAction(item));
                              final snackBar = SnackBar(
                                  duration: Duration(seconds: 2),
                                  content: Text(
                                    "Cart updated",
                                  ));
                              _scaffoldKey.currentState.showSnackBar(snackBar);
                            },
                          )
                        : Text("");
                  }),
            ),
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 5),
                  child: Text(item.description ?? "Not found",
                      style: Theme.of(context).textTheme.bodyText1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isInCart(AppState state, String id) {
    final List<Product> cartProducts = state.cartProducts;
    final index =
        cartProducts.lastIndexWhere((cartProduct) => cartProduct.id == id);
    return index > -1;
  }
}
