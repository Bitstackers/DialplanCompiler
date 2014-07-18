library ActionToXml;

import 'package:libdialplan/libdialplan.dart';
import 'package:XmlDialplanGenerator/utilities.dart';
import 'package:xml/xml.dart';

List<XmlElement> actionToXml(Action action) {
  if(action is Receptionists) {
    return receptionist(action);

  } else if (action is Voicemail) {
    return voicemail(action);

  } else if (action is PlayAudio) {
    return playAudio(action);

  } else if (action is Transfer) {
    return transfer(action);

  } else {
    return [];
  }
}

List<XmlElement> playAudio(PlayAudio action) {
  List<XmlElement> nodes = new List<XmlElement>();

  nodes.add(XmlAction('playback', '${action.filename}'));

  return nodes;
}

List<XmlElement> receptionist(Receptionists action) {
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

List<XmlElement> transfer(Transfer action) {
  List<XmlElement> nodes = new List<XmlElement>();

  if(action.type == TransferType.PHONE) {
    nodes.add(XmlAction('transfer', '${action.phoneNumber} XML default'));
  } else if (action.type == TransferType.GROUP) {
    nodes.add(XmlAction('transfer', '${action.extensionGroup} XML default'));
  }

  return nodes;
}

List<XmlElement> voicemail(Voicemail action) {
  List<XmlElement> nodes = new List<XmlElement>();

  nodes.add(XmlAction('transfer', 'voicemail XML default'));

  return nodes;
}
