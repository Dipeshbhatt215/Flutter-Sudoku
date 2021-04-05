import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:sudoku/Styles.dart';
import 'package:sudoku/Alerts.dart';
import 'package:sudoku/Sudoku.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sudoku',
      theme: ThemeData(
        primarySwatch: Styles.primaryColor,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new SplashScreen(
      seconds: 2,
      navigateAfterSeconds: AfterSplash(),
      title: new Text(
        '\nSudoku',
        style: new TextStyle(
            fontWeight: FontWeight.bold, fontSize: 25.0, color: Styles.fg),
      ),
      image: new Image.asset('assets/icon/icon_foreground.png'),
      photoSize: 50,
      backgroundColor: Styles.bg,
      loaderColor: Styles.primaryColor,
      loadingText: Text(
        'VarunS2002',
        style: TextStyle(color: Colors.grey),
      ),
    );
  }
}

class AfterSplash extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => AfterSplashState();
}

class AfterSplashState extends State<AfterSplash> {
  bool firstRun = true;
  bool gameOver = false;
  int timesCalled = 0;
  bool isButtonDisabled = false;
  List<List<List<int>>> gameList;
  List<List<int>> game;
  List<List<int>> gameCopy;
  List<List<int>> gameSolved;
  static String currentDifficultyLevel;
  static String currentTheme;
  static String platform;

  @override
  void initState() {
    super.initState();
    getPrefs().whenComplete(() {
      if (currentDifficultyLevel == null) {
        currentDifficultyLevel = 'easy';
        setPrefs('currentDifficultyLevel');
      }
      if (currentTheme == null) {
        currentTheme = 'dark';
        setPrefs('currentTheme');
      }
      newGame(currentDifficultyLevel);
      changeTheme('set');
    });
    if (kIsWeb) {
      platform = 'web-' +
          defaultTargetPlatform
              .toString()
              .replaceFirst("TargetPlatform.", "")
              .toLowerCase();
    } else {
      platform = defaultTargetPlatform
          .toString()
          .replaceFirst("TargetPlatform.", "")
          .toLowerCase();
    }
  }

