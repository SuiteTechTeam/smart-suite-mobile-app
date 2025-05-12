
import 'package:http/http.dart' as http;

import 'dart:convert';

// Package = dependency

import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class AuthService{
  // https://sweetmanager-api.ryzeon.me/api/v1/authentication
  final String baseUrl = 'https://sweetmanager-api.ryzeon.me/api/v1/authentication';

  final storage = const FlutterSecureStorage();

  Future<bool> login(String email, String password, int roleId) async
  {
    try
    {
      final response = await http.post(Uri.parse('$baseUrl/sign-in'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
        'rolesId': roleId
      }));

      if(response.statusCode == 200){
        final data = jsonDecode(response.body);

        await storage.write(key: 'token', value: data['token']);

        return true;
      }

      return false;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> signup(int id, String username, String name, String surname, String email, String phone, String password) async
  {
    try
    {
      final response = await http.post(Uri.parse('$baseUrl/sign-up-owner'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'id': id,
          'username': username,
          'name': name,
          'surname': surname,
          'email': email,
          'phone': phone,
          'state': 'ACTIVE',
          'password': password
        })
      );

      if(response.statusCode == 200)
      {
        return true;
      }

      return false;
    } catch(e)
    {
      rethrow;
    }

  }

  Future<bool> signupAdmin(int dni, String username, String name, String surname, String email, String phone, String password) async 
  {
    try
    {
      final response = await http.post(Uri.parse('$baseUrl/sign-up-admin'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'id': dni,
        'username': username,
        'name': name,
        'surname': surname,
        'email': email,
        'phone': phone,
        'state': 'ACTIVE',
        'password': password
      }));

      if(response.statusCode == 200)
      {
        return true;
      }
      else
      {
        return false;
      }
    }
    catch(e)
    {
      rethrow;
    }

  }


  Future<bool> signupWorker(int dni, String username, String name, String surname, String email, String phone, String password) async 
  {
    try
    {
      final response = await http.post(Uri.parse('$baseUrl/sign-up-worker'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'id': dni,
        'username': username,
        'name': name,
        'surname': surname,
        'email': email,
        'phone': phone,
        'state': 'ACTIVE',
        'password': password
      }));

      if(response.statusCode == 200)
      {
        return true;
      }
      else
      {
        return false;
      }
    }
    catch(e)
    {
      rethrow;
    }
  }


  Future<void> logout() async{
    await storage.delete(key: 'token');
  }

  Future<bool> isAuthenticated() async{
    final token = await storage.read(key: 'token');

    return token == null? false: true;
  }

}