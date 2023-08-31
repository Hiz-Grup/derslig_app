import 'dart:developer';

import 'package:derslig/models/login_response_model.dart';
import 'package:http/http.dart' as http;

class ApiService {
  Future<LoginResponseModel> login(String email, String password) async {
    //headers :  Content-Type :  application/x-www-form-urlencoded , Accept : application/json

    var response = await http.post(
      Uri.parse('https://www.derslig.com/api/login'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept': 'application/json',
      },
      body: {
        'login': email,
        'password': password,
      },
    );

    log(response.headers.toString());

    // {connection: keep-alive, x-powered-by: PHP/7.4.33, alt-svc: h3=":443"; ma=86400, cache-control: no-cache, private, set-cookie: XSRF-TOKEN=eyJpdiI6Imw5ckhNZnFZTjUvN2ZkYTFJL3ZLeFE9PSIsInZhbHVlIjoiM1luN1FPdWVVVlIvdStzaWtSMGpmdDgydHprYlNzcTVNZHQwb2NzSEdnMDlmUUVGakJyVlFqcUNhVGcyek8xVmJkMmRYMnBrdkNTelY2bjM5STFUU0QxNXJhSWJid1MvY01Vc3pLNjYvRUh2MG53VUV4QmxFRGdwcVQ2ZHhralciLCJtYWMiOiI4ZTIzZWJmYjNjMWQ5YzM2M2M5ZWI1MGE1MGU1MGU0MjAxMmZiZGE1NWZmZDkxYzI3YmNiMTQ5Y2E3MzFmMGY0IiwidGFnIjoiIn0%3D; expires=Sat, 16-Dec-2023 13:30:33 GMT; Max-Age=10368000; path=/; domain=.derslig.com; samesite=lax,derslig_cookie=eyJpdiI6InJIc01oZzZZVTdRV2d5eTVUbEFtM0E9PSIsInZhbHVlIjoiSVMvNzduTmJVb2cyOERPMWNUcTRPZXFyRElwbmlmSjZHaER1d2RrZnhsQmNDS2xsSktzWDRpZ1NRNHFwWDdmQnF6Zy9heEMrWXR2Slh2Y3U4aWF1ajZKdHUwQkRCa3JaWWVqRzAxY3RrYWMxVHNLcXFyOGJlQTVHN3M5VHlwTEQiLCJtYWMiOiIxMDE5ODIxOTQ5NjhlNGExODhiYmZhODBhMzQyOGI4NTQ5MTNmN2U5NzEzYWJhYzg2N2ZjNzcyYjlmMTRjZDQ2IiwidGFnIjoiIn0%3D; expires=Sat, 16-Dec-2023 13:30:33 GMT; Max-Age=10368000;
    RegExp regExpXsrg = RegExp(r'XSRF-TOKEN=(.*?);');
    String xsrfToken =
        regExpXsrg.firstMatch(response.headers.toString())!.group(1)!;
    RegExp regExpDersligCookie = RegExp(r'derslig_cookie=(.*?);');
    String dersligCookie =
        regExpDersligCookie.firstMatch(response.headers.toString())!.group(1)!;
    RegExp regExpExpire = RegExp(r'expires=(.*?);');
    String expire =
        regExpExpire.firstMatch(response.headers.toString())!.group(1)!;
    log(xsrfToken);
    log(dersligCookie);
    log(expire);
    // Sat, 16-Dec-2023 13:37:29 GMT
    DateTime expireDate = DateTime.now().add(const Duration(days: 60));
    // DateTime.parse(expire.replaceAll('GMT', '').split(',')[0].trim());
    log(expireDate.toString());

    return LoginResponseModel(
      xsrfToken: xsrfToken,
      dersligCookie: dersligCookie,
      expireDate: expireDate,
    );
  }

  Future<http.Response> postRequest(String url, Map<String, String> body,
      {Map<String, dynamic>? headers}) async {
    var response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept': 'application/json',
        if (headers != null) ...headers,
      },
      body: body,
    );
    return response;
  }

  Future<http.Response> getRequest(String url) async {
    var response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept': 'application/json',
      },
    );
    print(url);
    print(response.body);

    return response;
  }
}
