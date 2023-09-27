import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:scoped_model/scoped_model.dart';

class UserModel extends Model {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? user;
  Map<String, dynamic> userData = {};

  bool isLoading = false;

  static UserModel of(BuildContext context) => ScopedModel.of<UserModel>(context);
  
  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);

    _loadCurrentUser();
  }

  void signUp({required Map<String, dynamic> userData, required String pass, required VoidCallback onSuccess, required VoidCallback onFail}) {
    isLoading = true;
    notifyListeners();

    _auth.createUserWithEmailAndPassword(email: userData['email'], password: pass)
        .then((value) async {
          user = value.user;

          await _saveUserData(userData);

          onSuccess();
          isLoading = false;
          notifyListeners();
        })
        .catchError((e) {
          onFail();
          isLoading = false;
          notifyListeners();
        });
  }

  Future<void> signIn({required String email, required String pass, required VoidCallback onSuccess, required VoidCallback onFail}) async {
    isLoading = true;
    notifyListeners();

    _auth.signInWithEmailAndPassword(email: email, password: pass)
        .then((value) async {
          user = value.user;

          await _loadCurrentUser();

          onSuccess();
          isLoading = false;
          notifyListeners();
        })
        .catchError((e) {
          onFail();
          isLoading = false;
          notifyListeners();
        });
  }

  void signOut() async {
    await _auth.signOut();
    userData = {};
    user = null;
    notifyListeners();
  }

  void recoverPass(String email) {
    _auth.sendPasswordResetEmail(email: email);
  }

  bool isLoggedIn() {
    return user != null;
  }

  Future<Null> _saveUserData(Map<String, dynamic> userData) async {
    this.userData = userData;
    await FirebaseFirestore.instance.collection('users').doc(user!.uid).set(userData);
  }

  Future<Null> _loadCurrentUser() async {
    user = await _auth.currentUser;

    if(user != null) {
      DocumentSnapshot<Map<String, dynamic>> docUser = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
      userData = docUser.data.call()!;
      notifyListeners();
    }
  }
}
