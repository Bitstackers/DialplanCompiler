part of XmlDialplanGenerator.router;

class FreeswitchController {
  Configuration config;

  FreeswitchController(Configuration this.config);

  List<String> audioFormats = ['wav', 'mp3', 'ogg'];

  void listAudioFiles(HttpRequest request) {
    int receptionId = pathIntParameter(request.uri, 'reception');

    Directory dir = new Directory('${config.audioFolder}${receptionId}');
    if(dir.existsSync()) {
      List<FileSystemEntity> files = dir.listSync();

      Map result = {'files': files.
                      where((file) => audioFormats.any((format) => file.absolute.path.endsWith(format))).
                      map((file) => file.absolute.path).toList()};

      writeAndCloseJson(request, JSON.encode(result));

    } else {
      writeAndCloseJson(request, JSON.encode({}));
    }
  }
}
