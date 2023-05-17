import 'package:flutter/material.dart';

class MultiSelectDialogItem<V> {
  V value;

  String name;
  String type;

  MultiSelectDialogItem(
      {required this.name, required this.type, required this.value});
}

class MultiSelectDialog<V> extends StatefulWidget {
  const MultiSelectDialog({
    Key? key,
    required this.items,
    required this.initialSelectedValues,
  }) : super(key: key);

  final List<MultiSelectDialogItem<V>> items;
  final Set<V> initialSelectedValues;

  @override
  State<StatefulWidget> createState() => _MultiSelectDialogState<V>();
}

class _MultiSelectDialogState<V> extends State<MultiSelectDialog<V>> {
  final _selectedValues = <V>{};

  @override
  void initState() {
    super.initState();
    _selectedValues.addAll(widget.initialSelectedValues);
  }

  void _onItemCheckedChange(V itemValue, bool checked) {
    setState(() {
      if (checked) {
        _selectedValues.add(itemValue);
      } else {
        _selectedValues.remove(itemValue);
      }
    });
  }

  void _onCancelTap() {
    Navigator.pop(context);
  }

  void _onSubmitTap() {
    Navigator.pop(context, _selectedValues);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select filters'),
      contentPadding: const EdgeInsets.all(20.0),
      content: SingleChildScrollView(
        child: ListTileTheme(
          contentPadding: const EdgeInsets.fromLTRB(14.0, 0.0, 24.0, 0.0),
          child: ListBody(
            children: widget.items.map(_buildItem).toList(),
          ),
        ),
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: _onCancelTap,
          child: const Text('CANCEL'),
        ),
        ElevatedButton(
          onPressed: _onSubmitTap,
          child: const Text('OK'),
        )
      ],
    );
  }

  Widget _buildItem(MultiSelectDialogItem<V> item) {
    final checked = _selectedValues.contains(item.value);
    return item.type == "data"
        ? CheckboxListTile(
            value: checked,
            title: Text(item.name),
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (checked) => _onItemCheckedChange(item.value, checked!),
          )
        : Container(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                item.name,
                style: TextStyle(color: Color.fromARGB(255, 91, 91, 91)),
              ),
            ),
          );
  }
}
