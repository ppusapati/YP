import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/crop_recommendation_bloc.dart';
import '../bloc/crop_recommendation_event.dart';
import '../bloc/crop_recommendation_state.dart';
import '../widgets/recommendation_card.dart';

class CropRecommendationScreen extends StatelessWidget {
  const CropRecommendationScreen({
    super.key,
    this.fieldId,
  });

  final String? fieldId;

  @override
  Widget build(BuildContext context) {
    if (fieldId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final bloc = context.read<CropRecommendationBloc>();
        if (bloc.state is CropRecInitial) {
          bloc.add(LoadRecommendations(fieldId: fieldId!));
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop Recommendations'),
      ),
      body: BlocBuilder<CropRecommendationBloc, CropRecommendationState>(
        builder: (context, state) {
          if (state is CropRecLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CropRecError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load recommendations',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  if (fieldId != null)
                    FilledButton.tonal(
                      onPressed: () {
                        context
                            .read<CropRecommendationBloc>()
                            .add(LoadRecommendations(fieldId: fieldId!));
                      },
                      child: const Text('Retry'),
                    ),
                ],
              ),
            );
          }

          if (state is CropRecInitial) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.agriculture_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Select a field to get recommendations',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }

          if (state is RecommendationsLoaded) {
            final recs = state.recommendations;

            if (recs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No recommendations available',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Try selecting a different field',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 24),
              itemCount: recs.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: Text(
                      '${recs.length} crops recommended',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    ),
                  );
                }
                return RecommendationCard(
                  recommendation: recs[index - 1],
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
