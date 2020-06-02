import 'package:flutter/material.dart';

class NoPhotosButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          decoration: const BoxDecoration(
            color: Colors.black,
          ),
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Padding(padding: EdgeInsets.only(top: 120)),
              Container(
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      width: 1.0,
                      color: Color(0xFFFFFFFFFF),
                    ),
                    left: BorderSide(
                      width: 1.0,
                      color: Color(0xFFFFFFFFFF),
                    ),
                    right: BorderSide(
                      width: 1.0,
                      color: Color(0xFFFFFFFFFF),
                    ),
                    bottom: BorderSide(width: 1.0, color: Color(0xFFFFFFFFFF)),
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(100),
                  ),
                ),
                child: RawMaterialButton(
                  // onPressed: () async {},
                  child: Column(
                    children: <Widget>[
                      Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 70,
                      ),
                      Text(
                        "Tap to add a picture",
                        style: TextStyle(color: Colors.white, fontSize: 30),
                      ),
                    ],
                  ),
                  shape: CircleBorder(),
                  padding: const EdgeInsets.all(10.0),
                ),
              ),
            ],
          ),
        ),
      ],
    );
    // return Expanded(
    //   child: RawMaterialButton(
    //     child: Expanded(
    //               child: Icon(
    //         Icons.thumb_up,
    //         color: Colors.black38,
    //         size: 40,
    //       ),
    //     ),
    //     // shape: CircleBorder(),
    //     // elevation: 2.0,
    //     fillColor: Colors.green,
    //     onPressed: () {
    //       // launch modal to add photo from filesys or launch camera
    //     },
  }
}
