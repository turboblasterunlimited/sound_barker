
import 'dart:async';
import 'package:flutter/material.dart';

class ForgotPasswordDialog extends StatefulWidget {
  static const routeName = 'forgot-password-screen';
  @override
  _ForgotPasswordDialogState createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<ForgotPasswordDialog> {
  TextEditingController _textFieldController = TextEditingController();
  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('TextField in Dialog'),
            content: TextField(
              onChanged: (value) {
                setState(() {
                  valueText = value;
                });
              },
              controller: _textFieldController,
              decoration: InputDecoration(hintText: "Text Field in Dialog"),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.all(Radius.circular(22.0)),
                  ),
                  padding: EdgeInsets.symmetric(
                      vertical: 10, horizontal: 20),
                  child: const Text("CANCEL",
                      style:TextStyle(color: Colors.white, fontSize: 20)
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    codeDialog = valueText;
                    Navigator.pop(context);
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.all(Radius.circular(22.0)),
                  ),
                  padding: EdgeInsets.symmetric(
                      vertical: 10, horizontal: 20),
                  child: const Text("OK",
                      style:TextStyle(color: Colors.white, fontSize: 20)
                  ),
                ),
              ),
              // FlatButton(
              //   color: Colors.red,
              //   textColor: Colors.white,
              //   child: Text('CANCEL'),
              //   onPressed: () {
              //     setState(() {
              //       Navigator.pop(context);
              //     });
              //   },
              // ),
              // FlatButton(
              //   color: Colors.green,
              //   textColor: Colors.white,
              //   child: Text('OK'),
              //   onPressed: () {
              //     setState(() {
              //       codeDialog = valueText;
              //       Navigator.pop(context);
              //     });
              //   },
              // ),
            ],
          );
        });
  }

  String? codeDialog;
  String? valueText;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: (codeDialog == "123456") ? Colors.green : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text('Alert Dialog'),
      ),
      body: Center(
        child: TextButton(
          onPressed: () {
            setState(() {
              Navigator.pop(context);
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.all(Radius.circular(22.0)),
            ),
            padding: EdgeInsets.symmetric(
                vertical: 10, horizontal: 20),
            child: const Text("Press for alert",
                style:TextStyle(color: Colors.white, fontSize: 20)
            ),
          ),
        ),
        // child: FlatButton(
        //   color: Colors.teal,
        //   textColor: Colors.white,
        //   onPressed: () {
        //     _displayTextInputDialog(context);
        //   },
        //   child: Text('Press For Alert'),
        // ),
      ),
    );
  }
}
