import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';

/// Polls internet connectivity every 3 seconds using a DNS lookup.
/// No external packages required — uses dart:io only.
class NetworkProvider extends ChangeNotifier {
  bool _isOnline = true;
  late Timer _timer;

  bool get isOnline => _isOnline;

  NetworkProvider() {
    _checkNow();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _checkNow());
  }

  Future<void> _checkNow() async {
    try {
      // Check multiple reliable hosts to avoid single DNS failure
      final hosts = ['google.com', 'cloudflare.com', 'opendns.com'];
      bool online = false;
      
      for (var host in hosts) {
        try {
          final result = await InternetAddress.lookup(host)
              .timeout(const Duration(seconds: 5));
          if (result.isNotEmpty && result.first.rawAddress.isNotEmpty) {
            online = true;
            break;
          }
        } catch (_) {
          continue;
        }
      }

      if (online != _isOnline) {
        _isOnline = online;
        notifyListeners();
      }
    } catch (_) {
      if (_isOnline) {
        _isOnline = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
