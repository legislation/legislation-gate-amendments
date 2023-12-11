Any resource files (configuration files, JAPE grammars, etc.) that your plugin
uses should be placed under this directory.  To load them, declare a parameter
of type gate.creole.ResourceReference with the path from src/main/resources as
its default value:

@CreoleParameter(defaultValue = "resources/config.txt")
public void setConfigLocation(ResourceReference config) {
  // ...
}

public ResourceReference getConfigLocation() {
  // ...
}

A user of your plugin can then accept the default and use the resource file
from inside the plugin, or they can supply their own file: URL to override it.

You can then access the file's contents in your init() and/or execute() methods
using the ResourceReference API:

try(InputStream configStream = configLocation.openStream();
    InputStreamReader reader = new InputStreamReader(configStream, "UTF-8");
    BufferedReader configReader = new BufferedReader(reader)) {
  String line;
  while((line = configReader.readLine()) != null) {
    // ...
  }
}
