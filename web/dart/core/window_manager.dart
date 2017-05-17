import 'dart:html' as html;

import 'package:json_object/json_object.dart';
import 'package:stagexl/stagexl.dart';

import 'abs_factory_manager.dart';
import 'const_settings.dart';
import 'loading_manager.dart';
import 'abs_page_designer.dart';
import 'render_updater.dart';
import 'section_manager.dart';
import 'tab_manager.dart';

class WindowManager {

  RenderUpdater renderUpdater;
  TabManager tabManager;
  RenderLoop renderLoop;
  LoadingManager loadingManager;
  ResourceManager resourceManager;
  JsonObject config;

  FactoryManager factoryManager;

  WindowManager(FactoryManager factoryManager){
      this.factoryManager = factoryManager;
  }


  void init() {
    StageXL.stageOptions.backgroundColor = 0;
    StageXL.stageOptions.transparent = true;
    loadingManager = new LoadingManager();
    loadingManager.increment();
    String path = ConstSettings.CONFIG_PATH + ConstSettings.CONFIG_FILE;
    html.HttpRequest.getString(path).then((String configFileContent) {
      _initializeStages(configFileContent);
    }).catchError((Error error) {
      print(error.toString());
    });
  }

  void _initializeStages(String configFileContent) {
    config = new JsonObject.fromJsonString(configFileContent);
    html.window.console.log(configFileContent);
    loadingManager.setLimit(config.stages.length);
    resourceManager = new ResourceManager();
    renderLoop = new RenderLoop();
    renderUpdater = new RenderUpdater(renderLoop);
    tabManager = new TabManager(renderUpdater);
    tabManager.init();
    for (int i = 0; i < config.stages.length; i++) {
      SectionManager sectionManager = new SectionManager(
          this,
          factoryManager,
          config.stages[i],
          renderLoop,
          resourceManager,
          i,
          loadingManager,
          renderUpdater,
          config.useGlobalAssets);
      loadingManager.addCircleAnimator(sectionManager.canvas);
      sectionManager.init();
      renderUpdater.addManager(sectionManager);
    }
    PageDesigner pageDesigner = factoryManager.createPageDesigner();
    pageDesigner.init();
    renderUpdater.renderStagesInViewport();
    tabManager.managers = renderUpdater.managers;
  }

  void loadIncrement(){
    loadingManager.increment();
  }

  void loadCompleteStage(int index){
    loadingManager.stageCompleted(index);
  }


}