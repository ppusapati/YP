import 'package:equatable/equatable.dart';

class YieldFactor extends Equatable {
  const YieldFactor({
    required this.name,
    required this.impact,
    required this.value,
  });

  final String name;
  final double impact; // -1.0 to 1.0, negative = reducing yield
  final double value;

  bool get isPositive => impact >= 0;
  String get impactPercentage => '${(impact * 100).toStringAsFixed(1)}%';

  @override
  List<Object?> get props => [name, impact, value];
}
