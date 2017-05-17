import 'dart:html' as html;

import 'package:json_object/json_object.dart';
import 'package:stagexl/stagexl.dart';
import 'package:stagexl_spine/stagexl_spine.dart';

import 'section_manager.dart';

abstract class ModuleManager {

  JsonObject config;
  SectionManager section;

  html.Element canvas;
  html.Element shadowCanvas;
  Stage stage;
  Stage shadowStage;
  html.Element div;

  List<SkeletonAnimation> skeletons;
  SkeletonAnimation actor;

  ModuleManager(JsonObject config, SectionManager section) {
    this.config = config;
    this.section = section;
    this.canvas = section.canvas;
    this.shadowCanvas = section.getShadowCanvas();
    this.stage = section.getStage();
    this.shadowStage = section.getShadowStage();
    this.div = section.getDiv();
    this.skeletons = this.section.getSkeletons();
    this.actor = this.section.getActor();
  }

  void start(var result) {
    addModules();
  }

  void addModules();

  void delegateLockControls(bool value) {
    section.delegateLockControls(value);
  }

  bool isLockedControls() {
    return section.isLockedControls();
  }

  void delegateViewportRender() {
    section.delegateRenderStagesInViewport();
  }

  num getLeftReferenceX() {
    return section.getLeftReferenceX();
  }

  num getRightReferenceX() {
    return section.getRightReferenceX();
  }

  RenderLoop getRenderLoop() {
    return section.getRenderLoop();
  }

  bool delegateRenderInsideWindow(html.Element canvas) {
    return section.delegateRenderInsideWindow(canvas);
  }

}