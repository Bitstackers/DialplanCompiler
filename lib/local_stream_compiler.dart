library localstreamcompiler;

import 'package:xml/xml.dart';

import 'model/playlist.dart';

const int _DEFAULT_RATE = 8000;

XmlElement generateLocalStream(Playlist playlist) {
  XmlElement root = new XmlElement('include');

  root.children.add(_generateFromPlaylist(playlist));

  return root;
}

XmlElement _generateFromPlaylist(Playlist playlist) {
  List<XmlElement> parameters = new List<XmlElement>()
    ..add(_paramNode('rate', (playlist.rate == null || playlist.rate <= 0 ? _DEFAULT_RATE : playlist.rate).toString() ))
    ..add(_paramNode('shuffle', playlist.shuffle.toString()))
    ..add(_paramNode('channels', playlist.channels.toString()))
    ..add(_paramNode('interval', playlist.interval.toString()));

  //This is not supported, because there is some inconsistencies in how much of the file is getting played.
//  if(playlist.chimelist != null && playlist.chimelist.isNotEmpty) {
//    parameters
//      ..add(_paramNode('chime-list', playlist.chimelist.join(',')))
//      ..add(_paramNode('chime-freq', playlist.chimefreq.toString()))
//      ..add(_paramNode('chime-max', playlist.chimemax.toString()));
//  }

  XmlElement stream = new XmlElement('directory', elements: parameters)
    ..attributes['name'] = playlist.name
    ..attributes['path'] = playlist.path;
  return stream;
}

XmlElement _paramNode(String name, String value) {
  return new XmlElement('param')
    ..attributes['name'] = name
    ..attributes['value'] = value;
}
