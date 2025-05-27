/// HTTP请求类型枚举
///
/// 定义了常用的HTTP请求方法类型，用于网络请求时指定请求类型
///
/// 包含的请求类型：
/// - [get]: GET请求，用于获取数据
/// - [post]: POST请求，用于创建新资源
/// - [put]: PUT请求，用于更新整个资源
/// - [delete]: DELETE请求，用于删除资源
/// - [patch]: PATCH请求，用于部分更新资源
enum HttpMethod {
  /// GET请求：获取数据
  get,

  /// POST请求：创建新资源
  post,

  /// PUT请求：更新整个资源
  put,

  /// DELETE请求：删除资源
  delete,

  /// PATCH请求：部分更新资源
  patch
}
