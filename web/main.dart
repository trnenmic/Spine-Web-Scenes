import 'dart/core/window_manager.dart';
import 'dart/digitalshard/ds_factory_manager.dart';


void main() {
  DsFactoryManager dsFactoryManager = new DsFactoryManager();
  WindowManager windowManager = new WindowManager(dsFactoryManager);
  windowManager.init();

}





