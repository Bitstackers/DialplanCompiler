part of XmlDialplanGenerator.router;

class FreeswitchController {
  Configuration config;

  FreeswitchController(Configuration this.config);

  List<String> audioFormats = ['wav'];

  void listAudioFiles(HttpRequest request) {
    int receptionId = pathIntParameter(request.uri, 'reception');

    Directory dir = new Directory(path.join(config.audioFolder, '${receptionId}'));
    if(dir.existsSync()) {
      List<FileSystemEntity> files = dir.listSync();

      Map result = {'files': files.
                      where((FileSystemEntity file) => audioFormats.any((String format) => file.absolute.path.endsWith(format))).
                      map((FileSystemEntity file) => file.absolute.path).toList()};

      writeAndCloseJson(request, JSON.encode(result));

    } else {
      writeAndCloseJson(request, JSON.encode({}));
    }
  }
}
