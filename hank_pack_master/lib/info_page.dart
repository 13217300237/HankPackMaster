import 'package:flutter/material.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key, required this.content});

  final List<String> content;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemBuilder: (context, i) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            content[i],
            style: const TextStyle(fontSize: 16),
          ),
        );
      },
      itemCount: content.length,
    );
  }
}
