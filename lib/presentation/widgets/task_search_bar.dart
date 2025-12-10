import 'package:flutter/material.dart';

/// Search bar widget for filtering tasks.
class TaskSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const TaskSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: TextStyle(
        color: Colors.grey.shade900,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        hintText: 'Search tasks...',
        hintStyle: TextStyle(color: Colors.grey.shade400),
        border: InputBorder.none,
        prefixIcon: Icon(
          Icons.search,
          color: Colors.grey.shade600,
        ),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: Icon(
                  Icons.clear,
                  color: Colors.grey.shade600,
                ),
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
              )
            : null,
      ),
      onChanged: onChanged,
      autofocus: true,
    );
  }
}

