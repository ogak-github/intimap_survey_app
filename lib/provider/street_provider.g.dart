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

String _$loadAllStreetHash() => r'823383a7a0d24ab3794646b859f911a37b9533d5';

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
String _$drawStreetHash() => r'ee7fda8d250769f0fbee99af2784d7477d401054';

/// See also [DrawStreet].
@ProviderFor(DrawStreet)
final drawStreetProvider =
    AutoDisposeAsyncNotifierProvider<DrawStreet, Set<Polyline>>.internal(
  DrawStreet.new,
  name: r'drawStreetProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$drawStreetHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DrawStreet = AutoDisposeAsyncNotifier<Set<Polyline>>;
String _$loadedStreetDataHash() => r'4ea2778dc0dcabde01f17407cc1556733e1d44b9';

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
String _$inMemoryStreetHash() => r'108f85fda37c78a42d075dd0fe1485d5e7776bc0';

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
String _$focusedStreetHash() => r'200ce9b64ca10de77178df3a03013ded547dea19';

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
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
