import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

DateTime _focusedDay = DateTime.now();

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

  final List<Widget> _display = [ const PageTop(), const PageHome2(), const PagePostList(), const TestList()];

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

class PageTop extends StatelessWidget {
  const PageTop({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'カレンダー',
            style: Theme.of(context).textTheme.headline4,
          ),
          const Calendar(),
        ],
      ),
    );
  }
}

class Calendar extends StatefulWidget {
  const Calendar({ Key? key }) : super(key: key);

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget> [
        Container (
          child: TableCalendar(
            firstDay: DateTime.utc(2023, 5, 1),
            lastDay: DateTime.utc(2024, 4, 30),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
          ),
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
          margin: const EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.all(20),
        ),
        Text(_selectedDay.toString())
      ],
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
          return ListTile(title: Text('id:${memoList[index].id}' '  テキスト:${memoList[index].text}  日付:${memoList[index].date}'), );
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
  final idControl = TextEditingController();
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
                Memo(
                  id: int.parse(idControl.text), 
                  text: textControl.text,
                  date: DateFormat('yyyy/MM/dd').format(DateTime.parse(DateTime.now().toIso8601String()).toLocal()).toString()),
              ]
            );
          }
        ),
        TextField(
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          controller: idControl,
          decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: "id",
          )
        ),
        TextField(
          controller: textControl,
          decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: "text",
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
  final String? date;
  final List<Memo> memoList = <Memo>[];

  Memo({this.id, this.text, this.date});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'date': date,
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
          "CREATE TABLE memo(id INTEGER PRIMARY KEY AUTOINCREMENT, text TEXT, date TEXT)"
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
    memoList.clear();

     // 保持
    for (var i in maps) {
      memoList.add(
        Memo(id: i['id'], text: i['text'], date: i['date'])
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            child: const Text('t'),
            width: 200,
            height: 200,
            decoration: const BoxDecoration(
              color: Colors.cyanAccent,
            ),
          ),
          Container(
            width: 100,
            height: 200,
            child: Text(
              post.text!,
              style: Theme.of(context).textTheme.headline5,
              textAlign: TextAlign.start,
            ),
            decoration: const BoxDecoration(
              color: Colors.orange,
            ),
          ),
        ],
      ),
      
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
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(20),
    );
  }
}

// 投稿されたデータ(リスト)
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
