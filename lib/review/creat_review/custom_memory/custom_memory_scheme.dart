import 'package:flutter/material.dart';

class CustomMemoryScheme extends StatefulWidget {
  const CustomMemoryScheme({super.key});

  @override
  State<CustomMemoryScheme> createState() => _CustomMemoryScheme();
}

class _CustomMemoryScheme extends State<CustomMemoryScheme> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
             backgroundColor: Colors.white,
      leading: GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
        },
        child: const Icon(Icons.arrow_back),
      ),
        title: const Text(
          '自定义记忆方案',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
        ),
      ),
      body: const Center(
        child: Text('自定义记忆方案'),
      ),
    );
  }
}
