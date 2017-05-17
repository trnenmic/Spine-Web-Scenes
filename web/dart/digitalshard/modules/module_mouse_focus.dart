import 'dart:html' as html;

class ModuleMouseFocus {

  html.Element shadowCanvas;
  html.Element div;
  html.Element canvas;
  List<String> classes;

  ModuleMouseFocus(html.Element canvas, html.Element shadowCanvas, html.Element div){
    this.shadowCanvas = shadowCanvas;
    this.canvas = canvas;
    this.div = div;
    classes = new List<String>();
    classes.add("shadow-blur");
    classes.add("shadow-focus");
    classes.add("shadow-hover");
  }

  init(){
    shadowCanvas.onMouseMove.listen((e) {
      canvas.focus();
    });

    shadowCanvas.onFocus.listen((e) {
      div.classes.removeAll(classes);
      div.classes.add("shadow-focus");
      canvas.focus();
    });
    canvas.onBlur.listen((e) {
      div.classes.removeAll(classes);
      div.classes.add("shadow-blur");
      canvas.blur();
    });

    shadowCanvas.onMouseOut.listen((e) {
      if (div.classes.contains("shadow-hover")) {
        div.classes.removeAll(classes);
        div.classes.add("shadow-blur");
      }
    });
    shadowCanvas.onMouseEnter.listen((e) {
      if (div.classes.contains("shadow-blur")) {
        div.classes.removeAll(classes);
        div.classes.add("shadow-hover");
      }
    });
  }

}
