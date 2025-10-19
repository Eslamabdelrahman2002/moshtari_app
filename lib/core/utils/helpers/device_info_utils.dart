import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

class DeviceInfoUtils {
  DeviceInfoUtils(this.deviceInfoPlugin);
  final DeviceInfoPlugin deviceInfoPlugin;

  DeviceInfoModel deviceInfoModel = DeviceInfoModel();

  String get os => deviceInfoModel.operatingSystem ?? '';
  String get id => deviceInfoModel.id ?? '';
  String get manufacturer => deviceInfoModel.manufacturer ?? '';
  String get model => deviceInfoModel.model ?? '';

  Future<DeviceInfoModel?> getDeviceInfo() async {
    if (Platform.isAndroid) {
      var androidInfo = await deviceInfoPlugin.androidInfo;
      var release = androidInfo.version.release;
      var sdkInt = androidInfo.version.sdkInt;
      var manufacturer = androidInfo.manufacturer;
      var model = androidInfo.model;
      var deviceId = androidInfo.id;

      deviceInfoModel = DeviceInfoModel(
        operatingSystem: 'ANDROID',
        operatingSystemVersion: '$release (SDK $sdkInt)',
        manufacturer: manufacturer,
        model: model,
        id: deviceId,
      );
    }

    if (Platform.isIOS) {
      var iosInfo = await deviceInfoPlugin.iosInfo;
      var systemName = iosInfo.systemName;
      var version = iosInfo.systemVersion;
      var name = iosInfo.name;
      var model = iosInfo.model;
      var deviceId = iosInfo.identifierForVendor;

      deviceInfoModel = DeviceInfoModel(
        // operatingSystem: systemName,
        operatingSystem: 'IOS',
        operatingSystemVersion: version,
        manufacturer: name,
        model: model,
        id: deviceId,
      );
    }
    // deviceInfoModel.id = await PlatformDeviceId.getDeviceId;

    return deviceInfoModel;
  }
}

class DeviceInfoModel {
  const DeviceInfoModel({
    this.operatingSystem = '',
    this.operatingSystemVersion = '',
    this.manufacturer = '',
    this.model = '',
    this.id = '',
  });

  factory DeviceInfoModel.newDeviceInfoModel() => DeviceInfoModel();
  final String? operatingSystem;
  final String? operatingSystemVersion;
  final String? manufacturer;
  final String? model;
  final String? id;
}
