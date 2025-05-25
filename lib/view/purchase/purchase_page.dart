import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/product.dart';
import 'purchase_provider.dart';

class PurchasePage extends StatelessWidget {
  const PurchasePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      final state = ref.watch(purchaseProvider);
      final notifier = ref.read(purchaseProvider.notifier);

      return Scaffold(
        appBar: AppBar(title: const Text('购买页面')),
        body: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  const SizedBox(height: 16),
                  const Text('订阅产品', style: TextStyle(fontSize: 18)),
                  ...state.subscriptionProducts.map(
                    (product) => ListTile(
                      title: Text(product.title),
                      subtitle: Text(product.description),
                      trailing: Text(product.price),
                      onTap: () {
                        final selected = Product.fromProductDetails(product);
                        if (selected != null) {
                          notifier.setSelectedProduct(selected);
                        }
                      },
                    ),
                  ),
                  const Divider(),
                  const Text('消耗型产品', style: TextStyle(fontSize: 18)),
                  ...state.consumableProducts.map(
                    (product) => ListTile(
                      title: Text(product.title),
                      subtitle: Text(product.description),
                      trailing: Text(product.price),
                      onTap: () {
                        final selected = Product.fromProductDetails(product);
                        if (selected != null) {
                          notifier.setSelectedProduct(selected);
                        }
                      },
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: state.selectedProduct == null
                        ? null
                        : () => notifier.purchaseProduct(),
                    child: const Text('立即购买'),
                  ),
                ],
              ),
      );
    });
  }
}
