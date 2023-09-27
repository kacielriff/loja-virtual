import 'package:flutter/material.dart';
import 'package:flutter_clothing/models/cart_model.dart';
import 'package:flutter_clothing/screens/login_screen.dart';
import 'package:flutter_clothing/screens/order_screen.dart';
import 'package:flutter_clothing/widgets/discount_card.dart';
import 'package:flutter_clothing/widgets/ship_card.dart';
import 'package:scoped_model/scoped_model.dart';

import '../models/user_model.dart';
import '../tiles/cart_tile.dart';
import '../widgets/cart_price.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Carrinho'),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          Container(
            padding: const EdgeInsets.only(right: 8),
            alignment: Alignment.center,
            child: ScopedModelDescendant<CartModel>(
              builder: (context, child, model) {
                int quantityProducts = model.products.length;
                return Text(
                  "${quantityProducts ?? 0} ${quantityProducts == 1 ? 'ITEM' : 'ITENS'}",
                  style: const TextStyle(
                    fontSize: 17,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: ScopedModelDescendant<CartModel>(
        builder: (context, child, model) {
          if (model.isLoading && UserModel.of(context).isLoggedIn()) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (!UserModel.of(context).isLoggedIn()) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.remove_shopping_cart,
                    size: 100,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  const Text(
                    'Faça login para adicionar produtos!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const LoginScreen()));
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor),
                      child: const Text(
                        'ENTRAR',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else if (model.products.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum produto no carrinho!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            );
          } else {
            return ListView(
              children: [
                Column(
                  children: model.products.map((e) {
                    return CartTile(
                      cartProduct: e,
                    );
                  }).toList(),
                ),
                const DiscountCard(),
                const ShipCard(),
                CartPrice(
                  buy: () async {
                    String? orderId = await model.finishOrder();
                    if (orderId != null) {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => OrderScreen(orderID: orderId)));
                    }
                  },
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
