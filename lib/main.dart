import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import './detail.dart';
import './adddata.dart';
import './editdata.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "My Store",
      theme: ThemeData(
        primaryColor: Colors.blue,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.orange),
      ),
      home: Home(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Future<List> _getData;

  @override
  void initState() {
    super.initState();
    _getData = getData();
  }

  Future<List> getData() async {
    final response =
        await http.get(Uri.parse("http://192.168.56.1/my_store/getdata.php"));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }

  void _updateData(bool isEdited) {
    if (isEdited) {
      setState(() {
        _getData = getData();
      });
    }
  }

  void addData() async {
    bool? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (BuildContext context) => AddData()),
    );

    if (result != null && result) {
      setState(() {
        _getData = getData();
      });
    }
  }

  void editData(int index, List list) async {
    bool? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => EditData(
          list: list,
          index: index,
          onDataEdited: _updateData,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "MY STORE",
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 5, // Tambahkan elevation disini
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: addData,
      ),
      body: FutureBuilder<List>(
        future: _getData,
        builder: (context, AsyncSnapshot<List> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No data available"));
          } else {
            return ItemList(
              list: snapshot.data!,
              editData: editData,
              updateData: _updateData,
            );
          }
        },
      ),
    );
  }
}

class ItemList extends StatelessWidget {
  final List list;
  final Function(int, List) editData;
  final Function(bool) updateData;

  const ItemList({
    Key? key,
    required this.list,
    required this.editData,
    required this.updateData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        return Container(
          padding: const EdgeInsets.all(10.0),
          child: GestureDetector(
            onTap: () {
              if (item is Map<String, dynamic>) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) => Detail(
                      list: list,
                      index: index,
                      editData: editData,
                      onDataEdited: updateData,
                    ),
                  ),
                );
              }
            },
            child: Card(
              elevation: 4,
              child: ListTile(
                title: Text(
                  item['item_name'] ?? '',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                leading: Icon(
                  Icons.widgets_rounded,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                subtitle: Text(
                  "Stock : ${item['stock'] ?? ''}",
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
