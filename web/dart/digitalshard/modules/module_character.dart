import 'dart:async';
import 'dart:html' as html;
import 'dart:math';

import 'package:stagexl_spine/stagexl_spine.dart';

import '../constants/const_values.dart';
import '../ds_module_manager.dart';
import '../ds_ui_manager.dart';
import 'character_generator.dart';

class ModuleCharacter {

  SkeletonAnimation actor;
  DsUiManager uiManager;
  DsModuleManager moduleManager;
  html.Element canvas;

  String intro;
  String mouse;
  String idle;
  String click;
  String clickAlt;
  String scroll;
  List<String> emotions;
  int interactivePauseIndex;
  bool isInteractive;
  String characterName;


  bool scrolled = false;


  int emotionCounter = 0;
  int clickCounter = 0;

  html.Element currentQuote;

  ModuleCharacter(DsModuleManager moduleManager, DsUiManager uiManager, SkeletonAnimation actor, html.Element canvas) {
    this.moduleManager = moduleManager;
    this.uiManager = uiManager;
    this.actor = actor;
    this.canvas = canvas;
    this.emotions = new List<String>();
  }

  void init(String characterName) {
    isInteractive = true;
    this.characterName = characterName;
    switch (characterName) {
      case "hero":
        CharacterGenerator.prepareHero(this);
        CharacterGenerator.setTransitions(this, 0.2);
        break;
      case "ai":
        CharacterGenerator.prepareAi(this);
        CharacterGenerator.setTransitions(this, 0.2);

        break;
      case "garry":
        break;
      case "todd":
        CharacterGenerator.prepareTodd(this);
        CharacterGenerator.setTransitions(this, 0.5);
        break;
      default:
    };
  }

  void start() {
    endQuote();
    if (isInteractive) {
      if (html.window.sessionStorage.containsKey("flag-" + characterName)) {
        generateQuote("q-stored");
      } else {
        generateQuote("q-intro");
      }
      applyAnimation(1, intro, false, true);
    } else {
      html.Element q = generateQuote("q-intro-locked");
      endQuoteFuture(q);
    }
  }

  void playEmotion(int index) {
    emotionCounter++;
    endQuote();
    if (isInteractive) {
      html.Element qElement = generateQuote("q-" + (index + 1).toString());
      if (index == interactivePauseIndex) {
        isInteractive = false;
        html.window.sessionStorage.putIfAbsent(
            "flag-" + characterName, () => "true");
        applyAnimation(1, emotions[index], false, false);
        for (html.Element button in uiManager.characterEmotionButtons) {
          button.classes.add("locked");
        }
      } else {
        TrackEntry tr = actor.state.getCurrent(1);
        if (tr != null && tr.animation.name != emotions[index]) {
          applyAnimation(1, emotions[index], false, true);
        }
      }
    } else {
      endQuote();
      html.Element q = generateQuote("q-lock-" + (index + 1).toString());
      endQuoteFuture(q);
    }
  }

  void endQuoteFuture(html.Element q) {
    if (q != null) {
      int quoteLength = ConstValues.DURATION_PER_CHAR * q.innerHtml.length +
          ConstValues.DURATION_PLUS;
      String qInner = q.innerHtml;
      Future future = new Future.delayed(
          new Duration(milliseconds: quoteLength), () {
        if (currentQuote != null) {
          if (currentQuote.innerHtml == qInner) {
            endQuote();
          }
        }
      });
    }
  }

  void stageClick() {
    clickCounter++;
    if (isInteractive && currentQuote == null) {
      endQuote();
      if (clickCounter % 2 == 1) {
        TrackEntry tr = actor.state.getCurrent(1);
        if (tr != null && tr.animation.name != click) {
          applyAnimation(1, click, false, true);
        }
      } else {
        TrackEntry tr = actor.state.getCurrent(1);
        if (tr != null && tr.animation.name != clickAlt) {
          if (noQuoteOfType("q-click") && clickCounter > 100) {
            generateQuote("q-last-click");
          } else {
            generateQuote("q-click");
          }
          applyAnimation(1, clickAlt, false, true);
        }
      }
    }
  }

  void stageScroll() {
    if (moduleManager.delegateRenderInsideWindow(canvas)) {
      if (!scrolled) {
        if (isInteractive && currentQuote == null) {
          scrolled = true;
          TrackEntry tr = actor.state.getCurrent(1);
          if (tr != null && tr.animation.name == idle) {
            generateQuote("q-scroll");
            applyAnimation(1, scroll, false, true);
          }
          Future future = new Future.delayed(new Duration(seconds: 10), () {
            scrolled = false;
          });
        }
      }
    }
  }


  void look(html.MouseEvent me) {
    if (!moduleManager.isLockedControls()) {
      if (mouse != null) {
        double angle = computeAngle(
            actor.x, actor.y - (actor.skeleton.data
            .findBone("center")
            .y * actor.scaleY), me.offset.x, me.offset.y);
        angle = (angle + 90) % 360;

        actor.state.setAnimationByName(2, mouse, false);

        TrackEntry tr = actor.state.getCurrent(2);
        double lastTime = (tr.animation.duration -
            (tr.animation.duration / 360) * (angle));
        tr.animationStart = lastTime;
        tr.animationEnd = lastTime;
      }
    }
  }

  double computeAngle(p1x, p1y, p2x, p2y) {
    return atan2(p2y - p1y, p2x - p1x) * 180 / PI + 180;
  }

  void applyAnimation(int index, String animName, bool loop, bool backToIdle) {
    if (idle != null && idle != "" && animName != null && animName != "") {
      actor.state.setAnimationByName(index, animName, loop);
      TrackEntry tr2 = actor.state.getCurrent(index);
      html.Element quote = currentQuote;
      tr2.onTrackComplete.listen((e2) {
        if (quote != null && currentQuote != null) {
          if (quote.innerHtml == currentQuote.innerHtml) {
            endQuote();
          }
        }
      });
      if (backToIdle) {
        TrackEntry tr = actor.state.getCurrent(index);
        tr.onTrackComplete.listen((e) {
          actor.state.setAnimationByName(1, idle, true);
        });
      }
    }
  }


  html.Element generateQuote(String className) {
    if (uiManager.quotes != null) {
      for (html.Element e in uiManager.quotes.children) {
        if (e.classes.contains(className) && e.nodeName == "P") {
          currentQuote = e;
          currentQuote.classes.add("display-block");
          return e;
        } else if (e.classes.contains(className + "-repeat")) {
          currentQuote = e;
          currentQuote.classes.add("display-block");
          return e;
        }
      }
    }
  }

  bool noQuoteOfType(String className) {
    bool lastQuote = true;
    if (uiManager.quotes != null) {
      for (html.Element e in uiManager.quotes.children) {
        if (e.classes.contains(className) && e.nodeName == "P") {
          lastQuote = false;
          break;
        }
      }
    }
    return lastQuote;
  }

  void endQuote() {
    if (currentQuote != null &&
        currentQuote.classes.any((s) => s.endsWith("-repeat"))) {
      currentQuote.classes.remove("display-block");
      currentQuote = null;
    } else if (currentQuote != null) {
      currentQuote.classes.remove("display-block");
      currentQuote.remove();
      currentQuote = null;
    }
  }


  void prepareGarry() {
    intro = "";
  }

  void prepareTodd() {
    intro = "";
  }
}