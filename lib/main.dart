import 'dart:io';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: 'testing',
    options: Platform.isIOS
        ? FirebaseOptions(
            appId: '1:1017907057034:android:8c6da6dd809458bedd3873',
            apiKey:
                'AAAA7P_9EYo:APA91bHYWiQcr8IT4C52L7vVU3zmhsCkuTokaUPXq3pdgWvNeiTouF4tQvqUo3iO9GoVlqo-of-_cabAYJFl69G8oyhsC2AHhjma5JIecjTgFyOQNWCTJ8H2QeOrxZa4-SW5nfWFVec4',
            projectId: 'tictactoe-2bae4',
            messagingSenderId: '1017907057034',
            databaseURL: 'https://tictactoe-2bae4-default-rtdb.firebaseio.com',
          )
        : FirebaseOptions(
            appId: '1:1017907057034:android:8c6da6dd809458bedd3873',
            apiKey:
                'AAAA7P_9EYo:APA91bHYWiQcr8IT4C52L7vVU3zmhsCkuTokaUPXq3pdgWvNeiTouF4tQvqUo3iO9GoVlqo-of-_cabAYJFl69G8oyhsC2AHhjma5JIecjTgFyOQNWCTJ8H2QeOrxZa4-SW5nfWFVec4',
            messagingSenderId: '1017907057034',
            projectId: 'tictactoe-2bae4',
            databaseURL: 'https://tictactoe-2bae4-default-rtdb.firebaseio.com',
          ),
  );
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Tic Tac Toe',
    home: TicTacToe(),
  ));
}

class TicTacToe extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return HomeWidget();
  }
}

class HomeWidget extends StatefulWidget {
  @override
  _HomeWidgetState createState() {
    return _HomeWidgetState();
  }
}

class _HomeWidgetState extends State<HomeWidget> {
  bool _enabled = false;
  String _username;

  void enableButton(String value) {
    setState(() {
      _enabled = value.trim().isNotEmpty;
      if (_enabled) {
        _username = value.trim();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ColorizeAnimatedTextKit(
                  text: [
                    "Tic Tac Toe",
                  ],
                  textStyle:
                      TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold),
                  colors: [
                    Colors.blueGrey,
                    Colors.purple,
                    Colors.yellow,
                    Colors.red,
                    Colors.orange
                  ],
                  textAlign: TextAlign.start,
                  repeatForever: true,
                )
              ],
            ),
            SizedBox(
              height: 20,
            ),
            SizedBox(
              width: 200,
              child: Card(
                elevation: 3,
                child: TextFormField(
                  onChanged: (String value) => {enableButton(value)},
                  autofocus: false,
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(left: 20),
                      disabledBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      hintText: 'Enter a name',
                      hintStyle: TextStyle(color: Colors.grey)),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: _enabled
                  ? () => {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TicTacToeWidget(_username),
                            ))
                      }
                  : null,
              child: Text('Enter'),
            )
          ],
        ),
      ),
    );
  }
}

class TicTacToeWidget extends StatefulWidget {
  final String username;

  TicTacToeWidget(this.username);

  @override
  _TicTacToeWidgetState createState() => _TicTacToeWidgetState();
}

class _TicTacToeWidgetState extends State<TicTacToeWidget> {
  String _instruction = '';
  DatabaseReference _userRef;
  DatabaseReference _usersRef;
  DatabaseReference _gameRef;
  String _userId;
  String _opponentId;
  String _gameId;
  bool _turn = false;
  List board = [];
  TicTacToeMark _mark = TicTacToeMark.Empty;

