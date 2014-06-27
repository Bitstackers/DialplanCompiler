part of XmlDialplanGenerator.router;

class DialplanController {
  Database db;
  Configuration config;

  DialplanController(Database this.db, Configuration this.config);

  void deploy(HttpRequest request) {
    int receptionId = pathIntParameter(request.uri, 'reception');
    db.getDialplan(receptionId).then((Dialplan dialplan) {
      try {
        GeneratorOutput output = generateXml(dialplan);

        String publicFilePath = config.publicContextPath + 'reception_${receptionId}.xml';
        File publicFile = new File(publicFilePath);

        //FIXME The need for a replace here should be fixed in the package and not here.
        String publicContent = output.entry.toString().replaceAll('\r', '\n');
        publicFile.writeAsStringSync(publicContent, mode: FileMode.WRITE, flush:true);

        String localFilePath = config.localContextPath + 'reception_${receptionId}.xml';
        File localFile = new File(localFilePath);

        //FIXME The need for a replace here should be fixed in the package and not here.
        String localContent = output.receptionContext.toString().replaceAll('\r', '\n');
        localFile.writeAsStringSync(localContent, mode: FileMode.WRITE, flush:true);

        writeAndCloseJson(request, '{}');
      } catch(error, stack) {
        InternalServerError(request, error: error, stack: stack);
      }
    }).catchError((error, stack) {
      InternalServerError(request, error: error, stack: stack);
    });
  }
}


