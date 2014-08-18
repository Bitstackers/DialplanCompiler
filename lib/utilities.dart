library dialplan_utilities;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:xml/xml.dart';

import 'package:openreception_framework/httpserver.dart';
import 'logger.dart';

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
  Map body = {'error': 'Internal Server Error'};
  if(error != null) {
    logger.error(error);
    body['error'] = error.toString();
  }
  if(stack != null) {
    logger.error(stack);
    //body['stack'] = stack.toString();
  }

  if(message != null) {
    body['message'] = message;
  }
  String response = JSON.encode(body);
  request.response.statusCode = HttpStatus.INTERNAL_SERVER_ERROR;
  writeAndClose(request, response);
}

/** Makes a third list containing the content of the two lists.*/
List union(List aList, List bList) {
  List cList = new List();
  cList.addAll(aList);
  cList.addAll(bList);
  return cList;
}
