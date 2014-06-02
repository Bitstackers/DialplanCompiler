part of database;

Future<Dialplan> _getDialplan(Pool pool, int receptionId) {
  String sql = '''
    SELECT dialplan, reception_telephonenumber
    FROM receptions
    WHERE id = @receptionid
  ''';

  Map parameters = {'receptionid': receptionId};

  return query(pool, sql, parameters).then((rows) {
    if(rows.length != 1) {
      return null;
    } else {
      Row row = rows.first;
      return new Dialplan.fromJson(JSON.decode(row.dialplan))
        ..entryNumber = row.reception_telephonenumber
        ..receptionId = receptionId;
    }
  });
}
