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
    //TODO TESTING - REMOVE
    TestStart();
    //TODO TESTING - REMOVE

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

void TestOutPut() {
  Dialplan dialplan = new Dialplan();
  dialplan.startExtensionGroup = 'startingGroup';
  dialplan.extensionGroups['startingGroup'] =
      [ new Extension(name: 'mandag-torsdag')
          ..conditions = [new Time()..comment = 'mandag-torsdag'..wday='2-5']
          ..actions = [new Receptionists()..music = "I don't like mondays"],

        new Extension(name: 'fredag')
          ..conditions = [new Time()..comment = 'fredag'..wday='6']
          ..actions = [new Receptionists()..music = "Rebecca Black - Friday"]];

  dialplan.extensionGroups['lukket'] =
      [ new Extension(name: 'lukket')
          ..actions = [new Voicemail()..email = 'me@example.com']];

  print(JSON.encode(dialplan));
}

void TestStart() {
  int receptionId = 1;
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
 * TODO TESTING. DELETE IF YOU SEE ME IN PRODUCTION!.
 */

String dialplan2 ='''
{
    "version": 1,
    "extensionGroups": {
        "startingGroup": [
            {
                "name": "mandag-torsdag",
                "conditionlist": [
                    {
                        "condition": "time",
                        "comment": "mandag-torsdag",
                        "wday": "2-5"
                    }
                ],
                "actionlist": [
                    {
                        "action": "receptionists",
                        "music": "I don't like mondays"
                    }
                ]
            },
            {
                "name": "fredag",
                "conditionlist": [
                    {
                        "condition": "time",
                        "comment": "fredag",
                        "wday": "6"
                    }
                ],
                "actionlist": [
                    {
                        "action": "receptionists",
                        "music": "Rebecca Black - Friday"
                    }
                ]
            }
        ],
        "lukket": [
            {
                "name": "lukket",
                "conditionlist": [],
                "actionlist": [
                    {
                        "action": "voicemail",
                        "email": "me@example.com"
                    }
                ]
            }
        ]
    },
    "startExtensionGroup": "startingGroup"
}
''';
