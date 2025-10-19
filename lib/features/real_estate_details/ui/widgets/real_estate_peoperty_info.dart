import 'package:flutter/material.dart';

class RealEstatePropertyInfo extends StatelessWidget {
  final Map<String, String> data;

  const RealEstatePropertyInfo({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: data.entries.map((entry) {
          int index = data.keys.toList().indexOf(entry.key);
          Color backgroundColor =
              index % 2 == 0 ? Colors.grey[50]! : Colors.white;

          return Container(
            padding: const EdgeInsets.all(8.0),
            width: 342.0,
            height: 40.0,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8.0),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${entry.key}:',
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.black)),
                const Spacer(),
                Text(entry.value,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.black)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
