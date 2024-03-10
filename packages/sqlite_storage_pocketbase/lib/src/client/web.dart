import 'package:fetch_client/fetch_client.dart';
import 'package:http/http.dart';

Client createClient() => FetchClient(mode: RequestMode.cors);
