library configuration;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';

class Configuration {
  ArgResults _args;

  String configfile;
  String localContextPath;
  String publicContextPath;
  String dbuser;
  String dbpassword;
  String dbhost;
  int    dbport;
  String dbname;

  int httpport;

  Configuration(ArgResults args) {
    _args = args;
  }

  void parse() {
    if(_hasArgument('configfile')) {
      configfile = _args['configfile'];
      _parseFile();
    }
    _parseCLA();
    _validate();
  }

  void _parseCLA() {
    if(_hasArgument('dbhost')) {
      dbhost = _args['dbhost'];
    }

    if(_hasArgument('dbname')) {
      dbname = _args['dbname'];
    }

    if(_hasArgument('dbpassword')) {
      dbpassword = _args['dbpassword'];
    }

    if(_hasArgument('dbport')) {
      dbport = int.parse(_args['dbport']);
    }

    if(_hasArgument('dbuser')) {
      dbuser = _args['dbuser'];
    }

    if(_hasArgument('httpport')) {
      httpport = int.parse(_args['httpport']);
    }

    if(_hasArgument('localcontextpath')) {
      localContextPath = _args['localcontextpath'];
    }

    if(_hasArgument('publiccontextpath')) {
      publicContextPath = _args['publiccontextpath'];
    }
  }

  void _parseFile() {
    if(configfile == null) {
      return;
    }

    File file = new File(configfile);
    String rawContent = file.readAsStringSync();

    Map content = JSON.decode(rawContent);

    if(content.containsKey('dbhost')) {
      dbhost = content['dbhost'];
    }

    if(content.containsKey('dbname')) {
      dbname = content['dbname'];
    }

    if(content.containsKey('dbpassword')) {
      dbpassword = content['dbpassword'];
    }

    if(content.containsKey('dbport')) {
      dbport = content['dbport'];
    }

    if(content.containsKey('dbuser')) {
      dbuser = content['dbuser'];
    }

    if(content.containsKey('httpport')) {
      httpport = content['httpport'];
    }

    if(content.containsKey('localContextPath')) {
      localContextPath = content['localContextPath'];
    }

    if(content.containsKey('publicContextPath')) {
      publicContextPath = content['publicContextPath'];
    }
  }

  /**
   * Checks if the configuration is valid.
   */
  void _validate() {
    if(localContextPath == null) {
      throw new InvalidConfigurationException("localContextPath isn't specified");
    } else {
      Directory file = new Directory(localContextPath);
      if(!file.existsSync()) {
        throw new InvalidConfigurationException('localContextPath: "${localContextPath}" does not exists');
      }
    }

    if(publicContextPath == null) {
      throw new InvalidConfigurationException("publicContextPath isn't specified");
    } else {
      Directory file = new Directory(publicContextPath);
      if(!file.existsSync()) {
        throw new InvalidConfigurationException('publicContextPath: "${publicContextPath}" does not exists');
      }
    }
  }

  String toString() => '''
      LocalContextPath: ${localContextPath}
      publicContextPath: ${publicContextPath}
      HttpPort: $httpport
      Database:
        Host: $dbhost
        Port: $dbport
        User: $dbuser
        Pass: ${dbpassword.codeUnits.map((_) => '*').join()}
        Name: $dbname      
      ''';

  bool _hasArgument(String key) {
    assert(_args != null);
    return _args.options.contains(key) && _args[key] != null;
  }
}

class InvalidConfigurationException implements Exception {
  final String msg;
  const InvalidConfigurationException([this.msg]);

  String toString() => msg == null ? 'InvalidConfigurationException' : msg;
}
