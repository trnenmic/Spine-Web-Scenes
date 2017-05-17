import 'dart:html' as html;

class LoadingStageAnimator {

  html.Element canvas;

  LoadingStageAnimator(html.Element canvas) {
    this.canvas = canvas;
  }

  void complete() {
    canvas.style.background = "black";
    if (canvas.parentNode != null && canvas.parentNode.parentNode != null) {
      html.Element section = canvas.parentNode.parentNode;
      section.classes.add("hide-loading");
    }
  }

}