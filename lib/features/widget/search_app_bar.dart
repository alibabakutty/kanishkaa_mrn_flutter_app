import 'package:flutter/material.dart';

class SearchAppBar extends StatefulWidget {
  final Color cellBorderColor;
  final ValueChanged<String> onChanged;

  const SearchAppBar({
    super.key,
    required this.cellBorderColor,
    required this.onChanged,
  });

  @override
  State<SearchAppBar> createState() => _SearchAppBarState();
}

class _SearchAppBarState extends State<SearchAppBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _controller.clear();
    widget.onChanged('');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.deepPurpleAccent.shade700, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: TextField(
          controller: _controller,
          style: const TextStyle(fontSize: 14),
          textAlignVertical: TextAlignVertical.center,
          onChanged: (value) {
            widget.onChanged(value);
            setState(() {});
          },
          decoration: InputDecoration(
            hintText: "Search Products by Name or Part No...",
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
            prefixIcon: const Icon(
              Icons.search,
              size: 18,
              color: Colors.deepPurpleAccent,
            ),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
              onPressed: _clearSearch,
              icon: const Icon(
                Icons.close,
                size: 18,
                color: Colors.blueGrey,
              ),
            )
                : null,
            isDense: true,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}