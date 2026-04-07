class SmokeEntry {
  final int? id;
  final DateTime timestamp;
  final double cost;

  const SmokeEntry({
    this.id,
    required this.timestamp,
    required this.cost,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'cost': cost,
    };
  }

  factory SmokeEntry.fromMap(Map<String, dynamic> map) {
    return SmokeEntry(
      id: map['id'] as int?,
      timestamp:
          DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      cost: (map['cost'] as num).toDouble(),
    );
  }
}
