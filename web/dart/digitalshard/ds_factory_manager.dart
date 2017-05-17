import 'ds_page_designer.dart';
import 'package:json_object/json_object.dart';

import '../core/abs_factory_manager.dart';
import '../core/abs_module_manager.dart';
import '../core/abs_page_designer.dart';
import '../core/section_manager.dart';
import 'ds_module_manager.dart';

class DsFactoryManager implements FactoryManager{

  @override
  ModuleManager createModuleManager(JsonObject config, SectionManager section){
    return new DsModuleManager(config, section);
  }

  @override
  PageDesigner createPageDesigner() {
    return new DsPageDesigner();
  }
}