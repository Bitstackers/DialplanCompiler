library dialplan_utilities;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:xml/xml.dart';

import 'logger.dart';

final ContentType JSON_MIME_TYPE = new ContentType('application', 'json', charset: 'UTF-8');

/**
 * Makes a condition xml element
 */
XmlElement XmlCondition(String field, String expression) =>
    new XmlElement('condition')
  ..attributes['field'] = field
  ..attributes['expression'] = expression;

/**
 * Makes a action xml element
 */
XmlElement XmlAction(String application, String data, [bool anti_action = false]) =>
    new XmlElement(anti_action ? 'anti-action' : 'action')
    ..attributes['application'] = application
    ..attributes['data'] = data;

/**
 * Applies CORS headers to the [response].
 */
void addCorsHeaders(HttpResponse response) {
  response.headers
    ..add("Access-Control-Allow-Origin", "*")
    ..add("Access-Control-Allow-Methods", "POST, GET, PUT, DELETE, OPTIONS")
    ..add("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
}

/**
 * Creates a new Http Server that listens for IPv4 requests.
 */
Future<HttpServer> makeServer(int port) => HttpServer.bind(InternetAddress.ANY_IP_V4, port);

/**
 * Extracts the int from the uri.
 *
 * Format expected /<key>/<value>
 * The key-value pair may appier at any place in the url path.
 */
int pathIntParameter(Uri uri, String key) {
  try {
    return int.parse(uri.pathSegments.elementAt(uri.pathSegments.indexOf(key) + 1));
  } catch(error) {
    print('utilities.pathIntParameter failed $error Key: "$key" Uri: "$uri"');
    return null;
  }
}

void InternalServerError(HttpRequest request, {error, stack, String message}) {
  if(error != null) {
    logger.error(error);
  }
  if(stack != null) {
    logger.error(stack);
  }

  Map body = {'error': 'Internal Server Error'};
  if(message != null) {
    body['message'] = message;
  }
  String response = JSON.encode(body);
  request.response.statusCode = HttpStatus.INTERNAL_SERVER_ERROR;
  writeAndCloseJson(request, response);
}

/**
 * Writes out the body to the request, and closes the connection.
 */
void writeAndCloseJson(HttpRequest request, String body) {
  addCorsHeaders(request.response);
  request.response.headers.contentType = JSON_MIME_TYPE;

  request.response
    ..write(body)
    ..write('\n')
    ..close();
}
