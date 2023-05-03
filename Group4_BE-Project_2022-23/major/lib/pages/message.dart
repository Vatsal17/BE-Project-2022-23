import 'package:flutter/material.dart';

class MessagePage extends StatefulWidget {
  @override
  _MessagePageState createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( centerTitle: true,
        title: Text('AmbWay'),
        backgroundColor: Colors.red[400],
      ),
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height*0.10,
          child:Card(
        color: Colors.blueGrey,
        child: Text('  Smart Notice board  ',
          style: TextStyle(fontSize: 20),
        )
    ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(hintText: 'Enter your message'),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // Handle submit logic here
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}