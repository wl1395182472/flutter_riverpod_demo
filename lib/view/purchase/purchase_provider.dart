import 'dart:async' show StreamSubscription;
import 'dart:convert' show jsonEncode, jsonDecode;
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart' show ChangeNotifier, BuildContext;
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_riverpod/flutter_riverpod.dart'
    show ChangeNotifierProvider;
import 'package:go_router/go_router.dart';
import 'package:in_app_purchase/in_app_purchase.dart'
    show
        InAppPurchase,
        PurchaseDetails,
        ProductDetails,
        PurchaseStatus,
        PurchaseParam;
import 'package:in_app_purchase_android/in_app_purchase_android.dart'
    show GooglePlayProductDetails, GooglePlayPurchaseParam;
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart'
    show InAppPurchaseStoreKitPlatformAddition;
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart'
    show SKPaymentQueueWrapper;

import '../../constant/app_config.dart' show AppConfig;
import '../../model/product.dart'
    show
        Product,
        ProductType,
        SubscriptionPlan,
        ConsumableType,
        SubscriptionType,
        BillingPeriod;
import '../../model/storekit_payment_queue_delegate.dart'
    show StorekitPaymentQueueDelegate;
import '../../service/storage_service.dart' show StorageService;
import '../../util/log.dart' show Log;
import '../../util/secure_storage.dart' show SecureStorage;
import '../../util/toast.dart' show Toast;

/// 处理应用内购买的状态管理和业务逻辑
///
/// 该类负责初始化购买系统、加载商品信息、处理购买流程和恢复购买等功能。
/// 通过Riverpod的Notifier实现状态管理，并提供给UI层使用。
class PurchaseNotifier extends ChangeNotifier {
  // 日志打印总开关，用于控制调试信息输出
  final _enableLogging = false;

  /// 存储构建上下文，用于导航操作
  /// 由UI层通过setContext方法传入
  BuildContext? _context;

  // 获取应用内购买实例
  final _inAppPurchase = InAppPurchase.instance;

  /// iOS平台特定的IAP服务
  /// 用于显示价格同意弹窗等iOS特有功能
  late final iapStoreKitPlatformAddition = _inAppPurchase
      .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();

  // 标记应用内购买服务是否可用
  bool _isPurchaseAvailable = false;
  bool get isAvailable => _isPurchaseAvailable;

  // 加载状态标记
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // 用于监听购买事件的订阅
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  // 消耗型商品ID集合
  final Set<String> _consumableProductIds = {
    AppConfig.instance.token700ProductId,
    AppConfig.instance.token5000ProductId,
  };
  // 订阅型商品ID集合
  final Set<String> _subscriptionProductIds = {
    AppConfig.instance.proMonthlyProductId,
    AppConfig.instance.proYearlyProductId,
    AppConfig.instance.proPlusMonthlyProductId,
    AppConfig.instance.proPlusYearlyProductId,
  };

  // 消耗型商品详情列表
  List<ProductDetails> _consumableProducts = [];
  List<ProductDetails> get consumableProducts => _consumableProducts;
  // 订阅型商品详情列表
  List<ProductDetails> _subscriptionProducts = [];
  List<ProductDetails> get subscriptionProducts => _subscriptionProducts;
  // 所有商品详情列表
  List<ProductDetails> get products => [
        ..._subscriptionProducts,
        ..._consumableProducts,
      ];

  // 用户选择是什么商品，消耗品或者订阅，消耗品中的哪个，订阅中的哪个，是pro还是pro plus，是月付还是年付
  Product? _selectedProduct;
  Product? get selectedProduct => _selectedProduct;

  // 构造函数，初始化购买系统
  PurchaseNotifier() {
    _initialize();
  }

  // 销毁时取消购买事件订阅
  @override
  void dispose() {
    _purchaseSubscription?.cancel();
    super.dispose();
  }

