import 'package:flutter/material.dart';

/// Search input used to filter the Services catalog.
///
/// Search logic remains in the Services catalog controller. This widget only
/// displays the current query and reports user changes.
class ServicesSearchField extends StatefulWidget {
  const ServicesSearchField({
    required this.query,
    required this.onChanged,
    this.enabled = true,
    super.key,
  });

  /// Current search query.
  final String query;

  /// Called whenever the user changes the search query.
  final ValueChanged<String> onChanged;

  /// Whether the search field accepts input.
  final bool enabled;

  @override
  State<ServicesSearchField> createState() {
    return _ServicesSearchFieldState();
  }
}

class _ServicesSearchFieldState extends State<ServicesSearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(text: widget.query);
  }

  @override
  void didUpdateWidget(ServicesSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.query != oldWidget.query && widget.query != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.query,
        selection: TextSelection.collapsed(offset: widget.query.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasQuery = _controller.text.isNotEmpty;

    return Semantics(
      textField: true,
      enabled: widget.enabled,
      label: 'Search services',
      child: TextField(
        key: const ValueKey<String>('services-search-field'),
        controller: _controller,
        enabled: widget.enabled,
        textInputAction: TextInputAction.search,
        autofillHints: const [],
        decoration: InputDecoration(
          labelText: 'Search services',
          hintText: 'Search by name or description',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: hasQuery
              ? IconButton(
                  key: const ValueKey<String>('services-search-clear-button'),
                  tooltip: 'Clear service search',
                  onPressed: widget.enabled ? _clearQuery : null,
                  icon: const Icon(Icons.clear),
                )
              : null,
        ),
        onChanged: (value) {
          setState(() {});

          widget.onChanged(value);
        },
      ),
    );
  }

  void _clearQuery() {
    _controller.clear();

    setState(() {});

    widget.onChanged('');
  }
}
