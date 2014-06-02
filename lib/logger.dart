library adaheads.XmlDialplanGenerator.logger;

Logger logger = new Logger();

class Logger {
  void debug(message) => print('[DEBUG] [${new DateTime.now()}] $message');
  void error(message) => print('[ERROR] [${new DateTime.now()}] $message');
  void critical(message) => print('[CRITICAL] [${new DateTime.now()}] $message');
}
