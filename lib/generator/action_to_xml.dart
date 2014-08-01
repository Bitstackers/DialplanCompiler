library ActionToXml;

import 'package:libdialplan/libdialplan.dart';
import 'package:XmlDialplanGenerator/utilities.dart';
import 'package:xml/xml.dart';

/**
 * Transform an [Action] object to XmlNode.
 * There is returned a [List] because, an action require sometimes multiple
 *  Freeswitch XmlNodes.
 */
List<XmlElement> actionToXml(Action action) {
  if(action == null) {
    throw new ArgumentError('action is null');
  }

  if(action is Receptionists) {
    return _receptionist(action);

  } else if (action is Voicemail) {
    return _voicemail(action);

  } else if (action is PlayAudio) {
    return _playAudio(action);

  } else if (action is Transfer) {
    return _transfer(action);

  } else {
    throw 'Unknown Action. ${action.runtimeType}';
  }
}

List<XmlElement> _playAudio(PlayAudio action) {
  List<XmlElement> nodes = new List<XmlElement>();

  nodes.add(XmlAction('playback', '${action.filename}'));

  return nodes;
}

List<XmlElement> _receptionist(Receptionists action) {
  List<XmlElement> nodes = new List<XmlElement>();

  if(action.sleepTime != null) {
    nodes.add(XmlAction('set', 'sleeptime=${action.sleepTime}'));
  }

  if(action.music != null && action.music.isNotEmpty) {
    nodes.add(XmlAction('set', 'fifo_music=${action.music}'));
  }

  nodes.add(XmlAction('transfer', 'prequeue XML default'));

  return nodes;
}

List<XmlElement> _transfer(Transfer action) {
  List<XmlElement> nodes = new List<XmlElement>();

  if(action.type == TransferType.PHONE) {
    nodes.add(XmlAction('transfer', '${action.phoneNumber} XML default'));
  } else if (action.type == TransferType.GROUP) {
    nodes.add(XmlAction('transfer', '${action.extensionGroup} XML default'));
  }

  return nodes;
}

List<XmlElement> _voicemail(Voicemail action) {
  List<XmlElement> nodes = new List<XmlElement>();

  nodes.add(XmlAction('transfer', 'voicemail XML default'));

  return nodes;
}
