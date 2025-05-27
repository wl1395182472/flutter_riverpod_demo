import 'package:flutter/material.dart'
    show
        StatelessWidget,
        BuildContext,
        Widget,
        Center,
        SizedBox,
        Divider,
        Spacer,
        AppBar,
        CircularProgressIndicator,
        ListTile,
        MainAxisSize,
        Hero,
        Column,
        SafeArea,
        Scaffold;
import 'package:flutter_riverpod/flutter_riverpod.dart' show Consumer;

import '../../component/global_button.dart' show GlobalButton;
import '../../component/global_text.dart' show GlobalText;
import '../../model/product.dart' show Product;
import 'purchase_provider.dart' show purchaseProvider;

/// 购买页面组件
///
/// 展示应用内购买商品并处理购买流程：
/// - 显示订阅型商品列表
/// - 显示消耗型商品列表
/// - 处理商品选择
/// - 执行购买操作
class PurchasePage extends StatelessWidget {
  const PurchasePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 使用Consumer监听购买状态变化
    return Consumer(builder: (context, ref, _) {
      // 获取购买状态和控制器
      final state = ref.watch(purchaseProvider);
      final notifier = ref.read(purchaseProvider.notifier);

      return Scaffold(
        // 页面顶部标题栏
        appBar: AppBar(title: const GlobalText('购买页面')),
        body: SafeArea(
          child: state.isLoading
              // 加载状态显示进度指示器
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    const SizedBox(height: 16),
                    // 订阅型商品标题
                    const GlobalText(
                      '订阅产品',
                      fontSize: 18,
                    ),
                    // 订阅型商品列表
                    ...state.subscriptionProducts.map(
                      (product) => ListTile(
                        title: GlobalText(product.title),
                        subtitle: GlobalText(product.description),
                        trailing: GlobalText(product.price),
                        onTap: () {
                          // 将ProductDetails转换为Product并设置为选中
                          final selected = Product.fromProductDetails(product);
                          if (selected != null) {
                            notifier.setSelectedProduct(selected);
                          }
                        },
                      ),
                    ),
                    const Divider(),
                    // 消耗型商品标题
                    const GlobalText(
                      '消耗型产品',
                      fontSize: 18,
                    ),
                    // 消耗型商品列表
                    ...state.consumableProducts.map(
                      (product) => ListTile(
                        title: GlobalText(product.title),
                        subtitle: GlobalText(product.description),
                        trailing: GlobalText(product.price),
                        onTap: () {
                          // 将ProductDetails转换为Product并设置为选中
                          final selected = Product.fromProductDetails(product);
                          if (selected != null) {
                            notifier.setSelectedProduct(selected);
                          }
                        },
                      ),
                    ),
                    const Spacer(),
                    // 购买按钮，带Hero动画效果
                    Hero(
                      tag: 'Purchase',
                      child: GlobalButton(
                        // 只有选择了商品才能点击购买
                        onPressed: state.selectedProduct == null
                            ? null
                            : () => notifier.purchaseProduct(),
                        mainAxisSize: MainAxisSize.max,
                        text: 'Purchase',
                      ),
                    ),
                  ],
                ),
        ),
      );
    });
  }
}
