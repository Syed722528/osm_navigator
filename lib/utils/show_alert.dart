import 'package:flutter/material.dart';

class ShowAlert {
  static void showAlertDialog({
    required BuildContext context,
    required String title,
    required String message,
  }) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(10)),
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                  style: TextButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Okay')),
            ],
          );
        });
  }
}
