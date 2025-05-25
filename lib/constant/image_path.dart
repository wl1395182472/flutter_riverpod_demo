class ImagePath {
  ImagePath._privateConstructor();

  static final instance = ImagePath._privateConstructor();

  factory ImagePath() {
    return instance;
  }

  final icon = 'assets/icon/';
  final image = 'assets/image/';
  final global = 'assets/image/global/';
  final splash = 'assets/image/splash/';
}
