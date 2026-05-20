// lib/core/widgets/read_only_banner.dart
import 'package:flutter/material.dart';
import 'package:cashes/core/theme/app_colors.dart';

class ReadOnlyBanner extends StatelessWidget {
  const ReadOnlyBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.warning.withValues(alpha: 0.15),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.visibility_outlined, size: 16, color: AppColors.warning),
          const SizedBox(width: 8),
          Text(
            'وضع المشاهدة فقط',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.warning,
                ),
          ),
        ],
      ),
    );
  }
}
