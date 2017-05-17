import 'dart:core';

import 'package:json_object/json_object.dart';
import 'package:stagexl/stagexl.dart';
import 'package:stagexl_spine/stagexl_spine.dart';

import 'const_settings.dart';

//*******STEP 1: Set this to your line number, 1-9
const int LINE_NUM = 1;


class SkeletonCreator {


  static SkeletonAnimation createSkeleton(JsonObject data, Stage stage,
      ResourceManager resourceManager) {
    String spineJson = resourceManager.getTextFile(data.source);
    TextureAtlas textureAtlas = resourceManager.getTextureAtlas(data.source);
    AttachmentLoader attachmentLoader = new TextureAtlasAttachmentLoader(
        textureAtlas);
    SkeletonLoader skeletonLoader = new SkeletonLoader(attachmentLoader);
    SkeletonData skeletonData = skeletonLoader.readSkeletonData(spineJson);
    // Retrieving data from JSON and replacing empty values to default constants
    Iterable keys = data.keys;
    String name = data.name;
    bool isActor = keys.contains("isActor") ? data.isActor : ConstSettings
        .IS_ACTOR;
    num x = data.x;
    num y = data.y;
    double scaleX = keys.contains("scaleX") ? data.scaleX : ConstSettings.SCALE;
    double scaleY = keys.contains("scaleY") ? data.scaleY : ConstSettings.SCALE;
    String skin = keys.contains("skin") ? data.skin : ConstSettings.SKIN;
    String idle = keys.contains("idle") ? data.idle : ConstSettings.IDLE;
    // creating the skeleton itself
    AnimationStateData animationStateData = new AnimationStateData(
        skeletonData);
    SkeletonAnimation skeletonAnimation =
    new SkeletonAnimation(skeletonData, animationStateData);
    skeletonAnimation.x = x; //x;
    skeletonAnimation.y = -y; //stage.bounds.bottom; //y;
    skeletonAnimation.scaleX = scaleX;
    skeletonAnimation.scaleY = scaleY;
    skeletonAnimation.skeleton.skinName = skin;
    animationStateData.defaultMix = 0.0;
    skeletonAnimation.name = name;
    if (skeletonData.animations.contains(skeletonData.findAnimation(idle))) {
      skeletonAnimation.state.setAnimationByName(0, idle, true);
    }
    return skeletonAnimation;
  }


}


