library ConditionToXml;

import 'package:libdialplan/libdialplan.dart' as dialplan;
import 'package:xml/xml.dart';

/**
 * Transform a [Condition] object to XmlNode.
 */
XmlElement conditionToXml(dialplan.Condition condition) {
  if(condition == null) {
    throw new ArgumentError('condition is null');
  }

  if(condition is dialplan.Time) {
    return timeCondition(condition);

  } else if(condition is dialplan.Date) {
    return dateCondition(condition);

  } else {
    throw 'Unknow condition. ${condition.runtimeType}';
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

XmlElement dateCondition(dialplan.Date condition) {
  XmlElement node = new XmlElement('condition');

  node.attributes['year'] = condition.year;
  node.attributes['mon'] = condition.mon;
  node.attributes['mday'] = condition.mday;

  return node;
}
