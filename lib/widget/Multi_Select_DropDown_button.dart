import 'package:flutter/material.dart';

List<String> selectedItems = [];

class MultiSelectDropDown extends StatelessWidget {
  final List<String> items;
  const MultiSelectDropDown({super.key, required this.items, required String selectedItemText, required Null Function(dynamic selected) onSelected, required Null Function(dynamic selecdtItems) onSelectionchanged});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Text(
            '   Select Items',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).hintColor,
            ),
          ),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              enabled: false,
              child: StatefulBuilder(
                builder: (context, menuSetState) {
                  final isSelected = selectedItems.contains(item);
                  return InkWell(
                    onTap: () {
                      menuSetState(() {
                        if (isSelected) {
                          selectedItems.remove(item);
                        } else {
                          selectedItems.add(item);
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        children: [
                          Icon(
                            isSelected
                                ? Icons.check_box_outlined
                                : Icons.check_box_outline_blank_outlined,
                          ),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: Text(
                              item,
                              style: const TextStyle(fontSize: 14.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }).toList(),
          onChanged: (_) {}, // Required but unused in multi-select
        ),
      ),
    );
  }
}