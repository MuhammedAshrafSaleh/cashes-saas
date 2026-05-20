// lib/core/widgets/loading_skeleton.dart
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cashes/core/constants/app_spacing.dart';
import 'package:cashes/core/constants/app_radius.dart';
import 'package:cashes/core/theme/app_colors.dart';

class LoadingSkeleton extends StatelessWidget {
  const LoadingSkeleton({super.key, this.itemCount = 6});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      highlightColor: isDark ? AppColors.darkCard : AppColors.lightCard,
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (_, _) => Container(
          height: 72,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppRadius.lgBorder,
          ),
        ),
      ),
    );
  }
}

class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius,
  });

  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      highlightColor: isDark ? AppColors.darkCard : AppColors.lightCard,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? AppRadius.smBorder,
        ),
      ),
    );
  }
}
