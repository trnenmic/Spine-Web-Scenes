import 'dart:async';
import 'dart:html' as html;

import 'package:stagexl/stagexl.dart';

import 'section_manager.dart';

class RenderUpdater {

  List<SectionManager> managers;
  RenderLoop renderLoop;

  RenderUpdater(RenderLoop renderLoop) {
    this.managers = new List<SectionManager>();
    this.renderLoop = renderLoop;
    html.window.onScroll.listen((e) {
      resizeAll();
      renderStagesInViewport();
    });
    html.window.onResize.listen((e) {
      resizeAll();
      renderStagesInViewport();
    });
  }

  void renderStagesInViewport() {
    for (SectionManager sm in managers) {
      if (isInsideWindow(sm.canvas)) {
        renderLoop.addStage(sm.stageManager.stage);
        renderLoop.addStage(sm.stageManager.shadowStage);
        sm.stageManager.shadowStage.renderMode = StageRenderMode.ONCE;
        renderLoop.removeStage(sm.stageManager.shadowStage);
        Future future = new Future.delayed(new Duration(milliseconds: 50))
            .then((e) {
          sm.stageManager.shadowStage.renderMode = StageRenderMode.AUTO;
          renderLoop.removeStage(sm.stageManager.shadowStage);
          renderLoop.addStage(sm.stageManager.shadowStage);
          sm.stageManager.shadowStage.renderMode = StageRenderMode.ONCE;
        });
      } else {
        renderLoop.removeStage(sm.stageManager.stage);
        renderLoop.removeStage(sm.stageManager.shadowStage);
      }
    }
  }

  void resizeAll() {
    for (SectionManager sm in managers) {
      if (isInsideWindow(sm.canvas)) {
        resizeSection(sm);
      }
    }
  }

  void addManager(SectionManager sm) {
    managers.add(sm);
    renderStagesInViewport();
  }

  bool isInsideWindow(html.Element canvas) {
    html.Rectangle rectCanvas = canvas.getBoundingClientRect();
    html.Rectangle rectClient = html.document.documentElement.client;
    bool isInside = false;
    if (!(canvas
        .getComputedStyle()
        .visibility == "hidden" ||
        canvas
            .getComputedStyle()
            .display == "none")) {
      if ((rectCanvas.top > 0 && rectCanvas.top < rectClient.height)
          || (rectCanvas.bottom > 0 && rectCanvas.bottom < rectClient.height)
          || (rectCanvas.top < 0 && rectCanvas.bottom > 0)) {
        isInside = true;
      }
    }
    return isInside;
  }

  Future resizeSection(SectionManager sm) {
    if (!sm.stageManager.isResizing) {
      sm.stageManager.isResizing = true;
      return new Future.delayed(const Duration(milliseconds: 50), () =>
          _updateResizePosition(sm));
    }
  }

  void _updateResizePosition(SectionManager sm) {
    num halfRectangle = sm.stageManager.stage.contentRectangle.width / 2;
    if (sm.stageManager.actor != null) {
      if (sm.stageManager.actor.x != halfRectangle) {
        num delta = sm.stageManager.actor.x - halfRectangle;
        for (DisplayObject child in sm.stageManager.stage.children) {
          if (!(identical(child, sm.stageManager.actor))) {
            child.x -= delta;
          }
        }
        if (sm.stageManager.shadowStage != null) {
          for (DisplayObject child in sm.stageManager.shadowStage.children) {
            child.x -= delta;
          }
        }
        sm.stageManager.actor.x = halfRectangle;
        renderStagesInViewport();
      }
    }
    sm.stageManager.isResizing = false;
  }
}