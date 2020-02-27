import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

import '../widgets/creatable_song.dart';

class CreateSongList extends StatefulWidget {
  @override
  _CreateSongListState createState() => _CreateSongListState();
}

class _CreateSongListState extends State<CreateSongList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 1,
      itemBuilder: (ctx, i) {
        return CreatableSong();
      },
    );
  }
}
