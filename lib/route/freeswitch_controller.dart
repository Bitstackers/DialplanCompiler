part of XmlDialplanGenerator.router;

class FreeswitchController {
  Configuration config;
  Database db;

  FreeswitchController(Database this.db, Configuration this.config);

  List<String> audioFormats = ['wav'];

  void listAudioFiles(HttpRequest request) {
    int receptionId = pathIntParameter(request.uri, 'reception');

    Directory dir = new Directory(path.join(config.audioFolder, '${receptionId}'));
    List<String> listOfFiles = [];
    if(dir.existsSync()) {
      List<FileSystemEntity> files = dir.listSync();
      listOfFiles = files.
          where((FileSystemEntity file) => audioFormats.any((String format) => file.absolute.path.endsWith(format))).
          map((FileSystemEntity file) => file.absolute.path).toList();
    }

    writeAndCloseJson(request, JSON.encode({'files': listOfFiles}));
  }

  void deployPlaylist(HttpRequest request) {
    int playlistId = pathIntParameter(request.uri, 'playlist');

    db.getPlaylist(playlistId).then((Playlist playlist) {
      if(playlist == null) {
        return page404(request);
      }

      String filePath = path.join(config.localStreamPath, '${playlist.id}.xml');
      File file = new File(filePath);

      //The XmlPackage v1.0.0 is deprecated, and it uses carrage-return instead of newlines, for line breaks.
      String content = generateLocalStream(playlist).toString().replaceAll('\r', '\n');
      return file.writeAsString(content, mode: FileMode.WRITE, flush: true)
          .then((_) => writeAndCloseJson(request, JSON.encode({})) );
    }).catchError((error, stack) {
      logger.error('deployPlaylist url: ${request.uri}, gave Error: "${error}" \n${stack}');
      InternalServerError(request);
    });
  }
}
