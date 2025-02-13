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

String _$loadAllStreetHash() => r'4a09e0e750e04daec206767b1a6de8d3495e8be3';

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
String _$drawStreetHash() => r'2c6fd32c710a6e598affb26aef6feeaff2131bfc';

/// See also [DrawStreet].
@ProviderFor(DrawStreet)
final drawStreetProvider =
    AsyncNotifierProvider<DrawStreet, Set<Polyline>>.internal(
  DrawStreet.new,
  name: r'drawStreetProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$drawStreetHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DrawStreet = AsyncNotifier<Set<Polyline>>;
String _$loadedStreetDataHash() => r'8407771f3fcbbbf00d1522bf03eb10739273efef';

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
String _$inMemoryStreetHash() => r'7e516227f499bc3a6cf172c7afa94d3277004a20';

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
