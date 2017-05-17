import '../core/abs_page_designer.dart';
import 'dart:html' as html;
import 'dart:async';

class DsPageDesigner implements PageDesigner {
  bool isActiveFlashlight = false;

  @override
  void init() {
    _applyFadeIn();
    _applyFlashLightEffects();
    _prepareScrollUpButton();
  }

  void _applyFadeIn() {
    List<html.Element> fadeInElements = html.querySelectorAll(".fade-in");
    for (html.Element element in fadeInElements) {
      html.window.onScroll.listen((e) {
        int windowBottom = _getWindowBottom();
        html.window.console.log(
            windowBottom.toString() + " " + element.offsetTop.toString());
        if (element.offsetTop <= windowBottom) {
          element.classes.remove("fade-in");
          element.classes.add("in-view");
        }
      });
    }
  }

  void _applyFlashLightEffects() {
    html.Element flashlight = html.querySelector(".flashlight-front");
    html.window.onScroll.listen((e) {
      int windowBottom = _getWindowBottom();
      if (flashlight.offsetTop <= windowBottom) {
        flashlight.classes.add("flashlight-full");
        if (!isActiveFlashlight) {
          Future future = new Future.delayed(new Duration(milliseconds: 1000), () {
            flashlight.classes.remove("flashlight-full");
            flashlight.classes.add("flashlight-stop");
            Future future = new Future.delayed(new Duration(milliseconds: 150), () {
              flashlight.classes.remove("flashlight-stop");
              flashlight.classes.add("flashlight-full");
              Future future = new Future.delayed(new Duration(milliseconds: 150), () {
                flashlight.classes.remove("flashlight-full");
                flashlight.classes.add("flashlight-stop");
                Future future = new Future.delayed(new Duration(milliseconds: 250), () {
                  flashlight.classes.remove("flashlight-stop");
                  flashlight.classes.add("flashlight-full");
                  isActiveFlashlight = false;
                });
              });

            });
          });
        }
        isActiveFlashlight = true;
      }
    });
  }

  int _getWindowBottom() {
    return html.window.outerHeight + html.window.scrollY;
  }

  void _prepareScrollUpButton(){
    html.Element scrollButton = html.querySelector("#scroll-up");
    html.window.onScroll.listen((e){
      if(html.window.scrollY > 768){
        scrollButton.classes.remove("hide");
      } else {
        scrollButton.classes.add("hide");
      }
    });
    scrollButton.onClick.listen((e){
      html.window.scrollTo(0,0);
    });
  }
}