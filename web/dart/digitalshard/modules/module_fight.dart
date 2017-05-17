import 'dart:async';
import 'dart:html' as html;

import 'package:stagexl_spine/stagexl_spine.dart';

import '../ds_module_manager.dart';
import '../ds_ui_manager.dart';

class ModuleFight {

  bool deadLastTime = false;
  bool reset = false;
  int maxProgress = 0;
  int storyBranch = 0;

  List<String> intros;
  List<String> creature1Loops;
  List<String> creature2Loops;
  List<String> playerLoops;
  List<String> playerPunches;
  List<String> creature1Punches;

  DsUiManager uiManager;
  html.Element canvas;
  html.Element shadowCanvas;

  List<SkeletonAnimation> skeletons;
  SkeletonAnimation actor;
  SkeletonAnimation creature1;
  SkeletonAnimation creature2;

  DsModuleManager moduleManager;

  ModuleFight(SkeletonAnimation actor, html.Element canvas,
      html.Element shadowCanvas, List<SkeletonAnimation> skeletons,
      DsUiManager uiManager, DsModuleManager moduleManager) {
    intros = new List<String>();
    creature1Loops = new List<String>();
    creature2Loops = new List<String>();
    playerLoops = new List<String>();
    playerPunches = new List<String>();
    creature1Punches = new List<String>();
    this.uiManager = uiManager;
    this.canvas = canvas;
    this.shadowCanvas = shadowCanvas;
    this.actor = actor;
    this.skeletons = skeletons;
    this.moduleManager = moduleManager;
  }

  void init() {
    intros.add("story_r_walk");
    intros.add("");
    intros.add("");
    playerLoops.add("story_r_back_attack");
    playerLoops.add("story_l_front_attack_2");
    playerLoops.add("story_r_front_attack_3");
    creature1Loops.add("story_r_back_attack");
    creature1Loops.add("story_l_front_attack_2");
    creature1Loops.add("story_c2_l_back_attack_3");
    creature2Loops.add("");
    creature2Loops.add("");
    creature2Loops.add("strory_c1_r_front_attack_3");
    playerPunches.add("story_r_back_punch");
    playerPunches.add("story_l_front_punch_2");
    playerPunches.add("story_r_back_punch_3");
    creature1Punches.add("story_r_back_punch");
    creature1Punches.add("story_l_front_punch_2");
    creature1Punches.add("story_l_front_punch_3");
    for (SkeletonAnimation sa in skeletons) {
      if (sa.name.contains("crawler") || sa.name.contains("CRAWLER") ||
          sa.name.contains("Crawler")) {
        if (creature1 == null) {
          creature1 = sa;
          creature1.alpha = 0;
          addMeleeListener();
        } else if (creature2 == null) {
          creature2 = sa;
          creature2.alpha = 0;
        }
      }
    }
  }


  void continueFightAfterIntro() {
    if (creature1 != null) {
      creature1.alpha = 1;
      creature1.state.setAnimationByName(
          0, creature1Loops[storyBranch], false);
    }
    TrackEntry trackEnd = actor.state.getCurrent(0);
    trackEnd.onTrackComplete.listen((e) {
      showFightArticle(false);
      creature1.alpha = 0;
      dramaticCut();
      turnInvisible();
    });
    trackEnd.onTrackEvent.listen
      ((e) {
      if (e.event.stringValue == "player_killed") {
        uiManager.buttonMelee.classes.add("hide");
      }
    });
  }


  void startFight() {
    turnVisible();
    dramaticCutEnd();
    if (intros[storyBranch] != "") {
      actor.state.setAnimationByName(0, intros[storyBranch], false);
      TrackEntry tr = actor.state.getCurrent(0);
      tr.onTrackComplete.listen((e) {
        dramaticCut();
        Future future = new Future.delayed(
            const Duration(milliseconds: 1200), () {
          dramaticCutEnd();
          uiManager.buttonMelee.classes.remove("hide");
          actor.state.setAnimationByName(0, playerLoops[storyBranch], false);
          continueFightAfterIntro();
        });
      });
    } else {
      if (creature2Loops[storyBranch] == "") {
        creature2.alpha = 0;
      } else {
        creature2.alpha = 1;
        creature2.state.setAnimationByName(
            0, creature2Loops[storyBranch], false);
      }
      actor.state.setAnimationByName(0, playerLoops[storyBranch], false);
      TrackEntry playerTrack = actor.state.getCurrent(0);
      playerTrack.onTrackEvent.listen((e) {
        html.window.console.log(e.event.stringValue);
        if (e.event.stringValue == "punch_enabled") {
          uiManager.buttonMelee.classes.remove("hide");
        }
      });
      continueFightAfterIntro();
    }
  }


