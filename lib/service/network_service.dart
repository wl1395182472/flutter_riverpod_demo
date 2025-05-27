import 'package:connectivity_plus/connectivity_plus.dart'
    show Connectivity, ConnectivityResult;

import '../model/network_status.dart' show NetworkStatus;

/// 网络服务类
/// 负责监听和检测网络连接状态
/// 使用单例模式确保全局唯一实例
class NetworkService {
  /// 单例模式实例
  static final NetworkService instance = NetworkService._privateConstructor();

  /// 工厂构造函数，返回单例实例
  factory NetworkService() => instance;

  /// 私有构造函数，防止外部实例化
  NetworkService._privateConstructor();

  /// 网络连接检测插件实例
  final _connectivity = Connectivity();

  /// 获取当前网络连接状态
  Future<NetworkStatus> getCurrentStatus() async {
    try {
      final connectivityResults = await _connectivity.checkConnectivity();
      return _mapConnectivityResults(connectivityResults);
    } catch (e) {
      return NetworkStatus.unknown;
    }
  }

  /// 监听网络连接状态变化
  Stream<NetworkStatus> get networkStatusStream {
    return _connectivity.onConnectivityChanged.map(_mapConnectivityResults);
  }

  /// 检查是否有网络连接
  Future<bool> get isConnected async {
    final status = await getCurrentStatus();
    return status == NetworkStatus.online;
  }

  /// 将ConnectivityResult列表映射到NetworkStatus
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
