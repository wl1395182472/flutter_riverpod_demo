/// 图片路径管理类
/// 使用单例模式统一管理应用中所有图片资源的路径
/// 便于维护和修改图片资源路径
class ImagePath {
  /// 私有构造函数，防止外部直接实例化
  ImagePath._privateConstructor();

  /// 单例实例
  static final instance = ImagePath._privateConstructor();

  /// 工厂构造函数，返回单例实例
  factory ImagePath() {
    return instance;
  }

  /// 图标资源路径
  final icon = 'assets/icon/';

  /// 图片资源路径
  final image = 'assets/image/';

  /// 全局通用图片资源路径
  final global = 'assets/image/global/';

  /// 启动页图片资源路径
  final splash = 'assets/image/splash/';
}
