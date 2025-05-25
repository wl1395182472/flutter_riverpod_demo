import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'dart:convert';

import '../util/log.dart';
import '../util/secure_storage.dart';

class StorekitPaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  // 用于快速检查的内存缓存
  final Set<String> _processedTransactions = <String>{};

  // SecureStorage 的键
  static const String _storageKey = 'processed_transactions';

  // 单例模式
  static final StorekitPaymentQueueDelegate _instance =
      StorekitPaymentQueueDelegate._internal();

  factory StorekitPaymentQueueDelegate() {
    return _instance;
  }

  StorekitPaymentQueueDelegate._internal() {
    // 初始化时从持久化存储加载数据
    _loadProcessedTransactions();
  }

  // 从 SecureStorage 加载已处理的交易
  Future<void> _loadProcessedTransactions() async {
    final String? storedData = await SecureStorage.instance.read(
      key: _storageKey,
    );
    if (storedData != null) {
      final List<dynamic> transactions = jsonDecode(storedData);
      _processedTransactions.addAll(transactions.cast<String>());
      Log.instance.logger.d('已加载 ${_processedTransactions.length} 个历史交易记录');
    }
  }

  // 保存已处理的交易到 SecureStorage
  Future<void> _saveProcessedTransaction(String transactionId) async {
    _processedTransactions.add(transactionId);
    final String data = jsonEncode(_processedTransactions.toList());
    await SecureStorage.instance.write(key: _storageKey, value: data);
    Log.instance.logger.d('交易记录已保存到持久存储: $transactionId');
  }

  @override
  bool shouldContinueTransaction(
    SKPaymentTransactionWrapper transaction,
    SKStorefrontWrapper storefront,
  ) {
    // 详细日志：打印交易和店铺信息
    Log.instance.logger.d('检查交易是否应该继续处理...');
    Log.instance.logger.d('交易ID: ${transaction.transactionIdentifier}');
    Log.instance.logger.d('店铺ID: ${storefront.identifier}');
    Log.instance.logger.d('产品ID: ${transaction.payment.productIdentifier}');
    Log.instance.logger.d('交易状态: ${transaction.transactionState}');

    // 获取交易ID
    final String? originalTransactionId =
        transaction.originalTransaction?.transactionIdentifier;
    Log.instance.logger.d('原始交易ID: ${originalTransactionId ?? '无(新交易)'}');

    // 如果交易ID为空，允许交易继续
    if (originalTransactionId == null) {
      Log.instance.logger.d('新交易: 无原始交易ID，允许继续处理');
      return true;
    }

    // 检查内存缓存中是否有此交易ID
    if (_processedTransactions.contains(originalTransactionId)) {
      Log.instance.logger.d('交易已处理过，跳过重复交易: $originalTransactionId');
      return false;
    }

    // 新交易，异步保存到持久存储
    Log.instance.logger.d('发现新的交易ID，准备保存到持久存储');
    _saveProcessedTransaction(originalTransactionId);

    Log.instance.logger
        .d('originalTransactionId: $originalTransactionId, 允许继续处理');
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    Log.instance.logger.d('检查是否需要显示价格同意页面: false');
    return false;
  }
}
