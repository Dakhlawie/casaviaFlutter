import 'package:flutter/material.dart';
import 'package:expandable/expandable.dart';

class CustomExpandableText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int maxLines;

  const CustomExpandableText({
    Key? key,
    required this.text,
    this.style,
    this.maxLines = 2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExpandablePanel(
      header: SizedBox.shrink(), // Pas d'en-tête
      collapsed: Text(
        text,
        softWrap: true,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: style,
      ),
      expanded: Text(
        text,
        softWrap: true,
        style: style,
      ),
      theme: ExpandableThemeData(
        expandIcon: Icons.arrow_circle_down_rounded,
        collapseIcon: Icons.arrow_circle_up_rounded,
        tapBodyToExpand: true,
        tapBodyToCollapse: true,
        tapHeaderToExpand: true,
        iconColor: Colors.blue,
        iconSize: 28.0,
        iconPadding: EdgeInsets.only(right: 5),
        hasIcon: true,
      ),
      builder: (_, collapsed, expanded) {
        return Expandable(
          collapsed: collapsed,
          expanded: expanded,
          theme: const ExpandableThemeData(crossFadePoint: 0),
        );
      },
    );
  }
}
