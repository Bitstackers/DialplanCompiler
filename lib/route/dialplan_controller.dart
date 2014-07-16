part of XmlDialplanGenerator.router;

class DialplanController {
  Configuration config;
  Database db;

  DialplanController(Database this.db, Configuration this.config);

  void deploy(HttpRequest request) {
    int receptionId = pathIntParameter(request.uri, 'reception');
    db.getDialplan(receptionId).then((Dialplan dialplan) {
      if(dialplan == null) {
        return page404(request);
      }

      try {
        deployDialplan(dialplan, receptionId);


        writeAndCloseJson(request, '{}');
      } catch(error, stack) {
        InternalServerError(request, error: error, stack: stack);
      }
    }).catchError((error, stack) {
      InternalServerError(request, error: error, stack: stack);
    });
  }

  void deployDialplan(Dialplan dialplan, int receptionId) {
    DialplanGeneratorOutput output = generateDialplanXml(dialplan);

    String publicFilePath = path.join(config.publicContextPath, '${receptionId}.xml');
    File publicFile = new File(publicFilePath);

    //The XmlPackage v1.0.0 is deprecated, and it uses carrage-return instead of newlines, for line breaks.
    String publicContent = output.entry.toString().replaceAll('\r', '\n');
    publicFile.writeAsStringSync(publicContent, mode: FileMode.WRITE, flush:true);

    String localFilePath = path.join(config.localContextPath, '${receptionId}.xml');
    File localFile = new File(localFilePath);

    //The XmlPackage v1.0.0 is deprecated, and it uses carrage-return instead of newlines, for line breaks.
    String localContent = output.receptionContext.toString().replaceAll('\r', '\n');
    localFile.writeAsStringSync(localContent, mode: FileMode.WRITE, flush:true);
  }

  void deployIvr(IvrList list) {
    throw 'Not Implemented';
  }
}


