import 'package:ecommerce_clone/model/app_state.dart';
import 'package:ecommerce_clone/redux/actions.dart';
import 'package:ecommerce_clone/redux/reducers.dart';
import 'package:ecommerce_clone/screens/cart_screen.dart';
import 'package:ecommerce_clone/screens/login_screen.dart';
import 'package:ecommerce_clone/screens/products_screen.dart';
import 'package:ecommerce_clone/screens/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final store = Store<AppState>(appReducers, initialState: AppState.initial(), middleware: [thunkMiddleware]);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
      store: store,
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: Colors.cyan[400],
          accentColor: Colors.deepOrange[200],
          textTheme: TextTheme(
            headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
            headline3: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
            caption: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            bodyText1: TextStyle(fontSize: 18.0,)
          )
        ),
        routes: {
          '/': (BuildContext context) => ProductsScreen(
            onInit: () {
            //   // dispatch an action (getUserAction) to grab userData
              StoreProvider.of<AppState>(context).dispatch(getUserAction);
              StoreProvider.of<AppState>(context).dispatch(getProductsAction);
              StoreProvider.of<AppState>(context).dispatch(getCartProductsAction);
              print("oninit called");
            }
          ),
          // '/login': (context) => LoginScreen(),
          // '/register': (context) => RegisterScreen()
          '/cart' : (context) => CartScreen(onInit: () {
            StoreProvider.of<AppState>(context).dispatch(getCardsAction);
            StoreProvider.of<AppState>(context).dispatch(getCardTokenAction);
          })
        },
        // home: RegisterScreen(),
      ),
    );
  }
}

