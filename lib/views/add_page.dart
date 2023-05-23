import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddTodoPage extends StatefulWidget {
  final Map? todo;
  const AddTodoPage({super.key, this.todo});

  @override
  State<AddTodoPage> createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  bool isEdit = false;

  @override
  void initState() {
    if (widget.todo != null) {
      isEdit = true;
      final title = widget.todo!['title'];
      final description = widget.todo!['description'];
      _titleController.text = title;
      _descriptionController.text = description;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Task' : 'Add Task'),
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              hintText: 'Title',
            ),
          ),
          TextField(
            controller: _descriptionController,
            decoration: InputDecoration(
              hintText: 'Description',
            ),
            minLines: 5,
            maxLines: 8,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: isEdit ? updateData : submitData,
            child: Text(isEdit ? 'Update' : 'Submit'),
          )
        ],
      ),
    );
  }

  Future<void> updateData() async {
    if (widget.todo == null) {
      print('You can\'t call update without todo data');
      return;
    }
    final id = widget.todo!['_id'];
    //final isCompleted = widget.todo!['is_completed'];

    final title = _titleController.text;
    final description = _descriptionController.text;
    final body = {
      "title": title,
      "description": description,
      "is_completed": false
    };
    final url = 'http://api.nstack.in/v1/todos/$id';
    final response = await http.put(
      Uri.parse(url),
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      showSuccessMessage('Successfully updated');
    } else {
      showErrorMessage('Updating failed');
    }
  }

  Future<void> submitData() async {
    final title = _titleController.text;
    final description = _descriptionController.text;
    final body = {
      "title": title,
      "description": description,
      "is_completed": false
    };
    final url = 'http://api.nstack.in/v1/todos';
    final response = await http.post(
      Uri.parse(url),
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 201) {
      _titleController.text = '';
      _descriptionController.text = '';
      showSuccessMessage('Successfully added');
    } else {
      showErrorMessage('Adding failed');
    }
  }

  void showSuccessMessage(String message) {
    final snackBar = SnackBar(
      content: Text(message),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showErrorMessage(String message) {
    final snackBar = SnackBar(
      backgroundColor: Colors.red,
      content: Text(message),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
