import 'dart:async';
import 'dart:html' as html;

import 'package:stagexl/stagexl.dart';
import 'package:stagexl_spine/stagexl_spine.dart';

import '../ds_module_manager.dart';

class ModuleActorWalk {

  SkeletonAnimation actor;
  DsModuleManager moduleManager;
  Stage stage;
  Stage shadowStage;
  html.Element canvas;
  html.Element shadowCanvas;


  num walkSpeed;
  num boundingBox;
  num stopFrame;
  num mixAlpha;
  String walkAnimationRight;
  String walkAnimationLeft;
  String walkAnimationEnd1;
  String walkAnimationEnd2;
  bool stopped = true;
  bool isLeft = false;
  bool isRight = false;
  bool hasShadows = true;
  int transferBackground = 0;
  int transferActor = 0;

  ModuleActorWalk(DsModuleManager moduleManager, SkeletonAnimation actor,
      html.Element canvas, html.Element shadowCanvas, Stage stage,
      Stage shadowStage) {
    this.actor = actor;
    this.moduleManager = moduleManager;
    this.canvas = canvas;
    this.shadowCanvas = shadowCanvas;
    this.shadowStage = shadowStage;
    this.stage = stage;
  }

  void init() {
    walkSpeed = 12;
    boundingBox = 128;
    stopFrame = 0;
    mixAlpha = 1;
    walkAnimationRight = "x_walk_r";
    walkAnimationLeft = "x_walk_l";
    walkAnimationEnd1 = "x_walk_start";
    walkAnimationEnd2 = "x_walk_middle";
    actor.state.setAnimationByName(5, "x_idle_aiming", true);
    actor.state.setAnimationByName(1, walkAnimationEnd1, false);
    actor.state.data.setMixByName(
        walkAnimationRight, walkAnimationEnd1, 0.5);
    actor.state.data.setMixByName(
        walkAnimationRight, walkAnimationEnd2, 0.5);
    actor.state.data.setMixByName(
        walkAnimationLeft, walkAnimationEnd1, 0.5);
    actor.state.data.setMixByName(
        walkAnimationLeft, walkAnimationEnd2, 0.5);
  }

  void walkWithActor(e) {
    if (!moduleManager.isLockedControls()) {
      shadowStage.renderMode = StageRenderMode.AUTO;
      TrackEntry track = actor.state.getCurrent(1);
      switch (e.keyCode) {
        case 37:
          if (stopped) {
            stopped = false;
            walkLeft();
          }
          break;
        case 39:
          if (stopped) {
            stopped = false;
            walkRight();
          }
          break;
      }
    } else {
      stopped = true;
    }
  }

  void walkLeft() {
    transferBackground = 0;
    transferActor = 0;
    TrackEntry track = actor.state.getCurrent(1);
    if (moduleManager.getLeftReferenceX() + walkSpeed + boundingBox <
        actor.x) {
      transferBackground = walkSpeed;
      if (track == null) {
        actor.state.setAnimationByName(1, walkAnimationLeft, true);
      } else if (track.animation.name != walkAnimationLeft) {
        actor.state.setAnimationByName(1, walkAnimationLeft, true);
      }
    }
    changePosition();
    if (!stopped) {
      var future = new Future.delayed(
          const Duration(milliseconds: 50), walkLeft);
    }
  }


  void walkRight() {
    transferBackground = 0;
    transferActor = 0;
    TrackEntry track = actor.state.getCurrent(1);
    if (moduleManager.getRightReferenceX() - walkSpeed - boundingBox >
        actor.x) {
      transferBackground = -walkSpeed;
      if (track == null) {
        actor.state.setAnimationByName(1, walkAnimationRight, true);
      } else if (track.animation.name != walkAnimationRight) {
        actor.state.setAnimationByName(1, walkAnimationRight, true);
      }
    }
    changePosition();
    if (!stopped) {
      var future = new Future.delayed(
          const Duration(milliseconds: 50), walkRight);
    }
  }

  void changePosition() {
    if (transferActor == 0 && transferBackground != 0) {
      for (DisplayObject child in stage.children) {
        if (!(identical(child, actor))) {
          Tween tween = new Tween(child, 0.05);
          tween.animate.x.to(child.x + transferBackground);
          moduleManager.getRenderLoop().juggler.add(tween);
        }
      }
      if (hasShadows) {
        for (DisplayObject child in shadowStage.children) {
          if (!(identical(child, actor))) {
            Tween tween = new Tween(child, 0.05);
            tween.animate.x.to(child.x + transferBackground);
            moduleManager.getRenderLoop().juggler.add(tween);
          }
        }
      }
    }
  }


  void stopWalking(e) {
    stopped = true;
    switch (e.keyCode) {
      case 37:
        var future = new Future.delayed(
            const Duration(milliseconds: 50), stopWalkLeft);
        break;
      case 39:
        var future = new Future.delayed(
            const Duration(milliseconds: 50), stopWalkRight);
        break;
    }
  }

  void stopWalkingOnBlur() {
    var future = new Future.delayed(
        const Duration(milliseconds: 50), stopWalkLeft);
  }

  void stopWalkLeft() {
    TrackEntry track = actor.state.getCurrent(1);
    if (track.getAnimationTime() > track.animation.duration / 4 ||
        track.getAnimationTime() > 3 * track.animation.duration / 4) {
      actor.state.setAnimationByName(1, walkAnimationEnd2, false);
    } else {
      actor.state.setAnimationByName(1, walkAnimationEnd1, false);
    }
    shadowStage.renderMode = StageRenderMode.ONCE;
  }

  void stopWalkRight() {
    TrackEntry track = actor.state.getCurrent(1);
    if (track.getAnimationTime() > track.animation.duration / 4 ||
        track.getAnimationTime() > 3 * track.animation.duration / 4) {
      actor.state.setAnimationByName(1, walkAnimationEnd2, false);
    } else {
      actor.state.setAnimationByName(1, walkAnimationEnd1, false);
    }
    shadowStage.renderMode = StageRenderMode.ONCE;
  }

}