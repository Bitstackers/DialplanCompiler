library ConditionToXml;

import 'package:libdialplan/libdialplan.dart' as dialplan;
import 'package:xml/xml.dart';

import '../generator.dart';

XmlElement conditionToXml(dialplan.Condition condition, [String failoverExtension = null, int receptionId]) {
  if(condition is dialplan.Time) {
    return timeCondition(condition, failoverExtension, receptionId);

  } else {
    return null;
  }
}

XmlElement timeCondition(dialplan.Time condition, [String failoverExtension = null, int receptionId]) {
  XmlElement node = new XmlElement('condition');

  if(condition.timeOfDay != null && condition.timeOfDay.isNotEmpty) {
    node.attributes['time-of-day'] = condition.timeOfDay;
  }

  if(condition.wday != null && condition.wday.isNotEmpty) {
    node.attributes['wday'] = dialplan.Time.transformWdayToFreeSwitchFormat(condition.wday);
  }

  if(failoverExtension != null && failoverExtension.isNotEmpty && receptionId != null) {
    XmlElement antiAction = FsTransfer(receptionExtensionName(receptionId, failoverExtension), contextName(receptionId), anti_action: true);
    node.children.add(antiAction);
  }

  return node;
}
