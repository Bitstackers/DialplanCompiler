part of XmlDialplanGenerator.router;

/**
 * When there exists no reources at that location.
 */
void page404(HttpRequest request) {
  print('404: ${request.uri}');
  String body = JSON.encode({'error':'No resource found for ${request.uri}'});

  request.response.statusCode = HttpStatus.NOT_FOUND;
  writeAndCloseJson(request, body);
}
