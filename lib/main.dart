import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audio_cache.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Righteous',
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {

  List<MeltdownButton> controlBoard = new List<MeltdownButton>();
  List colorList = [Colors.greenAccent, Colors.amberAccent, Colors.redAccent];
  List textList = ["SAFE", "CAUTION", "DANGER"];
  int timeDifficulty = 0;
  Timer buttonTimer;
  AnimationController controller;
  static AudioCache player = new AudioCache();


  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(vsync: this, duration: Duration(hours: 20));
    controller.forward();
    _fillBoard();
    _update();

  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      body: Center(
        child: Container(
          padding: EdgeInsets.all(30),
          child: Column(
            children: <Widget>[
              AnimatedBuilder(
                  animation: controller,
                  builder: (BuildContext context, Widget child) {
                    return new Text(
                      timerString,
                      style: TextStyle(
                          fontSize: 60,
                          fontFamily: 'Monofett',
                          color: Colors.white),
                    );
                  }),
              Expanded(child: _generateControlBoard()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _generateControlBoard() {
    List<Widget> controlBoardList = new List<Widget>();
    for (int i = 0; i < 12; i++) {
      controlBoardList.add(_generateButton(controlBoard[i]));
    }
    return GridView.count(
        primary: false,
        padding: EdgeInsets.fromLTRB(10, 40, 10, 40),
        crossAxisCount: 3,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
        children: controlBoardList);
  }

  Widget _generateButton(MeltdownButton button) {
    return RaisedButton(
        color: colorList[button.state],
        onPressed: () {
          setState(() {
            player.play("Blip.wav");
            button._decreaseState();
          });
        },
        shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(40.0)));
  }

  _fillBoard() {
    for (int i = 0; i < 12; i++) {
      controlBoard.add(new MeltdownButton());
    }
  }

  _update() {
    buttonTimer = new Timer.periodic(
        Duration(milliseconds: 700), (Timer t) => _updateButtons());
  }

  _updateButtons() {
    timeDifficulty++;
    int checkFailure = 0;
    Random random = new Random();
    setState(() {
      for (int i = 0; i < 12; i++) {
        if (checkFailure >= 6 && buttonTimer.isActive) {
          _gameOver();
        }
        if (controlBoard[i].state > 1) checkFailure++;
        if (((random.nextInt(100))/100) < ((log(timeDifficulty)/10)*.65) && buttonTimer.isActive){
          controlBoard[i]._increaseState();
        }
      }
    });
  }

  _gameOver() {
    player.play("Explosion.wav");
    controller.stop();
    buttonTimer.cancel();
    _resetAllButtonStates();
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text("The Plant Has Had a Meltdown!"),
            content: new Text("Try to keep Danger panels below 6!\n \n Time Lasted: $timerString"),
            actions: <Widget>[
              new FlatButton(
                child: new Text("New Game?"),
                onPressed: () {
                  _resetGame();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  _resetAllButtonStates() {
    controlBoard.forEach((element) => element.state = 0);
  }

  _resetGame() {
    controller.reset();
    controller.forward();
    timeDifficulty = 0;
    _update();
  }

  String get timerString {
    Duration duration = controller.duration * controller.value;
    return '${duration.inMinutes % 60}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}:${(duration.inMilliseconds % 60).toString().padLeft(2, '0')}';
  }
}

class MeltdownButton {
  int state;

  MeltdownButton() {
    state = 0;

  }

  _increaseState() {
    if (state < 2) {
      state++;
    }
  }

  _decreaseState() {
    if (state > 0) {
      state--;
    }
  }
}
