import 'dart:async';
import 'dart:html' as html;

import 'package:stagexl_spine/stagexl_spine.dart';

import '../constants/const_values.dart';
import '../ds_module_manager.dart';
import '../ds_ui_manager.dart';

class ModuleDialogue {

  html.Element canvas;
  SkeletonAnimation actor;
  DsModuleManager moduleManager;
  DsUiManager uiManager;
  html.Element current;
  html.Element last;
  String quote;
  int currentLetter;
  Future<int> currentFuture;
  int iteration = 0;
  bool dialogueStarted = false;
  Duration duration;

  ModuleDialogue(DsModuleManager moduleManager, DsUiManager uiManager, html.Element canvas,
      SkeletonAnimation actor) {
    this.canvas = canvas;
    this.actor = actor;
    this.moduleManager = moduleManager;
    this.uiManager = uiManager;
  }

  init() {

  }

  void startDialogueByKey(var event) {
    if (event.keyCode == 69) {
      if (dialogueStarted) {
        skip(event);
      } else {
        dialogueStarted = true;
        startDialogue();
      }
    }
  }

  void startDialogueByTouch(var event) {
    startDialogue();
    dialogueStarted = true;
  }

  void startDialogue() {
    moduleManager.delegateLockControls(true);
    current = html.window.document.getElementById("1_dialogue_2");
    current = current.children[0];
    last = current;
    duration =
    new Duration(
        milliseconds: ConstValues.DURATION_PER_CHAR * last.innerHtml.length +
            ConstValues.DURATION_PLUS);
    cycleDialogue(0);
    uiManager.hideUiSection();
  }

  void cycleDialogue(int iter) {
    if (iter == iteration) {
      if (current != null) {
        iter = iteration;
        if (current.nodeName == "P") {
          last.classes.remove("display-block");
          current.classes.add("display-block");
          last = current;
          current = current.nextElementSibling;
          duration =
          new Duration(milliseconds: 20 * last.innerHtml.length + 500);
          currentFuture =
          new Future.delayed(duration, () => cycleDialogue(iter));
        } else if (current.nodeName == "UL") {
          showOptions();
        } else {
          dialogueEnd();
        }
      } else {
        dialogueEnd();
      }
    }
  }

  void skip(var event) {
    iteration++;
    goTroughDialogue();
  }

  void goTroughDialogue() {
    if (current != null) {
      if (current.nodeName == "P") {
        last.classes.remove("display-block");
        current.classes.add("display-block");
        last = current;
        current = current.nextElementSibling;
        duration =
        new Duration(milliseconds: 20 * last.innerHtml.length + 500);
        currentFuture =
        new Future.delayed(duration, () => cycleDialogue(iteration));
      } else if (current.nodeName == "UL") {
        showOptions();
      } else {

      }
    } else {
      dialogueEnd();
    }
  }

  void showOptions() {
    List<html.Element> children = current.children;
    for (html.Element child in children) {
      child.children[0].classes.add("display-block");
      child.children[0].addEventListener("click", chooseBranch);
    }
  }

  void chooseBranch(html.Event e) {
    last.classes.remove("display-block");
    if (current != null) {
      List<html.Element> children = current.children;
      for (html.Element child in children) {
        child.children[0].classes.remove("display-block");
        child.children[0].removeEventListener("click", chooseBranch);
      }
      last = current;
      current = (e.target as html.Element).nextElementSibling;
      cycleDialogue(iteration);
    }
  }

  void dialogueEnd() {
    iteration = 0;
    dialogueStarted = false;
    last.classes.remove("display-block");
    uiManager.showUiSection();
    moduleManager.delegateLockControls(false);
  }


  void doStuffCallback() {
    current.children[0].innerHtml += quote[currentLetter];
    currentLetter++;
    if (currentLetter < quote.length) {
      var future = new Future.delayed(
          const Duration(milliseconds: 25), doStuffCallback);
    }
  }
}