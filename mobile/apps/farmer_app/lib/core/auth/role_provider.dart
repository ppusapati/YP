import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'user_role.dart';

/// Provider holding the current user's role. Override at startup based on
/// authentication data. Defaults to [UserRole.farmer].
final userRoleProvider = StateProvider<UserRole>((ref) => UserRole.farmer);
