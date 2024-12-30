import 'package:flutter/material.dart';

class GreetingPage extends StatefulWidget {
  const GreetingPage({super.key});

  @override
  State<GreetingPage> createState() => _GreetingPageState();
}

class _GreetingPageState extends State<GreetingPage>
    with TickerProviderStateMixin {
  bool autoSend = true;
  String customGreeting = '你好';
  late TabController _tabController; // TabController 用于控制标签切换
  final Map<String, List<String>> greetings = {
    '自定义': ['你好'],
    '常规': ['您好！', '很高兴认识您。', '有什么可以帮您的吗？'],
    '幽默': ['哟，来了老弟！', '今天也要开心哦！', '世界那么大，一起去看看？'],
    '礼貌': ['早上好/下午好/晚上好！', '感谢您的光临。', '期待与您合作。'],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: greetings.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _editCustomGreeting() {
    showDialog(
      context: context,
      builder: (context) {
        String editedGreeting = customGreeting;
        return AlertDialog(
          title: const Text('编辑自定义招呼语'),
          content: TextField(
            onChanged: (value) => editedGreeting = value,
            controller: TextEditingController(text: customGreeting),
            decoration: const InputDecoration(hintText: '输入自定义招呼语'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  customGreeting = editedGreeting;
                  greetings['自定义'] = [customGreeting];
                  // 如果当前是自定义Tab，需要刷新UI
                  if (_tabController.index == 0) {
                    _tabController.index = 0; // 强制刷新
                  }
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
        title: const Text('招呼语'),
      ),
      body: Column(
        children: [
          Card(
            child: SwitchListTile(
              title: const Text('沟通时自动发送'),
              value: autoSend,
              onChanged: (value) {
                setState(() {
                  autoSend = value;
                });
              },
            ),
          ),
          Expanded(
            child: Row(
              children: [
                NavigationRail( // 左侧导航栏
                  selectedIndex: _tabController.index,
                  onDestinationSelected: (int index) {
                    setState(() {
                      _tabController.index = index;
                    });
                  },
                  labelType: NavigationRailLabelType.all,
                  destinations: greetings.keys.map((label) =>
                      NavigationRailDestination(
                        icon: const Icon(Icons.label_outline),
                        selectedIcon: const Icon(Icons.label),
                        label: Text(label),
                      ),
                  ).toList(),
                ),
                const VerticalDivider(thickness: 1, width: 1), // 分割线
                Expanded( // 右侧内容区域
                  child: TabBarView(
                    controller: _tabController,
                    children: greetings.entries.map((entry) {
                      String label = entry.key;
                      List<String> phraseList = entry.value;
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ListView.builder(
                          itemCount: phraseList.length,
                          itemBuilder: (context, index) {
                            String phrase = phraseList[index];
                            if (label == '自定义') {
                              return Row(
                                children: [
                                  Expanded(child: Text(phrase)),
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: _editCustomGreeting,
                                  ),
                                ],
                              );
                            } else {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Text(phrase),
                              );
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}