import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class PlaybackCard extends StatefulWidget {
  final bool isSelected;
  final Function select;
  final String name;
  final bool isLoading;
  final bool isPlaying;
  final Function stopAll;
  final Function startAll;
  final bool canDelete;
  // Optional
  final String barkLength;
  final Color color;
  final Function delete;

  PlaybackCard(
      {this.delete,
      this.color,
      this.barkLength,
      @required this.canDelete,
      @required this.isSelected,
      @required this.select,
      @required this.name,
      @required this.isLoading,
      @required this.startAll,
      @required this.stopAll,
      @required this.isPlaying});

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
      return Transform.scale(
        scale: 4,
        child: Icon(Icons.stop, color: Theme.of(context).errorColor, size: 15),
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
        IconButton(
          icon: Icon(
            widget.isSelected
                ? Icons.check_box_outlined
                : Icons.check_box_outline_blank_rounded,
            color: Theme.of(context).primaryColor,
          ),
          onPressed: widget.select,
        ),
        // Playback button
        // Select bark button
        Expanded(
          child: RawMaterialButton(
            onPressed: widget.isLoading
                ? null
                : widget.isPlaying
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
                          color: Theme.of(context).primaryColor,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    if (widget.barkLength != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 5.0),
                        child: Text(
                          widget.barkLength.toUpperCase(),
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
}
