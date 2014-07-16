library XmlDialplanGenerator.router;

import 'dart:convert';
import 'dart:io';

import 'package:libdialplan/libdialplan.dart';
import 'package:libdialplan/ivr.dart';
import 'package:route/pattern.dart';
import 'package:path/path.dart' as path;
import 'package:route/server.dart';

import 'configuration.dart';
import 'database.dart';
import 'dialplan_compiler.dart';
import 'ivr_compiler.dart';
import 'local_stream_compiler.dart';
import 'logger.dart';
import 'model/playlist.dart';
import 'utilities.dart';

part 'route/dialplan_controller.dart';
part 'route/freeswitch_controller.dart';
part 'route/page404.dart';

final Pattern receptionIdDialplanUrl = new UrlPattern(r'/reception/(\d+)/dialplan');
final Pattern receptionAudiofilesUrl = new UrlPattern(r'/reception/(\d+)/audio');
final Pattern receptionIdIvrUrl = new UrlPattern(r'/reception/(\d+)/ivr');
final Pattern playlistIdUrl = new UrlPattern(r'/playlist/(\d+)');

DialplanController dialplanController;
FreeswitchController freeswitchController;

void setupRoutes(HttpServer server, Configuration config, Logger logger) {
  Router router = new Router(server)
    //..filter(matchAny(allUniqueUrls), auth(config.authUrl))
    ..serve(receptionIdDialplanUrl, method: 'GET').listen(dialplanController.deploy)
    ..serve(receptionAudiofilesUrl, method: 'GET').listen(freeswitchController.listAudioFiles)
    ..serve(receptionIdIvrUrl, method: 'GET').listen(dialplanController.deployIvr)
    ..serve(playlistIdUrl, method: 'GET').listen(freeswitchController.deployPlaylist)
    ..defaultStream.listen(page404);
}

void setupControllers(Database db, Configuration config) {
  dialplanController = new DialplanController(db, config);
  freeswitchController = new FreeswitchController(db, config);
}
