import 'package:smart_suite/core/core.dart';

import '../models/create_iot_device_resource.dart';
import '../models/create_notification_history_resource.dart';
import '../models/create_room_device_resource.dart';
import '../models/iot_device.dart';
import '../models/notification_history.dart';
import '../models/room_device.dart';
import '../models/update_iot_device_resource.dart';
import '../models/update_room_device_resource.dart';

class IotService extends BaseService {
  Future<IoTDevice> createIotDevice(CreateIoTDeviceResource resource) async {
    final response = await authenticatedPost(
      '/io-t/iot-devices',
      body: resource.toJson(),
    );
    return IoTDevice.fromJson(response.body as Map<String, dynamic>);
  }

  Future<List<IoTDevice>> getAllIotDevices() async {
    final response = await authenticatedGet('/io-t/iot-devices');
    final List<dynamic> data = response.body as List<dynamic>;
    return data.map((item) => IoTDevice.fromJson(item)).toList();
  }

  Future<IoTDevice> updateIotDevice(
      int id, UpdateIoTDeviceResource resource) async {
    final response = await authenticatedPut(
      '/io-t/iot-devices/$id',
      body: resource.toJson(),
    );
    return IoTDevice.fromJson(response.body as Map<String, dynamic>);
  }

  Future<IoTDevice> getIotDeviceByID(int id) async {
    final response = await authenticatedGet('/io-t/iot-devices/$id');
    return IoTDevice.fromJson(response.body as Map<String, dynamic>);
  }

  Future<RoomDevice> createRoomDevice(
      CreateRoomDeviceResource resource) async {
    final response = await authenticatedPost(
      '/io-t/room-devices',
      body: resource.toJson(),
    );
    return RoomDevice.fromJson(response.body as Map<String, dynamic>);
  }

  Future<RoomDevice> updateRoomDevice(
      int id, UpdateRoomDeviceResource resource) async {
    final response = await authenticatedPut(
      '/io-t/room-devices/$id',
      body: resource.toJson(),
    );
    return RoomDevice.fromJson(response.body as Map<String, dynamic>);
  }

  Future<NotificationHistory> createNotificationHistory(
      CreateNotificationHistoryResource resource) async {
    final response = await authenticatedPost(
      '/io-t/notification-history',
      body: resource.toJson(),
    );
    return NotificationHistory.fromJson(response.body as Map<String, dynamic>);
  }

  Future<List<RoomDevice>> getRoomDeviceById(int id) async {
    final response = await authenticatedGet('/io-t/room-devices/by-iot-device/$id');
    final List<dynamic> data = response.body as List<dynamic>;
    return data.map((item) => RoomDevice.fromJson(item)).toList();
  }

  Future<List<NotificationHistory>> getRoomDevicesByRoomId(int roomId) async {
    final response = await authenticatedGet('/io-t/notification-history/by-room/$roomId');
    final List<dynamic> data = response.body as List<dynamic>;
    return data.map((item) => NotificationHistory.fromJson(item)).toList();
  }

  Future<List<NotificationHistory>> getNotificationhistoryByRoom(int roomId) async {
    final response = await authenticatedGet('/io-t/notification-history/by-room/$roomId');
    final List<dynamic> data = response.body as List<dynamic>;
    return data.map((item) => NotificationHistory.fromJson(item)).toList();
  }
}