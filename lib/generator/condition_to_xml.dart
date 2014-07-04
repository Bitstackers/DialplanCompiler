library ConditionToXml;

import 'package:libdialplan/libdialplan.dart' as dialplan;
import 'package:xml/xml.dart';

import '../dialplan_compiler.dart';

XmlElement conditionToXml(dialplan.Condition condition) {
  if(condition is dialplan.Time) {
    return timeCondition(condition);

  } else {
    return null;
  }
}

XmlElement timeCondition(dialplan.Time condition) {
  XmlElement node = new XmlElement('condition');

  if(condition.timeOfDay != null && condition.timeOfDay.isNotEmpty) {
    node.attributes['time-of-day'] = condition.timeOfDay;
  }

  if(condition.wday != null && condition.wday.isNotEmpty) {
    node.attributes['wday'] = dialplan.Time.transformWdayToFreeSwitchFormat(condition.wday);
  }

  return node;
}
