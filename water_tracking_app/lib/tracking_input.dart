import 'package:flutter/material.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_controls.dart';
import 'flare_controller.dart';

///主に画面を設計
class TrackingInput extends StatefulWidget {
  @override
  TrackingState createState() => new TrackingState();
}

class TrackingState extends State<TrackingInput> {
  double screenWidth = 0.0;
  double screenHeight = 0.0;

  ///これはwaterとiceBoyのアニメーションコントローラ
  AnimationControls _flareController;

  ///個々のコントローラの設定方法の例
  final FlareControls plusWaterControls = FlareControls();
  final FlareControls minusWaterControls = FlareControls();

  ///グラスに注がれた現在の水の量
  int currentWaterCount = 0;

  ///これはselectedGlassesの時間ouncesPerGlassから取得されます
  ///これを使用して、水で満たされたアニメーションの変換を計算します
  int maxWaterCount = 0;

  ///デフォルトは8ですが、これはユーザー入力に基づいて変更されます
  int selectedGlasses = 8;

  ///これは変わらないので、 'static const'、常にグラスあたり8オンスをカウントします
  static const int ouncePerGlass = 8;


  void initState() {
    _flareController = AnimationControls();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;        ///デバイスのサイズを取得
    screenHeight = MediaQuery.of(context).size.height;      ///デバイスのサイズを取得
    return Scaffold(
      backgroundColor: const Color.fromRGBO(93, 93, 93, 1),
      body: Container(
        ///Stack some widgets
        color: const Color.fromRGBO(93, 93, 93, 1),
        ///stack:widgetを重ねる時に使用する
        child: Stack(
          fit: StackFit.expand,
          children: [
            ///アイスボーイと水で満たされたメインアートボードです
            ///flareのアニメーション画面
            FlareActor(
              "assets/WaterArtboards.flr",
              controller: _flareController,
              fit: BoxFit.contain,
              animation: "iceboy",
              artboard: "Artboard",     ///flareのパーツ名
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Spacer(),   ///空のViewみたいなもの?
                ///縦に積んだいるだけ(位置などは指定していない)
                addWaterBtn(),
                subWaterBtn(),
                settingsButton(),
              ],
            )
          ],
        ),
      ),
    );
  }

  ///これは、摂取量をゼロにリセットするためのユーザーのクイックリセットです
  void _resetDay() {
    setState(() {
      currentWaterCount = 0;  ///水の量をリセット
      _flareController.resetWater();  ///塗りつぶしの量もリセット
    });
  }

  ///これを使用して、ユーザが飲んだ水の量を増やします。
  void _incrementWater() {
    setState(() {
      if (currentWaterCount < selectedGlasses) {
        currentWaterCount = currentWaterCount + 1;

        double diff = currentWaterCount / selectedGlasses;

        ///playは一時アニメーションを再生する
        ///applyは常に再生しているアニメーション？
        plusWaterControls.play("plus press");         ///プラスボタンを押下するアニメーションを再生

        _flareController.playAnimation("ripple");     ///flareで設定したアニメーションを呼び出す

        _flareController.updateWaterPercent(diff);    ///給水ライン(全体の塗りつぶし)を更新
      }

      ///水が上限だったらiceboyの特別アニメーションを再生
      if (currentWaterCount == selectedGlasses) {
        _flareController.playAnimation("iceboy_win");
      }
    });
  }

  ///これを使用してユーザーの水分摂取量を減らし、ボタンに接続します
  void _decrementWater() {
    setState(() {
      if (currentWaterCount > 0) {
        currentWaterCount = currentWaterCount - 1;
        double diff = currentWaterCount / selectedGlasses;

        _flareController.updateWaterPercent(diff);

        _flareController.playAnimation("ripple");
      } else {
        currentWaterCount = 0;
      }
      minusWaterControls.play("minus press");
    });
  }

  void calculateMaxOunces() {
    maxWaterCount = selectedGlasses * ouncePerGlass;
  }

  void _incSelectedGlasses(StateSetter updateModal, int value) {
    updateModal(() {
      selectedGlasses = (selectedGlasses + value).clamp(0, 26).toInt();
      calculateMaxOunces();
    });
  }

  Widget settingsButton() {
    ///ボタンの機能をつける
    return RawMaterialButton(
      constraints: BoxConstraints.tight(Size(95, 30)),
      onPressed: _showMenu,
      shape: Border(),
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      elevation: 0.0,
      child: FlareActor("assets/WaterArtboards.flr",
          fit: BoxFit.contain,
          sizeFromArtboard: true,
          artboard: "UI Ellipse"),
    );
  }

  Widget addWaterBtn() {
    return RawMaterialButton(
      constraints: BoxConstraints.tight(const Size(150, 150)),
      onPressed: _incrementWater,
      shape: Border(),
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      elevation: 0.0,
      child: FlareActor("assets/WaterArtboards.flr",
          controller: plusWaterControls,
          fit: BoxFit.contain,
          animation: "plus press",
          sizeFromArtboard: false,
          artboard: "UI plus"),
    );
  }

  Widget subWaterBtn() {
    return RawMaterialButton(
      constraints: BoxConstraints.tight(const Size(150, 150)),
      onPressed: _decrementWater,
      shape: Border(),
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      elevation: 0.0,
      child: FlareActor("assets/WaterArtboards.flr",
          controller: minusWaterControls,
          fit: BoxFit.contain,
          animation: "minus press",
          sizeFromArtboard: true,
          artboard: "UI minus"),
    );
  }

  ///ボトムシートメニューを設定する
  void _showMenu() {
    ///メニュー画面のWidget
    ///モーダル形式で表示される
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        ///stateを持ちsetStateを行えるwidget?
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter updateModal) {
            return Container(
              decoration: BoxDecoration(
                color: const Color.fromRGBO(93, 93, 93, 1),
              ),
              padding: const EdgeInsets.all(20),
              ///メニュー画面を縦に積んで配置
              child: Column(
                children: [
                  Text(
                    "Set Target",
                    style: TextStyle(
                        fontWeight: FontWeight.normal,
                        color: Colors.white,
                        fontSize: 24.0),
                    textAlign: TextAlign.center,
                  ),
                  // Some vertical padding between text and buttons row
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      ///水の上限をあげるアニメーション
                      FlareWaterTrackButton(
                        artboard: "UI arrow left",
                        pressAnimation: "arrow left press",
                        onPressed: () => _incSelectedGlasses(updateModal, -1),
                      ),
                      Expanded(
                        child: Text(
                          selectedGlasses.toString(),
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              color: Colors.white,
                              fontSize: 40.0),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      ///水の上限をさげるアニメーション
                      FlareWaterTrackButton(
                        artboard: "UI arrow right",
                        pressAnimation: "arrow right press",
                        onPressed: () => _incSelectedGlasses(updateModal, 1),
                      ),
                    ],
                  ),
                  // Some vertical padding between text and buttons row
                  const SizedBox(height: 20),
                  Text(
                    "/glasses",
                    style: TextStyle(
                        fontWeight: FontWeight.normal,
                        color: Colors.white,
                        fontSize: 20.0),
                    textAlign: TextAlign.center,
                  ),
                  // Some vertical padding between text and buttons row
                  const SizedBox(height: 20),
                  ///our Flare button that closes our menu
                  ///TODO: Here is your challenge!
                  FlareWaterTrackButton(
                    artboard: "UI refresh",
                    onPressed: () {
                      _resetDay();
                      // close modal
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

///メニュー画面のボタン
///自動的に再生されるFlareウィジェット付きのボタン
///押したときのフレアアニメーション。アニメーションを指定してください
class FlareWaterTrackButton extends StatefulWidget {
  final String pressAnimation;
  final String artboard;
  final VoidCallback onPressed;
  const FlareWaterTrackButton(
      {this.artboard, this.pressAnimation, this.onPressed});

  @override
  _FlareWaterTrackButtonState createState() => _FlareWaterTrackButtonState();
}

class _FlareWaterTrackButtonState extends State<FlareWaterTrackButton> {
  final _controller = FlareControls();

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      constraints: BoxConstraints.tight(const Size(95, 85)),
      onPressed: () {
        _controller.play(widget.pressAnimation);
        widget.onPressed?.call();
      },
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      child: FlareActor("assets/WaterArtboards.flr",
          controller: _controller,
          fit: BoxFit.contain,
          artboard: widget.artboard),
    );
  }
}