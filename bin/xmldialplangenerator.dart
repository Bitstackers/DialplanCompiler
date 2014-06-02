import 'dart:io';
import 'dart:convert';

import 'package:args/args.dart';
import 'package:libdialplan/libdialplan.dart';

import '../lib/configuration.dart';
import '../lib/database.dart';
import '../lib/generator.dart';
import '../lib/logger.dart';
import '../lib/router.dart';
import '../lib/utilities.dart';

ArgParser parser = new ArgParser();

void main(List<String> args) {
  ArgResults parsedArgs = registerAndParseCommandlineArguments(parser, args);

  if(parsedArgs['help']) {
    print(parser.getUsage());
    return;
  }

  Configuration config = new Configuration(parsedArgs);
  config.parse();
  print(config);

  setupDatabase(config)
    .then((db) => setupControllers(db, config))
    .then((_) => makeServer(config.httpport))
    .then((HttpServer server) {
      setupRoutes(server, config, logger);

      logger.debug('Server started up!');
    });
}

ArgResults registerAndParseCommandlineArguments(ArgParser parser, List<String> arguments) {
    parser
      ..addFlag  ('help', abbr: 'h', help: 'Output this help')
      ..addOption('configfile',      help: 'The JSON configuration file. Defaults to config.json')
      ..addOption('httpport',        help: 'The port the HTTP server listens on.  Defaults to 8080')
      ..addOption('dbuser',          help: 'The database user')
      ..addOption('dbpassword',      help: 'The database password')
      ..addOption('dbhost',          help: 'The database host. Defaults to localhost')
      ..addOption('dbport',          help: 'The database port. Defaults to 5432')
      ..addOption('dbname',          help: 'The database name');

  return parser.parse(arguments);
}

void TestStart() {
  int receptionId = 9;
  String number = '1234000${receptionId}';

  Map dialplan = JSON.decode(dialplan2);
  Dialplan handplan = new Dialplan.fromJson(dialplan)
    ..receptionId = receptionId
    ..entryNumber = number;

  GeneratorOutput output = generateXml(handplan);
  //print(JSON.encode(handplan.toJson()));
  print(output.entry.toString().substring(1));
  print('-- ^ PUBLIC CONTEXT ^ ---- v RECEPTION CONTEXT v --');
  print(output.receptionContext);
}

/**
 * ---- Krav til modellen.
 * Der skal altid være en, og kun en, extension med start = true
 * Der må højst være en extension med catchall = true
 */

/**
 * TODO TESTING. DELETE IF YOU SEE ME IN DOC!.
 */

String dialplan2 ='''
{
    "extensions": [
        {
            "start": true,
            "catchall": false,
            "name": "man-tors",
            "failoverextension": "fredag",
            "conditions": [
                {
                    "condition": "time",
                    "time-of-day": "08:00-17:00",
                    "wday": "mon-thu"
                }
            ],
            "actions": [
                {
                    "action": "receptionists",
                    "sleeptime": 0,
                    "music": "mohrec7",
                    "welcomefile": "r_8_welcome.wav"
                }
            ]
        },
        {
            "start": false,
            "catchall": false,
            "name": "fredag",
            "failoverextension": "lukket",
            "conditions": [
                {
                    "condition": "time",
                    "time-of-day": "08:00-16:30",
                    "wday": "fri"
                }
            ],
            "actions": [
                {
                    "action": "receptionists",
                    "sleeptime": 0,
                    "music": "mohrec7",
                    "welcomefile": "r_8_welcome.wav"
                }
            ]
        },
        {
            "start": false,
            "catchall": false,
            "name": "lukket",
            "conditions": [],
            "actions": [
                {
                    "action": "playaudio",
                    "filename": "en/us/callie/misc/8000/misc-soccer_mom.wav"
                }
            ]
        },
        {
            "start": false,
            "name": "natsvar",
            "catchall": true,
            "conditions": [],
            "actions": [
                {
                    "action": "playaudio",
                    "filename": "en/us/callie/misc/8000/error.wav"
                }
            ]
        }
    ]
}
''';
