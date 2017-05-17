import 'dart:html' as html;

import 'package:json_object/json_object.dart';

import '../core/abs_module_manager.dart';
import '../core/section_manager.dart';
import 'constants/const_anim.dart';
import 'constants/const_css.dart';
import 'constants/const_keys.dart';
import 'constants/const_values.dart';
import 'ds_ui_manager.dart';
import 'modules/module_actor_walk.dart';
import 'modules/module_character.dart';
import 'modules/module_dialogue.dart';
import 'modules/module_fight.dart';
import 'modules/module_mouse_focus.dart';
import 'modules/module_shoot_aim.dart';

class DsModuleManager extends ModuleManager {
  //stands for Digital Shard Module Manager
  int i;

  DsUiManager uiManager;

  ModuleCharacter moduleCharacter;
  ModuleFight moduleFight;
  ModuleShootAim moduleShootAim;
  ModuleMouseFocus moduleMouseFocus;
  ModuleActorWalk moduleActorWalk;
  ModuleDialogue moduleDialogue;

  DsModuleManager(JsonObject config, SectionManager section)
      : super(config, section) {
    uiManager = new DsUiManager(section.index);
    uiManager.init();
  }

  @override
  void addModules() {
    bool isWalking = config.containsKey(ConstKeys.MODULE_WALK) ?
    config.moduleWalk : ConstValues.MODULE_WALK;
    if (isWalking) {
      _addModuleActorWalk();
    }
    bool isDialogue = config.containsKey(ConstKeys.MODULE_DIALOGUE) ?
    config.moduleDialogue : ConstValues.MODULE_DIALOGUE;
    if (isDialogue) {
      _addModuleDialogue();
    }
    bool isQuote = config.containsKey(ConstKeys.MODULE_QUOTE) ?
    config.moduleQuote : ConstValues.MODULE_QUOTE;
    if (isQuote) {

    }
    bool isAim = config.containsKey(ConstKeys.MODULE_SHOOT_AIM) ?
    config.moduleShootAim : ConstValues.MODULE_SHOOT_AIM;
    if (isAim) {
      _addModuleShootAim();
    }
    bool isFight = config.containsKey(ConstKeys.MODULE_FIGHT) ?
    config.moduleFight : ConstValues.MODULE_FIGHT;
    if (isFight) {
      _addModuleFight();
    }
    bool isFocus = config.containsKey(ConstKeys.MODULE_MOUSE_FOCUS) ?
    config.moduleMouseFocus : ConstValues.MODULE_MOUSE_FOCUS;
    if (isFocus) {
      _addModuleMouseFocus();
    }
    String character = config.containsKey(ConstKeys.MODULE_CHARACTER) ?
    config.moduleCharacter : ConstValues.MODULE_CHARACTER;
    if (character != "none" && character != "") {
      _addModuleCharacter(character);
    }
    section.resizeSection();
    section.completeStage();
  }


  void _addModuleCharacter(String character) {
    if (character != "garry") {
      moduleCharacter = new ModuleCharacter(this, uiManager, actor, canvas);
      moduleCharacter.init(character);
      for (int i = 0; i < uiManager.characterEmotionButtons.length; i++) {
        html.Element e = uiManager.characterEmotionButtons[i];
        e.onClick.listen((e) {
          moduleCharacter.playEmotion(i);
        });
      }
      uiManager.widget.onClick.listen((e) {
        if (!uiManager.widget.classes.contains("loop")) {
          moduleCharacter.start();
        }
      });

      shadowStage.onMouseClick.listen((e) {
        moduleCharacter.stageClick();
      });
      html.window.onScroll.listen((e) {
        moduleCharacter.stageScroll();
      });

      shadowCanvas.onMouseMove.listen((e) {
        moduleCharacter.look(e);
      });
      moduleCharacter.start();
    }
  }

  void _addModuleShootAim() {
    moduleShootAim = new ModuleShootAim(this, actor);
    canvas.onMouseMove.listen((me) {
      moduleShootAim.aim(me);
    });
    shadowCanvas.onMouseMove.listen((me) {
      moduleShootAim.aim(me);
    });
    canvas.onClick.listen((me) {
      moduleShootAim.shoot(me);
    });
    shadowStage.onMouseClick.listen((me) {
      moduleShootAim.shoot(null);
    });
    for (html.Element weaponButton in uiManager.weaponButtons) {
      weaponButton.onClick.listen((e) {
        if (weaponButton.classes.contains(ConstCss.SHOTGUN)) {
          moduleShootAim.changeWeapon(ConstAnim.SHOTGUN);
        } else if (weaponButton.classes.contains(ConstCss.PISTOL)) {
          moduleShootAim.changeWeapon(ConstAnim.PISTOL);
        } else if (weaponButton.classes.contains(ConstCss.RIFLE)) {
          moduleShootAim.changeWeapon(ConstAnim.RIFLE);
        }
      });
    }
  }

  void _addModuleMouseFocus() {
    moduleMouseFocus = new ModuleMouseFocus(canvas, shadowCanvas, div);
    moduleMouseFocus.init();
  }

  void _addModuleActorWalk() {
    moduleActorWalk =
    new ModuleActorWalk(this, actor, canvas, shadowCanvas, stage, shadowStage);
    moduleActorWalk.init();
    canvas.onKeyDown.listen((e) {
      moduleActorWalk.walkWithActor(e);
    });
    canvas.onKeyUp.listen((e) {
      moduleActorWalk.stopWalking(e);
    });
    canvas.onBlur.listen((e) {
      //TO DO STOP ANIMATION
      moduleActorWalk.stopWalkingOnBlur();
    });
  }

  void _addModuleDialogue() {
    moduleDialogue = new ModuleDialogue(this, uiManager, canvas, actor);
    moduleDialogue.init();
    canvas.onKeyDown.listen((e) {
      moduleDialogue.startDialogueByKey(e);
    });
    if (uiManager.buttonInteract != null) {
      uiManager.buttonInteract.onClick.listen((e) {
        moduleDialogue.startDialogueByTouch(e);
      });
      uiManager.buttonInteract.onTouchStart.listen((e) {
        moduleDialogue.startDialogueByTouch(e);
      });
    }
  }

  void _addModuleFight() {
    ModuleFight moduleFight = new ModuleFight(
        actor, canvas, shadowCanvas, skeletons, uiManager, this);
    moduleFight.init();
    if (uiManager.buttonFightStart != null) {
      uiManager.buttonFightStart.onClick.listen((e) {
        if (!uiManager.buttonFightStart.classes.contains("disabled")) {
          moduleFight.startFight();
        }
      });
    }
  }


}