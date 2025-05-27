import 'package:in_app_purchase/in_app_purchase.dart' show ProductDetails;

/// 商品模型类
///
/// 定义了应用内购买商品的相关数据结构和枚举类型
/// 用于管理用户选择的商品类型（消耗品或订阅），以及具体的商品规格和计费周期
///
/// 主要功能：
/// - 定义商品类型和具体规格
/// - 提供预定义的商品实例
/// - 支持从ProductDetails创建Product实例
/// - 提供便捷的商品属性判断方法

/// 商品类型枚举
enum ProductType {
  /// 消耗型商品（代币等）
  consumable,

  /// 订阅型商品
  subscription,
}

/// 消耗型商品类型枚举
enum ConsumableType {
  /// 700代币
  token700,

  /// 5000代币
  token5000,
}

/// 订阅商品类型枚举
enum SubscriptionType {
  /// Pro版本
  pro,

  /// Pro Plus版本
  proPlus,
}

/// 计费周期枚举
enum BillingPeriod {
  /// 月付
  monthly,

  /// 年付
  yearly,
}

/// 订阅计划枚举（用于向后兼容）
enum SubscriptionPlan {
  /// 月度订阅
  monthly,

  /// 年度订阅
  yearly,
}

/// 商品信息类
///
/// 用于表示用户选择的商品信息，包括商品类型、订阅类型、计费周期等
class Product {
  /// 商品类型（消耗品或订阅）
  final ProductType type;

  /// 消耗型商品类型（仅当type为consumable时有效）
  final ConsumableType? consumableType;

  /// 订阅商品类型（仅当type为subscription时有效）
  final SubscriptionType? subscriptionType;

  /// 计费周期（仅当type为subscription时有效）
  final BillingPeriod? billingPeriod;

  const Product({
    required this.type,
    this.consumableType,
    this.subscriptionType,
    this.billingPeriod,
  });

  /// 创建消耗型商品
  const Product.consumable(ConsumableType this.consumableType)
      : type = ProductType.consumable,
        subscriptionType = null,
        billingPeriod = null;

  /// 创建订阅型商品
  const Product.subscription({
    required SubscriptionType this.subscriptionType,
    required BillingPeriod this.billingPeriod,
  })  : type = ProductType.subscription,
        consumableType = null;

  /// 预定义的商品实例

  /// 700代币
  static const token700 = Product.consumable(ConsumableType.token700);

  /// 5000代币
  static const token5000 = Product.consumable(ConsumableType.token5000);

  /// Pro月付
  static const proMonthly = Product.subscription(
    subscriptionType: SubscriptionType.pro,
    billingPeriod: BillingPeriod.monthly,
  );

  /// Pro年付
  static const proYearly = Product.subscription(
    subscriptionType: SubscriptionType.pro,
    billingPeriod: BillingPeriod.yearly,
  );

  /// Pro Plus月付
  static const proPlusMonthly = Product.subscription(
    subscriptionType: SubscriptionType.proPlus,
    billingPeriod: BillingPeriod.monthly,
  );

  /// Pro Plus年付
  static const proPlusYearly = Product.subscription(
    subscriptionType: SubscriptionType.proPlus,
    billingPeriod: BillingPeriod.yearly,
  );

  /// 是否为消耗型商品
  bool get isConsumable => type == ProductType.consumable;

  /// 是否为订阅型商品
  bool get isSubscription => type == ProductType.subscription;

  /// 是否为月付（仅订阅商品有效）
  bool get isMonthly => billingPeriod == BillingPeriod.monthly;

  /// 是否为年付（仅订阅商品有效）
  bool get isYearly => billingPeriod == BillingPeriod.yearly;

  /// 是否为Pro版本（仅订阅商品有效）
  bool get isPro => subscriptionType == SubscriptionType.pro;

  /// 是否为Pro Plus版本（仅订阅商品有效）
  bool get isProPlus => subscriptionType == SubscriptionType.proPlus;

  /// 转换为SubscriptionPlan（用于向后兼容）
  SubscriptionPlan? get toSubscriptionPlan {
    if (!isSubscription) return null;
    return billingPeriod == BillingPeriod.monthly
        ? SubscriptionPlan.monthly
        : SubscriptionPlan.yearly;
  }

  /// 从SubscriptionPlan创建Product（用于向后兼容）
  static Product fromSubscriptionPlan(SubscriptionPlan plan) {
    return plan == SubscriptionPlan.monthly ? proMonthly : proYearly;
  }

  /// 从ProductDetails创建Product实例
  ///
  /// 根据ProductDetails的id来匹配对应的Product类型
  /// 需要配合AppConfig中定义的产品ID来进行匹配
  static Product? fromProductDetails(ProductDetails productDetails) {
    final productId = productDetails.id;

    // 根据产品ID匹配对应的Product实例
    // 注意：这里需要根据实际的AppConfig中的产品ID进行匹配
    // 由于无法直接访问AppConfig，这里使用常见的产品ID模式进行匹配

    // 消耗型商品匹配
    if (productId.contains('token') || productId.contains('700')) {
      return Product.token700;
    }
    if (productId.contains('5000')) {
      return Product.token5000;
    }

    // 订阅型商品匹配
    if (productId.contains('pro_plus') || productId.contains('proplus')) {
      if (productId.contains('monthly') || productId.contains('month')) {
        return Product.proPlusMonthly;
      } else if (productId.contains('yearly') || productId.contains('year')) {
        return Product.proPlusYearly;
      }
    } else if (productId.contains('pro')) {
      if (productId.contains('monthly') || productId.contains('month')) {
        return Product.proMonthly;
      } else if (productId.contains('yearly') || productId.contains('year')) {
        return Product.proYearly;
      }
    }

    // 如果无法匹配，返回null
    return null;
  }

  /// 获取商品描述
  String get description {
    switch (type) {
      case ProductType.consumable:
        switch (consumableType) {
          case ConsumableType.token700:
            return '700 Tokens';
          case ConsumableType.token5000:
            return '5000 Tokens';
          default:
            return 'Unknown Consumable';
        }
      case ProductType.subscription:
        final typeStr =
            subscriptionType == SubscriptionType.pro ? 'Pro' : 'Pro Plus';
        final periodStr =
            billingPeriod == BillingPeriod.monthly ? 'Monthly' : 'Yearly';
        return '$typeStr $periodStr';
    }
  }

  @override
  String toString() {
    return 'Product(type: $type, consumableType: $consumableType, '
        'subscriptionType: $subscriptionType, billingPeriod: $billingPeriod)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product &&
        other.type == type &&
        other.consumableType == consumableType &&
        other.subscriptionType == subscriptionType &&
        other.billingPeriod == billingPeriod;
  }

  @override
  int get hashCode {
    return Object.hash(type, consumableType, subscriptionType, billingPeriod);
  }
}