  /// 初始化购买系统
  ///
  /// 检查购买服务可用性，设置平台特定配置，
  /// 开始监听购买事件并加载商品信息
  Future<void> _initialize() async {
    if (_enableLogging) {
      Log.instance.logger.i('[PurchaseNotifier] Initializing purchase system');
    }
    try {
      // 设置加载状态为true
      _setLoading(true);
      // 检查购买服务是否可用
      _isPurchaseAvailable = await _inAppPurchase.isAvailable();
      if (_enableLogging) {
        Log.instance.logger.i(
          '[PurchaseNotifier] ${kIsWeb ? '' : Platform.isAndroid ? 'Google Play ' : Platform.isIOS ? 'App Store ' : ''}Purchase Service availability: $_isPurchaseAvailable',
        );
      }

      if (_isPurchaseAvailable) {
        // 如果是iOS设备，设置StoreKit支付队列代理
        if (Platform.isIOS) {
          if (_enableLogging) {
            Log.instance.logger.i(
              '[PurchaseNotifier] Setting up iOS payment queue delegate',
            );
          }
          await SKPaymentQueueWrapper().setDelegate(
            StorekitPaymentQueueDelegate(),
          );
        }

        // 开始处理购买流事件
        _processPurchaseStreamAsync();

        // 加载商品信息
        await _loadProducts();
      } else {
        // 购买服务不可用时记录错误并提示用户
        if (_enableLogging) {
          Log.instance.logger.e(
            '[PurchaseNotifier] ${kIsWeb ? '' : Platform.isAndroid ? 'Google Play ' : Platform.isIOS ? 'App Store ' : ''}Purchase Service is not available on this device.',
          );
        }
        Toast.show(
          '${kIsWeb ? '' : Platform.isAndroid ? 'Google Play ' : Platform.isIOS ? 'App Store ' : ''}Purchase Service is not available on this device.',
        );
      }
    } catch (error, stackTrace) {
      // 捕获并记录初始化过程中的错误
      if (_enableLogging) {
        Log.instance.logger.e(
          '[PurchaseNotifier] _initialize error',
          error: error,
          stackTrace: stackTrace,
        );
      }
    } finally {
      // 初始化完成，记录日志并更新加载状态
      if (_enableLogging) {
        Log.instance.logger.i('[PurchaseNotifier] Initialization completed');
      }
      _setLoading(false);
    }
  }

