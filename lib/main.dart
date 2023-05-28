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

  final List<Widget> _display = [ const PageHome(), const PageHome2(), const PagePostList(), const TestList()];

  @override
  Widget build(BuildContext context) {
    const home = 'ホーム';
    const home2 = 'ホーム2';
    const list = '投稿リスト２';
    const list2 = 'リスト';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _display[_selectIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.home), label: home),
        BottomNavigationBarItem(icon: Icon(Icons.accessible_rounded), label: home2),
        BottomNavigationBarItem(icon: Icon(Icons.add_to_drive), label: list),
        BottomNavigationBarItem(icon: Icon(Icons.access_alarm_outlined), label: list2),
      ],
        type: BottomNavigationBarType.fixed,
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
      create: (_) => Memo(),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Expanded (
              child: DataList()
            ),
            const GetDataButton(),
            InsertButton(),
            const DeleteButton(),
          ]
        ),
      ),
    );
  }
}

class DataList extends StatelessWidget {
  const DataList({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final memoList = context.watch<Memo>().memoList;
    if (memoList.isEmpty) const CircularProgressIndicator();

    return ListView.builder(
      itemCount: memoList.length,
      itemBuilder: (context, index) {
          return ListTile(title: Text('id:${memoList[index].id}' '  テキスト:${memoList[index].text}'), );
        }
      );
  }
}

class GetDataButton extends StatelessWidget {
  const GetDataButton({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Function get = context.read<Memo>().getMemos;

    return TextButton(
      child: const Text('get'),
      onPressed: () async {
        get();
      }
    ); 
  }
}

class InsertButton extends StatelessWidget {
  InsertButton({ Key? key }) : super(key: key);
  final textControl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextButton(
          child: const Text('Insert'),
          onPressed: () async {
            Memo _memo = Memo();
            _memo.insertMemo(
              <Memo> [
                Memo(id: 2, text: textControl.text),
              ]
            );
          }
        ),
        TextField(
          controller: textControl,
          decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: "test",
          )
        ),
      ]
    );
  }
}

class DeleteButton extends StatelessWidget {
  const DeleteButton({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: const Text('delete'),
      onPressed: () {
        Memo.delete();
      },
    );
  }
}

class InputTextField extends StatelessWidget {
  const InputTextField({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    return const TextField(
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: "test",
      )
    );
  }
}

class Memo extends ChangeNotifier {
  final int? id;
  final String? text;
  final List<Memo> memoList = <Memo>[];

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

  // データ追加
  Future<void> insertMemo(List<Memo> memos) async {
    final Database db = await database;
    for (var memo in memos) {
      await db.insert(
        'memo',
        memo.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  // memoListの更新
  void getMemos() async {
    // データベースのインスタンス
    final Database db = await database;

    // データベースから取得
    final List<Map<String, dynamic>> maps = await db.query('memo');

    // 保持
    for (var i in maps) {
      memoList.add(
        Memo(id: i['id'], text: i['text'])
      );
    }
    notifyListeners();
  }

  static void delete() async {
    final String path = join(await getDatabasesPath(), 'memo_database.db');
    await deleteDatabase(path);
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

// 投稿されたデータ(単体)
class Post extends StatelessWidget {
  const Post(this.post, { Key? key }) : super(key: key);
  final Memo post;

  @override
  Widget build(BuildContext context) {
    if (post.text!.isEmpty)  {
      return Container();
    }

    return Container(
      // text
      child: Center(
        child: Text(post.text!)),

      // design
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
    );
  }
}

class PostList extends StatelessWidget {
  const PostList({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final postList = context.watch<Memo>().memoList;

    return Center(
      child: SizedBox(
        width: 350,
        child: ListView.builder(
        itemCount: postList.length,
        itemBuilder: (context, index) {
          return Post(postList[index]);
          },
        ),
      )
    );
  }
}

class PostType {
  PostType({this.id, this.text});
  final int? id;
  final String? text;
}

class PagePostList extends StatelessWidget {
  const PagePostList({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => Memo(),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            Expanded (child: 
              PostList(),
            ),
            GetDataButton(),
          ]
        ),
      ),
    );
  }
}
