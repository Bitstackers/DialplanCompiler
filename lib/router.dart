library XmlDialplanGenerator.router;

import 'dart:convert';
import 'dart:io';

import 'package:libdialplan/libdialplan.dart';
import 'package:route/pattern.dart';
import 'package:route/server.dart';

import 'configuration.dart';
import 'database.dart';
import 'generator.dart';
import 'logger.dart';
import 'utilities.dart';

part 'route/deploy.dart';
part 'route/page404.dart';

final Pattern receptionIdUrl = new UrlPattern(r'/reception/(\d+)');

DialplanController dialplanController;

void setupRoutes(HttpServer server, Configuration config, Logger logger) {
  Router router = new Router(server)
    //..filter(matchAny(allUniqueUrls), auth(config.authUrl))
    ..serve(receptionIdUrl, method: 'GET').listen(dialplanController.deploy)
    ..defaultStream.listen(page404);
}

void setupControllers(Database db, Configuration config) {
  dialplanController = new DialplanController(db, config);
}
