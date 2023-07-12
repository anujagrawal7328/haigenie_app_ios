import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../model/user.dart';
class AuthRepository {
  static const String baseUrl = 'https://haigeniemwprod.eastus.cloudapp.azure.com:4443'; // Replace with your API URL

  Future<User?> login(String username, String password) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final url = Uri.parse('$baseUrl/authenticateUser');
    final headers = {'Content-Type': 'application/json',};
    final body = json.encode({'email': username, 'password': password});

    final response = await http.post(url, headers: headers, body: body);
    if (response.statusCode == 200) {
      prefs.setString('token',json.decode(response.body)['jwtoken']);
      final user=await verifyToken();
      return user;
    } else {
      print(response.body);
      return null;
    }
  }

  Future<bool> register(User user) async {
    final url = Uri.parse('$baseUrl/registerUser');
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode(user.toJson());
    final response = await http.post(url, headers: headers, body: body);
    if (response.statusCode == 200) {
      return true;
    } else {
      print(response.body);
      return false;
    }
  }
  Future<bool> updateNewUser( String email,String password,String token) async {
    final url = Uri.parse('$baseUrl/createUserAccount');
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode({"email":email,"password":password,"token":token});
    final response = await http.post(url, headers: headers, body: body);
    if (response.statusCode == 200) {
      return true;
    } else {
      print(response.body);
      return false;
    }
  }
  Future<User?> verifyToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final url = Uri.parse('$baseUrl/verifyToken');
    final headers = {
      'Content-Type': 'application/json',
    };
    print("token:$token");
    if(token!=null){
    final body = json.encode({'jwtToken': token});
    final response = await http.post(url, headers: headers,body:body);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      final user = User.fromJson(jsonData);
      prefs.setString('user',  json.encode(user.toJson()));
      return user;
    } else {
      print(response.body);
      return null;
    }}
    else {
      return null;
    }
  }
  Future<bool> updateAttempts(int attempts) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    String? userJson = prefs.getString('user');
    final url = Uri.parse('$baseUrl/');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final body = json.encode({'attempts': attempts});
    final response = await http.post(url, headers: headers,body:body );

    if (response.statusCode == 200) {
      if (userJson != null) {
        Map<String, dynamic> jsonMap = json.decode(userJson);
        User user = User.fromJson(jsonMap);
        user.availableAttempts = attempts;
        final updatedJsonString = json.encode(user.toJson());
        await prefs.setString('user', updatedJsonString);
      }
      return true;
    } else {
      print(response.body);
      return false;
    }
  }
  Future<bool> logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    return true;
  }
}