import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';

class Impact {

  static String baseUrl = 'https://impact.dei.unipd.it/bwthw/'; //base URL of the APP the app/server is talking to
  static String pingEndpoint = 'gate/v1/ping/'; //endpoint to check if the server is up and running
  static String tokenEndpoint = 'gate/v1/token/'; //used to request an authentication token by sending a username and password
  static String refreshEndpoint = 'gate/v1/refresh/'; //to refresh expired or expiring token to avoid requiring the user to log in again

  // ADD these endpoints and patient username
  static String sleepTrendEndpoint = '/data/v1/sleep/patients/';
  static String sleepNightEndpoint = '/data/v1/sleep/patients/';
  static String patientUsername = 'x9Cr5EWXIY'; //DA MODIFICARE

  //This method allows to refresh the stored JWT in SharedPreferences
  Future<int> refreshTokens() async {
    //Create the request
    final url = Impact.baseUrl + Impact.refreshEndpoint; //create a url for the request
    final sp = await SharedPreferences.getInstance(); //gets the share prefences instance 
    final refresh = sp.getString('refresh'); //reads the stored refresh token, associated to the key "refresh"
    if (refresh != null) { //if the refresh token is store
      final body = {'refresh': refresh}; //creates the request body

      //Get the response
      print('Calling: $url');
      final response = await http.post(Uri.parse(url), body: body); //sends an HTTP POST request to refresh URL with the refresh token in the body

      //If the response is OK, set the tokens in SharedPreferences to the new values
      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body); //converts the JSON response body from the server
        final sp = await SharedPreferences.getInstance();
        await sp.setString('access', decodedResponse['access']); //stores the new access token
        await sp.setString('refresh', decodedResponse['refresh']); //stores the new refresh token
      } //if

      //Just return the status code
      return response.statusCode;
    }
    return 401; //because the user never logged in
  } //_refreshTokens

  Future<int> getAndStoreTokens(String username, String password ) async {

    //Create the request
    final url = Impact.baseUrl + Impact.tokenEndpoint;
    final body = {'username': username, 'password': password};

    //Get the response
    print('Calling: $url');
    final response = await http.post(Uri.parse(url), body: body);

    //If response is OK, decode it and store the tokens. Otherwise do nothing.
    if (response.statusCode == 200) {
      final decodedResponse = jsonDecode(response.body);
      final sp = await SharedPreferences.getInstance();
      await sp.setString('access', decodedResponse['access']);
      await sp.setString('refresh', decodedResponse['refresh']);
    } //if

    //Just return the status code
    return response.statusCode;
  } //_getAndStoreTokens

  //This method allows to fetch sleep trend data from IMPACT using stored JWT token
  static Future<dynamic> fetchSleepTrendData(String startDate, String endDate) async {
    final sp = await SharedPreferences.getInstance();
    var access = sp.getString('access');

    //If access token is expired, refresh it
    if (JwtDecoder.isExpired(access!)) {
      await Impact().refreshTokens();
      access = sp.getString('access');
    }

    //Create the request
    final url = Impact.baseUrl + Impact.sleepTrendEndpoint + Impact.patientUsername + '/range/$startDate/$endDate/';
    final headers = {HttpHeaders.authorizationHeader: 'Bearer $access'};

    //Get the response
    print('Calling: $url');
    final response = await http.get(Uri.parse(url), headers: headers);

    //if OK parse the response, otherwise return null
    var result = null;
    if (response.statusCode == 200) {
      result = jsonDecode(response.body);
    }

    //Return the result
    return result;
  } //fetchSleepTrendData

  //This method allows to fetch sleep night data from IMPACT using stored JWT token
  static Future<dynamic> fetchSleepNightData(String day) async {
    final sp = await SharedPreferences.getInstance();
    var access = sp.getString('access');

    //If access token is expired, refresh it
    if (JwtDecoder.isExpired(access!)) {
      await Impact().refreshTokens();
      access = sp.getString('access');
    }

    //Create the request
    final url = Impact.baseUrl + Impact.sleepNightEndpoint + Impact.patientUsername + '/day/$day/';
    final headers = {HttpHeaders.authorizationHeader: 'Bearer $access'};

    //Get the response
    print('Calling: $url');
    final response = await http.get(Uri.parse(url), headers: headers);

    //if OK parse the response, otherwise return null
    var result = null;
    if (response.statusCode == 200) {
      result = jsonDecode(response.body);
    }

    //Return the result
    return result;
  } //fetchSleepNightData

} //Impact
