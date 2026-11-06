import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? leading;
  final Widget? trailing;
  final EdgeInsetsGeometry margin;
  final bool isThreeLine;

  const CustomCard({
    super.key, required this.title, required this.subtitle, this.onTap,
    this.leading, this.trailing, this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 8), this.isThreeLine = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: margin, elevation: 2, clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: leading ?? const Icon(Icons.fastfood, size: 40, color: Colors.orange),
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
        isThreeLine: isThreeLine,
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}