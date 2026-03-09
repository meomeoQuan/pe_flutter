import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/order_provider.dart';
import '../widgets/background_wrapper.dart';
import '../widgets/glass_container.dart';

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
        return 'GLOBAL ACCUMULATION';
      case RevenueFilter.day:
        return 'TODAY (${DateFormat('MMM d').format(now).toUpperCase()})';
      case RevenueFilter.month:
        return DateFormat('MMMM yyyy').format(now).toUpperCase();
      case RevenueFilter.year:
        return '${now.year} DATA';
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();
    final filteredRevenue = _getFilteredRevenue(orderProvider);

    return BackgroundWrapper(
      hasAppBar: true,
      title: 'REVENUE',
      child: orderProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE50914)))
          : Column(
              children: [
                // Revenue Hero Card (Neon Indigo)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFE50914),
                        const Color(0xFFE50914).withValues(alpha: 0.6),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE50914).withValues(alpha: 0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        _getFilterLabel(),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12,
                          letterSpacing: 2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '\$${filteredRevenue.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Total Platform Revenue',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                // Filter chips (Glassmorphism row)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: RevenueFilter.values.map((f) {
                      final isSelected = _filter == f;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(
                            f.name[0].toUpperCase() + f.name.substring(1),
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (_) => setState(() => _filter = f),
                          selectedColor: const Color(0xFFE50914),
                          backgroundColor: Colors.white.withValues(alpha: 0.1),
                          side: BorderSide(
                            color: isSelected ? Colors.transparent : Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Order history header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.history, color: Color(0xFFE50914), size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'TRANSACTION LEDGER (${orderProvider.orders.length})',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: orderProvider.orders.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.receipt_long,
                                  size: 64, color: Colors.white.withValues(alpha: 0.2)),
                              const SizedBox(height: 12),
                              Text(
                                'No logged transactions',
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
                          itemCount: orderProvider.orders.length,
                          itemBuilder: (context, index) {
                            final order = orderProvider.orders[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: GlassContainer(
                                padding: const EdgeInsets.all(0),
                                borderRadius: BorderRadius.circular(16),
                                child: Theme(
                                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                                  child: ExpansionTile(
                                    iconColor: const Color(0xFFE50914),
                                    collapsedIconColor: Colors.white70,
                                    leading: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE50914).withValues(alpha: 0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.receipt, color: Color(0xFFE50914)),
                                    ),
                                    title: Text(
                                      '\$${order.totalAmount.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
                                    ),
                                    subtitle: Text(
                                      DateFormat('MMM d, yyyy – h:mm a').format(order.createdAt),
                                      style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
                                    ),
                                    children: order.items.map((item) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              item.productName,
                                              style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
                                            ),
                                            Text(
                                              '${item.quantity} × \$${item.price.toStringAsFixed(2)}',
                                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
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
