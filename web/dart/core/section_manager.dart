import 'dart:html' as html;

import 'package:json_object/json_object.dart';
import 'package:stagexl/stagexl.dart';
import 'package:stagexl_spine/stagexl_spine.dart';

import 'abs_factory_manager.dart';
import 'abs_module_manager.dart';
import 'loading_manager.dart';
import 'render_updater.dart';
import 'stage_manager.dart';
import 'window_manager.dart';


class SectionManager {


  JsonObject config;
  RenderLoop renderLoop;
  ResourceManager resourceManager;
  RenderUpdater renderUpdater;
  WindowManager windowManager;

  int index;
  bool useGlobalAssets;

  html.Element canvas;
  StageManager stageManager;
  ModuleManager moduleManager;
  FactoryManager factoryManager;

  SectionManager(WindowManager windowManager, FactoryManager factoryManager, JsonObject config, RenderLoop renderLoop,
      ResourceManager resourceManager, int index,
      LoadingManager loadingManager, RenderUpdater renderUpdater,
      bool useGlobalAssets) {
    this.factoryManager = factoryManager;
    this.windowManager = windowManager;
    this.config = config;
    this.renderLoop = renderLoop;
    this.resourceManager = resourceManager;
    this.index = index;
    this.useGlobalAssets = useGlobalAssets;
    this.renderUpdater = renderUpdater;
    canvas = html.document.querySelector('#' + config.id);
  }

  void init() {
    stageManager =
    new StageManager(this, config, renderLoop, resourceManager, canvas, index);
    if (canvas != null && stageManager.stage != null) {
      stageManager.load(resourceManager, useGlobalAssets)
          .then(stageManager.start)
          .then(completeInit);
    } else {
      html.window.console.log(
          "HTML elements for initialization of StageManager not found.");
    }
  }

  void completeInit(var result){
    loadIncrement();
    moduleManager = factoryManager.createModuleManager(config, this);
    moduleManager.start(result);
  }

  void delegateRenderStagesInViewport(){
    renderUpdater.renderStagesInViewport();
  }

  void resizeSection(){
    renderUpdater.resizeSection(this);
  }

  void loadIncrement(){
    windowManager.loadIncrement();
  }

  void completeStage(){
    windowManager.loadCompleteStage(index);
  }

  html.Element getShadowCanvas(){
    return stageManager.shadowCanvas;
  }

  Stage getStage(){
    return stageManager.stage;
  }

  Stage getShadowStage(){
    return stageManager.shadowStage;
  }

  html.Element getDiv(){
    return stageManager.div;
  }


  void delegateLockControls(bool value){
    stageManager.lockControls = value;
  }

  bool isLockedControls(){
    return stageManager.lockControls;
  }

  List<SkeletonAnimation> getSkeletons(){
    return stageManager.skeletons;
  }

  SkeletonAnimation getActor(){
    return stageManager.actor;
  }

  num getLeftReferenceX(){
    return stageManager.leftReference.x;
  }

  num getRightReferenceX(){
    return stageManager.rightReference.x;
  }

  RenderLoop getRenderLoop(){
    return renderLoop;
  }

  bool delegateRenderInsideWindow(html.Element canvas){
    return renderUpdater.isInsideWindow(canvas);
  }
}