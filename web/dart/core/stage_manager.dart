import 'dart:async';
import 'dart:core';
import 'dart:html' as html;
import 'dart:math';

import 'package:json_object/json_object.dart';
import 'package:stagexl/stagexl.dart';
import 'package:stagexl_spine/stagexl_spine.dart';

import 'const_settings.dart';
import 'section_manager.dart';
import 'skeleton_creator.dart';

class StageManager {

  JsonObject cfg;
  SkeletonAnimation actor;
  List<SkeletonAnimation> skeletons;
  DisplayObject center;
  RenderLoop renderLoop;
  ResourceManager resourceManager;
  Bitmap leftReference;
  Bitmap rightReference;
  SectionManager sectionManager;
  int index;
  bool debug = false;

  html.Element canvas;
  html.Element div;
  html.Element shadowCanvas;

  Stage stage;
  Stage shadowStage;

  bool redrawNeeded = false;
  bool lockControls = false;
  bool isResizing = false;

  StageManager(SectionManager sectionManager, JsonObject config, RenderLoop renderLoop,
      ResourceManager resourceManager, html.Element canvas, int index) {
    cfg = config;
    this.renderLoop = renderLoop;
    this.resourceManager = resourceManager;
    this.canvas = canvas;
    this.sectionManager = sectionManager;
    this.index = index;
    int width = cfg.width == null ? ConstSettings.WIDTH : cfg.width;
    int height = cfg.height == null ? ConstSettings.HEIGHT : cfg.height;
    StageXL.stageOptions.stageAlign;
    stage = new Stage(canvas, width: width, height: height);
    stage.align = StageAlign.TOP_LEFT;
    shadowCanvas = canvas.nextElementSibling;
    width = cfg.width == null ? ConstSettings.WIDTH : cfg.width;
    height = cfg.height == null ? ConstSettings.HEIGHT : cfg.height;
    shadowStage = new Stage(shadowCanvas, width: width, height: height);
    shadowStage.align = StageAlign.TOP_LEFT;
    this.skeletons = new List<SkeletonAnimation>();
    div = shadowCanvas.nextElementSibling;
  }

  Future load(ResourceManager resourceManager, bool useGlobalAssets) {
    for (int i = 0; i < cfg.images.length; i++) {
      if (!resourceManager.containsBitmapData(cfg.images[i].name)) {
        resourceManager.addBitmapData(cfg.images[i].name,
            cfg.images[i].path);
      }
    }
    if (!resourceManager.containsBitmapData("black")) {
      resourceManager.addBitmapData("black", "img/black.jpg");
    }
    TextureAtlasFormat libgdx = TextureAtlasFormat.LIBGDX;
    for (int i = 0; i < cfg.skeletons.length; i++) {
      if (!resourceManager.containsTextFile(cfg.skeletons[i].source)) {
        resourceManager.addTextFile(cfg.skeletons[i].source,
            "spine/" + cfg.skeletons[i].source + ".json");
      }
      if (!resourceManager.containsTextureAtlas(cfg.skeletons[i].source)) {
        resourceManager.addTextureAtlas(cfg.skeletons[i].source,
            "spine/" + cfg.skeletons[i].source + ".atlas", libgdx);
      }
    }
    if (useGlobalAssets) {
      if (!resourceManager.containsTextureAtlas(ConstSettings.GLOBAL_ASSETS)) {
        resourceManager.addTextureAtlas(
            ConstSettings.GLOBAL_ASSETS,
            "img/" + ConstSettings.GLOBAL_ASSETS + ".atlas", libgdx);
      }
    }

    if (!resourceManager.containsTextureAtlas("lights")) {
      resourceManager.addTextureAtlas("lights", "img/lights.atlas", libgdx);
    }
    /*
    if(!resourceManager.containsTextureAtlas(cfg.id)){
      resourceManager.addTextureAtlas(cfg.id, "img/" + cfg.id + ".atlas", libgdx);
    }
     */
    sectionManager.loadIncrement();
    return resourceManager.load();
  }

  void start(ResourceManager resourceManager) {
    _addLights();
    _addImages();
    _addBitmaps();
    _addSpineElements();
    if(debug){
      _debugPivots();
    }
    sectionManager.loadIncrement();
  }

