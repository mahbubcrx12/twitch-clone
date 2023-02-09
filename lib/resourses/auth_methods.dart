import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:twitch_clone/model/user.dart' as model;
import 'package:twitch_clone/provider/user_provider.dart';
import 'package:twitch_clone/utils/utils.dart';
import 'package:provider/provider.dart';


class AuthMethods {
  final _userRef = FirebaseFirestore.instance.collection('users');
  final _auth = FirebaseAuth.instance;

  getCurrentUser(String? uid)async{
    if(uid != null){
      final snap = await _userRef.doc(uid).get();
      return snap.data();
    }
    return null;
  }

 Future<bool> signUpUser(
     BuildContext context,
     String email,
     String username,
     String password,
     ) async {
   bool res = false;
      try{
       UserCredential cred=await _auth.createUserWithEmailAndPassword(email: email, password: password);
       if(cred.user != null){
         model.User user =model.User(
           username: username.trim(),
           email: email.trim(),
           uid: cred.user!.uid,
         );
         await _userRef.doc(cred.user!.uid).set(user.toMap());
         Provider.of<UserProvider>(context,listen: false).setUser(user);
         res = true;
       }
      }on FirebaseAuthException catch(e){
        showSnackBar(context, e.message!);
      }
      return res;
          

  }

  Future<bool> loginUser(
      BuildContext context,
      String email,
      String password,
      ) async {
    bool res = false;
    try{
      UserCredential cred=await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password);
      if(cred.user != null){
        Provider.of<UserProvider>(context,listen: false).setUser(
          model.User.fromMap(
            await getCurrentUser(cred.user!.uid) ?? {},
          )
        );
        res = true;
      }
    }on FirebaseAuthException catch(e){
      showSnackBar(context, e.message!);
    }
    return res;


  }

}