import 'dart:html' as html;

import 'loading_bar_animator.dart';
import 'loading_stage_animator.dart';

class LoadingManager {

  int stageLimit = 0;
  int completedStages = 0;
  LoadingBarAnimator loadingBarAnimator;
  List<LoadingStageAnimator> circleAnimators;

  LoadingManager() {
    loadingBarAnimator = new LoadingBarAnimator();
    circleAnimators = new List<LoadingStageAnimator>();
  }

  void addCircleAnimator(html.Element canvas) {
    increment();
    LoadingStageAnimator lsa = new LoadingStageAnimator(canvas);
    circleAnimators.add(lsa);
  }

  void increment() {
    loadingBarAnimator.increment();
  }

  void stageCompleted(int index) {
    completedStages++;
    increment();
    circleAnimators[index].complete();
    if (completedStages == stageLimit) {
      loadingBarAnimator.complete();
    }
  }

  void setLimit(int limit) {
    stageLimit = limit;
  }

}