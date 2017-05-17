import 'dart:async';
import 'dart:html' as html;
import 'dart:math';

import 'render_updater.dart';
import 'section_manager.dart';

class TabManager {

  RenderUpdater renderUpdater;
  List<html.Element> tabParents;
  List<SectionManager> managers;
  List<List<html.Element>> links;
  List<html.Element> tabsNext;
  List<html.Element> tabsPrevious;
  List<List<html.Element>> widgets;
  List<int> lastIndices;

  TabManager(RenderUpdater renderUpdater) {
    this.renderUpdater = renderUpdater;
    tabParents = html.querySelectorAll(".tab-parent");
    links = new List<List<html.Element>>();
    widgets = new List<List<html.Element>>();
    tabsNext = new List<html.Element>();
    tabsPrevious = new List<html.Element>();
    for (int i = 0; i < tabParents.length; i++) {
      links.add(new List<html.Element>());
      widgets.add(new List<html.Element>());
    }
    lastIndices = new List<int>();
  }

  init() {
    _findLinksAndArticles();
    _addListeners();
  }

  void _findLinksAndArticles() {
    for (int i = 0; i < tabParents.length; i++) {
      html.Element parent = tabParents[i];
      lastIndices.add(0);
      for (html.Element section in parent.children) {
        if (section.tagName == "DIV" &&
            section.classes.contains("tab-row")) {
          for (html.Element div in section.children) {
            for (html.Element link in div.children) {
              if (link.tagName == "A") {
                links[i].add(link); // j?
              }
            }
          }
        } else if (section.tagName == "DIV" &&
            section.classes.contains("widget")) {
          widgets[i].add(section);
        } else if (section.tagName == "DIV" &&
            section.classes.contains("tab-controller")) {
          html.Element controller = section;
          for (html.Element button in controller.children) {
            if (button.classes.contains("tab-next")) {
              tabsNext.add(button);
            } else if (button.classes.contains("tab-previous")) {
              tabsPrevious.add(button);
            }
          }
        }
      }
    }
  }

  void _addListeners() {
    for (int i = 0; i < tabParents.length; i++) {
      int length = min(links[i].length, widgets[i].length);
      for (int j = 0; j < length; j++) {
        links[i][j].onClick.listen((e) {
          for (int k = 0; k < length; k++) {
            _removeClasses(i, k);
          }
          if (lastIndices[i] != j) {
            widgets[i][j].click();
            lastIndices[i] = j;
          }
          _makeCurrent(i, j);
        });
      }
      tabsPrevious[i].onClick.listen((e) {
        _changeCharacter(false, i, length);
      });
      tabsNext[i].onClick.listen((e) {
        _changeCharacter(true, i, length);
      });
    }

    //invoking scroll event activates render loops to draw stages

  }

  void _changeCharacter(bool isNext, int i, int length) {
    for (int k = 0; k < length; k++) {
      _removeClasses(i, k);
    }
    if (isNext) {
      if (lastIndices[i] > 0) {
        lastIndices[i] = lastIndices[i] - 1;
        widgets[i][lastIndices[i]].click();
        _makeCurrent(i, lastIndices[i]);
      } else {
        lastIndices[i] = length - 1;
        widgets[i][lastIndices[i]].click();
        _makeCurrent(i, lastIndices[i]);
      }
    } else {
      if (lastIndices[i] < length - 1) {
        lastIndices[i] = lastIndices[i] + 1;
        widgets[i][lastIndices[i]].click();
        _makeCurrent(i, lastIndices[i]);
      } else {
        lastIndices[i] = 0;
        widgets[i][lastIndices[i]].click();
        _makeCurrent(i, lastIndices[i]);
      }
    }
  }

  void _makeCurrent(int i, int j) {
    links[i][j].classes.add("current");
    widgets[i][j].classes.remove("hide");
    renderUpdater.renderStagesInViewport();
    renderUpdater.resizeAll();
    Future future = new Future.delayed(
        new Duration(milliseconds: 20), () {
      widgets[i][j].classes.add("loop");
    });
  }

  void _removeClasses(int i, int k) {
    links[i][k].classes.remove("current");
    widgets[i][k].classes.add("hide");
    widgets[i][k].classes.remove("loop");
  }

}