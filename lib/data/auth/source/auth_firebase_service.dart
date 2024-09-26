import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:ecommerce/data/auth/models/user_creation_req.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthFirebaseService {

  Future<Either> signup(UserCreationReq user);

}

class AuthFirebaseServiceImpl extends AuthFirebaseService {
  
  @override
  Future<Either> signup(UserCreationReq user) async {
    try {

      var returnedData = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: user.email!,
        password: user.password!
      );

      FirebaseFirestore.instance.collection('Users').doc(
        returnedData.user!.uid
      ).set(
        {
          'firstName' : user.firstname,
          'lastName' : user.lastname,
          'email' : user.email,
          'gender' : user.gender,
          'age' : user.age
        }
      );

      return const Right(
        'Sign up was successfully'
      );

    } on FirebaseAuthException catch (e) {
      String message = '';
      
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if(e.code == 'email-already-in-case') {
        message = 'An account already exists with that email.';
      }

      return Left(message);

    }
  }
}