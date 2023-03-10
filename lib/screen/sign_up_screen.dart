import 'package:flutter/material.dart';
import 'package:twitch_clone/screen/home_screen.dart';
import 'package:twitch_clone/widgets/custom_button.dart';
import 'package:twitch_clone/widgets/custom_text_field.dart';
import 'package:twitch_clone/widgets/loading_indicator.dart';

import '../resources/auth_methods.dart';

class SignUpScreen extends StatefulWidget {
  static const String routeName = '/signUp';
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final AuthMethods _authMethods = AuthMethods();
  bool _isLoading = false;

  void signUpUser()async {
    setState(() {
      _isLoading = true;
    });
    bool res = await _authMethods.signUpUser(
        context,
        _emailController.text,
        _userNameController.text,
        _passwordController.text
    );
    setState(() {
      _isLoading = false;
    });
    if(res){
      Navigator.pushReplacementNamed(context, HomeScreen.routeName);
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _emailController.dispose();
    _userNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign Up"),
        centerTitle: true,
      ),
      body: _isLoading
          ? LoadingIndicator()
          :SingleChildScrollView(
        child: Padding(padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: size.height * 0.1,),
            const Text('Email',style: TextStyle(
              fontWeight: FontWeight.bold
            ),),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: CustomTextField(controller: _emailController),
            ),
            const SizedBox(height: 20,),
            const Text('User Name',style: TextStyle(
                fontWeight: FontWeight.bold
            ),),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: CustomTextField(controller: _userNameController),
            ),
            const SizedBox(height: 20,),
            const Text('Password',style: TextStyle(
                fontWeight: FontWeight.bold
            ),),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: CustomTextField(controller: _passwordController),
            ),
            const SizedBox(height: 20,),

            CustomButton(text: 'Sign Up', onTap: signUpUser)

          ],
        ),
        ),
      ),
    );
  }
}
