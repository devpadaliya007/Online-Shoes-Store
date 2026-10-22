import 'package:flutter/material.dart';

class DropDownBtn extends StatefulWidget {
  final List<String> items;
  final String selectedItemText;
  final Function(String?) onSelected;

  const DropDownBtn({super.key, required this.items, required this.selectedItemText, required this.onSelected,});

  @override
  State<DropDownBtn> createState() => _DropDownBtnState();
}

class _DropDownBtnState extends State<DropDownBtn> {
  String? selectedValue;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Text(
            widget.selectedItemText,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).hintColor,
            ),
          ),
          value: selectedValue,
          items: widget.items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedValue = value;
            });
            widget.onSelected(value);
          },
        ),
      ),
    );
  }
}


