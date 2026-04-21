import 'package:flutter/material.dart';
import 'package:ecommerce_project/views/pages/cart/model/cart_item_model.dart';
import 'package:ecommerce_project/views/pages/cart/provider/cart_provider.dart';
import 'package:provider/provider.dart';

class CartCard extends StatelessWidget {
  const CartCard({super.key, required this.item});

  final CartItemModel item;

  @override
  Widget build(BuildContext context) {
    final imageUrl = item.product.images.isNotEmpty
        ? item.product.images.first
        : null;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: imageUrl != null
                  ? Image.network(
                      imageUrl,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        width: 72,
                        height: 72,
                        color: Colors.grey.shade800,
                        child: const Icon(Icons.broken_image),
                      ),
                    )
                  : Container(
                      width: 72,
                      height: 72,
                      color: Colors.grey.shade800,
                      child: const Icon(Icons.image_not_supported),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${item.product.price.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => context
                            .read<CartProvider>()
                            .removeSingle(item.product.id),
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text('${item.quantity}'),
                      IconButton(
                        onPressed: () =>
                            context.read<CartProvider>().add(item.product),
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
