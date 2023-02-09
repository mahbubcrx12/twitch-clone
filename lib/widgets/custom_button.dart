import 'package:flutter/material.dart';
import 'package:twitch_clone/utils/colors.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({Key? key,required this.text,required this.onTap}) : super(key: key);
  final String text;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: onTap,
        child: Text(text),
    style: ElevatedButton.styleFrom(
      primary: buttonColor,
      minimumSize: const Size(double.infinity, 40),
    ),
    );
  }
}
