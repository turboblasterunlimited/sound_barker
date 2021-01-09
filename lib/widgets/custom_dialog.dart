import 'package:flutter/material.dart';

class CustomDialog extends StatefulWidget {
  final String header;
  final double headerSize;
  final String bodyText;
  final Widget body;
  final String primaryButtonText;
  final Function primaryFunction;
  final String secondaryButtonText;
  final Function secondaryFunction;
  final Icon iconPrimary;
  final Icon iconSecondary;
  final bool isYesNo;

  CustomDialog({
    this.header,
    this.headerSize,
    this.bodyText,
    this.body,
    this.primaryButtonText = "YES",
    this.primaryFunction,
    this.secondaryButtonText = "NO",
    this.secondaryFunction,
    @required this.iconPrimary,
    @required this.iconSecondary,
    this.isYesNo = false,
  });

  @override
  _CustomDialogState createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(32.0))),
      contentPadding: EdgeInsets.only(top: 10.0),
      content: Container(
        width: 300.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Stack(
              children: [
                Positioned(right: 20, bottom: 5, child: widget.iconPrimary),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Center(
                    child: Text(
                      widget.header,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: widget.headerSize ?? 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Divider(
              color: Colors.grey[300],
              thickness: 2,
            ),
            Stack(
              children: [
                Positioned(
                  bottom: 20,
                  left: 20,
                  child: widget.iconSecondary,
                ),
                widget.body != null
                    ? widget.body
                    : Padding(
                        padding: EdgeInsets.only(left: 30.0, right: 30.0),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: widget.bodyText,
                            border: InputBorder.none,
                          ),
                          maxLines: 6,
                        ),
                      ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: widget.secondaryFunction == null
                        ? () => Navigator.of(context).pop()
                        : () => widget.secondaryFunction(context),
                    child: Container(
                      padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                      decoration: BoxDecoration(
                        color: widget.isYesNo
                            ? Theme.of(context).errorColor
                            : Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(32.0),
                        ),
                      ),
                      child: Text(
                        widget.secondaryButtonText,
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                if (!widget.isYesNo)
                  Container(
                    width: 1,
                  ),
                Expanded(
                  child: InkWell(
                    onTap: () => widget.primaryFunction(context),
                    child: Container(
                      padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(32.0),
                        ),
                      ),
                      child: Text(
                        widget.primaryButtonText,
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
