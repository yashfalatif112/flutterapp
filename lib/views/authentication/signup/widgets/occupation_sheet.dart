import 'package:flutter/material.dart';

void showOccupationSheet(
    {required List<String> items,
    required Function(String) onSelected,
    required BuildContext context}) {
  showModalBottomSheet(
    backgroundColor: Colors.white,
    context: context,
    builder: (context) => ListView.separated(
      shrinkWrap: true,
      itemCount: items.length,
      separatorBuilder: (_, __) => Divider(),
      itemBuilder: (context, index) => ListTile(
        title: Text(items[index]),
        onTap: () {
          Navigator.pop(context);
          onSelected(items[index]);
        },
      ),
    ),
  );
}
