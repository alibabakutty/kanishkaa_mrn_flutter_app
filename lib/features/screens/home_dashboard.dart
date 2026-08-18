import 'package:flutter/material.dart';
import 'package:mobile_app/features/model/mrn_model.dart';
import 'package:mobile_app/features/provider/auth_provider.dart';
import 'package:mobile_app/features/provider/mrn_provider.dart';
import 'package:mobile_app/features/provider/site_provider.dart';
import 'package:mobile_app/features/provider/stock_provider.dart';
import 'package:mobile_app/features/screens/material_receipt_note_screen.dart';
import 'package:mobile_app/features/screens/site_screen.dart';
import 'package:mobile_app/features/screens/stock_screen.dart';
import 'package:mobile_app/features/screens/view_mrn_screen.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = context.read<AuthProvider>();
      if (!auth.isAuthenticated) return;

      await Future.wait([
        context.read<MrnProvider>().fetchAllOrders(),
        context.read<SiteProvider>().fetchAllSites(),
        context.read<StockProvider>().fetchAllProductsSummery(),
      ]);
    });
  }

  Future<void> _handleRefresh() async {
    final auth = context.read<AuthProvider>();
    if (!auth.isAuthenticated) return;

    await context.read<MrnProvider>().fetchAllOrders(force: true);
  }

  @override
  Widget build(BuildContext context) {
    final ordersProvider = context.watch<MrnProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              _buildSectionHeader('Quick Actions'),
              const SizedBox(height: 12),
              _buildQuickActions(context),
              const SizedBox(height: 24),
              _buildSectionHeader('MRN Summary'),
              const SizedBox(height: 12),
              _buildStatusGrid(ordersProvider),
              const SizedBox(height: 24),
              const Text(
                'Recent MRNs',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 12),
              _buildRecentOrdersList(ordersProvider.recentOrders),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildHeader(BuildContext context) {
    final String currentDay = DateFormat('EEEE').format(DateTime.now());
    final String currentDate = DateFormat(
      'dd MMMM yyyy',
    ).format(DateTime.now());

    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back,',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              Text(
                '${context.watch<AuthProvider>().username}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                currentDay,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                currentDate,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      {
        'icon': Icons.place,
        'label': 'Sites',
        'color': const Color(0xFFE0F2FE),
        'iconColor': const Color(0x78C702FF),
        'onTap': () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const SiteScreen()),
          );
        },
      },
      {
        'icon': Icons.inventory_2_outlined,
        'label': 'Stock Summary',
        'color': const Color(0xFFE0F2FE),
        'iconColor': const Color(0xFF0284C7),
        'onTap': () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => StockScreen()),
          );
        },
      },
      {
        'icon': Icons.add_shopping_cart,
        'label': 'New MRN',
        'color': const Color(0xFFEEF2FF),
        'iconColor': const Color(0xFF4F46E5),
        'onTap': () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const MaterialReceiptNoteScreen()),
          );
        },
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const double spacing = 12;
        final double itemWidth = (constraints.maxWidth - (spacing * 2)) / 3;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: actions.map((action) {
            return SizedBox(
              width: itemWidth,
              child: InkWell(
                onTap: action['onTap'] as VoidCallback,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 95,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.blueGrey.shade300),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundColor: action['color'] as Color,
                        radius: 18,
                        child: Icon(
                          action['icon'] as IconData,
                          color: action['iconColor'] as Color,
                          size: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          action['label'] as String,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF374151),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildStatusGrid(MrnProvider provider) {
    final int pendingCount = provider.allOrders
        .where((o) => o.tallyStatus.toLowerCase() == 'pending')
        .length;
    final int updatedCount = provider.allOrders
        .where((o) => o.tallyStatus.toLowerCase() == 'updated')
        .length;
    final int totalOrderCount = provider.allOrders.length;

    final statuses = [
      {
        'title': 'Pending',
        'count': '$pendingCount',
        'color': const Color(0xFFEF4444),
      },
      {
        'title': 'Updated',
        'count': '$updatedCount',
        'color': const Color(0xFF10B981),
      },
      {
        'title': 'Total MRNs',
        'count': '$totalOrderCount',
        'color': const Color(0xFF3B82F6),
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const double spacing = 12;
        final double itemWidth = (constraints.maxWidth - (spacing * 2)) / 3;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: statuses.map((item) {
            final Color baseColor = item['color'] as Color;

            return SizedBox(
              width: itemWidth,
              child: Container(
                height: 95,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blueGrey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: baseColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item['title'] as String,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: baseColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        item['count'] as String,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildRecentOrdersList(List<MrnModel> recentOrders) {
    if (recentOrders.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(
          child: Text(
            "No recent MRNs found",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    String formatQty(num? qty) {
    if (qty == null) return '0';

    final value = qty.toDouble();
    if (value == value.toInt()) {
      // Whole number: show without decimals
      return value.toInt().toString();
    } else {
      // Fractional: show up to 2 decimals, strip trailing zeros
      final s = value.toStringAsFixed(2);
      return s.replaceAll(RegExp(r'\.?0*$'), '');
    }
  }

    final int displayCount = recentOrders.length > 5 ? 5 : recentOrders.length;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: displayCount,
      itemBuilder: (context, index) {
        final order = recentOrders[index];

        final screenWidth = MediaQuery.sizeOf(context).width;
        final isSmallScreen = screenWidth < 360;

        final Widget statusBadge = Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 7,
            vertical: 2.5,
          ),
          decoration: BoxDecoration(
            color: order.tallyStatus.toLowerCase() == 'pending'
                ? Colors.deepOrangeAccent.withValues(alpha: 0.12)
                : Colors.green.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            order.tallyStatus,
            style: TextStyle(
              color: order.tallyStatus.toLowerCase() == 'pending'
                  ? Colors.deepOrangeAccent
                  : Colors.green,
              fontSize: isSmallScreen ? 9 : 9.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
        );

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ViewMrnScreen(
                    initialItems: order,
                    orderNumber: order.orderNumber,
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 10 : 12,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.015),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: isSmallScreen ? 18 : 20,
                    backgroundColor: const Color(0xFFF1F5F9),
                    child: Icon(
                      Icons.receipt_long,
                      color: const Color(0xFF0C685B),
                      size: isSmallScreen ? 18 : 22,
                    ),
                  ),
                  SizedBox(width: isSmallScreen ? 10 : 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '# ${order.orderNumber}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: isSmallScreen ? 13 : 14,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                            ),
                            if (!isSmallScreen) ...[
                              const SizedBox(width: 8),
                              statusBadge,
                            ],
                            const SizedBox(width: 8),
                            Text(
                              order.totalQty != null && order.totalUom != null
                                  ? '${formatQty(order.totalQty)} ${order.totalUom}'
                                  : '-',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: isSmallScreen ? 13.5 : 15,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                order.siteName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: const Color(0xFF64748B),
                                  fontWeight: FontWeight.w500,
                                  fontSize: isSmallScreen ? 11 : 12,
                                ),
                              ),
                            ),
                            if (isSmallScreen) ...[
                              const SizedBox(width: 8),
                              statusBadge,
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}