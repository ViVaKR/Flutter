import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp()); // (1) MyApp 에 정의된 앱(위젯)을 실행하라고 Flutter 에게 지시
}

// 위젯은 모든 Flutter 앱을 빌드하는데 사용되는 핵심 개념이다.
// 위젯은 UI 요소를 설명하는 객체이다.
// 위젯은 레이아웃, 텍스트, 이미지, 버튼, 폼 등과 같은 UI 요소를 설명한다.
// 위젯은 StatelessWidget 과 StatefulWidget 두 가지 유형이 있다.
// StatelessWidget 은 변경할 수 없는 상태를 가지는 위젯이다.
// StatefulWidget 은 변경할 수 있는 상태를 가지는 위젯이다.
// StatelessWidget 은 build() 메서드를 오버라이드하여 UI를 빌드한다.
// StatelessWidget 은 한 번 생성되면 변경할 수 없다.
// StatefulWidget 은 createState() 메서드를 오버라이드하여 상태를 가지는 위젯을 생성한다.
// StatefulWidget 은 상태가 변경되면 UI가 다시 빌드된다.
// 앱 자체도 위젯이다. MyApp 은 StatelessWidget 을 상속받는다.

class MyApp extends StatelessWidget {
  // (2) MyApp 은 StatelessWidget 을 상속받는다.

  const MyApp({super.key});

// MyApp 의 build() 메서드는 MaterialApp 위젯을 반환한다.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'WWW.KIMBUMJUN.COM',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

// MyAppState 클래스는 앱의 상태를 정의함.
// MyAppState 는 앱이 작동하는 데 필요한 데이터를 저장하고 관리함.
// ChangeNotifier 상태 변경을 관리하는 클래스 : 자체 변경사항을 다른 항목에 알릴 수 있음.
// 예를 들어 MyAppState 클래스의 current 변수가 변경되면 notifyListeners() 메서드를 호출하여 변경사항을 알림.
class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  // Add this.
  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  // 비즈니스 로직
  var favorites = <WordPair>{};

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
}

// 모든 위젯은 상황이 변경도리 때마다 자동으로 호출되는 build() 메서드를 가지고 있다.
// build() 메서드는 UI를 빌드하고 반환한다.
// MyHomePage 는 watch 메서들 사용하여 앱의 현재 상태에 관한 변경사항을 추적한다.
class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: constraints.maxWidth >= 600,
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite),
                    label: Text('Favorites'),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('You have '
              '${appState.favorites.length} favorites: '),
        ),
        for (var pair in appState.favorites)
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text(pair.asLowerCase),
          ),
      ],
    );
  }
}
