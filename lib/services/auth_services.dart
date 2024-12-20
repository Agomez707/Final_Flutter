import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthServices 
{
  //Gooogle Sign In
  signInGoogle() async
  {
    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

    //controlar cancelacion
    if(gUser == null) return;
    //
    final GoogleSignInAuthentication gAuth = await gUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken,
    );

    return await FirebaseAuth.instance.signInWithCredential(credential);

  }


}