  /// 异步处理购买流事件
  ///
  /// 持续监听InAppPurchase提供的购买流，
  /// 根据不同的购买状态调用相应的处理方法
  Future<void> _processPurchaseStreamAsync() async {
    try {
      // 监听购买流事件
      await for (final purchaseDetailsList in _inAppPurchase.purchaseStream) {
        if (_enableLogging) {
          Log.instance.logger.i(
            '[PurchaseNotifier] Received purchase details list: ${purchaseDetailsList.length} items',
          );
        }
        // 处理每一个购买详情
        for (final purchaseDetails in purchaseDetailsList) {
          if (_enableLogging) {
            Log.instance.logger.i(
              '[PurchaseNotifier] Processing purchase: ${purchaseDetails.productID} with status: ${purchaseDetails.status}',
            );
          }
          // 根据购买状态执行不同的处理逻辑
          switch (purchaseDetails.status) {
            case PurchaseStatus.pending:
              // 处理待处理的购买
              await _processPendingPurchase(purchaseDetails);
              break;
            case PurchaseStatus.purchased:
            case PurchaseStatus.restored:
              // 处理成功的购买或恢复的购买
              await _processSuccessfulPurchase(purchaseDetails);
              break;
            case PurchaseStatus.error:
              // 处理失败的购买
              await _processFailedPurchase(purchaseDetails);
              break;
            case PurchaseStatus.canceled:
              // 处理取消的购买
              await _processCanceledPurchase(purchaseDetails);
              break;
          }

          // 如果购买状态为待处理且需要完成，则调用完成购买方法
          if (purchaseDetails.status != PurchaseStatus.pending &&
              purchaseDetails.pendingCompletePurchase) {
            await _inAppPurchase.completePurchase(purchaseDetails);
          }
        }
        isCurrentPurchase = false;
      }
    } catch (error, stackTrace) {
      // 捕获并记录处理购买流程中的错误
      if (_enableLogging) {
        Log.instance.logger.e(
          '[PurchaseNotifier] _processPurchaseStreamAsync error',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }
  }

  /// 加载应用内商品信息
  ///
  /// 分别加载订阅型商品和消耗型商品，
  /// 并更新UI显示商品详情
  Future<void> _loadProducts() async {
    if (_enableLogging) {
      Log.instance.logger.i('[PurchaseNotifier] Starting to load products');
    }
    try {
      // 加载订阅型商品
      if (_enableLogging) {
        Log.instance.logger.i(
          '[PurchaseNotifier] Loading subscription products: ${_subscriptionProductIds.length} items',
        );
      }
      final subscriptionResponse = await _inAppPurchase.queryProductDetails(
        _subscriptionProductIds,
      );
      _subscriptionProducts = subscriptionResponse.productDetails;
      if (_enableLogging) {
        Log.instance.logger.i(
          '[PurchaseNotifier] Loaded ${_subscriptionProducts.length} subscription products',
        );
      }

      // 加载消耗型商品
      if (_enableLogging) {
        Log.instance.logger.i(
          '[PurchaseNotifier] Loading consumable products: ${_consumableProductIds.length} items',
        );
      }
      final consumableResponse = await _inAppPurchase.queryProductDetails(
        _consumableProductIds,
      );
      _consumableProducts = consumableResponse.productDetails;
      if (_enableLogging) {
        Log.instance.logger.i(
          '[PurchaseNotifier] Loaded ${_consumableProducts.length} consumable products',
        );
      }

      notifyListeners();
    } catch (error, stackTrace) {
      // 捕获并记录加载商品过程中的错误
      if (_enableLogging) {
        Log.instance.logger.e(
          '[PurchaseNotifier] _loadProducts error',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }
  }

  /// 标记当前是否正在进行购买流程
  /// 用于区分用户主动发起的购买/恢复和系统自动处理的购买事件
  bool isCurrentPurchase = false;

  /// 发起购买商品的请求
  ///
  /// 根据用户选择的商品类型和具体商品，
  /// 找到对应的商品详情后调用相应的购买方法
  void purchaseProduct() async {
    try {
      if (_selectedProduct == null) {
        Toast.show('Please select a product first.');
        return;
      }

      isCurrentPurchase = true;
      // 设置加载状态为true
      _setLoading(true);

      if (Platform.isIOS) {
        await iapStoreKitPlatformAddition.showPriceConsentIfNeeded();
      }

      // 根据选择的商品确定商品ID
      String? productId = _getProductId(_selectedProduct!);
      if (productId == null) {
        Toast.show('Product not configured.');
        return;
      }

      if (_enableLogging) {
        Log.instance.logger
            .i('[PurchaseNotifier] Selected product ID: $productId');
      }

      // 判断是否为订阅型商品
      final isSubscription = _subscriptionProductIds.contains(productId);
      ProductDetails? productDetails;
      // 获取对应的商品详情
      if (isSubscription) {
        productDetails = _subscriptionProducts
            .where((product) => product.id == productId)
            .firstOrNull;
      } else {
        productDetails = _consumableProducts
            .where((product) => product.id == productId)
            .firstOrNull;
      }

      // 如果找到商品详情，则进行购买
      if (productDetails != null) {
        final purchaseParam = productDetails is GooglePlayProductDetails
            ? GooglePlayPurchaseParam(
                productDetails: productDetails,
                applicationUserName: StorageService.instance.userId.toString(),
              )
            : PurchaseParam(
                productDetails: productDetails,
                applicationUserName: StorageService.instance.userId.toString(),
              );
        if (isSubscription) {
          // 购买非消耗型商品(订阅)
          await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
        } else {
          // 购买消耗型商品
          await _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
        }
      } else {
        // 商品未找到，记录错误并提示用户
        if (_enableLogging) {
          Log.instance.logger
              .e('[PurchaseNotifier] Product not found: $productId');
        }
        Toast.show('Product not found. Please try again later.');
      }
    } catch (error, stackTrace) {
      // 捕获并记录购买过程中的错误
      if (_enableLogging) {
        Log.instance.logger.e(
          '[PurchaseNotifier] purchaseProduct error',
          error: error,
          stackTrace: stackTrace,
        );
      }
      if (error is PlatformException) {
        // 处理平台异常，根据错误类型显示不同提示
        if (error.code.contains('cancelled') ||
            error.code.contains('canceled') ||
            error.message?.contains('cancelled') == true ||
            error.message?.contains('canceled') == true ||
            error.code == 'storekit2_purchase_cancelled') {
          Toast.show('Initiate payment canceled');
        } else {
          Toast.show(
            'Initiate payment failed:\n${error.message}\n(${error.code})',
          );
        }
      } else {
        // 处理其他类型的错误

        Toast.show('Initiate payment failed, please try again later');
      }
    } finally {
      // 购买尝试完成后，更新加载状态
      _setLoading(false);
    }
  }

  /// 恢复之前的购买
  ///
  /// 用于用户更换设备或重新安装应用后，
  /// 恢复已经购买的订阅或商品
  Future<void> restorePurchase() async {
    try {
      isCurrentPurchase = true;
      // 设置加载状态为true
      _setLoading(true);
      if (_enableLogging) {
        Log.instance.logger.i('[PurchaseNotifier] restorePurchase');
      }
      // 调用恢复购买API
      await _inAppPurchase.restorePurchases();
    } catch (error, stackTrace) {
      // 捕获并记录恢复购买过程中的错误
      if (_enableLogging) {
        Log.instance.logger.e(
          '[PurchaseNotifier] restorePurchase error',
          error: error,
          stackTrace: stackTrace,
        );
      }
      if (error is PlatformException) {
        Toast.show(
          'Initiate payment failed:\n${error.message}\n(${error.code})',
        );
      } else {
        // 处理其他类型的错误
        Toast.show('Initiate payment failed, please try again later');
      }
    } finally {
      // 恢复尝试完成后，更新加载状态
      _setLoading(false);
    }
  }

  /// 根据Product实例获取对应的商品ID
  ///
  /// 将Product实例映射到AppConfig中定义的具体商品ID
  ///
  /// [product] Product实例
  /// 返回对应的商品ID，如果未找到则返回null
  String? _getProductId(Product product) {
    switch (product.type) {
      case ProductType.consumable:
        switch (product.consumableType) {
          case ConsumableType.token700:
            return AppConfig.instance.token700ProductId;
          case ConsumableType.token5000:
            return AppConfig.instance.token5000ProductId;
          default:
            return null;
        }
      case ProductType.subscription:
        switch (product.subscriptionType) {
          case SubscriptionType.pro:
            return product.billingPeriod == BillingPeriod.monthly
                ? AppConfig.instance.proMonthlyProductId
                : AppConfig.instance.proYearlyProductId;
          case SubscriptionType.proPlus:
            return product.billingPeriod == BillingPeriod.monthly
                ? AppConfig.instance.proPlusMonthlyProductId
                : AppConfig.instance.proPlusYearlyProductId;
          default:
            return null;
        }
    }
  }

  /// 处理待处理状态的购买
  ///
  /// 显示加载提示，等待交易完成
  /// 这通常发生在用户已经确认购买但交易尚未完成的情况下
  Future<void> _processPendingPurchase(PurchaseDetails purchaseDetails) async {
    // 显示加载提示
    Toast.showLoading();
  }

  /// 处理成功完成的购买或恢复的购买
  ///
  /// 1. 检查订单是否已处理，避免重复处理
  /// 2. 向服务器验证购买有效性
  /// 3. 更新会员过期时间
  /// 4. 保存已处理订单信息
  /// 5. 完成导航和提示
  Future<void> _processSuccessfulPurchase(
    PurchaseDetails purchaseDetails,
  ) async {
    if (_enableLogging) {
      Log.instance.logger.i(
        '[PurchaseNotifier] _processSuccessfulPurchase:'
        '\n- Product ID: ${purchaseDetails.productID}'
        '\n- Status: ${purchaseDetails.status}'
        '\n- Transaction ID: ${purchaseDetails.purchaseID}'
        '\n- Transaction Date: ${purchaseDetails.transactionDate}'
        '\n- Verification Data: ${purchaseDetails.verificationData.source} / ${purchaseDetails.verificationData.serverVerificationData.length} chars',
      );
    }

    // 检查订单是否已处理以避免重复处理
    final orderId = purchaseDetails.purchaseID ?? '';
    if (orderId.isNotEmpty) {
      final isProcessed = await _isOrderProcessed(orderId);
      if (isProcessed) {
        if (_enableLogging) {
          Log.instance.logger
              .i('[PurchaseNotifier] Order already processed: $orderId');
        }
        if (purchaseDetails.status == PurchaseStatus.restored &&
            isCurrentPurchase) {
          Toast.show('You have already purchased this subscription.');
        }
        return;
      }
    }

    // TODO:向服务器验证购买

    // 在成功处理购买后标记订单为已处理
    if (orderId.isNotEmpty) {
      await _addProcessedOrder(orderId);
    }

    _context?.pop(true);
  }

  /// 处理失败的购买
  ///
  /// 记录错误信息并向用户展示错误提示
  Future<void> _processFailedPurchase(PurchaseDetails purchaseDetails) async {
    // 记录购买失败信息
    if (_enableLogging) {
      Log.instance.logger.e(
        '[PurchaseNotifier] _processFailedPurchase: (${purchaseDetails.productID})${purchaseDetails.error?.message}',
      );
    }
    // 关闭加载提示并显示错误信息
    Toast.closeAllLoading();
    Toast.show(
      'Purchase failed\n${purchaseDetails.error?.message ?? "Unknown error"}',
    );
  }

  /// 处理用户取消的购买
  ///
  /// 关闭加载提示并通知用户购买已取消
  Future<void> _processCanceledPurchase(PurchaseDetails purchaseDetails) async {
    // 记录购买取消信息
    if (_enableLogging) {
      Log.instance.logger.i(
        '[PurchaseNotifier] _processCanceledPurchase: ${purchaseDetails.productID}',
      );
    }
    // 关闭加载提示并显示取消信息
    Toast.closeAllLoading();
    Toast.show('Purchase canceled');
  }

  // 存储已处理订单ID的键
  static const String _processedOrdersKey = 'processed_orders';

  /// 检查订单是否已被处理
  ///
  /// 通过查询本地存储的已处理订单ID列表确定订单是否已处理，
  /// 避免重复处理同一笔交易
  ///
  /// [orderId] 待检查的订单ID
  /// 返回订单是否已被处理
  Future<bool> _isOrderProcessed(String orderId) async {
    if (orderId.isEmpty) return false;

    final List<String> orders = await _getProcessedOrders();
    return orders.contains(orderId);
  }

  /// 添加已处理的订单ID到本地存储
  ///
  /// 确保成功处理的订单被记录，防止重复处理
  ///
  /// [orderId] 要添加的订单ID
  Future<void> _addProcessedOrder(String orderId) async {
    if (orderId.isEmpty) return;

    final List<String> orders = await _getProcessedOrders();
    if (!orders.contains(orderId)) {
      orders.add(orderId);
      await SecureStorage.instance.write(
        key: _processedOrdersKey,
        value: jsonEncode(orders),
      );
      if (_enableLogging) {
        Log.instance.logger
            .i('[PurchaseNotifier] Added order to processed list: $orderId');
      }
    }
  }

  /// 从本地存储获取所有已处理的订单ID
  ///
  /// 读取并解析存储的订单记录，确保不会重复处理同一笔交易
  ///
  /// 返回包含所有已处理订单ID的列表
  Future<List<String>> _getProcessedOrders() async {
    final String? ordersJson = await SecureStorage.instance.read(
      key: _processedOrdersKey,
    );
    if (ordersJson == null || ordersJson.isEmpty) {
      if (_enableLogging) {
        Log.instance.logger
            .i('[PurchaseNotifier] No processed orders found in storage');
      }
      return [];
    }
    try {
      final List<dynamic> decoded = jsonDecode(ordersJson);

      if (_enableLogging) {
        Log.instance.logger.d(
          '[PurchaseNotifier] Retrieved ${decoded.length} processed orders from storage',
        );
      }

      return decoded.map((e) => e.toString()).toList();
    } catch (error, stackTrace) {
      if (_enableLogging) {
        Log.instance.logger.e(
          '[PurchaseNotifier] Error parsing processed orders: $error',
          error: error,
          stackTrace: stackTrace,
        );
      }
      return [];
    }
  }

  /// 设置构建上下文
  ///
  /// 在UI层调用，用于存储当前构建上下文，
  /// 以便在购买成功后进行导航操作。
  /// 这是确保购买流程完成后能正确导航到相应页面的关键步骤。
  ///
  /// [context] 要存储的构建上下文
  void setContext(BuildContext context) {
    _context = context;
    if (_enableLogging) {
      Log.instance.logger.i(
        '[PurchaseNotifier] Context set from ${context.widget.runtimeType}',
      );
    }
  }

  /// 设置加载状态并通知监听者
  ///
  /// 更新内部加载状态并触发UI更新，确保用户界面反映当前的处理状态
  ///
  /// [loading] 新的加载状态
  void _setLoading(bool loading) {
    if (_enableLogging && _isLoading != loading) {
      Log.instance.logger
          .i('[PurchaseNotifier] Loading state changed: $loading');
    }
    _isLoading = loading;
    notifyListeners();
  }

  /// 设置选择的订阅计划并通知监听者（用于向后兼容）
  ///
  /// 更新用户选择的订阅计划类型（月度/年度）并刷新UI
  ///
  /// [plan] 用户选择的订阅计划
  void setSelectedPlan(SubscriptionPlan plan) {
    final product = Product.fromSubscriptionPlan(plan);
    setSelectedProduct(product);
  }

  /// 设置选择的商品并通知监听者
  ///
  /// 更新用户选择的商品并刷新UI
  ///
  /// [product] 用户选择的商品
  void setSelectedProduct(Product product) {
    if (_enableLogging && _selectedProduct != product) {
      Log.instance.logger.i(
        '[PurchaseNotifier] Selected product changed from $_selectedProduct to $product',
      );
    }
    _selectedProduct = product;
    notifyListeners();
  }
}

final purchaseProvider = ChangeNotifierProvider<PurchaseNotifier>((ref) {
  return PurchaseNotifier();
});
