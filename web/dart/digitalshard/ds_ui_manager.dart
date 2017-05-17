import 'dart:html' as html;

import 'constants/const_css.dart';
class DsUiManager {

  int index;

  bool isEnabledScroll = true;
  bool scrollListenersAdded = false;
  int lastX = 0;
  int lastY = 0;
  int currentWeaponIndex = 2;

  html.Element uiSection;
  html.Element widget;
  html.Element backgroundFilter;
  html.Element body;

  html.Element weapons;
  html.Element weaponsDescription;
  List<html.Element> weaponButtons;
  List<html.Element> weaponMoreButtons;
  List<html.Element> weaponDescriptionArticles;
  html.Element tabController;
  html.Element tabNext;
  html.Element tabPrevious;

  html.Element characters;
  html.Element characterControls;
  html.Element characterBox;
  html.Element characterButton;
  List<html.Element> characterEmotionButtons;

  html.Element quotes;

  html.Element playerControls;
  html.Element buttonShoot;
  html.Element buttonLeft;
  html.Element buttonRight;
  html.Element buttonInteract;

  html.Element fightSection;
  html.Element fightArticle;
  html.Element buttonMelee;
  html.Element buttonFightStart;
  html.InputElement inputText;
  html.Element pFightInfo;
  html.Element pFightFailure;
  html.Element pFightLock;
  html.Element pFightCongrats;
  List<html.Element> divFights;

  DsUiManager(int index) {
    this.index = index;
    this.uiSection = null;
    this.widget = null;
    this.buttonInteract = null;

    weaponButtons = new List<html.Element>();
    weaponMoreButtons = new List<html.Element>();
    weaponDescriptionArticles = new List<html.Element>();

    characterEmotionButtons = new List<html.Element>();

    divFights = new List<html.Element>();
  }

  void init() {
    this.body = html.querySelector("body");
    this.widget = html.querySelectorAll(".widget")[index];
    this.backgroundFilter = html.querySelector(".background-filter");
    if (widget != null) {
      for (html.Element item in widget.children) {
        if (item.classes.contains("ui")) {
          uiSection = item;
          _findSubSections();
          break;
        }
      }
    }
  }

  void _findSubSections() {
    for (html.Element e in uiSection.children) {
      if (e.classes.contains(ConstCss.PLAYER_CONTROLS)) {
        playerControls = e;
        _findPlayerControlsElements();
      } else if (e.classes.contains(ConstCss.WEAPONS)) {
        weapons = e;
        _findWeaponButtons();
      } else if (e.classes.contains(ConstCss.WEAPON_DESCRIPTIONS)) {
        weaponsDescription = e;
        _findWeaponDescriptions();
      } else if (e.classes.contains(ConstCss.FIGHT_SECTION)) {
        fightSection = e;
        _findFightInterface();
      } else if (e.classes.contains(ConstCss.CHARACTERS)) {
        characters = e;
        _findCharacterButtons();
      } else if (e.classes.contains(ConstCss.QUOTES)) {
        quotes = e;
      } else if (e.classes.contains("tab-controller")) {
        tabController = e;
        _findTabControllers();
      }
    }
  }

  void _findTabControllers() {
    for (html.Element e in tabController.children) {
      if (e.classes.contains("tab-previous")) {
        tabPrevious = e;
        tabPrevious.onClick.listen((e) {
          _decrementCurrentWeapon();
          weaponButtons[currentWeaponIndex].click();
        });
      } else if (e.classes.contains("tab-next")) {
        tabNext = e;
        tabNext.onClick.listen((e) {
          _incrementCurrentWeapon();
          weaponButtons[currentWeaponIndex].click();
        });
      }
    }
  }

  void _decrementCurrentWeapon() {
    currentWeaponIndex--;
    if (currentWeaponIndex < 0) {
      currentWeaponIndex = 2;
    }
  }

  void _incrementCurrentWeapon() {
    currentWeaponIndex++;
    if (currentWeaponIndex > 2) {
      currentWeaponIndex = 0;
    }
  }

  void _findCharacterButtons() {
    for (html.Element e in characters.children) {
      if (e.classes.contains(ConstCss.CHARACTER_CONTROLS)) {
        characterControls = e;
        for (html.Element emotion in characterControls.children) {
          if (emotion.classes.contains(ConstCss.EMOTION)) {
            characterEmotionButtons.add(emotion);
          }
        }
      }
    }
  }

  void _findPlayerControlsElements() {
    for (html.Element e in playerControls.children) {
      if (e.classes.contains(ConstCss.MELEE)) {
        buttonMelee = e;
      } else if (e.classes.contains(ConstCss.INTERACT)) {
        buttonInteract = e;
      } else if (e.classes.contains(ConstCss.LEFT)) {
        buttonLeft = e;
      } else if (e.classes.contains(ConstCss.RIGHT)) {
        buttonRight = e;
      } else if (e.classes.contains(ConstCss.SHOOT)) {
        buttonShoot = e;
      }
    }
  }

