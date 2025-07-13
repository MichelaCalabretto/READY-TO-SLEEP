import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';

class Impact { 
  // static variables ---> they belong to the class itself, not to an istance of the class ---> they can be accessed directly using Impact.baseUrl
  static String baseUrl = 'https://impact.dei.unipd.it/bwthw/'; 
  static String pingEndpoint = 'gate/v1/ping/';
  static String tokenEndpoint = 'gate/v1/token/'; 
  static String refreshEndpoint = 'gate/v1/refresh/'; 
  static String sleepBaseEndpoint = 'data/v1/sleep/patients/';
  static String listPatientsEndpoint = 'study/v1/patients/';
  static String? patientUsername; // the patientUsername is nullable: the value will be set after the request to the server

  // Uses the refresh token to get new tokens
  Future<int> refreshTokens() async { // the returned object is the status code of the request
    final url = '$baseUrl$refreshEndpoint';
    final sp = await SharedPreferences.getInstance();
    final refresh = sp.getString('refresh');

    if (refresh != null) {
      final body = {'refresh': refresh};
      print('Calling refresh endpoint: $url');

      try {
        final response = await http.post(Uri.parse(url), body: body); // Uri.parse(url) ---> converts the URL from a String to a Uri object

        if (response.statusCode == 200) {
          final decodedResponse = jsonDecode(response.body); // jsonDecode to parse the JSON object (the body of the response) to a Dart object
          print('Tokens successfully refreshed');
          await sp.setString('access', decodedResponse['access']);
          await sp.setString('refresh', decodedResponse['refresh']);
        } else {
          print('Refresh failed with status: ${response.statusCode}');
        }
        return response.statusCode;
      } catch (e, stack) { // e = error object itself; what went wrong
                           // stack = stack trace; detailed report that tells where in the code the error occurred, showing the exact sequence of function calls that led to the problem
        print('Error during token refresh: $e\n$stack');
        return 500;
      }
    }
    print('No refresh token available'); // refresh tokens were null
    return 401;
  }

  // Fetches and stores the access and refresh tokens ---> used only once when the user logs in!
  Future<int> getAndStoreTokens(String username, String password) async { // to get the tokens the request must include the user credentials
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

        // After successfully getting tokens, fetch and store the patient username
        await fetchPatientUsername();
        
      } else {
        print('Token request failed with status: ${response.statusCode}');
      }
      return response.statusCode;
    } catch (e, stack) {
      print('Error during token request: $e\n$stack');
      return 500;
    }
  }

  // Fetches the list of patients and stores the first patient's username
  Future<void> fetchPatientUsername() async {
    final sp = await SharedPreferences.getInstance();
    var access = sp.getString('access'); // save the access token in a variable (not final!!) ---> final doesn't allow to change the variable value after assigning it the first time 
                                         // ---> if the access token is null or expired, we need to update the variable

    if (access == null || JwtDecoder.isExpired(access)) { // .isExpired is from the jwt_decoder package and allows to check if the token has expired ---> returns True or Fals
      print('Access token missing or expired for patient username fetch, refreshing...');
      final refreshResult = await refreshTokens();
      if (refreshResult != 200) {
        print('Failed to refresh token for patient username fetch');
        return;
      }
      access = sp.getString('access');
    }

    if (access == null) {
      print('Access token is still null after refresh. Cannot fetch patient username.');
      return;
    }

    final url = '$baseUrl$listPatientsEndpoint';
    final headers = {HttpHeaders.authorizationHeader: 'Bearer $access'};
    print('Fetching patient list from: $url');

    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      print('Patient list response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded['data'] is List) { // the expected response structure is a Map with objects (key=String, value) = {}
                                                                          // the "data" is expected to be a List = []
          final List<dynamic> patients = decoded['data'];
          if (patients.isNotEmpty && patients[0]['username'] != null) {
            patientUsername = patients[0]['username'];
            await sp.setString('patient_username', patientUsername!); // store the patientUsername 
            print('Successfully set patientUsername: $patientUsername');
          } else {
            print('No patient data found or username is null in the response.');
          }
        } else {
          print('Unexpected response format for patient list.');
        }
      } else {
        print('Patient list request failed: ${response.body}');
      }
    } catch (e, stack) {
      print('Error fetching patient list: $e\n$stack');
    }
  }

  // Fetches raw JSON data for sleep trend (multiple days) within a date range
  static Future<Map<String, dynamic>?> fetchSleepTrendData(String startDate, String endDate) async { // ? because there could be no data for the days of interest
    final sp = await SharedPreferences.getInstance();
    var access = sp.getString('access');

    // Ensure patientUsername is set
    if (patientUsername == null) {
      patientUsername = sp.getString('patient_username'); // try to load from SharedPreferences
      if (patientUsername == null) {
        print('Patient username not set. Attempting to fetch...');
        await Impact().fetchPatientUsername(); // attempt to fetch patientUsername
        patientUsername = sp.getString('patient_username'); // try loading again
        if (patientUsername == null) {
          print('Failed to retrieve patient username.');
          return null;
        }
      }
    }

    // Check tokens
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
        print('$decoded'); // for debugging
        return decoded as Map<String, dynamic>; // expected format of the response body
      } else {
        print('Trend data request failed: ${response.body}');
        return null;
      }
    } catch (e, stack) {
      print('Error fetching trend data: $e\n$stack');
      return null;
    }
  }

  // Fetches raw JSON data for a single night's sleep
  static Future<Map<String, dynamic>?> fetchSleepNightData(String day) async { // ? because there could be no data for the day of the request
    final sp = await SharedPreferences.getInstance();
    var access = sp.getString('access');

    // Ensure patientUsername is set
    if (patientUsername == null) {
      patientUsername = sp.getString('patient_username'); // try to load from SharedPreferences
      if (patientUsername == null) {
        print('Patient username not set. Attempting to fetch...');
        await Impact().fetchPatientUsername(); // attempt to fetch
        patientUsername = sp.getString('patient_username'); // try loading again
        if (patientUsername == null) {
          print('Failed to retrieve patient username.');
          return null;
        }
      }
    }

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
        print('$decoded'); // for debugging
        return decoded as Map<String, dynamic>; // expected format of the response body
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

