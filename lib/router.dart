library XmlDialplanGenerator.router;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:libdialplan/libdialplan.dart';
import 'package:libdialplan/ivr.dart';
import 'package:route/pattern.dart';
import 'package:path/path.dart' as path;
import 'package:route/server.dart';
import 'package:openreception_framework/httpserver.dart';

import 'configuration.dart';
import 'dialplan_compiler.dart';
import 'ivr_compiler.dart';
import 'local_stream_compiler.dart';
import 'logger.dart';
import 'model/playlist.dart';
import 'utilities.dart';

part 'route/dialplan_controller.dart';
part 'route/freeswitch_controller.dart';

final Pattern receptionIdDialplanUrl = new UrlPattern(r'/reception/(\d+)/dialplan');
final Pattern receptionAudiofilesUrl = new UrlPattern(r'/reception/(\d+)/audio');
final Pattern receptionIdIvrUrl = new UrlPattern(r'/reception/(\d+)/ivr');
final Pattern playlistIdUrl = new UrlPattern(r'/playlist/(\d+)');
final Pattern audiofileUrl = new UrlPattern(r'/audio');

DialplanController dialplanController;
FreeswitchController freeswitchController;

List<Pattern> serviceAgentURL =
  [receptionIdDialplanUrl, receptionAudiofilesUrl, receptionIdIvrUrl, playlistIdUrl, audiofileUrl];

void setupRoutes(HttpServer server, Configuration config, Logger logger) {
  Router router = new Router(server)
    ..filter(matchAny(serviceAgentURL), auth(config.authurl))
    ..serve(receptionIdDialplanUrl, method: 'POST').listen(dialplanController.deployCompiler)
    ..serve(receptionAudiofilesUrl, method: 'GET').listen(freeswitchController.listAudioFiles)
    ..serve(audiofileUrl, method: 'DELETE').listen(freeswitchController.deleteAudioFile)
    ..serve(receptionIdIvrUrl, method: 'POST').listen(dialplanController.deployIvr)
    ..serve(playlistIdUrl, method: 'POST').listen(freeswitchController.deployPlaylist)
    ..serve(playlistIdUrl, method: 'DELETE').listen(freeswitchController.deletePlaylist)
    ..defaultStream.listen(page404);
}

void setupControllers(Configuration config) {
  dialplanController = new DialplanController(config);
  freeswitchController = new FreeswitchController(config);
}