  void _findWeaponButtons() {
    for (html.Element div in weapons.children) {
      if (div.classes.contains(ConstCss.TAB_CELL)) {
        for (html.Element button in div.children) {
          if (button.classes.contains(ConstCss.WEAPON)) {
            weaponButtons.add(button);
//Listener for current weaponButton design
            weaponButtons.last.onClick.listen((e) {
              for (html.Element wb in weaponButtons) {
                if (wb == button) {
                  wb.classes.add("current");
                } else {
                  wb.classes.remove("current");
                }
              }
            });
          } else if (button.classes.contains(ConstCss.MORE)) {
            weaponMoreButtons.add(button);
            int current = weaponButtons.length - 1;
//Listener for showing weapon article window
            weaponMoreButtons.last.onClick.listen((e) {
              if (weaponDescriptionArticles[current] != null) {
                _addScrollListeners();
                isEnabledScroll = false; //
                lastX = html.window.scrollX;
                lastY = html.window.scrollY;
                weaponDescriptionArticles[current].focus();
                weaponDescriptionArticles[current].classes.add(
                    ConstCss.CURRENT);
                backgroundFilter.classes.remove("hide");
                _hideEach(weaponButtons);
                _hideEach(weaponMoreButtons);
              }
            });
          }
        }
      }
    }
  }

  void _findWeaponDescriptions() {
    for (html.Element article in weaponsDescription.children) {
      if (article.classes.contains("description")) {
        weaponDescriptionArticles.add(article);
        _enableClose(weaponDescriptionArticles.last);
      }
    }
  }

  void _enableClose(html.Element description) {
    for (html.Element e in description.children) {
      if (e.nodeName == "BUTTON") {
        e.onClick.listen((e) {
          body.classes.remove("modal-open");
          isEnabledScroll = true;
          backgroundFilter.classes.add("hide");
          description.classes.remove("current");
          _showEach(weaponButtons);
          _showEach(weaponMoreButtons);
        });
      }
    }
  }

  void _addScrollListeners() {
    if (!scrollListenersAdded) {
      scrollListenersAdded = true;
      html.window.onMouseWheel.listen((e) {
        if (!isEnabledScroll) {
          e.preventDefault();
        }
      });
      html.window.onScroll.listen((e) {
        if (!isEnabledScroll) {
          html.window.scrollTo(lastX, lastY);
          e.preventDefault();
        }
      });
      html.window.onKeyDown.listen((e) {
        if (!isEnabledScroll) {
          if (e.keyCode == 37 || e.keyCode == 38 || e.keyCode == 39 ||
              e.keyCode == 40 || e.keyCode == 32 || e.keyCode == 33 ||
              e.keyCode == 34) {
            e.preventDefault();
          }
        }
      });
    }
  }

  void _findFightInterface() {
    for (html.Element e in fightSection.children) {
      if (e.classes.contains("fight-article")) {
        fightArticle = e;
        for (html.Element inner in fightArticle.children) {
          if (inner.classes.contains("fight-start")) {
            buttonFightStart = inner;
            buttonFightStart.classes.remove("disabled");
            buttonFightStart.onClick.listen((e) {
              if (!buttonFightStart.classes.contains("disabled")) {
                fightArticle.classes.remove("current");
              }
            });
          } else if (inner.nodeName == "INPUT") {
            inputText = inner;
            inputText.onInput.listen((e) {
              if (inputText.value == "T2D2-D3PO") {
                if (buttonFightStart != null) {
                  buttonFightStart.classes.remove("disabled");
                }
              }
            });
          } else if (inner.classes.contains("fight-info")) {
            pFightInfo = inner;
          } else if (inner.classes.contains("fight-failure")) {
            pFightFailure = inner;
          } else if (inner.classes.contains("fight-lock")) {
            pFightLock = inner;
          } else if (inner.classes.contains("fight-congrats")) {
            pFightCongrats = inner;
          } else if (inner.classes.contains("level")) {
            divFights.add(inner);
          }
        }
      }
    }
  }

  void _hideEach(List<html.Element> elements) {
    for (html.Element e in elements) {
      e.classes.add("hide");
    }
  }

  void _showEach(List<html.Element> elements) {
    for (html.Element e in elements) {
      e.classes.remove("hide");
    }
  }

  void hideUiSection() {
    uiSection.classes.add("display-none");
  }

  void showUiSection() {
    uiSection.classes.remove("display-none");
  }
}