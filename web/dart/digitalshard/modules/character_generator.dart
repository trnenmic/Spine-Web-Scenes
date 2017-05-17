import 'module_character.dart';

class CharacterGenerator {

  static void prepareTodd(ModuleCharacter module) {
    module.intro = "intro";
    module.idle = "idle_blue";
    module.mouse = "eye";
    module.click = "click";
    module.clickAlt = "click_alt";
    module.emotions.add("talk"); //talk
    module.emotions.add("heart"); //heart
    module.emotions.add("hate"); //dislike
    module.scroll = "scroll";
    module.interactivePauseIndex = -1;
  }

  static void prepareHero(ModuleCharacter module) {
    module.intro = "0_idle_setup";
    module.mouse = null;
    module.idle = "0_idle_wide_legs";
    module.click = "0_react_weird";
    module.clickAlt = "0_react_weird";
    module.emotions.add("0_react_dont_give_fuck"); //talk
    module.emotions.add("0_idle_shotgun_on_back"); //heart
    module.emotions.add("0_react_fuck_off"); //dislike
    module.scroll = "0_idle_sratch_armpit";
    module.interactivePauseIndex = -1;
  }

  static void prepareAi(ModuleCharacter module) {
    module.intro = "story_intro";
    module.idle = "story_idle";
    module.click = "0_react_opposite";
    module.clickAlt = "0_react_opposite";
    module.emotions.add("0_react_dont_know"); //talk
    module.emotions.add("0_react_shy"); //heart
    module.emotions.add("story_walk_away"); //dislike
    module.scroll = "0_rest";
    module.interactivePauseIndex = 2;
  }


  static void setTransitions(ModuleCharacter module, double value) {
    setOneTransition(module, module.intro, module.idle, value);
    setOneTransition(module, module.intro, module.click, value);
    setOneTransition(module, module.intro, module.clickAlt, value);
    setOneTransition(module, module.idle, module.click, value);
    setOneTransition(module, module.idle, module.clickAlt, value);
    setOneTransition(module, module.scroll, module.click, value);
    setOneTransition(module, module.scroll, module.idle, value);
    setOneTransition(module, module.scroll, module.clickAlt, value);
    setOneTransition(module, module.click, module.clickAlt, value);
    for (String e1 in module.emotions) {
      for (String e2 in module.emotions) {
        setOneTransition(module, e1, e2, value);
      }
      setOneTransition(module, module.idle, e1, value);
      setOneTransition(module, module.click, e1, value);
      setOneTransition(module, module.scroll, e1, value + 0.5);
      setOneTransition(module, module.clickAlt, e1, value);
      setOneTransition(module, module.intro, e1, value);
    }
  }

  static void setOneTransition(ModuleCharacter module, String a, String b, double mix) {
    if (a != null && a != "" && b != null && b != "") {
      module.actor.state.data.setMixByName(a, b, mix);
      module.actor.state.data.setMixByName(b, a, mix);
    }
  }
}