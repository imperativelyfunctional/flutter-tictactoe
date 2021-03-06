import 'package:flutter/material.dart';

void main() {
  runApp(TicTacToe());
}

class TicTacToe extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TicTacToeWidget(),
    );
  }
}

class TicTacToeWidget extends StatefulWidget {
  @override
  _TicTacToeWidgetState createState() => _TicTacToeWidgetState();
}

class _TicTacToeWidgetState extends State<TicTacToeWidget> {
  String _result = '';
  final List<TicTacToeModel> models = [
    TicTacToeModel(right: BorderSide(), bottom: BorderSide(), index: 0),
    TicTacToeModel(right: BorderSide(), bottom: BorderSide(), index: 1),
    TicTacToeModel(bottom: BorderSide(), index: 2),
    TicTacToeModel(right: BorderSide(), bottom: BorderSide(), index: 3),
    TicTacToeModel(right: BorderSide(), bottom: BorderSide(), index: 4),
    TicTacToeModel(bottom: BorderSide(), index: 5),
    TicTacToeModel(right: BorderSide(), index: 6),
    TicTacToeModel(right: BorderSide(), index: 7),
    TicTacToeModel(right: BorderSide(), index: 8)
  ];

  void checkWinner(int index) {
    if (models[index].mark == TicTacToeMark.Empty) {
      var numberOfCrosses =
          models.where((element) => element.mark == TicTacToeMark.Cross).length;
      var numberOfCircles = models
          .where((element) => element.mark == TicTacToeMark.Circle)
          .length;
      setState(() {
        if (numberOfCrosses > numberOfCircles) {
          models[index].mark = TicTacToeMark.Circle;
        } else {
          models[index].mark = TicTacToeMark.Cross;
        }

        final winningModels = _findWinnerModels();
        if (winningModels.length != 0) {
          models.forEach((element) {
            element.enabled = false;
          });
          winningModels.forEach((element) {
            element.color = Colors.orange.withAlpha(128);
          });
          if (winningModels[0].mark == TicTacToeMark.Circle) {
            _result = 'Circle won the game';
          } else {
            _result = 'Cross won the game';
          }
        }

        if (models
                .where((element) => element.mark == TicTacToeMark.Empty)
                .length ==
            0) {
          setState(() {
            _result = 'There is no winner';
          });
        }
      });
    }
  }

  List<TicTacToeModel> _findWinnerModels() {
    if (models[0].mark == models[1].mark &&
        models[1].mark == models[2].mark &&
        models[0].mark != TicTacToeMark.Empty) {
      return [models[0], models[1], models[2]];
    } else if (models[3].mark == models[4].mark &&
        models[4].mark == models[5].mark &&
        models[3].mark != TicTacToeMark.Empty) {
      return [models[3], models[4], models[5]];
    } else if (models[6].mark == models[7].mark &&
        models[7].mark == models[8].mark &&
        models[6].mark != TicTacToeMark.Empty) {
      return [models[6], models[7], models[8]];
    } else if (models[0].mark == models[3].mark &&
        models[3].mark == models[6].mark &&
        models[0].mark != TicTacToeMark.Empty) {
      return [models[0], models[3], models[6]];
    } else if (models[1].mark == models[4].mark &&
        models[4].mark == models[7].mark &&
        models[1].mark != TicTacToeMark.Empty) {
      return [models[1], models[4], models[7]];
    } else if (models[2].mark == models[5].mark &&
        models[5].mark == models[8].mark &&
        models[2].mark != TicTacToeMark.Empty) {
      return [models[2], models[5], models[8]];
    } else if (models[0].mark == models[4].mark &&
        models[4].mark == models[8].mark &&
        models[0].mark != TicTacToeMark.Empty) {
      return [models[0], models[4], models[8]];
    } else if (models[2].mark == models[4].mark &&
        models[4].mark == models[6].mark &&
        models[2].mark != TicTacToeMark.Empty) {
      return [models[2], models[4], models[6]];
    }
    return [];
  }

  void reset() {
    setState(() {
      models.forEach((element) {
        element.color = Colors.transparent;
        element.mark = TicTacToeMark.Empty;
        element.enabled = true;
        _result = '';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Container(
              alignment: Alignment.center,
              child: Text(
                _result,
                style: TextStyle(
                    color: Colors.purple, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          AspectRatio(
            aspectRatio: 1 / 1,
            child: Container(
              child: GridView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3),
                  itemCount: 9,
                  itemBuilder: (BuildContext context, int index) {
                    return TicTacToeMarkWidget(models[index], checkWinner);
                  }),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              alignment: Alignment.center,
              child: SizedBox(
                height: 40,
                width: 100,
                child: ElevatedButton(
                  onPressed: () => {reset()},
                  child: Text(
                    'Reset',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          )
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

enum TicTacToeMark { Empty, Circle, Cross }

class TicTacToeModel {
  final BorderSide top;
  final BorderSide bottom;
  final BorderSide left;
  final BorderSide right;
  Color color;
  bool enabled;
  TicTacToeMark mark;
  final int index;

  TicTacToeModel(
      {this.top: BorderSide.none,
      this.bottom: BorderSide.none,
      this.left: BorderSide.none,
      this.right: BorderSide.none,
      this.mark: TicTacToeMark.Empty,
      this.color: Colors.transparent,
      this.enabled: true,
      this.index});
}

class TicTacToeMarkWidget extends StatefulWidget {
  final TicTacToeModel model;
  final Function callBack;

  TicTacToeMarkWidget(this.model, this.callBack);

  @override
  _TicTacToeMarkWidgetState createState() {
    return _TicTacToeMarkWidgetState(model, callBack);
  }
}

class _TicTacToeMarkWidgetState extends State<TicTacToeMarkWidget> {
  final TicTacToeModel _model;
  final Function _callBack;

  _TicTacToeMarkWidgetState(this._model, this._callBack);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      padding: EdgeInsets.zero,
      onPressed: () => {
        if (_model.enabled) {_callBack(_model.index)}
      },
      child: AnimatedContainer(
          duration: Duration(seconds: 1),
          decoration: BoxDecoration(
              color: _model.color,
              border: Border(
                  top: _model.top,
                  bottom: _model.bottom,
                  left: _model.left,
                  right: _model.right)),
          child: _model.mark == TicTacToeMark.Empty
              ? Container()
              : (_model.mark == TicTacToeMark.Cross
                  ? Image.asset(
                      'images/cross.png',
                      color: Colors.green,
                    )
                  : Image.asset(
                      'images/circle.png',
                      color: Colors.red,
                    ))),
    );
  }
}
