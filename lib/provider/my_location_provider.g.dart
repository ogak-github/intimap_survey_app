// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_location_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$hasLocationHash() => r'4fbd583147131c6d86621ae25c62d641716d32c3';

/// See also [hasLocation].
@ProviderFor(hasLocation)
final hasLocationProvider = Provider<bool>.internal(
  hasLocation,
  name: r'hasLocationProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$hasLocationHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HasLocationRef = ProviderRef<bool>;
String _$locationUpdateHash() => r'27d98edae699a8657461f6cc7421e51f5cce700d';

/// See also [locationUpdate].
@ProviderFor(locationUpdate)
final locationUpdateProvider = StreamProvider<LocationData?>.internal(
  locationUpdate,
  name: r'locationUpdateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$locationUpdateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LocationUpdateRef = StreamProviderRef<LocationData?>;
String _$myLocationHash() => r'aa0d104d2c1f261e9a98acf4055705c16bf30800';

/// See also [MyLocation].
@ProviderFor(MyLocation)
final myLocationProvider =
    AutoDisposeAsyncNotifierProvider<MyLocation, LocationData?>.internal(
  MyLocation.new,
  name: r'myLocationProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$myLocationHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$MyLocation = AutoDisposeAsyncNotifier<LocationData?>;
String _$checkServiceHash() => r'd181eeba74de00cddd3d3c2464f1ceddd2eafc43';

/// See also [CheckService].
@ProviderFor(CheckService)
final checkServiceProvider =
    AutoDisposeAsyncNotifierProvider<CheckService, bool>.internal(
  CheckService.new,
  name: r'checkServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$checkServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CheckService = AutoDisposeAsyncNotifier<bool>;
String _$checkPermissionHash() => r'4f332812e011ed2ae244c00c9ed48547e45cc0c1';

/// See also [CheckPermission].
@ProviderFor(CheckPermission)
final checkPermissionProvider =
    AutoDisposeAsyncNotifierProvider<CheckPermission, bool>.internal(
  CheckPermission.new,
  name: r'checkPermissionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$checkPermissionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CheckPermission = AutoDisposeAsyncNotifier<bool>;
String _$requestPermissionHash() => r'07717c63bec9ccfbfd7c43e49f8d27ef39b3ae26';

/// See also [RequestPermission].
@ProviderFor(RequestPermission)
final requestPermissionProvider =
    AutoDisposeNotifierProvider<RequestPermission, void>.internal(
  RequestPermission.new,
  name: r'requestPermissionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$requestPermissionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$RequestPermission = AutoDisposeNotifier<void>;
String _$myCurrentLocationHash() => r'4a7a65d707ca77224472da30794ce189ec0bbe5e';

/// See also [MyCurrentLocation].
@ProviderFor(MyCurrentLocation)
final myCurrentLocationProvider =
    NotifierProvider<MyCurrentLocation, LocationData?>.internal(
  MyCurrentLocation.new,
  name: r'myCurrentLocationProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$myCurrentLocationHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$MyCurrentLocation = Notifier<LocationData?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
