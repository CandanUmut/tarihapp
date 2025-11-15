class StreakDay {
  const StreakDay({
    required this.date,
    required this.done,
  });

  factory StreakDay.fromJson(Map<String, dynamic> json) {
    return StreakDay(
      date: json['date'] as int,
      done: json['done'] as bool,
    );
  }

  final int date;
  final bool done;

  Map<String, dynamic> toJson() => {
        'date': date,
        'done': done,
      };
}

class StreakStats {
  const StreakStats({
    required this.current,
    required this.longest,
    required this.days,
  });

  final int current;
  final int longest;
  final List<StreakDay> days;
}