  Future<void> getPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentDifficultyLevel = prefs.getString('currentDifficultyLevel');
      currentTheme = prefs.getString('currentTheme');
    });
  }

  setPrefs(String property) async {
    final prefs = await SharedPreferences.getInstance();
    if (property == 'currentDifficultyLevel') {
      prefs.setString('currentDifficultyLevel', currentDifficultyLevel);
    } else if (property == 'currentTheme') {
      prefs.setString('currentTheme', currentTheme);
    }
  }

  void changeTheme(String mode) {
    setState(() {
      if (currentTheme == 'light') {
        if (mode == 'switch') {
          Styles.bg = Styles.dark;
          Styles.bg_2 = Styles.grey;
          Styles.fg = Styles.light;
          currentTheme = 'dark';
        } else if (mode == 'set') {
          Styles.bg = Styles.light;
          Styles.bg_2 = Styles.light;
          Styles.fg = Styles.dark;
        }
      } else if (currentTheme == 'dark') {
        if (mode == 'switch') {
          Styles.bg = Styles.light;
          Styles.bg_2 = Styles.light;
          Styles.fg = Styles.dark;
          currentTheme = 'light';
        } else if (mode == 'set') {
          Styles.bg = Styles.dark;
          Styles.bg_2 = Styles.grey;
          Styles.fg = Styles.light;
        }
      }
      setPrefs('currentTheme');
    });
  }

  void checkResult() {
    if (game.toString() == gameSolved.toString()) {
      isButtonDisabled = !isButtonDisabled;
      gameOver = true;
      Timer(Duration(milliseconds: 500), () {
        showAnimatedDialog<void>(
            animationType: DialogTransitionType.fadeScale,
            barrierDismissible: true,
            duration: Duration(milliseconds: 350),
            context: context,
            builder: (_) => AlertGameOver()).whenComplete(() {
          if (AlertGameOver.newGame) {
            newGame();
            AlertGameOver.newGame = false;
          } else if (AlertGameOver.restartGame) {
            restartGame();
            AlertGameOver.restartGame = false;
          }
        });
      });
    }
  }

  static List<List<List<int>>> getNewGame([String difficulty = 'easy']) {
    Sudoku object = new Sudoku(difficulty);
    return [object.newSudoku, object.newSudokuSolved];
  }

  void setGame(int mode, [String difficulty = 'easy']) {
    if (mode == 1) {
      game = new List.generate(9, (i) => [0, 0, 0, 0, 0, 0, 0, 0, 0]);
      gameCopy = Sudoku.copyGrid(game);
      gameSolved = Sudoku.copyGrid(game);
    } else {
      gameList = getNewGame(difficulty);
      game = gameList[0];
      gameCopy = Sudoku.copyGrid(game);
      gameSolved = gameList[1];
    }
  }

  void showSolution() {
    setState(() {
      game = Sudoku.copyGrid(gameSolved);
      isButtonDisabled =
          !isButtonDisabled ? !isButtonDisabled : isButtonDisabled;
      gameOver = true;
    });
  }

  void newGame([String difficulty = 'easy']) {
    setState(() {
      setGame(2, difficulty);
      isButtonDisabled =
          isButtonDisabled ? !isButtonDisabled : isButtonDisabled;
      gameOver = false;
    });
  }

  void restartGame() {
    setState(() {
      game = Sudoku.copyGrid(gameCopy);
      isButtonDisabled =
          isButtonDisabled ? !isButtonDisabled : isButtonDisabled;
      gameOver = false;
    });
  }

  Color buttonColor(int k, int i) {
    Color color;
    if (([0, 1, 2].contains(k) && [3, 4, 5].contains(i)) ||
        ([3, 4, 5].contains(k) && [0, 1, 2, 6, 7, 8].contains(i)) ||
        ([6, 7, 8].contains(k) && [3, 4, 5].contains(i))) {
      if (Styles.bg == Styles.dark) {
        color = Styles.grey;
      } else {
        color = Colors.grey[300];
      }
    } else {
      color = Styles.bg;
    }

    return color;
  }

  double buttonSize() {
    double size = 50;
    if (AfterSplashState.platform.contains('android') ||
        AfterSplashState.platform.contains('ios')) {
      size = 38;
    }
    return size;
  }

  double buttonFontSize() {
    double size = 20;
    if (AfterSplashState.platform.contains('android') ||
        AfterSplashState.platform.contains('ios')) {
      size = 16;
    }
    return size;
  }

  BorderRadiusGeometry buttonEdgeRadius(int k, int i) {
    if (k == 0 && i == 0) {
      return BorderRadius.only(topLeft: Radius.circular(5));
    } else if (k == 0 && i == 8) {
      return BorderRadius.only(topRight: Radius.circular(5));
    } else if (k == 8 && i == 0) {
      return BorderRadius.only(bottomLeft: Radius.circular(5));
    } else if (k == 8 && i == 8) {
      return BorderRadius.only(bottomRight: Radius.circular(5));
    }
    return BorderRadius.circular(0);
  }

  List<SizedBox> createButtons() {
    if (firstRun) {
      setGame(1);
      firstRun = false;
    }
    MaterialColor emptyColor;
    if (gameOver) {
      emptyColor = Styles.primaryColor;
    } else {
      emptyColor = Styles.secondaryColor;
    }
    List<SizedBox> buttonList = new List<SizedBox>.filled(9, null);
    for (var i = 0; i <= 8; i++) {
      var k = timesCalled;
      buttonList[i] = SizedBox(
        width: buttonSize(),
        height: buttonSize(),
        child: TextButton(
          onPressed: isButtonDisabled || gameCopy[k][i] != 0
              ? null
              : () {
                  showAnimatedDialog<void>(
                      animationType: DialogTransitionType.fade,
                      barrierDismissible: true,
                      duration: Duration(milliseconds: 300),
                      context: context,
                      builder: (_) => AlertNumbersState()).whenComplete(() {
                    callback([k, i], AlertNumbersState.number);
                    AlertNumbersState.number = null;
                  });
                },
          style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all<Color>(buttonColor(k, i)),
            foregroundColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
              if (states.contains(MaterialState.disabled)) {
                return gameCopy[k][i] == 0 ? emptyColor : Styles.fg;
              }
              return game[k][i] == 0
                  ? buttonColor(k, i)
                  : Styles.secondaryColor;
            }),
            shape: MaterialStateProperty.all<OutlinedBorder>(
                RoundedRectangleBorder(
              borderRadius: buttonEdgeRadius(k, i),
            )),
            side: MaterialStateProperty.all<BorderSide>(BorderSide(
              color: Styles.fg,
              width: 1,
              style: BorderStyle.solid,
            )),
          ),
          child: Text(
            game[k][i] != 0 ? game[k][i].toString() : ' ',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: buttonFontSize()),
          ),
        ),
      );
    }
    timesCalled++;
    if (timesCalled == 9) {
      timesCalled = 0;
    }
    return buttonList;
  }

  Row oneRow() {
    return Row(
      children: createButtons(),
      mainAxisAlignment: MainAxisAlignment.center,
    );
  }

  List<Row> createRows() {
    List<Row> rowList = new List<Row>.filled(9, null);
    for (var i = 0; i <= 8; i++) {
      rowList[i] = oneRow();
    }
    return rowList;
  }

  void callback(List<int> index, int number) {
    setState(() {
      if (number == null) {
        return;
      }
      game[index[0]][index[1]] = number;
      checkResult();
    });
  }

  showOptionModalSheet(BuildContext context) {
    BuildContext outerContext = context;
    showModalBottomSheet(
        context: context,
        backgroundColor: Styles.bg_2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(10),
          ),
        ),
        builder: (context) {
          final TextStyle customStyle =
              TextStyle(inherit: false, color: Styles.fg);
          return Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.refresh, color: Styles.fg),
                title: Text('Restart Game', style: customStyle),
                onTap: () {
                  Navigator.pop(context);
                  Timer(Duration(milliseconds: 200), () => restartGame());
                },
              ),
              ListTile(
                leading: Icon(Icons.add_rounded, color: Styles.fg),
                title: Text('New Game', style: customStyle),
                onTap: () {
                  Navigator.pop(context);
                  Timer(Duration(milliseconds: 200),
                      () => newGame(currentDifficultyLevel));
                },
              ),
              ListTile(
                leading:
                    Icon(Icons.lightbulb_outline_rounded, color: Styles.fg),
                title: Text('Show Solution', style: customStyle),
                onTap: () {
                  Navigator.pop(context);
                  Timer(Duration(milliseconds: 200), () => showSolution());
                },
              ),
              ListTile(
                leading: Icon(Icons.build_outlined, color: Styles.fg),
                title: Text('Set Difficulty', style: customStyle),
                onTap: () {
                  Navigator.pop(context);
                  Timer(
                      Duration(milliseconds: 300),
                      () => showAnimatedDialog<void>(
                              animationType: DialogTransitionType.fadeScale,
                              barrierDismissible: true,
                              duration: Duration(milliseconds: 350),
                              context: outerContext,
                              builder: (_) => AlertDifficultyState(
                                  currentDifficultyLevel)).whenComplete(() {
                            if (AlertDifficultyState.difficulty != null) {
                              Timer(Duration(milliseconds: 300), () {
                                newGame(AlertDifficultyState.difficulty);
                                currentDifficultyLevel =
                                    AlertDifficultyState.difficulty;
                                AlertDifficultyState.difficulty = null;
                                setPrefs('currentDifficultyLevel');
                              });
                            }
                          }));
                },
              ),
              ListTile(
                leading: Icon(Icons.invert_colors_on_rounded, color: Styles.fg),
                title: Text('Switch Theme', style: customStyle),
                onTap: () {
                  Navigator.pop(context);
                  Timer(Duration(milliseconds: 200), () {
                    changeTheme('switch');
                  });
                },
              ),
              ListTile(
                leading: Icon(Icons.info_outline_rounded, color: Styles.fg),
                title: Text('About', style: customStyle),
                onTap: () {
                  Navigator.pop(context);
                  Timer(
                      Duration(milliseconds: 200),
                      () => showAnimatedDialog<void>(
                          animationType: DialogTransitionType.fadeScale,
                          barrierDismissible: true,
                          duration: Duration(milliseconds: 350),
                          context: outerContext,
                          builder: (_) => AlertAbout()));
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
        onWillPop: () async {
          if (kIsWeb) {
            return false;
          } else {
            showAnimatedDialog<void>(
                animationType: DialogTransitionType.fadeScale,
                barrierDismissible: true,
                duration: Duration(milliseconds: 350),
                context: context,
                builder: (_) => AlertExit());
          }
          return true;
        },
        child: new Scaffold(
            backgroundColor: Styles.bg,
            appBar: AppBar(
              centerTitle: true,
              title: Text('Sudoku'),
            ),
            body: Builder(builder: (builder) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: createRows(),
                ),
              );
            }),
            floatingActionButton: FloatingActionButton(
              foregroundColor: Styles.bg,
              backgroundColor: Styles.primaryColor,
              onPressed: () => showOptionModalSheet(context),
              child: Icon(Icons.menu_rounded),
            )));
  }
}
