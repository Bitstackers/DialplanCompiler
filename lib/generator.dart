library generator;

import 'package:libdialplan/libdialplan.dart';
import 'package:xml/xml.dart';

import 'generator/action_to_xml.dart';
import 'generator/condition_to_xml.dart';
import 'utilities.dart';

class GeneratorOutput {
  XmlElement entry;
  XmlElement receptionContext;
}

/**
 * Generates multiple extensions for a receptions dialplan.
 */
GeneratorOutput generateXml(Dialplan dialplan) {
  GeneratorOutput output = new GeneratorOutput();

  //The extension the caller hits.
  output.entry = makeEntryNode(dialplan,[]);


  XmlElement context = new XmlElement('context')
    ..attributes['name'] = contextName(dialplan.receptionId);

  //Every included file, must have the root element <include>
  XmlElement include = new XmlElement('include');
  output.receptionContext = include
    ..children.add(context);

  //Make actual Extension.
  //The Catch all extension should be last i the chain.
  Iterable<XmlElement> extensions = dialplan.Extensions.where((Extension ext) => !ext.isCatchAll).map((Extension ext) => makeReceptionExtensions(ext, dialplan.receptionId));
  context.children.addAll(extensions);

  //There should only be one extension as CatchAll, but this is the simplest one.
  Iterable<XmlElement> catchAllExtension = dialplan.Extensions.where((Extension ext) => ext.isCatchAll).map((Extension ext) => makeReceptionExtensions(ext, dialplan.receptionId));
  context.children.addAll(catchAllExtension);
  return output;
}

/**
 * Makes the reception extensions.
 */
XmlElement makeReceptionExtensions(Extension extension, int receptionId) {
  XmlElement head = new XmlElement('extension')
    ..attributes['name'] = receptionExtensionName(receptionId, extension.name);

  if(!extension.isCatchAll) {
    //Makes the conditions.
    XmlElement destCond = XmlCondition('destination_number', receptionExtensionName(receptionId, extension.name));
    head.children.add(destCond);

    head.children.addAll(extension.conditions.map((condition) => conditionToXml(condition, extension.failoverExtension, receptionId)));
  } else {
    head.children.add(new XmlElement('condition'));
  }
  XmlElement lastCondition = head.children.last;

  //Makes all the actions
  Iterable<List<XmlElement>> actions = extension.actions.map(actionToXml);
  if(actions.isNotEmpty) {
    lastCondition.children.addAll(actions.reduce(union));
  }

  return head;
}

/**
 * Makes the extension that catches one the phonenumber.
 */
XmlElement makeEntryNode(Dialplan dialplan, Iterable<String> conditionExtensions) {
  XmlElement entry = new XmlElement('extension')
    ..attributes['name'] = entryExtensionName(dialplan.receptionId);

  XmlElement numberCondition = XmlCondition('destination_number', '^${dialplan.entryNumber}\$');
  entry.children.add(numberCondition);

  XmlElement setId = XmlAction('set', 'receptionid=${dialplan.receptionId}');
  numberCondition.children.add(setId);

  //Executes all the extensions that sets condition variables.
  numberCondition.children.addAll(conditionExtensions.map((String extentionName) => XmlAction('execute_extension', extentionName)));

  Extension startExtension = dialplan.Extensions.firstWhere((Extension e) => e.isStart);
  XmlElement main = FsTransfer(receptionExtensionName(dialplan.receptionId, startExtension.name), contextName(dialplan.receptionId)); //XmlAction('transfer', receptionExtensionName(dialplan.receptionId, startExtension.name));
  numberCondition.children.add(main);

  return entry;
}

//TODO REMOVE - LIBRARY THIS.
XmlElement FsTransfer(String extension, String context, {bool anti_action: false}) {
  return XmlAction('transfer', '${extension} xml ${context}', anti_action);
}

/** Returns the name of the context for the reception*/
String contextName(int receptionId) => 'Rcontext_${receptionId}';

/** Returns the name of the branching extensions for a reception.*/
String mainDestinationName(int receptionId) => 'r_${receptionId}_main';

/** Returns the name of the entry extension for a reception.*/
String entryExtensionName(int receptionid) => 'r_$receptionid';

/** Returns the name of the branching extension.*/
String receptionExtensionName(int receptionId, String extensionName) => 'r_${receptionId}_${extensionName}';

