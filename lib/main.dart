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
  String _result = '';
  DatabaseReference _userRef;
  DatabaseReference _usersRef;
  DatabaseReference _gamesRef;
  DatabaseReference _gameRef;
  String _userId;
  bool _inGame = false;

  @override
  void initState() {
    super.initState();
    _userId = FirebaseDatabase.instance.reference().push().key;
    _userRef = FirebaseDatabase.instance.reference().child('/users/$_userId');
    _usersRef = FirebaseDatabase.instance.reference().child('/users');
    _gamesRef = FirebaseDatabase.instance.reference().child('/games');
    _userRef.set({
      'username': widget.username,
      'online': true,
      'inGame': false,
      'turn': false
    });
    _userRef.onValue.listen((event) {
      setState(() {
        _inGame = event.snapshot.value['inGame'] as bool;
        var gameId = event.snapshot.value['gameId'];
        if (gameId != null) {
          _gameRef =
              FirebaseDatabase.instance.reference().child('/games/$gameId');
        }
      });
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

  void checkWinner(int index) {
    if (models[index].mark == TicTacToeMark.Empty) {
      var numberOfCrosses =
          models.where((element) => element.mark == TicTacToeMark.Cross).length;
      var numberOfCircles = models
          .where((element) => element.mark == TicTacToeMark.Circle)
          .length;
      setState(() {
        if (numberOfCrosses > numberOfCircles) {
          // models[index].mark = TicTacToeMark.Circle;
          _gameRef.push().set({'symbol': 'circle', 'userId': _userId});
        } else {
          _gameRef.push().set({'symbol': 'cross', 'userId': _userId});
          // models[index].mark = TicTacToeMark.Cross;
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

  void startGame(String player1, String player2) {
    var gameKey = FirebaseDatabase.instance.reference().push().key;
    _usersRef.child(player1).update({'inGame': true, 'gameId': gameKey});
    _usersRef.child(player2).update({'inGame': true, 'gameId': gameKey});
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
            ),
            AspectRatio(
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
                          models[index], checkWinner, _inGame);
                    }),
              ),
            ),
          ],
        ), // This trailing comma makes auto-formatting nicer for build methods.
      ),
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
  final bool inGame;

  TicTacToeMarkWidget(this.model, this.callBack, this.inGame);

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
          if (model.enabled && widget.inGame) {widget.callBack(model.index)}
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
