import 'package:flutter/material.dart';

/// Input rating berbentuk bintang (1..max). Dipakai di form Tambah & Edit.
class RatingInput extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final int max;

  const RatingInput({
    super.key,
    required this.value,
    required this.onChanged,
    this.max = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: List.generate(max, (index) {
        final star = index + 1;
        return IconButton(
          tooltip: '$star bintang',
          onPressed: () => onChanged(star),
          icon: Icon(
            star <= value ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 36,
          ),
        );
      }),
    );
  }
}