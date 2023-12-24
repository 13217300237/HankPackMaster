import 'package:flutter/material.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key, required this.content});

  final List<String> content;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemBuilder: (context, i) {
        return Text(content[i]);
      },
      itemCount: content.length,
    );
  }
}
