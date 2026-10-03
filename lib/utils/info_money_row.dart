import 'package:flutter/material.dart';
import 'package:sasacation/core/apptheme.dart';
import 'package:sasacation/utils/money.dart';

class InfoMoneyRow extends StatelessWidget {
  final IconData? icon;
  final String label;
  final double usd;
  final String suffix;
  final String emptyText;
  const InfoMoneyRow({
    super.key,
    this.icon,
    required this.label,
    required this.usd,
    this.suffix = '',
    this.emptyText = '-',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: AppTheme.primaryColor),
            const SizedBox(width: 10),
          ],
          Text(
            '$label:  ',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          Expanded(
            child: usd > 0
                ? MoneyText(usd,
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 14),
                    suffix: suffix)
                : Text(
                    emptyText,
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 14),
                  ),
          ),
        ],
      ),
    );
  }
}