  @override
  void initState() {
    super.initState();
    _userId = FirebaseDatabase.instance.reference().push().key;
    _userRef = FirebaseDatabase.instance.reference().child('/users/$_userId');
    _usersRef = FirebaseDatabase.instance.reference().child('/users');
    _userRef.set({
      'username': widget.username,
      'online': true,
      'inGame': false,
      'turn': false
    });
    _userRef.onValue.listen((event) {
      _turn = event.snapshot.value['turn'] as bool;
      _gameId = event.snapshot.value['gameId'];
      _mark = (event.snapshot.value['mark'] as String).mark;
      setState(() {
        if (_mark == TicTacToeMark.Empty) {
          _instruction = 'Please choose a user from the list to start playing';
        } else {
          final sign = _mark == TicTacToeMark.Circle ? 'O' : 'X';
          _instruction = _turn
              ? "You are $sign, it's your turn"
              : 'You are $sign, please wait for the other player';
        }
      });
      if (_gameId != null) {
        listenToGameChanges(
            FirebaseDatabase.instance.reference().child('/games/$_gameId'));
      }
    });
    FirebaseDatabase.instance
        .reference()
        .child('.info/connected')
        .onValue
        .listen((Event event) {
      _userRef
          .onDisconnect()
          .update({'online': false, 'inGame': false}).then((value) => null);
    });
  }

