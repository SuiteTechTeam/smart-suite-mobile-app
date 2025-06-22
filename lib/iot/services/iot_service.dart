import 'dart:convert';
import 'dart:math';
import 'package:smart_suite/core/core.dart';

import '../models/iot_device/create_iot_device_resource.dart';
import '../models/notification_history/create_notification_history_resource.dart';
import '../models/room_device/create_room_device_resource.dart';
import '../models/iot_device/iot_device.dart';
import '../models/notification_history/notification_history.dart';
import '../models/room_device/room_device.dart';
import '../models/iot_device/update_iot_device_resource.dart';
import '../models/room_device/update_room_device_resource.dart';
import '../models/temperature/temperature_data.dart';

class IotService extends BaseService {
  Future<IoTDevice?> createIotDevice(CreateIoTDeviceResource resource) async {
    final response = await authenticatedPost(
      '/io-t/iot-devices',
      body: resource.toJson(),
    );
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return IoTDevice.fromJson(decoded);
      } else {
        // Si el backend responde con true/false, simplemente retorna null
        return null;
      }
    } catch (e) {
      // Si la respuesta no es JSON, ignora el parseo y retorna null
      return null;
    }
  }

  Future<List<IoTDevice>> getAllIotDevices() async {
    final response = await authenticatedGet('/io-t/iot-devices');
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((item) => IoTDevice.fromJson(item)).toList();
  }

  Future<IoTDevice> updateIotDevice(
      int id, UpdateIoTDeviceResource resource) async {
    final response = await authenticatedPut(
      '/io-t/iot-devices/$id',
      body: resource.toJson(),
    );
    return IoTDevice.fromJson(jsonDecode(response.body));
  }

  Future<IoTDevice> getIotDeviceByID(int id) async {
    final response = await authenticatedGet('/io-t/iot-devices/$id');
    return IoTDevice.fromJson(jsonDecode(response.body));
  }

  Future<RoomDevice> createRoomDevice(
      CreateRoomDeviceResource resource) async {
    final response = await authenticatedPost(
      '/io-t/room-devices',
      body: resource.toJson(),
    );
    return RoomDevice.fromJson(jsonDecode(response.body));
  }

  Future<RoomDevice> updateRoomDevice(
      int id, UpdateRoomDeviceResource resource) async {
    final response = await authenticatedPut(
      '/io-t/room-devices/$id',
      body: resource.toJson(),
    );
    return RoomDevice.fromJson(jsonDecode(response.body));
  }

  Future<NotificationHistory> createNotificationHistory(
      CreateNotificationHistoryResource resource) async {
    final response = await authenticatedPost(
      '/io-t/notification-history',
      body: resource.toJson(),
    );
    return NotificationHistory.fromJson(jsonDecode(response.body));
  }

  Future<List<RoomDevice>> getRoomDeviceById(int id) async {
    final response = await authenticatedGet('/io-t/room-devices/by-iot-device/$id');
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((item) => RoomDevice.fromJson(item)).toList();
  }

  Future<List<NotificationHistory>> getRoomDevicesByRoomId(int roomId) async {
    final response = await authenticatedGet('/io-t/notification-history/by-room/$roomId');
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((item) => NotificationHistory.fromJson(item)).toList();
  }

  Future<List<NotificationHistory>> getNotificationhistoryByRoom(int roomId) async {
    final response = await authenticatedGet('/io-t/notification-history/by-room/$roomId');
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((item) => NotificationHistory.fromJson(item)).toList();
  }

  // Temperature data methods
  Future<List<TemperatureData>> getRoomTemperatureHistory(int roomId) async {
    try {
      final response = await authenticatedGet('/io-t/temperature/history/$roomId');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => TemperatureData.fromJson(item)).toList();
      } else {
        throw Exception('Failed to fetch temperature history: ${response.statusCode}');
      }
    } catch (e) {
      // Return mock data for demonstration purposes
      return _getMockTemperatureData(roomId);
    }
  }
  
  // Method for providing mock temperature data for demo purposes
  List<TemperatureData> _getMockTemperatureData(int roomId) {
    final now = DateTime.now();
    return List.generate(24, (i) {
      // Generate temperature between 20-26°C with some variations
      final hour = now.subtract(Duration(hours: 24 - i));
      final baseTemp = 23.0;
      final variation = (i % 5 - 2.5) * 0.8;
      final timeVariation = sin(i / 3) * 1.5;
      
      return TemperatureData(
        roomId: roomId,
        value: baseTemp + variation + timeVariation,
        timestamp: hour,
      );
    });
  }
}