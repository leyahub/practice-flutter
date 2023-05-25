import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectIndex = index;
    });
  }

  final List<Widget> _display = [ const PageHome(), const PageHome2(), const TestList()];

  @override
  Widget build(BuildContext context) {
    const home = 'ホーム';
    const home2 = 'ホーム2';
    const list = 'リスト';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _display[_selectIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.home), label: home),
        BottomNavigationBarItem(icon: Icon(Icons.accessible_rounded), label: home2),
        BottomNavigationBarItem(icon: Icon(Icons.access_alarm_outlined), label: list),
      ],
        onTap: _onItemTapped,
        currentIndex: _selectIndex,
      ),
    );
  }
}

class PageHome extends StatelessWidget {
  const PageHome({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            't',
            style: Theme.of(context).textTheme.headline4,
          ),
        ],
      ),
    );
  }
}

class PageHome2 extends StatelessWidget {
  const PageHome2({Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
    create: (context) => Memo(),
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          FutureBuilder<List<Memo>>(
            future: Memo.getMemos(),
            builder:(context, snapshot) {
              if (snapshot.hasData) {
                return Expanded(
                  child: 
                    ListView.builder(
                      itemCount: snapshot.data?.length,
                      itemBuilder:(context, index) {
                        return ListTile(title: Text('id:${snapshot.data?[index].id}' '  テキスト:${snapshot.data?[index].text}'), );
                      },
                    ),
                  );
              } else {
                return const CircularProgressIndicator();
              }
            }
            
          ),
      TextButton(
        child: const Text('insert'),
        onPressed: () async {
          Memo _memo = Memo(id: 1, text: 'test');
          await _memo.insertMemo(_memo);
        }
      )
        ]
      ),
      ),
    );
  }
}

class PageHome2State extends ChangeNotifier {

  void get() {
    Memo.getMemos();
  }
}

class TestList extends StatelessWidget {
  const TestList({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 350,
        child: ListView(
          children: [
            Container(
              child: const Center(child: Text('NICE 筋トレ！')),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade400,
                    spreadRadius: 0.1,
                    blurRadius: 4,
                  )
                ]
              ),
              constraints: const BoxConstraints(minHeight: 200),
              margin: const EdgeInsets.symmetric(vertical: 20),
            ),
            Container(
              child: const Center(child: Text('Entry B')),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade400,
                    spreadRadius: 0.1,
                    blurRadius: 4,
                  )
                ]
              ),
              constraints: const BoxConstraints(minHeight: 300),
              margin: const EdgeInsets.symmetric(vertical: 20),
            ),
          ],
        )
      )
    );
  }
}

class Memo extends ChangeNotifier {
  final int? id;
  final String? text;
  List<Memo> memoList = <Memo>[];

  Memo({this.id, this.text});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
    };
  }
  
  static Future<Database> get database async {

    // openDatabaseでdbのインスタンスを取得することができる
    final Future<Database> _database = openDatabase(

      // データベース(ファイル)の保存先を決める
      // dbがpathに存在しないとき、onCreateが呼ばれる
      join(await getDatabasesPath(), 'memo_database.db'),
      onCreate:(db, version) {
        return db.execute(
          "CREATE TABLE memo(id INTEGER PRIMARY KEY AUTOINCREMENT, text TEXT)"
        );
      },
      version: 1,
    );
    return _database;
  }

  Future<void> insertMemo(Memo memo) async {
    final Database db = await database;
    await db.insert(
      'memo',
      memo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Memo>> getMemos() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('memo');
    return List.generate(maps.length, (i) {
      return Memo(
        id: maps[i]['id'],
        text: maps[i]['text'],
        );
    });
  }
}
