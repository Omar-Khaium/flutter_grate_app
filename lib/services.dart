import 'package:flutter_grate_app/constraints.dart';
import 'package:http/http.dart';

Future<Response> loginService(body) async {
  return await post(BASE_URL + API_POST_LOGIN, body: body);
}

Future<Response> getUserInfoService(headers) async {
  return await get(BASE_URL + API_GET_USER_INFO, headers: headers);
}

Future<Response> getOrganizationService(headers) async {
  return await get(BASE_URL + API_GET_ORGANIZATION, headers: headers);
}

Future<Response> changeOrganizationService(headers) async {
  return await post(BASE_URL + API_POST_CHANGE_COMPANY, headers: headers);
}

Future<Response> getZipCodeService(headers) async {
  return await get(ZIP_LOOKUP_URL, headers: headers);
}

Future<Response> saveCustomerService(headers) async {
  return await post(BASE_URL + API_POST_SAVE_CUSTOMER, headers: headers);
}
