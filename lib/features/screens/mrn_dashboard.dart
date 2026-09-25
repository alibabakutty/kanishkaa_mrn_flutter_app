import 'package:flutter/material.dart';
import 'package:mobile_app/features/provider/mrn_provider.dart';
import 'package:mobile_app/features/screens/material_receipt_note_screen.dart';
import 'package:mobile_app/features/screens/view_mrn_screen.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class MrnDashboard extends StatefulWidget {
  const MrnDashboard({super.key});

  @override
  State<MrnDashboard> createState() => _MrnDashboardState();
}

class _MrnDashboardState extends State<MrnDashboard> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();

  String _formatQty(num? qty) {
    if (qty == null) return '0';

    final value = qty.toDouble();
    if (value == value.toInt()) {
      // Whole number: no decimals
      return value.toInt().toString();
    } else {
      // Fractional: up to 2 decimals, strip trailing zeros
      final s = value.toStringAsFixed(2);
      return s.replaceAll(RegExp(r'\.?0*$'), '');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Grab the list of orders for our current selection state
    final ordersProvider = context.watch<MrnProvider>();
    final selectedOrders = ordersProvider.getOrdersForDay(
      _selectedDay ?? _focusedDay,
    );

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('MRN Dashboard'),
        // centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ordersProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ordersProvider.errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    ordersProvider.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      context.read<MrnProvider>().fetchAllOrders();
                    },
                    child: const Text('Retry Connection'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // --- CALENDAR ZONE ---
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onVerticalDragEnd: (details) {
                    if (details.primaryVelocity! > 50 &&
                        _calendarFormat == CalendarFormat.week) {
                      setState(() => _calendarFormat = CalendarFormat.month);
                    } else if (details.primaryVelocity! < -50 &&
                        _calendarFormat == CalendarFormat.month) {
                      setState(() => _calendarFormat = CalendarFormat.week);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        TableCalendar(
                          firstDay: DateTime.utc(2025, 1, 1),
                          lastDay: DateTime.utc(2030, 12, 31),
                          focusedDay: _focusedDay,
                          calendarFormat: _calendarFormat,
                          availableGestures: AvailableGestures.all,
                          availableCalendarFormats: const {
                            CalendarFormat.month: 'Month',
                            CalendarFormat.week: 'Week',
                          },
                          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                          eventLoader: ordersProvider.getOrdersForDay,
                          onDaySelected: (selectedDay, focusedDay) {
                            setState(() {
                              _selectedDay = selectedDay;
                              _focusedDay = focusedDay;
                            });
                          },
                          onPageChanged: (focusedDay) {
                            _focusedDay = focusedDay;
                          },

                          // Custom builders for ultra-clean markers
                          calendarBuilders: CalendarBuilders(
                            markerBuilder: (context, date, events) {
                              if (events.isNotEmpty) {
                                return Positioned(
                                  bottom: 4,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFF0C685B), // Matches your primary brand color
                                    ),
                                    width: 5,
                                    height: 5,
                                  ),
                                );
                              }
                              return null;
                            },
                          ),

                          // Clean, borderless modern header
                          headerStyle: const HeaderStyle(
                            titleCentered: true,
                            formatButtonVisible: false,
                            leftChevronMargin: EdgeInsets.symmetric(horizontal: 4),
                            rightChevronMargin: EdgeInsets.symmetric(horizontal: 4),
                            titleTextStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1F2937), // Dark slate/charcoal text
                              letterSpacing: 0.5,
                            ),
                            leftChevronIcon: Icon(
                              Icons.arrow_back_ios_new_rounded, // Sleeker, thinner modern icon
                              size: 16,
                              color: Color(0xFF0C685B),
                            ),
                            rightChevronIcon: Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 16,
                              color: Color(0xFF0C685B),
                            ),
                          ),

                          // Minimalist lowercase/subtle weekday labels
                          daysOfWeekStyle: const DaysOfWeekStyle(
                            weekdayStyle: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF9CA3AF), // Muted grey
                              fontWeight: FontWeight.w600,
                            ),
                            weekendStyle: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF9CA3AF),
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          // The Style Makeover
                          calendarStyle: CalendarStyle(
                            isTodayHighlighted: true,
                            // rowDecoration: 48, // Tightens spacing for a snugger, premium look

                            // Clean modern typography
                            defaultTextStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF374151),
                            ),
                            weekendTextStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF374151),
                            ),
                            outsideTextStyle: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFFD1D5DB), // Blends out matching previous/next month dates
                            ),

                            // Active modern elements
                            selectedDecoration: BoxDecoration(
                              color: const Color(0xFF0C685B),
                              shape: BoxShape.circle, // Circular shapes look cleaner than squircle blocks
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF4F46E5).withValues(alpha: 0.15),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2), // Smooth elevation shadow glow
                                ),
                              ],
                            ),
                            selectedTextStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),

                            // Today indicator (Subtle border circle ring instead of a full colored box)
                            todayDecoration: BoxDecoration(
                              color: Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF4F46E5),
                                width: 1.5,
                              ),
                            ),
                            todayTextStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4F46E5),
                            ),

                            // Removing distracting cell boundaries
                            defaultDecoration: const BoxDecoration(shape: BoxShape.circle),
                            weekendDecoration: const BoxDecoration(shape: BoxShape.circle),
                            outsideDecoration: const BoxDecoration(shape: BoxShape.circle),
                            disabledDecoration: const BoxDecoration(shape: BoxShape.circle),
                            holidayDecoration: const BoxDecoration(shape: BoxShape.circle),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Container(
                            width: 40,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // --- COMPACT ORDERS LIST ZONE ---
                Expanded(
                  child: selectedOrders.isEmpty
                      ? const Center(
                          child: Text(
                            "No orders scheduled for this date.",
                            style: TextStyle(color: Colors.grey, fontSize: 15),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 6.0,
                          ),
                          itemCount: selectedOrders.length,
                          itemBuilder: (context, index) {
                            final order = selectedOrders[index];

                            final isPending =
                                order.status.toLowerCase() == 'pending';

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 4.0),
                              elevation: 0.5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              color: Colors.white,
                              clipBehavior: Clip
                                  .antiAlias, // Ensures the InkWell splash doesn't bleed past the card corners
                              child: InkWell(
                                onTap: () async {
                                  final result = await Navigator.push(
                                    context, 
                                    MaterialPageRoute(
                                      builder: (context) => ViewMrnScreen(
                                        initialItems: order, 
                                        orderNumber: order.orderNumber
                                      )
                                    )
                                  );

                                  if (result == true) {
                                    setState(() {
                                      
                                    });
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14.0,
                                    vertical: 10.0,
                                  ),
                                  child: Column(
                                    children: [
                                      // ROW 1: Site Name & Quantity
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              order.siteName,
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black87,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isPending
                                                  ? Colors.orange[50]
                                                  : Colors.green[50],
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              order.status.toUpperCase(),
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: isPending
                                                    ? Colors.orange[800]
                                                    : Colors.green[800],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            order.totalQty != null && order.totalUom != null
                                                ? '${_formatQty(order.totalQty)} ${order.totalUom}'
                                                : '-',
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 6),

                                      // ROW 2: MRN Order No & Status Badge
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "MRN Order No: ${order.orderNumber ?? 'N/A'}",
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey[600],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0C685B),
        foregroundColor: Colors.white,
        tooltip: 'Create Order',
        onPressed: () async {
          await Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => MaterialReceiptNoteScreen()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
