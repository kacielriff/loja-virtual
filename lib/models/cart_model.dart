import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_clothing/models/user_model.dart';
import 'package:scoped_model/scoped_model.dart';

import '../datas/cart_product.dart';

class CartModel extends Model {
  CartModel({required this.user}) {
    if (user.isLoggedIn()) {
      _loadCartItems();
    }
  }

  UserModel user;
  List<CartProduct> products = [];

  String? couponCode;
  int discountPercentage = 0;

  bool isLoading = false;

  static CartModel of(BuildContext context) =>
      ScopedModel.of<CartModel>(context);

  void addCartItem(CartProduct cartProduct) {
    products.add(cartProduct);

    FirebaseFirestore.instance
        .collection('users')
        .doc(user.user!.uid)
        .collection('cart')
        .add(cartProduct.toMap())
        .then((value) => cartProduct.cid = value.id);

    notifyListeners();
  }

  void removerCartItem(CartProduct cartProduct) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(user.user!.uid)
        .collection('cart')
        .doc(cartProduct.cid)
        .delete();

    products.remove(cartProduct);
    notifyListeners();
  }

  void incProduct(CartProduct cartProduct) {
    cartProduct.quantity = cartProduct.quantity! + 1;

    FirebaseFirestore.instance
        .collection('users')
        .doc(user.user!.uid)
        .collection('cart')
        .doc(cartProduct.cid)
        .update(cartProduct.toMap());

    notifyListeners();
  }

  void decProduct(CartProduct cartProduct) {
    cartProduct.quantity = cartProduct.quantity! - 1;

    FirebaseFirestore.instance
        .collection('users')
        .doc(user.user!.uid)
        .collection('cart')
        .doc(cartProduct.cid)
        .update(cartProduct.toMap());

    notifyListeners();
  }

  void setCoupon(String? couponCode, int discountPercentage) {
    this.couponCode = couponCode;
    this.discountPercentage = discountPercentage;
  }

  double getProductsPrice() {
    double price = 0.0;
    for (CartProduct c in products) {
      if (c.productData != null) {
        price += c.quantity! * c.productData!.price;
      }
    }

    return price;
  }

  void updatePrices() {
    notifyListeners();
  }

  double getDiscount() {
    return getProductsPrice() * discountPercentage / 100;
  }

  double getShipPrice() {
    return 9.90;
  }

  Future<String?> finishOrder() async {
    if (products.isEmpty) return null;

    isLoading = true;
    notifyListeners();

    double productsPrice = getProductsPrice();
    double shipPrice = getShipPrice();
    double discount = getDiscount();

    DocumentReference refOrder = await FirebaseFirestore.instance.collection('orders').add(
        {
          'clienteID': user.user!.uid,
          'products': products.map((e) => e.toMap()).toList(),
          'productsPrice': productsPrice,
          'discount': discount,
          'shipPrice': shipPrice,
          'totalPrice': productsPrice + shipPrice - discount,
          'status': 1,
        }
    );

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.user!.uid)
        .collection('orders')
        .doc(refOrder.id)
        .set(
        {
          'orderID': refOrder.id
        }
    );
    
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.user!.uid)
        .collection('cart')
        .get();

    for (DocumentSnapshot doc in query.docs) {
      doc.reference.delete();
    }

    products.clear();
    couponCode = null;
    discountPercentage = 0;

    isLoading = false;
    notifyListeners();

    return refOrder.id;
  }

  void _loadCartItems() async {
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.user!.uid)
        .collection('cart')
        .get();

    products = query.docs.map((e) => CartProduct.fromDocument(e)).toList();
    notifyListeners();
  }
}
