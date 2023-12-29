import 'package:flutter/material.dart';

class InfoPage extends StatelessWidget {
  const InfoPage(
      {super.key, required this.content, required this.scrollController});

  final List<String> content;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(40),
      itemBuilder: (context, i) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: SelectableText(
            content[i],
            style: const TextStyle(fontSize: 16),
          ),
        );
      },
      itemCount: content.length,
    );
  }
}
