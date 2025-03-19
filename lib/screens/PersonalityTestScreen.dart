import 'package:flutter/material.dart';

// 问题数据模型
class Question {
  final String questionText;
  final Map<String, int> options; // 选项和对应的分值
  final String dimension; // 题目对应的性格维度

  Question(
      {required this.questionText,
      required this.options,
      required this.dimension});
}

class PersonalityTestScreen extends StatefulWidget {
  const PersonalityTestScreen({super.key});

  @override
  _PersonalityTestScreenState createState() => _PersonalityTestScreenState();
}

class _PersonalityTestScreenState extends State<PersonalityTestScreen> {
  int _currentQuestionIndex = 0;
  Map<String, int> _scores = {
    '外向': 0,
    '内向': 0,
    '理性': 0,
    '感性': 0,
  }; // 存储各维度得分

  List<Question> _questions = [];

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  void _loadQuestions() {
    _questions = [
      Question(
        questionText: '你更喜欢参加社交活动还是独自思考？',
        options: {'参加社交活动': 1, '独自思考': 1},
        // 这里可以根据你的实际需求设置分值，例如社交活动对应外向，独自思考对应内向
        dimension: '外向', // 假设选择“参加社交活动”增加“外向”的分数
      ),
      Question(
        questionText: '你做决定时更倾向于逻辑分析还是情感直觉？',
        options: {'逻辑分析': 1, '情感直觉': 1},
        dimension: '理性', // 假设选择“逻辑分析”增加“理性”的分数
      ),
      Question(
        questionText: '你喜欢按计划行事还是随性而为？',
        options: {'按计划行事': 1, '随性而为': 1},
        dimension: '理性', // 假设选择“按计划行事”增加“理性”的分数
      ),
      Question(
        questionText: '你更注重实际和细节还是可能性和全局？',
        options: {'实际和细节': 1, '可能性和全局': 1},
        dimension: '理性', // 假设选择“实际和细节”增加“理性”的分数
      ),
      // 更多问题...
    ];
    setState(() {});
  }

  void _answerQuestion(String selectedOption) {
    int score = _questions[_currentQuestionIndex].options[selectedOption]!;
    String dimension = _questions[_currentQuestionIndex].dimension;

    setState(() {
      // 根据答案更新得分
      if (dimension == '外向') {
        if (selectedOption == '参加社交活动') {
          _scores['外向'] = (_scores['外向'] ?? 0) + score;
          _scores['内向'] = (_scores['内向'] ?? 0) + (1 - score); // 假设是二元对立维度
        } else if (selectedOption == '独自思考') {
          _scores['内向'] = (_scores['内向'] ?? 0) + score;
          _scores['外向'] = (_scores['外向'] ?? 0) + (1 - score);
        }
      } else if (dimension == '理性') {
        if (selectedOption == '逻辑分析' ||
            selectedOption == '按计划行事' ||
            selectedOption == '实际和细节') {
          _scores['理性'] = (_scores['理性'] ?? 0) + score;
          _scores['感性'] = (_scores['感性'] ?? 0) + (1 - score);
        } else if (selectedOption == '情感直觉' ||
            selectedOption == '随性而为' ||
            selectedOption == '可能性和全局') {
          _scores['感性'] = (_scores['感性'] ?? 0) + score;
          _scores['理性'] = (_scores['理性'] ?? 0) + (1 - score);
        }
      }
      // ... 根据其他维度更新其他维度的得分

      _currentQuestionIndex++;
      if (_currentQuestionIndex >= _questions.length) {
        _showResult();
      }
    });
  }

  void _showResult() {
    // 根据得分判断人格类型
    String personality = '';
    if (_scores['外向']! > _scores['内向']!) {
      personality += "外向";
    } else if (_scores['内向']! > _scores['外向']!) {
      personality += "内向";
    } else {
      personality += "不确定 (外向/内向)"; // 可以添加平局处理
    }

    if (_scores['理性']! > _scores['感性']!) {
      personality += "理性";
    } else if (_scores['感性']! > _scores['理性']!) {
      personality += "感性";
    } else {
      personality += "不确定 (理性/感性)"; // 可以添加平局处理
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('测试结果'),
          content: Text('你的人格类型是：$personality'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _currentQuestionIndex = 0;
                  _scores = {
                    '外向': 0,
                    '内向': 0,
                    '理性': 0,
                    '感性': 0,
                  };
                });
              },
              child: Text('重新测试'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Center(child: CircularProgressIndicator()); // 加载中
    }
    if (_currentQuestionIndex >= _questions.length) {
      // 所有问题回答完毕，显示结果
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('测试结束！',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('你的人格类型是：', style: TextStyle(fontSize: 18)),
            Text('',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            // 结果将在 _showResult 方法中显示
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _showResult(), // 点击按钮显示结果对话框
              child: Text('查看结果'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _currentQuestionIndex = 0;
                  _scores = {
                    '外向': 0,
                    '内向': 0,
                    '理性': 0,
                    '感性': 0,
                  };
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
      appBar: AppBar(title: Text('人格测试')),
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
            ...currentQuestion.options.keys.map((option) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ElevatedButton(
                  onPressed: () => _answerQuestion(option),
                  child: Text(option),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
