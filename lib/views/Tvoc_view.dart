import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/frame-one-view-model.dart';

class TVOCView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FrameViewModel(),
      child: Consumer<FrameViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.lastFrame == null) {
            return Center(child: CircularProgressIndicator());
          }

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('TVOC', style: TextStyle(fontSize: 24)),
              Text('${viewModel.lastFrame!.tvoc}',
                  style: TextStyle(fontSize: 48)),
              Image.asset('assets/Tvoc-icon.png'),
            ],
          );
        },
      ),
    );
  }
}
