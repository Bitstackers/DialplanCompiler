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

Future<IvrList> _getIvr(Pool pool, int receptionId) {
  String sql = '''
    SELECT ivr
    FROM receptions
    WHERE id = @receptionid
  ''';

  Map parameters = {'receptionid': receptionId};

  return query(pool, sql, parameters).then((rows) {
    if(rows.length != 1) {
      return null;
    } else {
      Row row = rows.first;
      return new IvrList.fromJson(JSON.decode(row.ivr));
    }
  });
}

Future<Playlist> _getPlaylist(Pool pool, int playlistId) {
  String sql = '''
    SELECT id, content
    FROM playlists
    WHERE id = @playlistid
  ''';

  Map parameters = {'playlistid': playlistId};

  return query(pool, sql, parameters).then((rows) {
    if(rows.length != 1) {
      return null;
    } else {
      Row row = rows.first;
      return new Playlist.fromJson(JSON.decode(row.content))
        ..id = row.id;
    }
  });
}
