import 'dart:async';
import 'dart:html' as html;
import 'dart:math';

class LoadingBarAnimator {

  num displayValue;
  num value;

  html.Element bar;

  LoadingBarAnimator([int stageLimit]) {
    bar =
        html.document.querySelector("body progress[value]:first-child");
    displayValue = double.parse(bar.getAttribute("value"));
    value = displayValue;
  }

  void increment() {
    Random random = new Random(100);
    value = (random.nextInt(1500) / 100) + 1;
    if (displayValue + value < 80) {
      displayValue += value;
    } else if (displayValue < 90) {
      displayValue += 0.5;
    } else if (displayValue < 95){
      displayValue += 0.1;
    }
    if (bar != null) {
      bar.setAttribute("value", displayValue.toString());
    }
    value = 0;
  }

  void complete() {
    if (bar != null) {
      bar.setAttribute("value", "100");
      Future future = new Future.delayed(
          const Duration(milliseconds: 500), () => bar.style.height = "0");
    }
  }

}