import 'dart:core';


class ConstSettings {

  static final num DURATION_PER_CHAR = 50;
  static final num DURATION_PLUS = 500;

  num walkSpeed = 20;
  num boundingBox = 384;

  /*Stage*/
  static final String ID = "stage";
  static final int WIDTH = 640;
  static final int HEIGHT = 640;

  /*BITMAP, SPINE*/
  static final int X = 0;
  static final int Y = 0;

/*TEXTURES, ATLASES*/
  static final String PNG = "PNG";
  static final String IMG_PATH = "img/";
  static final String SPINE_PATH = "spine/";
  static final String CONFIG_PATH = "json/";
  static final String CONFIG_FILE = "cfg.json";
  static final String GLOBAL_ASSETS = "all_assets";

  /*Stage*/
  static final String IDLE = "idle";
  static final double SCALE = 1.0;
  static final String SKIN = "default";
  static final bool IS_ACTOR = false;

/*JSON CONFIG FILE KEYS */

}