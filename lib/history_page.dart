import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/db/db.dart';
import 'package:flutter_application_1/setting_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/providers/gameCounter.dart';
import 'package:sqflite/sqflite.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  var timer = [];
  bool loading = false;
  DB_Helper dbHelper = DB_Helper();
  Future<List<Score>>? getList;

  @override
  void initState() {
    super.initState();
    dbHelper.initializeDB();
    getList = dbHelper.getScore();
    _loadTimer();
  }

  _loadTimer() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var timer = (prefs.getStringList('timer') ?? []);

    print(timer);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIOverlays([]);

    if (!loading) {
      return Container(
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text("History Page"),
          ),
          body: Container(
            child: Center(
              child: FutureBuilder(
                future: dbHelper.getScore(),
                builder: (context, AsyncSnapshot<List<Score>> snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                      return CircularProgressIndicator();
                    case ConnectionState.active:
                      return CircularProgressIndicator();
                    case ConnectionState.waiting:
                      return CircularProgressIndicator();
                    case ConnectionState.done:
                      if (snapshot.hasData) {
                        List<Score> data = List.from(snapshot.data!.reversed);
                        // List<Score> data = snapshot.data!;
                        // print(getList!.then((value) => print(value[0].id)));
                        // print(data);
                        return ListView.builder(
                            itemCount: snapshot.data?.length,
                            itemBuilder: (context, int index) {
                              // final item = data[index];
                              print(data[index].toMap());
                              return Dismissible(
                                key: UniqueKey(),
                                onDismissed: (direction) async {
                                  await dbHelper.deleteScore(data[index].id!);
                                  setState(() {
                                    data.removeAt(index);
                                    // getList!
                                    //     .then((value) => value.removeAt(index));
                                  });

                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text("Match Dismissed")));
                                },
                                child: Card(
                                  child: ListTile(
                                    title: Text(
                                        "${data[index].leftScore.toString()} : ${data[index].rightScore.toString()}"),
                                    subtitle: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                            "${data[index].minutes}m ${data[index].seconds}s"),
                                        Text(
                                            "${data[index].year}/${data[index].month}/${data[index].day}")
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            });
                      } else {
                        return Center(child: CircularProgressIndicator());
                      }
                  }
                },
              ),
            ),
          ),

          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/setting').then((value) {
                // print("test");
                SystemChrome.setPreferredOrientations(
                    [DeviceOrientation.portraitUp]);
              });
            },
            child: Icon(Icons.add),
          ),
        ),
      );
    } else {
      return CircularProgressIndicator();
    }
  }
}
