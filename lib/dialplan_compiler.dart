library dialplancompiler;

import 'package:libdialplan/libdialplan.dart';
import 'package:xml/xml.dart';

import 'generator/action_to_xml.dart';
import 'generator/condition_to_xml.dart';
import 'utilities.dart';

/**
 * The call comes in in the public context, and gets transfered to it's own
 *  reception specifict context. Therefore we need to generate "two" dialplans
 */
class DialplanGeneratorOutput {
  XmlElement entry;
  XmlElement receptionContext;
}

/**
 * Generates multiple extensions for a receptions dialplan.
 */
DialplanGeneratorOutput generateDialplanXml(Dialplan dialplan) {
  DialplanGeneratorOutput output = new DialplanGeneratorOutput();

  //The extension the caller first hits.
  output.entry = _makeEntryNode(dialplan,[]);

  output.receptionContext = _makeReceptionContext(dialplan);

  return output;
}

XmlElement _makeReceptionContext(Dialplan dialplan) {
  //Every included file, must have the root element <include>
  XmlElement include = new XmlElement('include');

  XmlElement context = new XmlElement('context')
     ..attributes['name'] = contextName(dialplan.receptionId);
  include.children.add(context);

  List<XmlElement> extensions = new List<XmlElement>();
  for(ExtensionGroup group in dialplan.extensionGroups) {
    List<Extension> extensionList = group.extensions;
    extensions.addAll(extensionList.map((Extension ext) => _makeReceptionExtensions(ext, group.name, dialplan.receptionId)));

    if(extensionList.any((Extension ext) => ext.conditions.isEmpty)) {
      //TODO make a "I as a creater of this dialplan may just have fucked up, and please catch the call so Freeswitch don't hangup on it" extension
    }
  }
  context.children.addAll(extensions);

  return include;
}

/**
 * Makes the reception extensions.
 */
XmlElement _makeReceptionExtensions(Extension extension, String groupName, int receptionId) {
  XmlElement extensionNode = new XmlElement('extension')
    ..attributes['name'] = receptionExtensionName(receptionId, extension.name);

  //Check if the destination_number is right
  XmlElement destCond = XmlCondition('destination_number', receptionExtensionName(receptionId, groupName));
  extensionNode.children.add(destCond);

  //Makes the conditions
  XmlElement lastCondition = destCond;
  for(Condition condition in extension.conditions) {
    XmlElement conditionNode = conditionToXml(condition);
    //The conditions must be nested, otherwise the Freeswitch stops look after it
    // have found it's a condition which criteria is meet.
    lastCondition.children.add(conditionNode);
    lastCondition = conditionNode;
  }

  //Makes all the actions
  Iterable<List<XmlElement>> xmlActions = extension.actions.map(actionToXml);
  if(xmlActions.isNotEmpty) {
    lastCondition.children.addAll(xmlActions.reduce(union));
  }

  return extensionNode;
}

/**
 * Makes the extension that catches one the phonenumber.
 */
XmlElement _makeEntryNode(Dialplan dialplan, Iterable<String> conditionExtensions) {
  XmlElement entry = new XmlElement('extension')
    ..attributes['name'] = entryExtensionName(dialplan.receptionId);

  String entryNumber = dialplan.entryNumber.replaceAll(' ', '');
  XmlElement numberCondition = XmlCondition('destination_number', '^${entryNumber}\$');
  entry.children.add(numberCondition);

  XmlElement setId = XmlAction('set', 'reception_id=${dialplan.receptionId}');
  numberCondition.children.add(setId);

  //Executes all the extensions that sets condition variables.
  numberCondition.children.addAll(conditionExtensions.map((String extentionName) => XmlAction('execute_extension', extentionName)));

  String context = contextName(dialplan.receptionId);
  String extension = receptionExtensionName(dialplan.receptionId, dialplan.startExtensionGroup);
  XmlElement main = _FsXmlTransfer(extension, context);
  numberCondition.children.add(main);

  return entry;
}

/**Makes a simple transfer node.*/
XmlElement _FsXmlTransfer(String extension, String context, {bool anti_action: false}) {
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

