import 'dart:ui' as ui;

import 'package:dartx/dartx.dart';
import 'package:meta/meta.dart';
import 'package:time_machine/time_machine.dart';

import 'basic.dart';

/// The base class of all events.
///
/// See also:
/// - [BasicEvent], which provides a basic implementation to get you started.
abstract class Event {
  Event({
    @required this.id,
    this.size,
    this.offset,
    @required this.start,
    @required this.end,
  })
      : assert(id != null),
        assert(start != null),
        assert(end != null),
        assert(start <= end);

  /// A unique ID, used e.g. for animating events.
  final Object id;

  /// Size of event widget.
  ui.Size size;

  /// Offset of event widget.
  ui.Offset offset;

  /// Start of the event.
  LocalDateTime start;

  // End of the event; exclusive.
  LocalDateTime end;

  bool get isAllDay =>
      start
          .periodUntil(end)
          .normalize()
          .days >= 1;

  bool get isPartDay => !isAllDay;

  @override
  bool operator ==(dynamic other) {
    return runtimeType == other.runtimeType &&
        id == other.id &&
        start == other.start &&
        end == other.end;
  }

  @override
  int get hashCode => ui.hashList([runtimeType, id, start, end]);

  @override
  String toString() => id.toString();
}

extension TimetableEvent on Event {
  bool intersectsDate(LocalDate date) =>
      intersectsInterval(DateInterval(date, date));

  bool intersectsInterval(DateInterval interval) {
    return start.calendarDate <= interval.end &&
        endDateInclusive >= interval.start;
  }

  LocalDate get endDateInclusive {
    if (start.calendarDate == end.calendarDate) {
      return end.calendarDate;
    }

    return (end - Period(nanoseconds: 1)).calendarDate;
  }

  DateInterval get intersectingDates =>
      DateInterval(start.calendarDate, endDateInclusive);
}

extension TimetableEventIterable<E extends Event> on Iterable<E> {
  Iterable<E> get allDayEvents => where((e) => e.isAllDay);

  Iterable<E> get partDayEvents => where((e) => e.isPartDay);

  Iterable<E> intersectingInterval(DateInterval interval) =>
      where((e) => e.intersectsInterval(interval));

  Iterable<E> intersectingDate(LocalDate date) =>
      where((e) => e.intersectsDate(date));

  List<E> sortedByStartLength() =>
      sortedBy((e) => e.start).thenByDescending((e) => e.end);
}
