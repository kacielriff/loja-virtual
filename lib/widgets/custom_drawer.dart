import 'package:flutter/material.dart';
import 'package:flutter_clothing/screens/login_screen.dart';
import 'package:flutter_clothing/tiles/drawer_tile.dart';
import 'package:scoped_model/scoped_model.dart';

import '../models/user_model.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({Key? key, required this.pageController})
      : super(key: key);

  final PageController pageController;

  Widget _buildDrawerBack() => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 203, 236, 241), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Stack(
        children: [
          _buildDrawerBack(),
          ListView(
            padding: const EdgeInsets.only(left: 32, top: 16),
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.fromLTRB(0, 16, 16, 8),
                height: 170,
                child: Stack(
                  children: [
                    const Positioned(
                      top: 8,
                      left: 0,
                      child: Text(
                        "Flutter's\nClothing",
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Positioned(
                        left: 0,
                        bottom: 0,
                        child: ScopedModelDescendant<UserModel>(
                          builder: (context, child, model) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Olá ${!model.isLoggedIn() ? '' : model.userData['name']}",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                GestureDetector(
                                  child: Text(
                                    !model.isLoggedIn()
                                        ? 'Entre ou cadastre-se >'
                                        : 'Sair >',
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onTap: () {
                                    !model.isLoggedIn() ?
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                LoginScreen()))
                                    : model.signOut();
                                  },
                                )
                              ],
                            );
                          },
                        )),
                  ],
                ),
              ),
              const Divider(),
              DrawerTile(
                icon: Icons.home,
                text: 'Início',
                controller: pageController,
                page: 0,
              ),
              DrawerTile(
                  icon: Icons.list,
                  text: 'Produtos',
                  controller: pageController,
                  page: 1),
              DrawerTile(
                  icon: Icons.location_on,
                  text: 'Encontre uma Loja',
                  controller: pageController,
                  page: 2),
              DrawerTile(
                  icon: Icons.playlist_add_check,
                  text: 'Meus Pedidos',
                  controller: pageController,
                  page: 3),
            ],
          ),
        ],
      ),
    );
  }
}
