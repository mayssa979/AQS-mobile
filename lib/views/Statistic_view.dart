import 'package:aqs/Colors.dart';
import 'package:flutter/material.dart';

class StatPage extends StatelessWidget {
  const StatPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      padding: const EdgeInsets.all(20.0), // Adjust padding as needed
      child: Text(
        'Statistics',
        style: TextStyle(
          fontSize: 18,
          color: AppColors.actiaGreen,
        ),
      ),
    );
  }
}
