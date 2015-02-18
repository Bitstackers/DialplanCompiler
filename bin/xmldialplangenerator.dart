import 'dart:io';

import 'package:args/args.dart';

import '../lib/configuration.dart';
import '../lib/logger.dart';
import '../lib/router.dart';
import '../lib/utilities.dart';

ArgParser parser = new ArgParser();

void main(List<String> args) {
  ArgResults parsedArgs = registerAndParseCommandlineArguments(parser, args);

  if(parsedArgs['help']) {
    print(parser.usage);
    return;
  }

  Configuration config = new Configuration(parsedArgs);
  config.parse();
  print(config);

  setupControllers(config, logger);

  makeServer(config.httpport)
    .then((HttpServer server) {
      setupRoutes(server, config, logger);

      logger.debug('Server started up!');
    });
}

ArgResults registerAndParseCommandlineArguments(ArgParser parser, List<String> arguments) {
  parser
    ..addFlag  ('help', abbr: 'h',   help: 'Output this help')
    ..addOption('configfile',        help: 'The JSON configuration file. Defaults to config.json')
    ..addOption('httpport',          help: 'The port the HTTP server listens on.  Defaults to 8080')
    ..addOption('localcontextpath',  help: 'The path for the reception specific dialplans')
    ..addOption('publiccontextpath', help: 'The path for the public dialplans')
    ..addOption('audiofolder',       help: 'The path for the sounds, specific for receptions')
    ..addOption('localstreampath',   help: 'The path for the configurationfiles to local streams')
    ..addOption('ivrpath',           help: 'The path for the ivr menues');

  return parser.parse(arguments);
}
