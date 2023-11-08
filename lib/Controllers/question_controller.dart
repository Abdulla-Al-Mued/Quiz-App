import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/state_manager.dart';
import 'package:quiz_app/Screens/HomePage.dart';
import 'package:quiz_app/Model/Questions2.dart';
import 'package:quiz_app/Utils/SharedPreferenceUtil.dart';
import 'package:quiz_app/Utils/constants.dart';


class QuestionController extends GetxController
    with GetSingleTickerProviderStateMixin {
  // Lets animated our progress bar

  late AnimationController _animationController;
  late Animation _animation;
  // so that we can access our animation outside
  Animation get animation => this._animation;

  late PageController _pageController;
  PageController get pageController => _pageController;


  final List<Question2> _questions2 = sample_data2
      .map(
        (question) => Question2(
        score: question['score'],
        question: question['question'],
        correctAnswer: question['correctAnswer'],
        options: question['answers']),
  )
      .toList();
  List<Question2> get questions2 => _questions2;

  bool _isAnswered = false;
  bool get isAnswered => _isAnswered;

  late int _correctAns;
  int get correctAns => _correctAns;

  late int _totalScore = 0;
  int get totalScore => _totalScore;

  late int _selectedAns;
  int get selectedAns => _selectedAns;

  // for more about obs please check documentation
  final RxInt _questionNumber = 1.obs;
  RxInt get questionNumber => _questionNumber;

  int _numOfCorrectAns = 0;
  int get numOfCorrectAns => _numOfCorrectAns;

  // called immediately after the widget is allocated memory
  @override
  void onInit() {
    // Our animation duration is 60 s
    // so our plan is to fill the progress bar within 60s
    _animationController =
        AnimationController(duration: const Duration(seconds: 6), vsync: this);
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController)
      ..addListener(() {
        // update like setState
        update();
      });

    // start animation
    _animationController.forward().whenComplete(nextQuestion);
    _pageController = PageController();
    super.onInit();
  }

  @override
  void onClose() {
    super.onClose();
    _animationController.dispose();
    _pageController.dispose();
  }

  void checkAns(Question2 question, int selectedIndex) {
    // because once user press any option then it will run
    _isAnswered = true;
    _correctAns = getIntByChar(question.correctAnswer);
    _selectedAns = selectedIndex;

    if (_correctAns == _selectedAns){
      _numOfCorrectAns++;
      _totalScore += question.score;
    }

    // It will stop the counter
    _animationController.stop();
    update();

    // Once user select an ans after 3s it will go to the next qn
    Future.delayed(Duration(seconds: 3), () {
      nextQuestion();
    });
  }

  Future<void> nextQuestion() async {
    if (_questionNumber.value != _questions2.length) {
      _isAnswered = false;
      _pageController.nextPage(
          duration: const Duration(milliseconds: 250), curve: Curves.ease);

      // Reset the counter
      _animationController.reset();

      // Then start it again
      // Once timer is finish go to the next qn
      _animationController.forward().whenComplete(nextQuestion);
    } else {

      int temp = await getScoreData();

      if(_totalScore > temp) {
        SharedPref.saveIntData(score, _totalScore);
      }
      print("score ");
      print(_totalScore);

      Get.offAll(
          const HomePage(),
        predicate: (route) => false,
      );

    }
  }

  Future<int> getScoreData() async {

    int? _score = await SharedPref.getIntData(score);

    int totalScore = 0;

    print(_score.toString());

    if (_score != null) {

      totalScore = _score;

    }
    print(totalScore);

    return totalScore;

  }

  void updateTheQnNum(int index) {
    _questionNumber.value = index + 1;
  }

  int getIntByChar(String option){

    int item = 1;

    if(option == "A"){
      item = 1;
    }
    if(option == "B"){
      item = 2;
    }
    if(option == "B"){
      item = 3;
    }
    if(option == "C"){
      item = 4;
    }

    return item;
  }

}
