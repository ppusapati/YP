import 'package:drift/native.dart';
import 'package:farmer_app/features/farm/data/datasources/farm_local_datasource.dart';
import 'package:farmer_app/features/farm/data/models/farm_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

/// The offline cache, against real SQLite.
///
/// The repositories fall back to this cache whenever the network fails, which
/// on a rural connection is most of the time — so a farmer's experience of the
/// app is largely the cache's behaviour, not the network's.
///
/// Unit tests mock the datasource, which proves the repository calls it and
/// nothing about whether the Drift schema, the type converters or the
/// migrations work. This drives the real database: in-memory SQLite with the
/// shipped schema, opened the way the app opens it.
///
/// Runs headlessly — sqlite3 needs no device — so it belongs here rather than
/// under `integration_test/`, where it would only run when CI has an emulator.
/// A test that needs a device it rarely gets is a test that rarely runs.

const _owner = 'user-1';

FarmModel _farm({
  String id = 'farm-1',
  String name = 'North Block',
  double areaHectares = 12.5,
  List<LatLng>? boundaries,
}) {
  return FarmModel(
    id: id,
    name: name,
    ownerId: _owner,
    boundaries: boundaries ??
        const [
          LatLng(20.1000, 77.3000),
          LatLng(20.1010, 77.3000),
          LatLng(20.1010, 77.3012),
          LatLng(20.1000, 77.3012),
        ],
    totalAreaHectares: areaHectares,
    createdAt: DateTime.utc(2026, 3, 1, 8),
    updatedAt: DateTime.utc(2026, 3, 14, 9, 30),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('farm cache', () {
    late FarmDatabase db;
    late FarmLocalDataSource cache;

    setUp(() {
      db = FarmDatabase(NativeDatabase.memory());
      cache = FarmLocalDataSourceImpl(database: db);
    });

    tearDown(() => db.close());

    testWidgets('a fresh database opens and migrates', (_) async {
      // A migration that fails on a fresh install is invisible to every mocked
      // test and fatal on first launch.
      expect(await cache.getFarms(_owner), isEmpty);
    });

    testWidgets('a cached farm comes back as it went in', (_) async {
      await cache.cacheFarms([_farm()]);

      final read = await cache.getFarms(_owner);

      expect(read, hasLength(1));
      expect(read.single.id, 'farm-1');
      expect(read.single.name, 'North Block');
      // Doubles through SQLite are where a converter written against the wrong
      // column type shows up, and an area that rounds to zero would make every
      // per-hectare figure in the app wrong.
      expect(read.single.totalAreaHectares, closeTo(12.5, 1e-9));
    });

    testWidgets('a boundary polygon survives the round trip', (_) async {
      // The polygon is encoded into a text column. A boundary that comes back
      // empty, or with its latitude and longitude swapped, puts the farm in
      // the wrong hemisphere — and the row still looks like a valid record.
      await cache.cacheFarms([_farm()]);

      final read = await cache.getFarms(_owner);
      final boundary = read.single.boundaries;

      expect(boundary, hasLength(4));
      expect(boundary.first.latitude, closeTo(20.1000, 1e-9));
      expect(boundary.first.longitude, closeTo(77.3000, 1e-9));
    });

    testWidgets('timestamps survive the round trip', (_) async {
      await cache.cacheFarms([_farm()]);

      final read = await cache.getFarms(_owner);

      expect(read.single.updatedAt.toUtc(), DateTime.utc(2026, 3, 14, 9, 30));
    });

    testWidgets('caching the same farm twice does not duplicate it', (_) async {
      // A repository refreshing from the network writes the same rows on every
      // fetch; without an upsert the list grows without bound and the farm
      // appears several times on the dashboard.
      await cache.cacheFarms([_farm()]);
      await cache.cacheFarms([_farm()]);

      expect(await cache.getFarms(_owner), hasLength(1));
    });

    testWidgets('a re-cached farm reflects the newer values', (_) async {
      await cache.cacheFarms([_farm()]);
      await cache.cacheFarms([
        _farm(name: 'North Block (surveyed)', areaHectares: 13.1),
      ]);

      final read = await cache.getFarms(_owner);

      expect(read, hasLength(1));
      expect(read.single.name, 'North Block (surveyed)');
      expect(read.single.totalAreaHectares, closeTo(13.1, 1e-9));
    });

    testWidgets('getFarmById finds a farm and misses cleanly', (_) async {
      await cache.cacheFarms([_farm()]);

      expect((await cache.getFarmById('farm-1'))?.name, 'North Block');
      expect(
        await cache.getFarmById('farm-nope'),
        isNull,
        reason: 'a miss is null, not an empty farm that renders as a real one',
      );
    });

    testWidgets('a deleted farm is gone', (_) async {
      await cache.cacheFarms([_farm(), _farm(id: 'farm-2', name: 'South')]);

      await cache.deleteFarm('farm-1');

      final read = await cache.getFarms(_owner);
      expect(read, hasLength(1));
      expect(read.single.id, 'farm-2');
    });

    testWidgets('clearAll empties the cache', (_) async {
      // What sign-out has to do: leaving one tenant's farms on the device for
      // the next person to sign in is the failure worth preventing.
      await cache.cacheFarms([_farm(), _farm(id: 'farm-2', name: 'South')]);

      await cache.clearAll();

      expect(await cache.getFarms(_owner), isEmpty);
    });
  });
}
