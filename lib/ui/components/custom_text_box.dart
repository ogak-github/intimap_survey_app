import 'package:flutter/material.dart';

class CustomTextBox extends StatelessWidget {
  final Widget? widget;
  final String text;
  const CustomTextBox({super.key, required this.text, this.widget});

  @override
  Widget build(BuildContext context) {
    return Material(
      clipBehavior: Clip.hardEdge,
      borderRadius: BorderRadius.circular(12),
      color: Theme.of(context).primaryColor,
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: widget ??
            Text(
              text,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(color: Theme.of(context).colorScheme.onPrimary),
            ),
      ),
    );
  }
}
