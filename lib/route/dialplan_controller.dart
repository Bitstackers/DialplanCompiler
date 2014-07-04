part of XmlDialplanGenerator.router;

class DialplanController {
  Database db;
  Configuration config;

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

    String publicFilePath = config.publicContextPath + '${receptionId}.xml';
    File publicFile = new File(publicFilePath);

    //FIXME The need for a replace here should be fixed in the package and not here.
    String publicContent = output.entry.toString().replaceAll('\r', '\n');
    publicFile.writeAsStringSync(publicContent, mode: FileMode.WRITE, flush:true);

    String localFilePath = config.localContextPath + '${receptionId}.xml';
    File localFile = new File(localFilePath);

    //FIXME The need for a replace here should be fixed in the package and not here.
    String localContent = output.receptionContext.toString().replaceAll('\r', '\n');
    localFile.writeAsStringSync(localContent, mode: FileMode.WRITE, flush:true);
  }

  void deployIvr(IvrList list) {
    throw 'Not Implemented';
  }
}


