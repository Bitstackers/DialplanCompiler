library ivrcompiler;

import 'package:xml/xml.dart';

import 'package:libdialplan/ivr.dart';

import 'dialplan_compiler.dart';

XmlElement generateIvrXml(IvrList list, int receptionId) {
  //Every include file must have a root element <include>
  XmlElement root = new XmlElement('include');

  root.children.addAll(list.list.map((Ivr ivr) => _generateMenu(ivr, receptionId)));

  return root;
}

XmlElement _generateMenu(Ivr ivr, int receptionId) {
  XmlElement menu = new XmlElement('menu')
    ..attributes['name'] = _menuName(ivr.name, receptionId);

  if(ivr.confirmAttempts != null) {
    menu.attributes['confirm-attempts'] = ivr.confirmAttempts.toString();
  }

  if(ivr.confirmKey != null) {
    menu.attributes['confirm-key'] = ivr.confirmKey;
  }

  if(ivr.ditgitLength != null) {
    menu.attributes['digit-len'] = ivr.ditgitLength.toString();
  }

  if(ivr.exitSound != null) {
    menu.attributes['exit-sound'] = ivr.exitSound;
  }

  if(ivr.greetingLong != null) {
    menu.attributes['greet-long'] = ivr.greetingLong;
  }

  if(ivr.greetingShort != null) {
    menu.attributes['greet-short'] = ivr.greetingShort;
  }

  if(ivr.interDigitTimeout != null) {
    menu.attributes['inter-digit-timeout'] = ivr.interDigitTimeout.toString();
  }

  if(ivr.invalidSound != null) {
    menu.attributes['invalid-sound'] = ivr.invalidSound;
  }

  if(ivr.maxFailures != null) {
    menu.attributes['max-failures'] = ivr.maxFailures.toString();
  }

  if(ivr.maxTimeouts != null) {
    menu.attributes['max-timeouts'] = ivr.maxTimeouts.toString();
  }

  if(ivr.timeout != null) {
    menu.attributes['timeout'] = ivr.timeout.toString();
  }

  menu.children.addAll(ivr.entries.map((Entry entry) => _makeEntryNode(entry, receptionId)));

  return menu;
}

XmlElement _makeEntryNode(Entry entry, int receptionId) {
  XmlElement node = new XmlElement('entry');

  node.attributes['action'] = 'menu-exec-app';
  node.attributes['digits'] = entry.digits;
  node.attributes['param'] = 'transfer ${entry.extensionGroup} XML ${contextName(receptionId)}';

  return node;
}

String _menuName(String ivrName, int receptionId) => '${receptionId}_${ivrName}';
