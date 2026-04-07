import 'package:flutter/material.dart';

class HomeFiltersBar extends StatelessWidget {
  const HomeFiltersBar({
    super.key,
    required this.titleController,
    required this.categoryController,
    required this.minPriceController,
    required this.maxPriceController,
    required this.onApply,
    required this.onClear,
  });

  final TextEditingController titleController;
  final TextEditingController categoryController;
  final TextEditingController minPriceController;
  final TextEditingController maxPriceController;
  final VoidCallback onApply;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Column(
        children: [
          TextField(
            controller: titleController,
            decoration: const InputDecoration(
              labelText: 'Filter by title',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: categoryController,
            decoration: const InputDecoration(
              labelText: 'Filter by category slug (e.g. clothes)',
              prefixIcon: Icon(Icons.category),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: minPriceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Min price'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: maxPriceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Max price'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: onApply,
                  child: const Text('Apply filters'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: onClear,
                  child: const Text('Clear filters'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
