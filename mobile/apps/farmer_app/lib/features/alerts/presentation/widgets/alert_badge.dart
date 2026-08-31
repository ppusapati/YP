import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/alert_bloc.dart';
import '../bloc/alert_state.dart';

class AlertBadge extends StatelessWidget {
  const AlertBadge({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AlertBloc, AlertState>(
      buildWhen: (previous, current) {
        final prevCount =
            previous is AlertsLoaded ? previous.unreadCount : 0;
        final currCount =
            current is AlertsLoaded ? current.unreadCount : 0;
        return prevCount != currCount;
      },
      builder: (context, state) {
        final count = state is AlertsLoaded ? state.unreadCount : 0;

        if (count == 0) return child;

        return Badge(
          label: Text(
            count > 99 ? '99+' : count.toString(),
            style: const TextStyle(fontSize: 10),
          ),
          child: child,
        );
      },
    );
  }
}
