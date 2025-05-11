import 'package:flutter/material.dart';
import 'package:task_day/core/extensions/extensions.dart';

class PaddingExampleView extends StatelessWidget {
  const PaddingExampleView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Padding Extensions Example')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Example with paddingAll
            Container(
              color: Colors.red,
              child: const Text(
                'No Padding',
              ).paddingAll(16).paddingAll(8), // Can be chained
            ),

            const SizedBox(height: 20),

            // Example with paddingSymmetric
            Container(
              color: Colors.blue,
              child: const Text(
                'Symmetric Padding',
              ).paddingSymmetric(horizontal: 24, vertical: 12),
            ),

            const SizedBox(height: 20),

            // Example with paddingOnly
            Container(
              color: Colors.green,
              child: const Text(
                'Padding Only Left & Bottom',
              ).paddingOnly(left: 30, bottom: 20),
            ),

            const SizedBox(height: 20),

            // Example with paddingHorizontal
            Container(
              color: Colors.amber,
              child: const Text('Horizontal Padding').paddingHorizontal(40),
            ),

            const SizedBox(height: 20),

            // Example with paddingVertical
            Container(
              color: Colors.purple,
              child: const Text('Vertical Padding').paddingVertical(25),
            ),
          ],
        ).paddingAll(16), // Apply padding to the entire column
      ),
    );
  }
}
