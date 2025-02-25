// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'street_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$updateDataHash() => r'0e60897db2aa366581f31ed5e4e1c2172adbdc12';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [updateData].
@ProviderFor(updateData)
const updateDataProvider = UpdateDataFamily();

/// See also [updateData].
class UpdateDataFamily extends Family<AsyncValue<bool>> {
  /// See also [updateData].
  const UpdateDataFamily();

  /// See also [updateData].
  UpdateDataProvider call(
    List<Street> newStreets,
  ) {
    return UpdateDataProvider(
      newStreets,
    );
  }

  @override
  UpdateDataProvider getProviderOverride(
    covariant UpdateDataProvider provider,
  ) {
    return call(
      provider.newStreets,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'updateDataProvider';
}

/// See also [updateData].
class UpdateDataProvider extends AutoDisposeFutureProvider<bool> {
  /// See also [updateData].
  UpdateDataProvider(
    List<Street> newStreets,
  ) : this._internal(
          (ref) => updateData(
            ref as UpdateDataRef,
            newStreets,
          ),
          from: updateDataProvider,
          name: r'updateDataProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$updateDataHash,
          dependencies: UpdateDataFamily._dependencies,
          allTransitiveDependencies:
              UpdateDataFamily._allTransitiveDependencies,
          newStreets: newStreets,
        );

  UpdateDataProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.newStreets,
  }) : super.internal();

  final List<Street> newStreets;

  @override
  Override overrideWith(
    FutureOr<bool> Function(UpdateDataRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UpdateDataProvider._internal(
        (ref) => create(ref as UpdateDataRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        newStreets: newStreets,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<bool> createElement() {
    return _UpdateDataProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UpdateDataProvider && other.newStreets == newStreets;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, newStreets.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin UpdateDataRef on AutoDisposeFutureProviderRef<bool> {
  /// The parameter `newStreets` of this provider.
  List<Street> get newStreets;
}

class _UpdateDataProviderElement extends AutoDisposeFutureProviderElement<bool>
    with UpdateDataRef {
  _UpdateDataProviderElement(super.provider);

  @override
  List<Street> get newStreets => (origin as UpdateDataProvider).newStreets;
}

String _$routingFnHash() => r'e20dedf644137840edea7e113e4b045c4b1392c2';

/// See also [routingFn].
@ProviderFor(routingFn)
final routingFnProvider = AutoDisposeFutureProvider<RoutingFn?>.internal(
  routingFn,
  name: r'routingFnProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$routingFnHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RoutingFnRef = AutoDisposeFutureProviderRef<RoutingFn?>;
String _$loadAllStreetHash() => r'0d4a43f3c10a35ad5c7e6a560d04ff7b07532e2c';

/// See also [LoadAllStreet].
@ProviderFor(LoadAllStreet)
final loadAllStreetProvider =
    AutoDisposeAsyncNotifierProvider<LoadAllStreet, void>.internal(
  LoadAllStreet.new,
  name: r'loadAllStreetProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$loadAllStreetHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$LoadAllStreet = AutoDisposeAsyncNotifier<void>;
String _$drawStreetHash() => r'7a9a0e5cd720d855e03b3579de7c8c250d74b2d9';

/// See also [DrawStreet].
@ProviderFor(DrawStreet)
final drawStreetProvider = AsyncNotifierProvider<DrawStreet, MapData>.internal(
  DrawStreet.new,
  name: r'drawStreetProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$drawStreetHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DrawStreet = AsyncNotifier<MapData>;
String _$loadedStreetDataHash() => r'3452e0517be35e20b14648ec2f0b068353a2d948';

/// See also [LoadedStreetData].
@ProviderFor(LoadedStreetData)
final loadedStreetDataProvider =
    AutoDisposeAsyncNotifierProvider<LoadedStreetData, List<Street>>.internal(
  LoadedStreetData.new,
  name: r'loadedStreetDataProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$loadedStreetDataHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$LoadedStreetData = AutoDisposeAsyncNotifier<List<Street>>;
String _$inMemoryStreetHash() => r'33a53b84d7daa7f4667d6fc5119ef9b3d449bfcf';

/// See also [InMemoryStreet].
@ProviderFor(InMemoryStreet)
final inMemoryStreetProvider =
    AutoDisposeNotifierProvider<InMemoryStreet, List<Street>>.internal(
  InMemoryStreet.new,
  name: r'inMemoryStreetProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$inMemoryStreetHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$InMemoryStreet = AutoDisposeNotifier<List<Street>>;
String _$focusedStreetHash() => r'07fead3d2cf314846388f908d78dc37345797277';

/// See also [FocusedStreet].
@ProviderFor(FocusedStreet)
final focusedStreetProvider =
    AutoDisposeNotifierProvider<FocusedStreet, Street?>.internal(
  FocusedStreet.new,
  name: r'focusedStreetProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$focusedStreetHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$FocusedStreet = AutoDisposeNotifier<Street?>;
String _$markerDataHash() => r'c49ee2c09ed9604954b8e3a0cc9838b47bf54e6f';

/// See also [MarkerData].
@ProviderFor(MarkerData)
final markerDataProvider =
    AutoDisposeNotifierProvider<MarkerData, Set<TmpRouteData>>.internal(
  MarkerData.new,
  name: r'markerDataProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$markerDataHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$MarkerData = AutoDisposeNotifier<Set<TmpRouteData>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
