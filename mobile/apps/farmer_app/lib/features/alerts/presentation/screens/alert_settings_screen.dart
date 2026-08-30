import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import '../../domain/entities/alert_entity.dart';
import '../../domain/repositories/alert_repository.dart';

/// Screen for configuring alert rules per field with notification channel
/// toggles and threshold settings.
class AlertSettingsScreen extends StatefulWidget {
  const AlertSettingsScreen({
    super.key,
    required this.repository,
  });

  final AlertRepository repository;

  @override
  State<AlertSettingsScreen> createState() => _AlertSettingsScreenState();
}

class _AlertSettingsScreenState extends State<AlertSettingsScreen> {
  static final _log = Logger('AlertSettingsScreen');

  List<AlertRule> _rules = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRules();
  }

  Future<void> _loadRules() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final rules = await widget.repository.getAlertRules();
      setState(() {
        _rules = rules;
        _loading = false;
      });
    } catch (e) {
      _log.warning('Failed to load alert rules: $e');
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _toggleRule(AlertRule rule, bool enabled) async {
    final updated = rule.copyWith(enabled: enabled);
    try {
      final result = await widget.repository.updateAlertRule(updated);
      setState(() {
        _rules = _rules.map((r) => r.id == result.id ? result : r).toList();
      });
    } catch (e) {
      _log.warning('Failed to update rule: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update rule: $e')),
        );
      }
    }
  }

  Future<void> _toggleChannel(
    AlertRule rule, {
    bool? push,
    bool? email,
    bool? sms,
  }) async {
    final updated = rule.copyWith(
      pushEnabled: push ?? rule.pushEnabled,
      emailEnabled: email ?? rule.emailEnabled,
      smsEnabled: sms ?? rule.smsEnabled,
    );
    try {
      final result = await widget.repository.updateAlertRule(updated);
      setState(() {
        _rules = _rules.map((r) => r.id == result.id ? result : r).toList();
      });
    } catch (e) {
      _log.warning('Failed to update notification channel: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alert Settings'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline,
                          size: 48, color: theme.colorScheme.error),
                      const SizedBox(height: 16),
                      Text('Failed to load settings',
                          style: theme.textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text(_error!, style: theme.textTheme.bodySmall),
                      const SizedBox(height: 16),
                      FilledButton.tonal(
                        onPressed: _loadRules,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _rules.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.rule_outlined,
                              size: 64, color: theme.colorScheme.outline),
                          const SizedBox(height: 16),
                          Text('No alert rules configured',
                              style: theme.textTheme.titleMedium),
                          const SizedBox(height: 4),
                          Text(
                            'Rules will appear here when fields are set up',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadRules,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: _rules.length,
                        itemBuilder: (context, index) {
                          final rule = _rules[index];
                          return _AlertRuleCard(
                            rule: rule,
                            onToggle: (enabled) =>
                                _toggleRule(rule, enabled),
                            onToggleChannel: ({push, email, sms}) =>
                                _toggleChannel(rule,
                                    push: push, email: email, sms: sms),
                          );
                        },
                      ),
                    ),
    );
  }
}

class _AlertRuleCard extends StatelessWidget {
  const _AlertRuleCard({
    required this.rule,
    required this.onToggle,
    required this.onToggleChannel,
  });

  final AlertRule rule;
  final ValueChanged<bool> onToggle;
  final void Function({bool? push, bool? email, bool? sms}) onToggleChannel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rule.alertType.displayName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        rule.fieldName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: rule.enabled,
                  onChanged: onToggle,
                ),
              ],
            ),
            if (rule.enabled) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Text(
                'Min. Severity: ${rule.minimumSeverity.displayName}',
                style: theme.textTheme.bodySmall,
              ),
              if (rule.threshold != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Threshold: ${rule.threshold}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 12),
              Text(
                'Notification Channels',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _ChannelChip(
                    icon: Icons.notifications_outlined,
                    label: 'Push',
                    enabled: rule.pushEnabled,
                    onToggle: (v) => onToggleChannel(push: v),
                  ),
                  const SizedBox(width: 8),
                  _ChannelChip(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    enabled: rule.emailEnabled,
                    onToggle: (v) => onToggleChannel(email: v),
                  ),
                  const SizedBox(width: 8),
                  _ChannelChip(
                    icon: Icons.sms_outlined,
                    label: 'SMS',
                    enabled: rule.smsEnabled,
                    onToggle: (v) => onToggleChannel(sms: v),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ChannelChip extends StatelessWidget {
  const _ChannelChip({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onToggle,
  });

  final IconData icon;
  final String label;
  final bool enabled;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      selected: enabled,
      onSelected: onToggle,
      visualDensity: VisualDensity.compact,
    );
  }
}
