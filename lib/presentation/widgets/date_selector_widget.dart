import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Widget displaying a horizontal week date selector.
class DateSelectorWidget extends StatefulWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const DateSelectorWidget({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  State<DateSelectorWidget> createState() => _DateSelectorWidgetState();
}

class _DateSelectorWidgetState extends State<DateSelectorWidget> {
  late DateTime _selectedDate;
  late List<DateTime> _weekDates;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
    _updateWeekDates();
  }

  @override
  void didUpdateWidget(DateSelectorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate) {
      _selectedDate = widget.selectedDate;
      _updateWeekDates();
    }
  }

  void _updateWeekDates() {
    // Get the start of the week (Monday)
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    
    _weekDates = List.generate(7, (index) {
      return startOfWeek.add(Duration(days: index));
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _weekDates.map((date) {
          final isSelected = _isSelected(date);
          final isToday = _isToday(date);
          
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDate = date;
                });
                widget.onDateSelected(date);
              },
              child: Container(
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
                    // Dot indicator
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? Colors.white
                            : (isToday ? Theme.of(context).colorScheme.primary : Colors.grey.shade400),
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
            ),
          );
        }).toList(),
      ),
    );
  }
}

