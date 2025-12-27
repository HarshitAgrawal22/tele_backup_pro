import 'package:connectivity_plus/connectivity_plus.dart';

class WifiUtils {
  static Future<bool> isWifiConnected() async {
    final List<ConnectivityResult> results = await Connectivity()
        .checkConnectivity();

    return results.contains(ConnectivityResult.wifi);
  }
}
