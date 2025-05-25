import 'package:connectivity_plus/connectivity_plus.dart';

import '../model/network_status.dart';

class NetworkService {
  /// 单例模式
  static final NetworkService instance = NetworkService._privateConstructor();
  factory NetworkService() => instance;
  NetworkService._privateConstructor();

  final _connectivity = Connectivity();

  // 获取当前网络连接状态
  Future<NetworkStatus> getCurrentStatus() async {
    try {
      final connectivityResults = await _connectivity.checkConnectivity();
      return _mapConnectivityResults(connectivityResults);
    } catch (e) {
      return NetworkStatus.unknown;
    }
  }

  // 监听网络连接状态变化
  Stream<NetworkStatus> get networkStatusStream {
    return _connectivity.onConnectivityChanged.map(_mapConnectivityResults);
  }

  // 检查是否有网络连接
  Future<bool> get isConnected async {
    final status = await getCurrentStatus();
    return status == NetworkStatus.online;
  }

  // 将ConnectivityResult列表映射到NetworkStatus
  NetworkStatus _mapConnectivityResults(List<ConnectivityResult> results) {
    if (results.isEmpty) {
      return NetworkStatus.unknown;
    }

    // 如果任何一个连接类型表示在线，则认为在线
    for (final result in results) {
      switch (result) {
        case ConnectivityResult.wifi:
        case ConnectivityResult.mobile:
        case ConnectivityResult.ethernet:
          return NetworkStatus.online;
        case ConnectivityResult.none:
          continue;
        default:
          continue;
      }
    }

    // 如果所有连接都是none，则离线
    return NetworkStatus.offline;
  }
}
