library database;

import 'dart:async';
import 'dart:convert';

import 'package:postgresql/postgresql_pool.dart';
import 'package:postgresql/postgresql.dart';
import 'package:libdialplan/libdialplan.dart';

import 'configuration.dart';

part 'database/dialplan.dart';

Future<Database> setupDatabase(Configuration config) {
  Database db = new Database(config.dbuser, config.dbpassword, config.dbhost, config.dbport, config.dbname);
  return db.start().then((_) => db);
}

class Database {
  Pool pool;
  String user, password, host, name;
  int port, minimumConnections, maximumConnections;

  Database(String this.user, String this.password, String this.host, int this.port, String this.name, {int this.minimumConnections: 1, int this.maximumConnections: 10});

  Future start() {
    String connectString = 'postgres://${user}:${password}@${host}:${port}/${name}';

    pool = new Pool(connectString, min: minimumConnections, max: maximumConnections);
    return pool.start().then((_) => _testConnection());
  }

  Future _testConnection() => pool.connect().then((Connection conn) => conn.close());

  Future<Dialplan> getDialplan(int receptionId) =>
      _getDialplan(pool, receptionId);
}

/* ***********************************************
   ***************** Utilities *******************
 */

Future<List<Row>> query(Pool pool, String sql, [Map parameters = null]) =>  pool.connect()
  .then((Connection conn) => conn.query(sql, parameters).toList()
  .whenComplete(() => conn.close()));

Future<int> execute(Pool pool, String sql, [Map parameters = null]) => pool.connect()
  .then((Connection conn) => conn.execute(sql, parameters)
  .whenComplete(() => conn.close()));
