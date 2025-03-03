// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_location_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$myLocationHash() => r'6b2299ebedc520b96c57496d157c1770f490bafa';

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
String _$checkPermissionHash() => r'2f54fa6a603536764073423beab15f17e4053fb8';

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
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