  void listenToGameChanges(DatabaseReference game) {
    _gameRef = game;
    _gameRef.onValue.listen((event) {
      var game = event.snapshot.value;
      if (game != null) {
        _opponentId =
            (game['player1'] == _userId) ? game['player2'] : game['player1'];
      }
      setState(() {
        List<dynamic> data = (game == null) ? null : game['moves'];
        if (data == null) {
          final sign = _mark == TicTacToeMark.Circle ? 'O' : 'X';
          _instruction = _turn
              ? "You are $sign, it's your turn"
              : 'You are $sign, please wait for the other player';
          board.clear();
          models.forEach((element) {
            element.color = Colors.transparent;
            element.mark = TicTacToeMark.Empty;
            element.enabled = true;
          });
        } else {
          data.forEach((element) {
            board.add(element);
          });
          for (var i = 0; i < board.length; i++) {
            var model = models[board[i]['index']];
            model.enabled = false;
            var symbol = board[i]['symbol'];
            model.mark = (symbol == 'cross')
                ? TicTacToeMark.Cross
                : TicTacToeMark.Circle;
          }
        }
        final winningModels = _findWinnerModels();
        if (winningModels.length != 0) {
          models.forEach((element) {
            element.enabled = false;
          });
          winningModels.forEach((element) {
            element.color = Colors.orange.withAlpha(128);
          });
          final sign = _mark == TicTacToeMark.Circle ? 'O' : 'X';
          var wonGameMessage = 'You are $sign and won the game!';
          var lostGameMessage = 'You are $sign and lost the game!';
          if (winningModels[0].mark == TicTacToeMark.Circle) {
            if (_mark == TicTacToeMark.Circle) {
              _instruction = wonGameMessage;
            } else {
              _instruction = lostGameMessage;
            }
          } else {
            if (_mark == TicTacToeMark.Cross) {
              _instruction = wonGameMessage;
            } else {
              _instruction = lostGameMessage;
            }
          }
        }

        if (models
                .where((element) => element.mark == TicTacToeMark.Empty)
                .length ==
            0) {
          setState(() {
            _instruction = 'There is no winner';
          });
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  final List<TicTacToeModel> models = [
    TicTacToeModel(right: BorderSide(), bottom: BorderSide(), index: 0),
    TicTacToeModel(right: BorderSide(), bottom: BorderSide(), index: 1),
    TicTacToeModel(bottom: BorderSide(), index: 2),
    TicTacToeModel(right: BorderSide(), bottom: BorderSide(), index: 3),
    TicTacToeModel(right: BorderSide(), bottom: BorderSide(), index: 4),
    TicTacToeModel(bottom: BorderSide(), index: 5),
    TicTacToeModel(right: BorderSide(), index: 6),
    TicTacToeModel(right: BorderSide(), index: 7),
    TicTacToeModel(index: 8)
  ];

  void checkWinner(int index) async {
    if (models[index].mark == TicTacToeMark.Empty) {
      var numberOfCrosses =
          models.where((element) => element.mark == TicTacToeMark.Cross).length;
      var numberOfCircles = models
          .where((element) => element.mark == TicTacToeMark.Circle)
          .length;

      if (numberOfCrosses > numberOfCircles) {
        board.add({'symbol': 'circle', 'userId': _userId, 'index': index});
      } else {
        board.add({'symbol': 'cross', 'userId': _userId, 'index': index});
      }
      await _gameRef.update({'moves': board});
      if (_turn) {
        _usersRef
            .child(_userId)
            .update({'inGame': true, 'gameId': _gameId, 'turn': false});
        _usersRef
            .child(_opponentId)
            .update({'inGame': true, 'gameId': _gameId, 'turn': true});
      } else {
        _usersRef
            .child(_userId)
            .update({'inGame': true, 'gameId': _gameId, 'turn': true});
        _usersRef
            .child(_opponentId)
            .update({'inGame': true, 'gameId': _gameId, 'turn': false});
      }
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

  void reset() async {
    await startGame(_opponentId, _userId);
  }

  Future<void> startGame(String player1, String player2) async {
    var gameKey = FirebaseDatabase.instance.reference().push().key;
    await _usersRef
        .child(player1)
        .update({'inGame': true, 'gameId': gameKey, 'turn': true, 'mark': 'x'});
    await _usersRef.child(player2).update(
        {'inGame': true, 'gameId': gameKey, 'turn': false, 'mark': 'o'});
    await _gameRef.set({'player1': player1, 'player2': player2, 'moves': []});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Container(
                alignment: Alignment.center,
                child: FirebaseAnimatedList(
                  query: _usersRef.orderByChild('online').equalTo(true),
                  itemBuilder: (BuildContext context, DataSnapshot snapshot,
                      Animation<double> animation, int index) {
                    var userKey = snapshot.key;
                    return SizeTransition(
                      sizeFactor: animation,
                      child: ListTile(
                        enabled:
                            userKey != _userId && !snapshot.value['inGame'],
                        onTap: () => {startGame(userKey, _userId)},
                        title: Text(
                          "${snapshot.value['username']}",
                        ),
                        trailing: Icon(
                          Icons.online_prediction,
                          color: snapshot.value['inGame']
                              ? Colors.amber
                              : Colors.green,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Text(
                      _instruction,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      height: 30,
                      width: 100,
                      child: ElevatedButton(
                        onPressed: () => {reset()},
                        child: Text(
                          'Reset',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: AspectRatio(
                aspectRatio: 1 / 1,
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: GridView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3),
                      itemCount: 9,
                      itemBuilder: (BuildContext context, int index) {
                        return TicTacToeMarkWidget(
                            models[index], checkWinner, _turn);
                      }),
                ),
              ),
            ),
          ],
        ), // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }
}

enum TicTacToeMark { Empty, Circle, Cross }

extension TicTacTokMarkParser on String {
  TicTacToeMark get mark {
    if (this == null) return TicTacToeMark.Empty;
    if (this.toLowerCase() == 'x') return TicTacToeMark.Cross;
    return TicTacToeMark.Circle;
  }
}

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
  final bool turn;

  TicTacToeMarkWidget(this.model, this.callBack, this.turn);

  @override
  _TicTacToeMarkWidgetState createState() {
    return _TicTacToeMarkWidgetState();
  }
}

class _TicTacToeMarkWidgetState extends State<TicTacToeMarkWidget> {
  @override
  Widget build(BuildContext context) {
    var model = widget.model;
    return MaterialButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        return {
          if (model.enabled && widget.turn) {widget.callBack(model.index)}
        };
      },
      child: AnimatedContainer(
          duration: Duration(seconds: 1),
          decoration: BoxDecoration(
              color: model.color,
              border: Border(
                  top: model.top,
                  bottom: model.bottom,
                  left: model.left,
                  right: model.right)),
          child: model.mark == TicTacToeMark.Empty
              ? Container()
              : (model.mark == TicTacToeMark.Cross
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
