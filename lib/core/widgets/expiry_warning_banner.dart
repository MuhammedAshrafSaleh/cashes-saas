// lib/core/widgets/expiry_warning_banner.dart
import 'package:flutter/material.dart';
import 'package:cashes/core/theme/app_colors.dart';

class ExpiryWarningBanner extends StatelessWidget {
  const ExpiryWarningBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.warning.withValues(alpha: 0.15),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_outlined, size: 16, color: AppColors.warning),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'تنتهي صلاحية بعض الإيصالات خلال 5 أيام',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.warning,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
