import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/order_provider.dart';

class RevenueScreen extends StatefulWidget {
  const RevenueScreen({super.key});

  @override
  State<RevenueScreen> createState() => _RevenueScreenState();
}

enum RevenueFilter { all, day, month, year }

class _RevenueScreenState extends State<RevenueScreen> {
  RevenueFilter _filter = RevenueFilter.all;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<OrderProvider>().loadOrders();
    });
  }

  double _getFilteredRevenue(OrderProvider provider) {
    final now = DateTime.now();
    switch (_filter) {
      case RevenueFilter.all:
        return provider.totalRevenue;
      case RevenueFilter.day:
        return provider.revenueForDay(now);
      case RevenueFilter.month:
        return provider.revenueForMonth(now.year, now.month);
      case RevenueFilter.year:
        return provider.revenueForYear(now.year);
    }
  }

  String _getFilterLabel() {
    final now = DateTime.now();
    switch (_filter) {
      case RevenueFilter.all:
        return 'All Time';
      case RevenueFilter.day:
        return 'Today (${DateFormat('MMM d').format(now)})';
      case RevenueFilter.month:
        return DateFormat('MMMM yyyy').format(now);
      case RevenueFilter.year:
        return '${now.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();
    final colorScheme = Theme.of(context).colorScheme;
    final filteredRevenue = _getFilteredRevenue(orderProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Revenue Statistics'),
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/products'),
        ),
      ),
      body: orderProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Revenue card
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary,
                        colorScheme.tertiary,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        _getFilterLabel(),
                        style: TextStyle(
                          color: colorScheme.onPrimary.withValues(alpha: 0.8),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$${filteredRevenue.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: colorScheme.onPrimary,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Total Revenue',
                        style: TextStyle(
                          color: colorScheme.onPrimary.withValues(alpha: 0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                // Filter chips
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: RevenueFilter.values.map((f) {
                      return ChoiceChip(
                        label: Text(f.name[0].toUpperCase() + f.name.substring(1)),
                        selected: _filter == f,
                        onSelected: (_) => setState(() => _filter = f),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(),

                // Order history
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Order History (${orderProvider.orders.length})',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ),

                Expanded(
                  child: orderProvider.orders.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.receipt_long,
                                  size: 64, color: Colors.grey[400]),
                              const SizedBox(height: 12),
                              Text(
                                'No orders yet',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: orderProvider.orders.length,
                          itemBuilder: (context, index) {
                            final order = orderProvider.orders[index];
                            return Card(
                              child: ExpansionTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      colorScheme.primaryContainer,
                                  child: Icon(Icons.receipt,
                                      color: colorScheme.onPrimaryContainer),
                                ),
                                title: Text(
                                  '\$${order.totalAmount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  DateFormat('MMM d, yyyy – h:mm a')
                                      .format(order.createdAt),
                                ),
                                children: order.items.map((item) {
                                  return ListTile(
                                    dense: true,
                                    title: Text(item.productName),
                                    trailing: Text(
                                      '${item.quantity} × \$${item.price.toStringAsFixed(2)}',
                                    ),
                                  );
                                }).toList(),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
