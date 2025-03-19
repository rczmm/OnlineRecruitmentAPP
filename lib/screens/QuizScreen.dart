import 'package:flutter/material.dart';

// 题目数据模型
class Question {
  final String questionText;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation; // 答案解析

  Question({
    required this.questionText,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
  });
}

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  List<Question> _questions = []; // 存储题目

  @override
  void initState() {
    super.initState();
    _loadQuestions(); // 加载题目
  }

  // 模拟加载题目，实际应用中应从本地/网络加载
  Future<void> _loadQuestions() async {
    // 示例题目数据
    _questions = [
      Question(
        questionText: 'Flutter使用什么语言开发？',
        options: ['Java', 'C++', 'Dart', 'Kotlin'],
        correctAnswerIndex: 2,
        explanation: 'Flutter使用Dart语言开发。',
      ),
      Question(
        questionText: 'Widget在Flutter中是什么？',
        options: ['组件', '布局', '状态', '渲染对象'],
        correctAnswerIndex: 0,
        explanation: 'Widget是Flutter中的基本UI组件。',
      ),
      // 更多题目...
      Question(
        questionText: 'Flutter的渲染引擎是什么？',
        options: ['Skia', 'Blink', 'WebKit', 'Gecko'],
        correctAnswerIndex: 0,
        explanation: 'Flutter使用Skia作为其渲染引擎。',
      ),
      Question(
        questionText: 'Flutter中StatefulWidget和StatelessWidget的区别？',
        options: ['前者有状态，后者无状态', '前者无状态，后者有状态', '没有区别', '前者用于静态UI，后者用于动态UI'],
        correctAnswerIndex: 0,
        explanation: 'StatefulWidget拥有可变状态，而StatelessWidget没有。',
      ),
    ];
    setState(() {});
  }

  void _answerQuestion(int selectedIndex) {
    if (selectedIndex == _questions[_currentQuestionIndex].correctAnswerIndex) {
      setState(() {
        _score++;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("回答正确"),
        backgroundColor: Colors.green,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("回答错误"),
        backgroundColor: Colors.red,
      ));
    }
    setState(() {
      _currentQuestionIndex++;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Center(child: CircularProgressIndicator()); // 加载中
    }
    if (_currentQuestionIndex >= _questions.length) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('测试结束！',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('你答对了 $_score / ${_questions.length} 道题',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _currentQuestionIndex = 0;
                  _score = 0;
                });
              },
              child: Text('重新测试'),
            ),
          ],
        ),
      );
    }
    final currentQuestion = _questions[_currentQuestionIndex];
    return Scaffold(
      appBar: AppBar(title: Text('面试刷题')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '第 ${_currentQuestionIndex + 1} / ${_questions.length} 题',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              currentQuestion.questionText,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ...currentQuestion.options.map((option) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ElevatedButton(
                  onPressed: () =>
                      _answerQuestion(currentQuestion.options.indexOf(option)),
                  child: Text(option),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
