// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_location_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

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
String _$requestPermissionHash() => r'1696ac89bfad2c1235c3317d9b585c16a273a2af';

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
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
