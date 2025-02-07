// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'street_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$streetProviderHash() => r'7ff4ac9face2778f260379f6379c20c71f7a1f2f';

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

abstract class _$StreetProvider extends BuildlessAsyncNotifier<List<Street>> {
  late final int page;

  FutureOr<List<Street>> build({
    int page = 1,
  });
}

/// See also [StreetProvider].
@ProviderFor(StreetProvider)
const streetProviderProvider = StreetProviderFamily();

/// See also [StreetProvider].
class StreetProviderFamily extends Family<AsyncValue<List<Street>>> {
  /// See also [StreetProvider].
  const StreetProviderFamily();

  /// See also [StreetProvider].
  StreetProviderProvider call({
    int page = 1,
  }) {
    return StreetProviderProvider(
      page: page,
    );
  }

  @override
  StreetProviderProvider getProviderOverride(
    covariant StreetProviderProvider provider,
  ) {
    return call(
      page: provider.page,
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
  String? get name => r'streetProviderProvider';
}

/// See also [StreetProvider].
class StreetProviderProvider
    extends AsyncNotifierProviderImpl<StreetProvider, List<Street>> {
  /// See also [StreetProvider].
  StreetProviderProvider({
    int page = 1,
  }) : this._internal(
          () => StreetProvider()..page = page,
          from: streetProviderProvider,
          name: r'streetProviderProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$streetProviderHash,
          dependencies: StreetProviderFamily._dependencies,
          allTransitiveDependencies:
              StreetProviderFamily._allTransitiveDependencies,
          page: page,
        );

  StreetProviderProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.page,
  }) : super.internal();

  final int page;

  @override
  FutureOr<List<Street>> runNotifierBuild(
    covariant StreetProvider notifier,
  ) {
    return notifier.build(
      page: page,
    );
  }

  @override
  Override overrideWith(StreetProvider Function() create) {
    return ProviderOverride(
      origin: this,
      override: StreetProviderProvider._internal(
        () => create()..page = page,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        page: page,
      ),
    );
  }

  @override
  AsyncNotifierProviderElement<StreetProvider, List<Street>> createElement() {
    return _StreetProviderProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StreetProviderProvider && other.page == page;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, page.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin StreetProviderRef on AsyncNotifierProviderRef<List<Street>> {
  /// The parameter `page` of this provider.
  int get page;
}

class _StreetProviderProviderElement
    extends AsyncNotifierProviderElement<StreetProvider, List<Street>>
    with StreetProviderRef {
  _StreetProviderProviderElement(super.provider);

  @override
  int get page => (origin as StreetProviderProvider).page;
}

String _$loadAllStreetHash() => r'39788237c0a98bbdf98db76b6b15a1c7de30a50a';

/// See also [LoadAllStreet].
@ProviderFor(LoadAllStreet)
final loadAllStreetProvider =
    AutoDisposeAsyncNotifierProvider<LoadAllStreet, List<Street>>.internal(
  LoadAllStreet.new,
  name: r'loadAllStreetProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$loadAllStreetHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$LoadAllStreet = AutoDisposeAsyncNotifier<List<Street>>;
String _$drawStreetHash() => r'ba1ce8a572d19baaed53c6d15e94ed770df1b641';

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
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
