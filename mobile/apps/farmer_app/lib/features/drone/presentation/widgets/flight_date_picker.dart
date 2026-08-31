import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/drone_layer_entity.dart';
import '../bloc/drone_bloc.dart';
import '../bloc/drone_event.dart';
import '../bloc/drone_state.dart';

class FlightDatePicker extends StatelessWidget {
  const FlightDatePicker({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DroneBloc, DroneState>(
      builder: (context, state) {
        if (state is! DroneLayersLoaded || state.flights.isEmpty) {
          return const SizedBox.shrink();
        }

        final selectedFlight = state.selectedFlight;
        final dateFormat = DateFormat('MMM d, yyyy');

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButtonFormField<DroneFlight>(
            value: selectedFlight,
            decoration: InputDecoration(
              labelText: 'Flight Date',
              prefixIcon: const Icon(Icons.flight_takeoff, size: 20),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: state.flights.map((flight) {
              return DropdownMenuItem<DroneFlight>(
                value: flight,
                child: Row(
                  children: [
                    Text(dateFormat.format(flight.flightDate)),
                    const SizedBox(width: 8),
                    Text(
                      '${flight.layers.length} layers',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (flight) {
              if (flight != null) {
                context.read<DroneBloc>().add(SelectFlight(flight));
              }
            },
            hint: const Text('Select a flight'),
          ),
        );
      },
    );
  }
}
