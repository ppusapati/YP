/// Defines the roles available in the unified YieldPoint app.
enum UserRole {
  farmer,
  agronomist;

  String get displayName => switch (this) {
        farmer => 'Farmer',
        agronomist => 'Agronomist',
      };

  String get appTitle => switch (this) {
        farmer => 'YieldPoint',
        agronomist => 'YieldPoint Agronomist',
      };
}
