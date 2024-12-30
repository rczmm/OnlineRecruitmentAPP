import 'package:flutter/material.dart';

class CommonPhrasesPage extends StatefulWidget {
  const CommonPhrasesPage({super.key});

  @override
  State<CommonPhrasesPage> createState() => _CommonPhrasesPageState();
}

class _CommonPhrasesPageState extends State<CommonPhrasesPage> {
  List<String> commonPhrases = [
    '你好，很高兴认识你！',
    '请问有什么可以帮到你的？',
    '稍等一下，我正在处理。',
  ];

  void _addPhrase() {
    showDialog(
      context: context,
      builder: (context) {
        String newPhrase = '';
        return AlertDialog(
          title: const Text('添加常用语'),
          content: TextField(
            onChanged: (value) => newPhrase = value,
            decoration: const InputDecoration(hintText: '输入常用语'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  commonPhrases.add(newPhrase);
                });
                Navigator.pop(context);
              },
              child: const Text('添加'),
            ),
          ],
        );
      },
    );
  }

  void _editPhrase(int index) {
    showDialog(
      context: context,
      builder: (context) {
        String editedPhrase = commonPhrases[index];
        return AlertDialog(
          title: const Text('编辑常用语'),
          content: TextField(
            onChanged: (value) => editedPhrase = value,
            controller: TextEditingController(text: commonPhrases[index]),
            decoration: const InputDecoration(hintText: '输入常用语'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  commonPhrases[index] = editedPhrase;
                });
                Navigator.pop(context);
              },
              child: const Text('保存'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('常用语'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: commonPhrases.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text(commonPhrases[index]),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _editPhrase(index),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _addPhrase,
              child: const Text('添加常用语'),
            ),
          ),
        ],
      ),
    );
  }
}