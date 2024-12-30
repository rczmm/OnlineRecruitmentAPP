import 'package:flutter/material.dart';

// 问题数据模型
class Question {
  final String questionText;
  final Map<String, int> options; // 选项和对应的分值

  Question({required this.questionText, required this.options});
}

class PersonalityTestScreen extends StatefulWidget {
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
        options: {'参加社交活动': 1, '独自思考': 0},
      ),
      Question(
        questionText: '你做决定时更倾向于逻辑分析还是情感直觉？',
        options: {'逻辑分析': 1, '情感直觉': 0},
      ),
      Question(
        questionText: '你喜欢按计划行事还是随性而为？',
        options: {'按计划行事': 1, '随性而为': 0},
      ),
      Question(
        questionText: '你更注重实际和细节还是可能性和全局？',
        options: {'实际和细节': 1, '可能性和全局': 0},
      ),
      // 更多问题...
    ];
    setState(() {});
  }

  void _answerQuestion(String selectedOption) {
    int score = _questions[_currentQuestionIndex].options[selectedOption]!;
    // 根据答案更新得分
    if (_currentQuestionIndex == 0) {
      _scores['外向'] = score;
      _scores['内向'] = 1 - score;
    } else if (_currentQuestionIndex == 1) {
      _scores['理性'] = score;
      _scores['感性'] = 1 - score;
    }
    // ...根据其他问题更新其他维度的得分

    setState(() {
      _currentQuestionIndex++;
      if (_currentQuestionIndex >= _questions.length) {
        _showResult();
      }
    });
  }

  void _showResult() {
    // 根据得分判断人格类型
    String personality = '';
    if(_scores['外向']! > _scores['内向']!){
      personality += "外向";
    }else{
      personality += "内向";
    }
    if(_scores['理性']! > _scores['感性']!){
      personality += "理性";
    }else{
      personality += "感性";
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