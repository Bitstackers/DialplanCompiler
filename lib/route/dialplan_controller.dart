part of XmlDialplanGenerator.router;

class DialplanController {
  Configuration config;

  DialplanController(Configuration this.config);

  void deployCompiler(HttpRequest request) {
      int receptionId = pathIntParameter(request.uri, 'reception');
      extractContent(request).then((String content) {
        Map json;
        Dialplan dialplan;
        try {
          json = JSON.decode(content);
        } catch(error) {
          clientError(request, "Malformed Json format");
          return;
        }

        try {
          dialplan = new Dialplan.fromJson(json)
            ..receptionId = receptionId;
        } catch(error) {
          clientError(request, "Malformed Dialplan format");
          return;
        }

        try {
          _compileDialplan(dialplan);
        } catch(error) {
          clientError(request, "Compiler error. ${error}");
          return;
        }

        allOk(request);
      }).catchError((error, stack) {
        InternalServerError(request, error: error, stack: stack);
      });
    }

  void _compileDialplan(Dialplan dialplan) {
    DialplanGeneratorOutput output = generateDialplanXml(dialplan);

    String publicFilePath = path.join(config.publicContextPath, '${dialplan.receptionId}.xml');
    File publicFile = new File(publicFilePath);

    //The XmlPackage v1.0.0 is deprecated, and it uses carrage-return instead of newlines, for line breaks.
    String publicContent = output.entry.toString().replaceAll('\r', '\n');
    publicFile.writeAsStringSync(publicContent, mode: FileMode.WRITE, flush:true);

    String localFilePath = path.join(config.localContextPath, '${dialplan.receptionId}.xml');
    File localFile = new File(localFilePath);

    //The XmlPackage v1.0.0 is deprecated, and it uses carrage-return instead of newlines, for line breaks.
    String localContent = output.receptionContext.toString().replaceAll('\r', '\n');
    localFile.writeAsStringSync(localContent, mode: FileMode.WRITE, flush:true);
  }

  void deployIvr(HttpRequest request) {
    int receptionId = pathIntParameter(request.uri, 'reception');

    extractContent(request).then((String content) {
      if(content == null || content.isEmpty) {
        clientError(request, "No date send");
        return new Future.value();
      }

      Map json;
      try {
        json = JSON.decode(content);
      } catch(error) {
        clientError(request, "Malformed json");
        return new Future.value();
      }

      IvrList ivrlist;
      try {
        ivrlist = new IvrList.fromJson(json);
      } catch(error) {
        clientError(request, "Malformed Ivr");
        return new Future.value();
      }

      try {
        String filePath = path.join(config.ivrPath, '${receptionId}.xml');
        File file = new File(filePath);

        //The XmlPackage v1.0.0 is deprecated, and it uses carrage-return instead of newlines, for line breaks.
        String compiledIvr = generateIvrXml(ivrlist, receptionId).toString().replaceAll('\r', '\n');
        return file.writeAsString(compiledIvr, mode: FileMode.WRITE, flush: true)
                   .then((_) => allOk(request));
      } catch(error, stack) {
        logger.error('deployIvr url: ${request.uri}, gave Error: "${error}" \n${stack}');
        InternalServerError(request);
      }
    }).catchError((error, stack) {
      logger.error('deployIvr url: ${request.uri}, gave Error: "${error}" \n${stack}');
      InternalServerError(request);
    });
  }
}


