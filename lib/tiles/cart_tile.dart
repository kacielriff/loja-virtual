import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_clothing/datas/product_data.dart';
import 'package:flutter_clothing/models/cart_model.dart';

import '../datas/cart_product.dart';

class CartTile extends StatelessWidget {
  const CartTile({Key? key, required this.cartProduct}) : super(key: key);

  final CartProduct cartProduct;

  @override
  Widget build(BuildContext context) {

    Widget _buildContent() {
      CartModel.of(context).updatePrices();

      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            width: 120,
            child: Image.network(cartProduct.productData!.images[0], fit: BoxFit.cover,),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    cartProduct.productData!.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Tamanho: ${cartProduct!.size}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  Text(
                    'R\$ ${cartProduct.productData!.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: cartProduct.quantity! > 1
                            ? () => CartModel.of(context).decProduct(cartProduct)
                            : null,
                        icon: Icon(
                          Icons.remove,
                          color: cartProduct.quantity! > 1
                              ? Theme.of(context).primaryColor
                              : Colors.grey.shade500,
                        ),
                      ),
                      Text(
                        cartProduct.quantity.toString(),
                      ),
                      IconButton(
                        onPressed: () => CartModel.of(context).incProduct(cartProduct),
                        icon: Icon(Icons.add, color: Theme.of(context).primaryColor,),
                      ),
                      TextButton(
                        onPressed: () {
                          CartModel.of(context).removerCartItem(cartProduct);
                        },
                        child: Text(
                          'Remover',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: cartProduct.productData == null ?
        FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('products')
              .doc(cartProduct.category)
              .collection('items')
              .doc(cartProduct.pid)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              cartProduct.productData = ProductData.fromDocument(snapshot.data!);
              return _buildContent();
            } else {
              return Container(
                height: 70,
                alignment: Alignment.center,
                child: const CircularProgressIndicator(),
              );
            }
          },
        ) :
          _buildContent(),
    );
  }
}
