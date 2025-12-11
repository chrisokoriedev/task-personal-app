import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/task.dart';

/// Widget displaying a horizontal week date selector.
class DateSelectorWidget extends StatefulWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final List<Task> tasks;

  const DateSelectorWidget({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    required this.tasks,
  });

  @override
  State<DateSelectorWidget> createState() => _DateSelectorWidgetState();
}

class _DateSelectorWidgetState extends State<DateSelectorWidget> {
  late ScrollController _scrollController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedDate();
    });
  }

  @override
  void didUpdateWidget(DateSelectorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate) {
      _selectedDate = widget.selectedDate;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSelectedDate();
      });
    }
    // If tasks changed, we might need to regenerate dates and scroll
    if (oldWidget.tasks.length != widget.tasks.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSelectedDate();
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSelectedDate() {
    if (!_scrollController.hasClients) return;
    
    final weekDates = _getWeekDates(_selectedDate);
    final selectedIndex = weekDates.indexWhere((date) =>
        date.year == _selectedDate.year &&
        date.month == _selectedDate.month &&
        date.day == _selectedDate.day);
    
    if (selectedIndex != -1) {
      // Calculate scroll position: each item is 60px wide + 8px margins (4px each side)
      final itemWidth = 68.0; // 60px width + 8px margins
      final screenWidth = MediaQuery.of(context).size.width;
      final scrollPosition = (selectedIndex * itemWidth) - (screenWidth / 2) + (itemWidth / 2);
      
      _scrollController.animateTo(
        scrollPosition.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  List<DateTime> _getWeekDates(DateTime centerDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Find the earliest and latest dates from tasks
    DateTime? earliestDate;
    DateTime? latestDate;
    
    for (final task in widget.tasks) {
      if (task.dueDate != null) {
        final taskDate = DateTime(
          task.dueDate!.year,
          task.dueDate!.month,
          task.dueDate!.day,
        );
        if (earliestDate == null || taskDate.isBefore(earliestDate)) {
          earliestDate = taskDate;
        }
        if (latestDate == null || taskDate.isAfter(latestDate)) {
          latestDate = taskDate;
        }
      }
    }
    
    // Determine the date range to show
    // Start from: earliest task date, today, or selected date (whichever is earliest) - 1 week buffer
    // End at: latest task date, today, or selected date (whichever is latest) + 1 week buffer
    final datesToConsider = <DateTime>[today, centerDate];
    if (earliestDate != null) datesToConsider.add(earliestDate);
    if (latestDate != null) datesToConsider.add(latestDate);
    
    final startDate = datesToConsider.reduce((a, b) => a.isBefore(b) ? a : b);
    final endDate = datesToConsider.reduce((a, b) => a.isAfter(b) ? a : b);
    
    // Add buffer weeks
    final bufferStart = startDate.subtract(const Duration(days: 7));
    final bufferEnd = endDate.add(const Duration(days: 7));
    
    // Get the start of the week (Monday) for the earliest date
    final startOfFirstWeek = bufferStart.subtract(
      Duration(days: bufferStart.weekday - 1),
    );
    
    // Calculate number of weeks needed
    final daysDifference = bufferEnd.difference(startOfFirstWeek).inDays;
    final weeksNeeded = (daysDifference / 7).ceil() + 1;
    
    // Generate all dates
    final allDates = <DateTime>[];
    for (int week = 0; week < weeksNeeded; week++) {
      final weekStart = startOfFirstWeek.add(Duration(days: week * 7));
      for (int day = 0; day < 7; day++) {
        final date = weekStart.add(Duration(days: day));
        // Only add dates up to the buffer end
        if (date.isBefore(bufferEnd.add(const Duration(days: 1)))) {
          allDates.add(date);
        }
      }
    }
    
    return allDates;
  }

  bool _hasTasksForDate(DateTime date) {
    return widget.tasks.any((task) {
      if (task.dueDate == null) return false;
      final taskDate = DateTime(
        task.dueDate!.year,
        task.dueDate!.month,
        task.dueDate!.day,
      );
      final checkDate = DateTime(date.year, date.month, date.day);
      return taskDate.isAtSameMomentAs(checkDate);
    });
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isSelected(DateTime date) {
    return _selectedDate.year == date.year &&
        _selectedDate.month == date.month &&
        _selectedDate.day == date.day;
  }

  String _getDayAbbreviation(DateTime date) {
    return DateFormat('EEE').format(date).substring(0, 3);
  }

  @override
  Widget build(BuildContext context) {
    final weekDates = _getWeekDates(_selectedDate);
    
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: weekDates.length,
        itemBuilder: (context, index) {
          final date = weekDates[index];
          final isSelected = _isSelected(date);
          final isToday = _isToday(date);
          final hasTasks = _hasTasksForDate(date);
          
          return GestureDetector(
            onTap: () => widget.onDateSelected(date),
            child: Container(
              width: 60,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey.shade300,
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dot indicator - show if has tasks or is today
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? Colors.white
                          : (hasTasks
                              ? Theme.of(context).colorScheme.primary
                              : (isToday
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey.shade400)),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Day abbreviation
                  Text(
                    _getDayAbbreviation(date),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Day number
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : Colors.grey.shade900,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

