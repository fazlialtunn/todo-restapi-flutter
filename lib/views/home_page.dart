import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:restapi_flutter/views/add_page.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = true;
  List items = [];
  @override
  void initState() {
    fetchInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TO DO APP WITH RESTAPI'),
      ),
      body: Visibility(
        visible: isLoading,
        child: Center(child: CircularProgressIndicator()),
        replacement: RefreshIndicator(
          onRefresh: fetchInfo,
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final id = items[index]['_id'];
              return ListTile(
                leading: CircleAvatar(child: Text('${index + 1}')),
                title: Text(items[index]['title']),
                subtitle: Text(items[index]['description']),
                trailing: PopupMenuButton(
                  onSelected: (value) {
                    if (value == 'edit') {
                      editTask(items[index]);
                    } else if (value == 'delete') {
                      deleteById(id);
                    }
                  },
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem(
                        child: Text('Edit'),
                        value: 'edit',
                      ),
                      PopupMenuItem(
                        child: Text('Delete'),
                        value: 'delete',
                      ),
                    ];
                  },
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addTask,
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> addTask() async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => AddTodoPage(),
    ));
    setState(() {
      isLoading = true;
    });
    fetchInfo();
  }

  Future<void> editTask(Map item) async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => AddTodoPage(todo: item),
    ));

    setState(() {
      isLoading = true;
    });

    fetchInfo();
  }

  Future<void> deleteById(String id) async {
    final url = 'http://api.nstack.in/v1/todos/$id';
    final response = await http.delete(Uri.parse(url));
    if (response.statusCode == 200) {
      final filtered = items.where((element) => element['_id'] != id).toList();
      setState(() {
        items = filtered;
      });
    } else {
      showErrorMessage('Deletion Failed!');
    }
  }

  Future<void> fetchInfo() async {
    final url = 'http://api.nstack.in/v1/todos?page=1&limit=20';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map;
      final result = json['items'] as List;
      setState(() {
        items = result;
      });
    } else {}
    setState(() {
      isLoading = false;
    });
  }

  void showErrorMessage(String message) {
    final snackBar = SnackBar(
      backgroundColor: Colors.red,
      content: Text(message),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
