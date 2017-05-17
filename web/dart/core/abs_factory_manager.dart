import 'package:json_object/json_object.dart';

import 'abs_module_manager.dart';
import 'abs_page_designer.dart';
import 'section_manager.dart';

abstract class FactoryManager {

  ModuleManager createModuleManager(JsonObject config, SectionManager section);
  PageDesigner createPageDesigner();

}