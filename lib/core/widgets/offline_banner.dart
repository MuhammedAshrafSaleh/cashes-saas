// lib/core/widgets/offline_banner.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cashes/core/network/network_info.dart';
import 'package:cashes/core/theme/app_colors.dart';

class OfflineBanner extends StatefulWidget {
  const OfflineBanner({super.key, required this.networkInfo, required this.child});

  final NetworkInfo networkInfo;
  final Widget child;

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner> {
  bool _isOffline = false;
  StreamSubscription<bool>? _sub;

  @override
  void initState() {
    super.initState();
    _checkInitial();
    _sub = widget.networkInfo.onConnectivityChanged.listen((connected) {
      if (mounted) setState(() => _isOffline = !connected);
    });
  }

  Future<void> _checkInitial() async {
    final connected = await widget.networkInfo.isConnected;
    if (mounted) setState(() => _isOffline = !connected);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_isOffline)
          Material(
            color: AppColors.danger,
            child: SafeArea(
              bottom: false,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                child: const Text(
                  'لا يوجد اتصال بالإنترنت',
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        Expanded(child: widget.child),
      ],
    );
  }
}
