import 'package:aqs/Colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/frame-one-view-model.dart';

class HCHOView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FrameViewModel(),
      child: Consumer<FrameViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.lastFrame == null) {
            return Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Image.asset('assets/Hcho-icon.png', height: 24),
                        SizedBox(width: 8),
                        Text(
                          'HCHO',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.normal,
                              color: AppColors.grey),
                        ),
                      ],
                    ),
                    Text(
                      '${viewModel.lastFrame!.hcho} g/m³',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Divider(color: Colors.grey),
              ],
            ),
          );
        },
      ),
    );
  }
}