  void _addLights() {
    shadowStage.backgroundColor = 0;
    Bitmap black = new Bitmap(resourceManager.getBitmapData("black"));
    black.scaleY = 2000;
    black.scaleX = 10000;
    black.x = -2000;
    black.y = 0;
    black.alpha = 0.90;
    black.name = "black_overlay";
    black.blendMode = BlendMode.NORMAL;
    shadowStage.addChild(black);

    for (int i = 0; i < cfg.lights.length; i++) {
      Bitmap light = new Bitmap(
          resourceManager.getTextureAtlas("lights").getBitmapData(
              cfg.lights[i].type));
      light.alignPivot(HorizontalAlign.Center, VerticalAlign.Center);
      light.x = cfg.lights[i].x;
      light.y = -cfg.lights[i].y;
      light.scaleY = cfg.lights[i].scaleX;
      light.scaleX = cfg.lights[i].scaleY;
      light.name = cfg.lights[i].name;
      light.alpha = cfg.lights[i].alpha;
      light.blendMode = BlendMode.ERASE;
      shadowStage.addChild(light);
    }
  }

  void _addSpineElements() {
    if (cfg.keys.contains("skeletons")) {
      for (int i = 0; i < cfg.skeletons.length; i++) {
        JsonObject jsonSkeleton = cfg.skeletons[i];
        SkeletonAnimation skeleton = SkeletonCreator.createSkeleton(
            jsonSkeleton, stage, resourceManager);
        if (jsonSkeleton.isActor == true) {
          actor = skeleton;
        }
        stage.addChild(skeleton);
        stage.juggler.add(skeleton);
        skeletons.add(skeleton);
      }
    }
  }

  void _addImages() {
    for (int i = 0; i < cfg.images.length; i++) {
      Bitmap bitmap = new Bitmap(
          resourceManager.getBitmapData(cfg.images[i].name));
      bitmap.x = cfg.images[i].x;
      bitmap.y = cfg.images[i].y;
      bitmap.scaleX = cfg.bitmaps[i].scaleX;
      bitmap.scaleY = cfg.bitmaps[i].scaleY;
      bitmap.name = cfg.images[i].name;
    }
  }

  void _addBitmaps() {
    num minX = cfg.bitmaps[0].x;
    num maxX = cfg.bitmaps[0].x;
    for (int i = 0; i < cfg.bitmaps.length; i++) {
      Bitmap bmp = new Bitmap(
          resourceManager.getTextureAtlas("all_assets")
              .getBitmapData( //cfg.id
              cfg.bitmaps[i].texture));
      bmp.alignPivot(HorizontalAlign.Center, VerticalAlign.Center);
      bmp.x = cfg.bitmaps[i].x;
      bmp.y = -cfg.bitmaps[i].y;
      bmp.scaleY = cfg.bitmaps[i].scaleY;
      bmp.scaleX = cfg.bitmaps[i].scaleX;
      bmp.name = cfg.bitmaps[i].name;
      stage.addChild(bmp);
      minX = min(bmp.x - bmp.width / 2, minX);
      maxX = max(bmp.x + bmp.width / 2, maxX);
    }
    _createReferences(minX, maxX);
  }

  void _debugPivots() {
    int length = stage.children.length;
    //Stage.defaultOptions.stageRenderMode

    for (int i = 0; i < length; i++) {
      Bitmap bmp2 = new Bitmap(resourceManager.getBitmapData("img"));
      bmp2.x = stage
          .getChildAt(i)
          .x
          .toInt();
      bmp2.y = stage
          .getChildAt(i)
          .y
          .toInt();
      bmp2.scaleY = 10;
      bmp2.scaleX = 10;
      bmp2.name = "bmp" + i.toString();
      bmp2.blendMode = BlendMode.ERASE;
      stage.addChild(bmp2);
    }
  }


  void _createReferences(num leftX, num rightX) {
    leftReference = new Bitmap();
    leftReference.x = leftX;
    leftReference.y = 0;
    leftReference.name = "leftReference";

    rightReference = new Bitmap();
    rightReference.x = rightX;
    rightReference.y = 0;
    rightReference.name = "rightReference";

    stage.addChild(leftReference);
    stage.addChild(rightReference);
  }
}