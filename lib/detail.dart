import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import './editdata.dart';
import './main.dart';

class Detail extends StatelessWidget {
  final List list;
  final int index;
  final Function(int, List) editData;
  final Function(bool) onDataEdited;

  Detail({
    required this.list,
    required this.index,
    required this.editData,
    required this.onDataEdited,
  });

  void deleteData(BuildContext context, int index, String id) async {
    var url = Uri.parse("http://192.168.56.1/my_store/deletedata.php");
    var response = await http.post(url, body: {
      "id": id,
    });

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Data deleted successfully!"),
        ),
      );
      onDataEdited(true);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => Home()),
        (Route<dynamic> route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to delete data. Please try again later."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "DETAIL",
          textAlign: TextAlign.center, // Tengahkan judul
        ),
        centerTitle: true, // Tengahkan judul
        elevation: 5, // Tambahkan shadow pada navbar
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              padding: EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow("Item Code", list[index]['item_code']),
                  _buildDetailRow("Item Name", list[index]['item_name']),
                  _buildDetailRow("Price", list[index]['price']),
                  _buildDetailRow("Stock", list[index]['stock']),
                ],
              ),
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildButton(
                  text: "EDIT",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => EditData(
                          list: list,
                          index: index,
                          onDataEdited: onDataEdited,
                        ),
                      ),
                    );
                  },
                  color: Colors.white, // Warna latar belakang tombol EDIT
                  textColor: Colors.black, // Warna teks tombol EDIT
                ),
                _buildButton(
                  text: "DELETE",
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Confirmation"),
                          content: Text("Are you sure you want to delete this data?"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text("CANCEL"),
                            ),
                            TextButton(
                              onPressed: () {
                                deleteData(context, index, list[index]['id']);
                              },
                              child: Text("DELETE"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  color: Colors.red, // Warna latar belakang tombol DELETE
                  textColor: Colors.white, // Warna teks tombol DELETE
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required Function() onPressed,
    required Color color,
    required Color textColor,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(color: textColor),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        elevation: 5, // Tambahkan shadow pada tombol
      ),
    );
  }
}
