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
        return 'Total Global Revenue';
      case RevenueFilter.day:
        return 'Today (${DateFormat('MMM d').format(now).toUpperCase()})';
      case RevenueFilter.month:
        return DateFormat('MMMM yyyy').format(now);
      case RevenueFilter.year:
        return '${now.year} DATA';
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();
    final filteredRevenue = _getFilteredRevenue(orderProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => context.pop(),
              child: const SizedBox(
                width: 36, height: 36,
                child: Center(child: Icon(Icons.arrow_back, color: Colors.white, size: 20)),
              ),
            ),
          ),
        ),
      ),
      body: orderProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE60A15)))
          : Stack(
              children: [
                // Minimal glow effect top right
                Positioned(
                  top: -80, right: -40,
                  child: Container(
                    width: 200, height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: const Color(0xFFE60A15).withValues(alpha: 0.2), blurRadius: 100, spreadRadius: 40),
                      ],
                    ),
                  ),
                ),
                
                SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        const Text('Revenue Analytics', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, height: 1.1)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.greenAccent, blurRadius: 8)])),
                            const SizedBox(width: 8),
                            const Text('LIVE TRACKING', style: TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Main Metric Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFF181111).withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 20, offset: const Offset(0, 10)),
                            ],
                          ),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                right: -40, top: -40,
                                child: Container(width: 120, height: 120, decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: const Color(0xFFE60A15).withValues(alpha: 0.2), blurRadius: 50, spreadRadius: 20)])),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_getFilterLabel(), style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 14)),
                                  const SizedBox(height: 8),
                                  Text('\$${filteredRevenue.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold, letterSpacing: -1)),
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(color: Colors.greenAccent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.2))),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.trending_up, color: Colors.greenAccent, size: 16),
                                        SizedBox(width: 4),
                                        Text('+24.5% vs last period', style: TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Filters
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: RevenueFilter.values.map((f) {
                              final isSelected = _filter == f;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: GestureDetector(
                                  onTap: () => setState(() => _filter = f),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: isSelected ? const Color(0xFFE60A15) : Colors.transparent,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: isSelected ? const Color(0xFFE60A15) : Colors.white.withValues(alpha: 0.1)),
                                    ),
                                    child: Text(
                                      f.name[0].toUpperCase() + f.name.substring(1),
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.6),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        const Text('Active Streams', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),

                        // Orders List
                        if (orderProvider.orders.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(32),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(color: const Color(0xFF181111).withValues(alpha: 0.5), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withValues(alpha: 0.05))),
                            child: Column(
                              children: [
                                Icon(Icons.receipt_long, size: 48, color: Colors.white.withValues(alpha: 0.2)),
                                const SizedBox(height: 16),
                                Text('No logged transactions', style: TextStyle(color: Colors.white.withValues(alpha: 0.5))),
                              ],
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: orderProvider.orders.length,
                            itemBuilder: (context, index) {
                              final order = orderProvider.orders[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF181111).withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                                ),
                                child: Theme(
                                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                                  child: ExpansionTile(
                                    tilePadding: EdgeInsets.zero,
                                    collapsedIconColor: Colors.white54,
                                    iconColor: const Color(0xFFE60A15),
                                    leading: Container(
                                      width: 48, height: 48,
                                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12)),
                                      child: const Icon(Icons.shopping_bag, color: Colors.white54),
                                    ),
                                    title: Text('\$${order.totalAmount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                                    subtitle: Text(DateFormat('MMM d, h:mm a').format(order.createdAt), style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13)),
                                    children: order.items.map((item) {
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 12),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('${item.quantity}x ${item.productName}', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14)),
                                            Text('\$${item.price.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              );
                            },
                          ),
                        const SizedBox(height: 48),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
