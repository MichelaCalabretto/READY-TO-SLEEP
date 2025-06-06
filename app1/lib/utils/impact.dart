import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:intl/intl.dart';

class Impact {
  static String baseUrl = 'https://impact.dei.unipd.it/bwthw/';
  static String pingEndpoint = 'gate/v1/ping/';
  static String tokenEndpoint = 'gate/v1/token/';
  static String refreshEndpoint = 'gate/v1/refresh/';
  static String sleepBaseEndpoint = 'data/v1/sleep/patients/';
  static String patientUsername = 'Jpefaq6m58'; 

  Future<int> refreshTokens() async {
    final url = '$baseUrl$refreshEndpoint';
    final sp = await SharedPreferences.getInstance();
    final refresh = sp.getString('refresh');
    
    if (refresh != null) {
      final body = {'refresh': refresh};
      print('Calling refresh endpoint: $url');
      
      try {
        final response = await http.post(Uri.parse(url), body: body);
        
        if (response.statusCode == 200) {
          final decodedResponse = jsonDecode(response.body);
          print('Tokens successfully refreshed');
          await sp.setString('access', decodedResponse['access']);
          await sp.setString('refresh', decodedResponse['refresh']);
        } else {
          print('Refresh failed with status: ${response.statusCode}');
        }
        return response.statusCode;
      } catch (e, stack) {
        print('Error during token refresh: $e\n$stack');
        return 500;
      }
    }
    print('No refresh token available');
    return 401;
  }

  Future<int> getAndStoreTokens(String username, String password) async {
    final url = '$baseUrl$tokenEndpoint';
    final body = {'username': username, 'password': password};
    print('Calling token endpoint: $url');

    try {
      final response = await http.post(Uri.parse(url), body: body);
      
      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        print('Successfully obtained tokens');
        final sp = await SharedPreferences.getInstance();
        await sp.setString('access', decodedResponse['access']);
        await sp.setString('refresh', decodedResponse['refresh']);
      } else {
        print('Token request failed with status: ${response.statusCode}');
      }
      return response.statusCode;
    } catch (e, stack) {
      print('Error during token request: $e\n$stack');
      return 500;
    }
  }

  /// Fetch raw JSON data for sleep trend (multiple days) within a date range.
  static Future<Map<String, dynamic>?> fetchSleepTrendData(String startDate, String endDate) async {
    final sp = await SharedPreferences.getInstance();
    var access = sp.getString('access');

    if (access == null || JwtDecoder.isExpired(access)) {
      print('Access token missing or expired, refreshing...');
      final refreshResult = await Impact().refreshTokens();
      if (refreshResult != 200) {
        print('Failed to refresh token');
        return null;
      }
      access = sp.getString('access');
    }

    final url = '$baseUrl$sleepBaseEndpoint$patientUsername/daterange/start_date/$startDate/end_date/$endDate/';
    final headers = {HttpHeaders.authorizationHeader: 'Bearer $access'};
    print('Fetching trend data from: $url');

    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      print('Trend data response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        print('$decoded'); //for debugging
        return decoded as Map<String, dynamic>;
      } else {
        print('Trend data request failed: ${response.body}');
        return null;
      }
    } catch (e, stack) {
      print('Error fetching trend data: $e\n$stack');
      return null;
    }
  }

  /// Fetch raw JSON data for a single night's sleep.
  static Future<Map<String, dynamic>?> fetchSleepNightData(String day) async {
    final sp = await SharedPreferences.getInstance();
    var access = sp.getString('access');

    if (access == null || JwtDecoder.isExpired(access)) {
      print('Access token missing or expired, refreshing...');
      final refreshResult = await Impact().refreshTokens();
      if (refreshResult != 200) {
        print('Failed to refresh token');
        return null;
      }
      access = sp.getString('access');
    }

    final url = '$baseUrl$sleepBaseEndpoint$patientUsername/day/$day/';
    final headers = {HttpHeaders.authorizationHeader: 'Bearer $access'};
    print('Fetching night data from: $url');

    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      print('Night data response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        print('$decoded'); //for debugging
        return decoded as Map<String, dynamic>;
      } else {
        print('Night data request failed: ${response.body}');
        return null;
      }
    } catch (e, stack) {
      print('Error fetching night data: $e\n$stack');
      return null;
    }
  }
}
