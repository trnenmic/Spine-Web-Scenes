import 'dart:html' as html;
import 'dart:math';

import 'package:stagexl_spine/stagexl_spine.dart';

import '../constants/const_anim.dart';
import '../ds_module_manager.dart';

class ModuleShootAim {

  SkeletonAnimation actor;
  DsModuleManager moduleManager;
  String currentWeapon = ConstAnim.SHOTGUN;
  bool directionRight = true;


  ModuleShootAim(DsModuleManager moduleManager, SkeletonAnimation actor) {
    this.actor = actor;
    this.moduleManager = moduleManager;
    actor.state.setAnimationByName(2, "45_setup_pose_shotgun", true);
    actor.state.data.setMixByName(
        "x_shoot_l_shotgun", "x_shoot_l_shotgun", 0.1);
    actor.state.data.setMixByName(
        "x_shoot_r_shotgun", "x_shoot_l_shotgun", 0.1);
    actor.state.data.setMixByName(
        "x_shoot_l_shotgun", "x_shoot_r_shotgun", 0.1);
    actor.state.data.setMixByName(
        "x_shoot_r_shotgun", "x_shoot_r_shotgun", 0.1);
    actor.state.data.setMixByName(
        "x_shoot_l_pistol", "x_shoot_l_pistol", 0.1);
    actor.state.data.setMixByName(
        "x_shoot_l_pistol", "x_shoot_r_pistol", 0.1);
    actor.state.data.setMixByName(
        "x_shoot_r_pistol", "x_shoot_l_pistol", 0.1);
    actor.state.data.setMixByName(
        "x_shoot_r_pistol", "x_shoot_r_pistol", 0.1);
    actor.state.data.setMixByName(
        "x_shoot_l_rifle", "x_shoot_l_rifle", 0.1);
    actor.state.data.setMixByName(
        "x_shoot_l_rifle", "x_shoot_r_rifle", 0.1);
    actor.state.data.setMixByName(
        "x_shoot_r_rifle", "x_shoot_l_rifle", 0.1);
    actor.state.data.setMixByName(
        "x_shoot_r_rifle", "x_shoot_r_rifle", 0.1);
    actor.state.data.setMixByName("x_aim_shotgun", "x_aim_shotgun", 0.0);
    actor.state.data.setMixByName("x_aim_rifle", "x_aim_shotgun", 0.0);
    actor.state.data.setMixByName("x_aim_shotgun", "x_aim_rifle", 0.0);
    actor.state.data.setMixByName("x_aim_rifle", "x_aim_rifle", 0.0);
    actor.state.data.setMixByName("x_aim_pistol", "x_aim_pistol", 0.0);
  }

  void aim(html.MouseEvent me) {
    if (!moduleManager.isLockedControls()) {
      TrackEntry lastTrack = actor.state.getCurrent(2);
      if (lastTrack.getAnimationTime() == lastTrack.animationEnd) {
        double angle = computeAngle(
            actor.x, actor.y - (actor.skeleton.data
            .findBone("45_aim_rotator")
            .y * actor.scaleY), me.offset.x, me.offset.y);
        angle = (angle + 90) % 360;
        if (angle > 180) {
          directionRight = true;
        } else {
          directionRight = false;
        }
        if (currentWeapon == ConstAnim.SHOTGUN) {
          actor.state.setAnimationByName(2, "x_aim_shotgun", false);
        } else if (currentWeapon == ConstAnim.RIFLE) {
          actor.state.setAnimationByName(2, "x_aim_rifle", false);
        } else if (currentWeapon == ConstAnim.PISTOL) {
          actor.state.setAnimationByName(2, "x_aim_pistol", false);
        }
        TrackEntry tr = actor.state.getCurrent(2);
        double lastTime = (tr.animation.duration -
            (tr.animation.duration / 360) * (angle));
        tr.animationStart = lastTime;
        tr.animationEnd = lastTime;
      }
    }
  }

  void shoot(html.MouseEvent me) {
    if (!moduleManager.isLockedControls()) {
      TrackEntry lastTrack = actor.state.getCurrent(2);
      if (lastTrack.getAnimationTime() == lastTrack.animationEnd) {
        if (currentWeapon == ConstAnim.RIFLE) {
          if (directionRight) {
            actor.state.setAnimationByName(5, "x_shoot_r_rifle", false);
          } else {
            actor.state.setAnimationByName(5, "x_shoot_l_rifle", false);
          }
        } else if (currentWeapon == ConstAnim.SHOTGUN) {
          if (directionRight) {
            actor.state.setAnimationByName(5, "x_shoot_r_shotgun", false);
          } else {
            actor.state.setAnimationByName(5, "x_shoot_l_shotgun", false);
          }
        } else if (currentWeapon == ConstAnim.PISTOL) {
          if (directionRight) {
            actor.state.setAnimationByName(5, "x_shoot_r_pistol", false);
          } else {
            actor.state.setAnimationByName(5, "x_shoot_l_pistol", false);
          }
        }
        if (actor.state.getCurrent(5) != null) {
          actor.state
              .getCurrent(5)
              .onTrackComplete
              .listen((e) {
            actor.state.setAnimationByName(5, "x_idle_aiming", true);
          });
        }
      }
    }
  }


  double computeAngle(p1x, p1y, p2x, p2y) {
    return atan2(p2y - p1y, p2x - p1x) * 180 / PI + 180;
  }

  void changeWeapon(String type) {
    if (type == ConstAnim.RIFLE) {
      if (currentWeapon == ConstAnim.SHOTGUN) {
        if (directionRight) {
          actor.state.setAnimationByName(2, "45_swap_shotgun_to_rifle", false);
        } else {
          actor.state.setAnimationByName(2, "300_swap_shotgun_to_rifle", false);
        }
      } else if (currentWeapon == ConstAnim.PISTOL) {
        if (directionRight) {
          actor.state.setAnimationByName(2, "45_swap_pistol_to_rifle", false);
        } else {
          actor.state.setAnimationByName(2, "300_swap_pistol_to_rifle", false);
        }
      }
    } else if (type == ConstAnim.SHOTGUN) {
      if (currentWeapon == ConstAnim.RIFLE) {
        if (directionRight) {
          actor.state.setAnimationByName(2, "45_swap_rifle_to_shotgun", false);
        } else {
          actor.state.setAnimationByName(2, "300_swap_rifle_to_shotgun", false);
        }
      } else if (currentWeapon == ConstAnim.PISTOL) {
        if (directionRight) {
          actor.state.setAnimationByName(2, "45_swap_pistol_to_shotgun", false);
        } else {
          actor.state.setAnimationByName(
              2, "300_swap_pistol_to_shotgun", false);
        }
      }
    } else if (type == ConstAnim.PISTOL) {
      if (currentWeapon == ConstAnim.RIFLE) {
        if (directionRight) {
          actor.state.setAnimationByName(2, "45_swap_rifle_to_pistol", false);
        } else {
          actor.state.setAnimationByName(2, "300_swap_rifle_to_pistol", false);
        }
      } else if (currentWeapon == ConstAnim.SHOTGUN) {
        if (directionRight) {
          actor.state.setAnimationByName(2, "45_swap_shotgun_to_pistol", false);
        } else {
          actor.state.setAnimationByName(
              2, "300_swap_shotgun_to_pistol", false);
        }
      }
    }
    currentWeapon = type;
  }

}