  void turnVisible() {
    canvas.parent.classes.remove("invisible");
    moduleManager.delegateViewportRender();
  }

  void turnInvisible() {
    canvas.parent.classes.add("invisible");
    moduleManager.delegateViewportRender();
  }

  void dramaticCut() {
    shadowCanvas.style.backgroundColor = "black";
    shadowCanvas.style.opacity = "1";
  }

  void dramaticCutEnd() {
    shadowCanvas.attributes.remove("style");
  }

  void addMeleeListener() {
    uiManager.buttonMelee.onClick.listen((e) {
      uiManager.buttonMelee.classes.add("hide");
      actor.state.data.setMixByName(
          playerLoops[storyBranch], playerPunches[storyBranch], 0.1);
      actor.state.setAnimationByName(0, playerPunches[storyBranch], false);
      creature1.state.data.setMixByName(
          creature1Loops[storyBranch], creature1Punches[storyBranch], 0.1);
      creature1.state.setAnimationByName(
          0, creature1Punches[storyBranch], false);
      TrackEntry tr = actor.state.getCurrent(0);
      tr.onTrackComplete.listen((e) {
        showFightArticle(true);
        dramaticCut();
        creature1.alpha = 0;
        turnInvisible();
      });
    });
  }

  void addResetDivs() {
    uiManager.buttonFightStart.onClick.listen((e) {
      if (reset) {
        for (html.Element e in uiManager.divFights) {
          e.classes.remove("success");
          e.classes.remove("failure");
        }
        reset = false;
      }
    });
  }

  void showFightArticle(bool isWon) {
    if (isWon) {
      uiManager.divFights[storyBranch].classes.remove("fail");
      uiManager.divFights[storyBranch].classes.add("success");
      incrementBranch();
      if (storyBranch < intros.length - 1) {
        uiManager.pFightCongrats.classes.add("display-none");
        uiManager.pFightFailure.classes.add("display-none");
        uiManager.pFightInfo.classes.remove("display-none");
        uiManager.pFightLock.classes.add("display-none");
        uiManager.inputText.classes.add("display-none");
        uiManager.buttonFightStart.innerHtml = "FIGHT";
      } else if (storyBranch == intros.length - 1) {
        uiManager.pFightCongrats.classes.add("display-none");
        uiManager.pFightFailure.classes.add("display-none");
        uiManager.pFightInfo.classes.add("display-none");
        uiManager.pFightLock.classes.remove("display-none");
        if (uiManager.inputText.value != "T2D2-D3PO") {
          uiManager.buttonFightStart.classes.add("disabled");
        }
        uiManager.inputText.classes.remove("display-none");
        uiManager.buttonFightStart.innerHtml = "FIGHT";
      } else if (storyBranch == intros.length) {
        uiManager.pFightCongrats.classes.remove("display-none");
        uiManager.pFightFailure.classes.add("display-none");
        uiManager.pFightInfo.classes.add("display-none");
        uiManager.pFightLock.classes.add("display-none");
        uiManager.inputText.classes.add("display-none");
        uiManager.buttonFightStart.innerHtml = "RETRY ALL";
        reset = true;
        resetBranch();
      }
    } else {
      uiManager.divFights[storyBranch].classes.add("fail");
      uiManager.pFightCongrats.classes.add("display-none");
      uiManager.pFightFailure.classes.remove("display-none");
      uiManager.pFightInfo.classes.add("display-none");
      uiManager.pFightLock.classes.add("display-none");
      uiManager.inputText.classes.add("hide");
      uiManager.buttonFightStart.innerHtml = "RETRY THIS";
    }
    uiManager.fightArticle.classes.add("current");
  }

  void incrementBranch() {
    storyBranch++;
  }

  void resetBranch() {
    storyBranch = 0;
  }
}