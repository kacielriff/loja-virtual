import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrderTile extends StatelessWidget {
  const OrderTile({Key? key, required this.orderId}) : super(key: key);

  final String orderId;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('orders').doc(orderId).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator(),);
            } else {
                int status = snapshot.data!['status'];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Código do pedido: $orderId',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4,),
                    Text(
                      _buildProductsText(snapshot.data!),
                    ),
                    const SizedBox(height: 4,),
                    const Text(
                      'Status do pedido:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildCircle('1', 'Preparação', status, 1),
                        Container(height: 1, width: 40, color: Colors.grey.shade500,),
                        _buildCircle('2', 'Transporte', status, 2),
                        Container(height: 1, width: 40, color: Colors.grey.shade500,),
                        _buildCircle('3', 'Entrega', status, 3),
                      ],
                    ),
                  ],
                );
            }
          },
        ),
      ),
    );
  }

  String _buildProductsText(DocumentSnapshot snapshot) {
    String text = 'Descrição:\n';

    for(LinkedHashMap p in snapshot.get('products')) {
      text += '${p['quantity']} x ${p['product']['title']} (R\$ ${p['product']['price'].toStringAsFixed(2)})\n';
    }

    text += 'Total: R\$ ${snapshot.get('totalPrice').toStringAsFixed(2)}';
    return text;
  }

  Widget _buildCircle(String title, String subtitle, int status, int thisStatus) {
    Color backColor;
    Widget child;

    if (status < thisStatus) {
      backColor = Colors.grey.shade500;
      child = Text(title, style: const TextStyle(color: Colors.white),);
    } else if (status == thisStatus) {
      backColor = Colors.blueAccent;
      child = Stack(
        alignment: Alignment.center,
        children: [
          Text(title, style: const TextStyle(color: Colors.white),),
          const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white),),
        ],
      );
    } else {
      backColor = Colors.green;
      child = const Icon(Icons.check, color: Colors.white,);
    }

    return Column(
      children: [
        CircleAvatar(radius: 20, backgroundColor: backColor, child: child,),
        Text(subtitle),
      ],
    );
  }
}
