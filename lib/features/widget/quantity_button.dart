import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QuantityButton extends StatefulWidget {
  final num quantity;
  final VoidCallback onAdd;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final ValueChanged<num> onQuantityChanged;

  const QuantityButton({
    super.key,
    required this.quantity,
    required this.onAdd,
    required this.onIncrement,
    required this.onDecrement,
    required this.onQuantityChanged,
  });

  @override
  State<QuantityButton> createState() => _QuantityButtonState();
}

class _QuantityButtonState extends State<QuantityButton> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isEmptyAndFocused = false; // Tracks if the user cleared the text field but is still typing

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: _formatQuantity(widget.quantity),
    );
    _focusNode = FocusNode();

    // Listen for focus changes (e.g., clicking away or pressing Done)
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      // When focus is lost and the field was empty, tell the parent it's officially 0
      if (_controller.text.isEmpty) {
        setState(() {
          _isEmptyAndFocused = false;
        });
        widget.onQuantityChanged(0);
      }
    }
  }

  @override
  void didUpdateWidget(covariant QuantityButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.quantity != widget.quantity) {
      final parsedValue = num.tryParse(_controller.text) ?? 0;
      // Only override if the text doesn't match and the user isn't holding an empty focus
      if (parsedValue != widget.quantity && !_isEmptyAndFocused) {
        _controller.text = _formatQuantity(widget.quantity);
        _moveCursorToEnd();
      }
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  String _formatQuantity(num qty) {
    return qty % 1 == 0 ? qty.toInt().toString() : qty.toString();
  }

  void _moveCursorToEnd() {
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: _controller.text.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    // CRITICAL CHANGE: Show the "Add" button ONLY if quantity is 0 AND the user isn't actively focusing an empty input.
    if (widget.quantity == 0 && !_isEmptyAndFocused) {
      return SizedBox(
        height: 24,
        child: OutlinedButton(
          onPressed: widget.onAdd,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.deepPurpleAccent.shade700),
            foregroundColor: Colors.deepPurpleAccent.shade700,
            backgroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 11),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          child: const Text(
            "Add",
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    return Container(
      height: 28,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.deepPurpleAccent.shade700),
        borderRadius: BorderRadius.circular(6),
        color: Colors.white,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Decrement Button (-)
          InkWell(
            onTap: widget.onDecrement,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(6), right: Radius.circular(0)),
              ),
              child: Text(
                "-",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurpleAccent.shade700,
                ),
              ),
            ),
          ),

          // Editable text area
          SizedBox(
            width: 45,
            child: TextField(
              controller: _controller,
              focusNode: _focusNode, // Attached focus node
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 6),
                border: InputBorder.none,
              ),
              onChanged: (value) {
                if (value.isEmpty) {
                  // Keep the text field alive locally, do not broadcast 0 to parent yet
                  setState(() {
                    _isEmptyAndFocused = true;
                  });
                } else {
                  if (_isEmptyAndFocused) {
                    setState(() {
                      _isEmptyAndFocused = false;
                    });
                  }
                  final parsedValue = num.tryParse(value) ?? 0;
                  widget.onQuantityChanged(parsedValue);
                }
              },
              onSubmitted: (_) {
                // If they press the keyboard action button (Done/Enter)
                _focusNode.unfocus();
              },
            ),
          ),

          // Increment Button (+)
          InkWell(
            onTap: widget.onIncrement,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(0), right: Radius.circular(6)),
              ),
              child: Text(
                "+",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurpleAccent.shade700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}