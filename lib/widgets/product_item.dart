import 'package:ecommerce_clone/model/app_state.dart';
import 'package:ecommerce_clone/model/product.dart';
import 'package:ecommerce_clone/redux/actions.dart';
import 'package:ecommerce_clone/screens/product_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:ecommerce_clone/screens/register_screen.dart';

class ProductItemWidget extends StatelessWidget {
  final Product item;

  ProductItemWidget({this.item});

  @override
  Widget build(BuildContext context) {
    final pictureUrl = "http://$localHost${item.picture['url']}";

    return InkWell(
      onTap: () {
        print("item in products: ${item.description}");
        Navigator.of(context).push(
            MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(item: item)
            )
        );
      },
      child: GridTile(
        footer: GridTileBar(
          title: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              item.name,
              style: TextStyle(fontSize: 20),
            ),
          ),
          subtitle: Text("\$${item.price}", style: TextStyle(fontSize: 16)),
          backgroundColor: Color(0xBB000000),
          trailing: StoreConnector<AppState, AppState>(
              converter: (store) => store.state,
              builder: (context, state) {
                return state.user != null
                    ? IconButton(
                        icon: Icon(Icons.shopping_cart),
                        color: _isInCart(state, item.id) ? Colors.cyan[700] : Colors.white,
                        onPressed: () {
                          StoreProvider.of<AppState>(context).dispatch(toggleCartProductAction(item));
                        },
                      )
                    : Text("");
              }),
        ),
        child: Hero(
            tag: item, child: Image.network(pictureUrl, fit: BoxFit.cover)
        ),
      ),
    );
  }

  bool _isInCart(AppState state, String id) {
    final List<Product> cartProducts = state.cartProducts;
    final index = cartProducts.lastIndexWhere((cartProduct) => cartProduct.id == id);
    return index > -1;
  }

}
