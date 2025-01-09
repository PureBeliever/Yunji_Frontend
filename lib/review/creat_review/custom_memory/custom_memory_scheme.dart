import 'package:flutter/material.dart';

class CustomMemoryScheme extends StatefulWidget {
  const CustomMemoryScheme({super.key});

  @override
  State<CustomMemoryScheme> createState() => _CustomMemoryScheme();
}

class _CustomMemoryScheme extends State<CustomMemoryScheme> {
  List<String> _textList = ['本次学习后'];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
      body: ListView.builder(
        itemCount: _textList.length + 1,
        itemBuilder: (context, index) {
          if (index == _textList.length) {
            return Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.only(left: 80, right: 80),
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Color.fromRGBO(84, 87, 105, 1)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    _textList.add('2024-01-09 进行第${_textList.length + 1}次复习');
                  });
                },
                child: const Icon(
                  Icons.add,
                  color: Color.fromRGBO(84, 87, 105, 1),
                ),
              ),
            );
          } else {
            return AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(seconds: 1),
              child: ListTile(
           
                title: Text(_textList[index]),
                titleTextStyle: const TextStyle(
                  fontSize: 17,
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
