import 'dart:math';
import 'package:flare_dart/math/mat2d.dart';
import 'package:flare_flutter/flare.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_controller.dart';

///アニメーションを処理するクラス
class AnimationControls extends FlareController {

  ///これを宣言すると、どこでもこれを参照できます
  ///パブリック変数として宣言することでどこからでも参照できるようにした
  FlutterActorArtboard _artboard;

  ///塗りつぶしアニメーション。水摂取量を追加/削減するたびにこれをアニメーション化できます
  ActorAnimation _fillAnimation;

  ///現在の取水量に基づいてY軸上を移動する氷
  ActorAnimation _iceboyMoveY;

  ///アニメーションのミックスに使用
  final List<FlareAnimationLayer> _baseAnimations = [];

  ///全体の塗りつぶし
  double _waterFill = 0.00;
  ///現在の水の消費量
  double _currentWaterFill = 0;

  ///塗りつぶしラインの動きを滑らかにするために使用される時間
  double _smoothTime = 5;

  void initialize(FlutterActorArtboard artboard) {
    ///ここでアニメーションとアートボードのリファレンスを取得します
    _artboard = artboard;
    _fillAnimation = artboard.getAnimation("water up");
    _iceboyMoveY = artboard.getAnimation("iceboy_move_up");
  }

  void setViewTransform(Mat2D viewTransform) {}

  ///Artboard:flareの基盤のパーツ
  bool advance(FlutterActorArtboard artboard, double elapsed) {

    ///artboardが"Artboardなら"
    if(artboard.name.compareTo("Artboard") == 0) {
      _currentWaterFill += (_waterFill-_currentWaterFill) * min(1, elapsed *
          _smoothTime);
      _fillAnimation.apply( _currentWaterFill * _fillAnimation.duration, artboard, 1);  ///任意の時間アニメーションを制御
      _iceboyMoveY.apply(_currentWaterFill * _iceboyMoveY.duration, artboard, 1);       ///任意の時間(_currentWaterFill * _iceboyMoveY.duration)アニメーションを制御
    }

    int len = _baseAnimations.length - 1;

    for (int i = len; i >= 0; i--) {
      FlareAnimationLayer layer = _baseAnimations[i];
      layer.time += elapsed;
      layer.mix = min(1.0, layer.time / 0.01);
      layer.apply(_artboard);

      if (layer.isDone) {
        _baseAnimations.removeAt(i);
      }
    }
    return true;
  }

  ///tracking_input」から呼び出されます
  ///アニメーションを呼び出す=_baseAnimationsに追加？
  void playAnimation(String animName){
    ActorAnimation animation = _artboard.getAnimation(animName);
    ///「..」カスケード構文
    if (animation != null) {
      _baseAnimations.add(FlareAnimationLayer()
        ..name = animName
        ..animation = animation
      );
    }
  }
  ///tracking_input」から呼び出されます
  ///給水ライン(全体の塗りつぶし)を更新します
  void updateWaterPercent(double amt){
    _waterFill = amt;
  }
  ///tracking_input」から呼び出されます
  ///給水ライン(全体の塗りつぶし)をリセットします。
  void resetWater(){
    _waterFill = 0;
  }
}