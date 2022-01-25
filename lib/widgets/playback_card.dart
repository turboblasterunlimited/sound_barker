import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class PlaybackCard extends StatefulWidget {
  final bool isSelected;
  final VoidCallback select;
  final String name;
  final bool isLoading;
  final bool isPlaying;
  final VoidCallback stopAll;
  final VoidCallback startAll;
  final bool canDelete;
  // Optional
  String? barkLength;
  Color? color;
  VoidCallback? delete;

  PlaybackCard(
      {this.delete,
      this.color,
      this.barkLength,
      required this.canDelete,
      required this.isSelected,
      required this.select,
      required this.name,
      required this.isLoading,
      required this.startAll,
      required this.stopAll,
      required this.isPlaying});

  @override
  _PlaybackCardState createState() => _PlaybackCardState();
}

class _PlaybackCardState extends State<PlaybackCard> {
  Widget getAudioButton() {
    if (widget.isLoading)
      return Transform.scale(
          scale: 3,
          child: SpinKitWave(size: 15, color: Theme.of(context).primaryColor));
    else if (widget.isPlaying)
      return
          // Center(
          //   child: Icon(Icons.stop, color: Theme.of(context).errorColor, size: 15),
          // );
          Transform.translate(
        child: Transform.scale(
          scale: 5,
          child:
              Icon(Icons.stop, color: Theme.of(context).errorColor, size: 10),
        ),
        offset: const Offset(0, 4),
      );
    else
      return Container(
        height: 15,
      );
    // return Transform.scale(
    //   scale: 3,
    //   child: Icon(Icons.play_arrow_outlined,
    //       color: Theme.of(context).primaryColor, size: 15),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Column(children: <Widget>[
          IconButton(
            padding: const EdgeInsets.all(0.0),
            icon: widget.isSelected
                ? Icon(Icons.music_note)
                : ImageIcon(
                    AssetImage("assets/images/Circle.png"),
                    color: Theme.of(context).primaryColor,
                  ),
            iconSize: 36,
            onPressed: widget.select,
          ),
        ]),
        // IconButton(
        //   icon: widget.isSelected
        //       ? Icons.music_note
        //       : Image.asset('assets/images/Circle.png'),
        //   iconSize: 24,
        //   onPressed: widget.select,
        // ),
        // Playback button
        // Select bark button
        Expanded(
          child: RawMaterialButton(
            onPressed: widget.isLoading
                ? null
                : _isPlaying()
                    ? widget.stopAll
                    : widget.startAll,
            fillColor: null,
            child: Stack(
              children: [
                Row(
                  mainAxisAlignment: widget.barkLength != null
                      ? MainAxisAlignment.spaceBetween
                      : MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                          left: widget.barkLength != null ? 5.0 : 0),
                      child: Text(
                        widget.name,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: widget.isPlaying
                              ? Colors.grey
                              : Theme.of(context).primaryColor,
                          //color: Colors.amber,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    if (widget.barkLength != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 5.0),
                        child: Text(
                          widget.barkLength!.toUpperCase(),
                          style: TextStyle(color: widget.color, fontSize: 10),
                        ),
                      ),
                  ],
                ),
                Center(
                  child: getAudioButton(),
                ),
              ],
            ),

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40.0),
              side: BorderSide(color: Theme.of(context).primaryColor, width: 3),
            ),
            elevation: 2.0,
            // fillColor: Theme.of(context).primaryColor,
            // padding:
            //     const EdgeInsets.symmetric(vertical: 0, horizontal: 22.0),
          ),
        ),
        // Menu button
        if (widget.canDelete)
          IconButton(
            onPressed: widget.delete,
            icon: Icon(Icons.more_vert,
                color: Theme.of(context).primaryColor, size: 30),
          ),
        if (!widget.canDelete)
          Padding(
            padding: EdgeInsets.only(left: 20),
          )
      ],
    );
  }

  bool _isPlaying() {
    print(widget.isPlaying.toString());
    return widget.isPlaying;
  }
}
