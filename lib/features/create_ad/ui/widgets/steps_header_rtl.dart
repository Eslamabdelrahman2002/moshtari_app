import 'package:flutter/material.dart';

class StepsHeaderRtl extends StatelessWidget {
  final List<String> labels;
  final int current;
  final ValueChanged<int>? onTap;

  const StepsHeaderRtl({
    super.key,
    required this.labels,
    required this.current,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(labels.length * 2 - 1, (i) {
            if (i.isOdd) {
              return Container(
                width: MediaQuery.of(context).size.height * .07,
                height: 2,
                color: Colors.black12,
                margin: const EdgeInsets.symmetric(horizontal: 4),
              );
            }
            final index = i ~/ 2;
            final isActive = index == current;
            final isDone = index < current;
            return GestureDetector(
              onTap: onTap == null ? null : () => onTap!(index),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Column(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive || isDone ? const Color(0xFFFFC107) : Colors.white,
                        border: Border.all(
                          color: isActive || isDone ? const Color(0xFFFFC107) : Colors.black26,
                        ),
                      ),
                      child: isDone
                          ? const Icon(Icons.check, size: 16, color: Colors.white)
                          : const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      labels[index],
                      style: TextStyle(
                        fontSize: 12,
                        color: isActive ? Colors.black : Colors.black54,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}