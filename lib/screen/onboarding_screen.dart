import 'package:flutter/material.dart';
import 'package:twitch_clone/screen/login_screen.dart';
import 'package:twitch_clone/screen/sign_up_screen.dart';
import 'package:twitch_clone/widgets/custom_button.dart';

class OnboardingScreen extends StatelessWidget {
  static const routeName = '/onboarding';
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            const Text("Welcome to \n Twitch",style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 40
            ),
            textAlign: TextAlign.center,),
             const SizedBox(height: 20,),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: CustomButton(text: "Login",
                    onTap: (){
                       Navigator.pushNamed(context, LoginScreen.routeName);
                    }),
              ),

              CustomButton(text: "Sign Up", onTap: (){
                Navigator.pushNamed(context, SignUpScreen.routeName);
              }),

          ],),
        )
      ),
    );
  }
}
