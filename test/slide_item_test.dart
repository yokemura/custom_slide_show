import 'package:flutter_test/flutter_test.dart';
import 'package:custom_slide_show/slide_item.dart';

void main() {
  group('SlideItem JSONデコード・エンコードテスト', () {
    test('既存のJSONファイルが正しくデコードされる', () {
      // 既存のslideshow.jsonの構造を模擬
      final jsonData = [
        {
          "image": "0001.png",
          "text": "最初の画像です",
          "pan": "down",
          "duration": 5.0,
          "scale": 1.2,
          "xoffset": 0.1,
          "yoffset": -0.05
        },
        {
          "image": "0002.jpg",
          "text": "2番目の画像",
          "pan": "down",
          "duration": 3.0,
          "xoffset": -0.1
        },
        {
          "image": "0003.gif",
          "pan": "left",
          "scale": 0.8,
          "yoffset": 0.1
        },
        {
          "image": "0004.bmp",
          "text": "4番目の画像です",
          "duration": 7.0,
          "xoffset": 0.05,
          "yoffset": 0.05
        },
        {
          "image": "0005.tiff",
          "pan": "right",
          "scale": 1.5,
          "duration": 4.0,
          "xoffset": -0.05,
          "yoffset": -0.1
        }
      ];

      // デコードテスト
      final slideItems = jsonData
          .map((json) => SlideItem.fromJson(json as Map<String, dynamic>))
          .toList();

      // 結果の検証
      expect(slideItems.length, 5);

      // 1番目のスライド（textあり）
      expect(slideItems[0].image, "0001.png");
      expect(slideItems[0].caption, isA<CaptionShow>());
      expect((slideItems[0].caption as CaptionShow).text, "最初の画像です");
      expect(slideItems[0].pan, PanDirection.down);
      expect(slideItems[0].duration, 5.0);
      expect(slideItems[0].scale, 1.2);
      expect(slideItems[0].xoffset, 0.1);
      expect(slideItems[0].yoffset, -0.05);

      // 2番目のスライド（textあり）
      expect(slideItems[1].image, "0002.jpg");
      expect(slideItems[1].caption, isA<CaptionShow>());
      expect((slideItems[1].caption as CaptionShow).text, "2番目の画像");
      expect(slideItems[1].pan, PanDirection.down);
      expect(slideItems[1].duration, 3.0);
      expect(slideItems[1].xoffset, -0.1);

      // 3番目のスライド（textなし）
      expect(slideItems[2].image, "0003.gif");
      expect(slideItems[2].caption, isA<CaptionKeep>());
      expect(slideItems[2].pan, PanDirection.left);
      expect(slideItems[2].scale, 0.8);
      expect(slideItems[2].yoffset, 0.1);

      // 4番目のスライド（textあり）
      expect(slideItems[3].image, "0004.bmp");
      expect(slideItems[3].caption, isA<CaptionShow>());
      expect((slideItems[3].caption as CaptionShow).text, "4番目の画像です");
      expect(slideItems[3].duration, 7.0);
      expect(slideItems[3].xoffset, 0.05);
      expect(slideItems[3].yoffset, 0.05);

      // 5番目のスライド（textなし）
      expect(slideItems[4].image, "0005.tiff");
      expect(slideItems[4].caption, isA<CaptionKeep>());
      expect(slideItems[4].pan, PanDirection.right);
      expect(slideItems[4].scale, 1.5);
      expect(slideItems[4].duration, 4.0);
      expect(slideItems[4].xoffset, -0.05);
      expect(slideItems[4].yoffset, -0.1);
    });

    test('toFileJsonで既存のJSON形式にエンコードされる', () {
      // 新しい構造でSlideItemを作成
      final slideItems = [
        SlideItem(
          image: "0001.png",
          caption: CaptionState.show("最初の画像です"),
          pan: PanDirection.down,
          duration: 5.0,
          scale: 1.2,
          xoffset: 0.1,
          yoffset: -0.05,
        ),
        SlideItem(
          image: "0002.jpg",
          caption: CaptionState.show("2番目の画像"),
          pan: PanDirection.down,
          duration: 3.0,
          xoffset: -0.1,
        ),
        SlideItem(
          image: "0003.gif",
          caption: const CaptionState.keep(),
          pan: PanDirection.left,
          scale: 0.8,
          yoffset: 0.1,
        ),
        SlideItem(
          image: "0004.bmp",
          caption: CaptionState.show("4番目の画像です"),
          duration: 7.0,
          xoffset: 0.05,
          yoffset: 0.05,
        ),
        SlideItem(
          image: "0005.tiff",
          caption: const CaptionState.keep(),
          pan: PanDirection.right,
          scale: 1.5,
          duration: 4.0,
          xoffset: -0.05,
          yoffset: -0.1,
        ),
      ];

      // toFileJsonでエンコード
      final jsonData = slideItems.map((item) => item.toFileJson()).toList();

      // 結果の検証
      expect(jsonData.length, 5);

      // 1番目のスライド
      expect(jsonData[0]["image"], "0001.png");
      expect(jsonData[0]["text"], "最初の画像です");
      expect(jsonData[0]["pan"], "down");
      expect(jsonData[0]["duration"], 5.0);
      expect(jsonData[0]["scale"], 1.2);
      expect(jsonData[0]["xoffset"], 0.1);
      expect(jsonData[0]["yoffset"], -0.05);

      // 2番目のスライド
      expect(jsonData[1]["image"], "0002.jpg");
      expect(jsonData[1]["text"], "2番目の画像");
      expect(jsonData[1]["pan"], "down");
      expect(jsonData[1]["duration"], 3.0);
      expect(jsonData[1]["xoffset"], -0.1);

      // 3番目のスライド（textなし）
      expect(jsonData[2]["image"], "0003.gif");
      expect(jsonData[2]["text"], isNull);
      expect(jsonData[2]["pan"], "left");
      expect(jsonData[2]["scale"], 0.8);
      expect(jsonData[2]["yoffset"], 0.1);

      // 4番目のスライド
      expect(jsonData[3]["image"], "0004.bmp");
      expect(jsonData[3]["text"], "4番目の画像です");
      expect(jsonData[3]["duration"], 7.0);
      expect(jsonData[3]["xoffset"], 0.05);
      expect(jsonData[3]["yoffset"], 0.05);

      // 5番目のスライド（textなし）
      expect(jsonData[4]["image"], "0005.tiff");
      expect(jsonData[4]["text"], isNull);
      expect(jsonData[4]["pan"], "right");
      expect(jsonData[4]["scale"], 1.5);
      expect(jsonData[4]["duration"], 4.0);
      expect(jsonData[4]["xoffset"], -0.05);
      expect(jsonData[4]["yoffset"], -0.1);
    });

    test('空文字列のtextはCaptionHideにデコードされる', () {
      final jsonData = {
        "image": "test.png",
        "text": "",
      };

      final slideItem = SlideItem.fromJson(jsonData);
      expect(slideItem.caption, isA<CaptionHide>());
    });

    test('nullのtextはCaptionKeepにデコードされる', () {
      final jsonData = {
        "image": "test.png",
        // textフィールドなし
      };

      final slideItem = SlideItem.fromJson(jsonData);
      expect(slideItem.caption, isA<CaptionKeep>());
    });

    test('CaptionHideは空文字列としてエンコードされる', () {
      final slideItem = SlideItem(
        image: "test.png",
        caption: const CaptionState.hide(),
      );

      final jsonData = slideItem.toFileJson();
      expect(jsonData["text"], "");
    });

    test('CaptionKeepはnullとしてエンコードされる', () {
      final slideItem = SlideItem(
        image: "test.png",
        caption: const CaptionState.keep(),
      );

      final jsonData = slideItem.toFileJson();
      expect(jsonData["text"], isNull);
    });

    test('CaptionShowはテキストとしてエンコードされる', () {
      final slideItem = SlideItem(
        image: "test.png",
        caption: CaptionState.show("テストテキスト"),
      );

      final jsonData = slideItem.toFileJson();
      expect(jsonData["text"], "テストテキスト");
    });

    test('デコード・エンコードの往復テスト', () {
      // 元のJSONデータ
      final originalJson = {
        "image": "test.png",
        "text": "テストキャプション",
        "pan": "up",
        "duration": 10.0,
        "scale": 1.5,
        "xoffset": 0.2,
        "yoffset": -0.3
      };

      // デコード
      final slideItem = SlideItem.fromJson(originalJson);

      // エンコード
      final encodedJson = slideItem.toFileJson();

      // 再度デコード
      final decodedSlideItem = SlideItem.fromJson(encodedJson);

      // 結果が一致することを確認
      expect(decodedSlideItem.image, slideItem.image);
      expect(decodedSlideItem.caption, slideItem.caption);
      expect(decodedSlideItem.pan, slideItem.pan);
      expect(decodedSlideItem.duration, slideItem.duration);
      expect(decodedSlideItem.scale, slideItem.scale);
      expect(decodedSlideItem.xoffset, slideItem.xoffset);
      expect(decodedSlideItem.yoffset, slideItem.yoffset);
    });
  });

  group('CaptionStateテスト', () {
    test('CaptionState.showのwhenメソッド', () {
      final captionState = CaptionState.show("テストテキスト");
      
      final result = captionState.when(
        show: (text) => "表示: $text",
        hide: () => "消去",
        keep: () => "継続",
      );

      expect(result, "表示: テストテキスト");
    });

    test('CaptionState.hideのwhenメソッド', () {
      const captionState = CaptionState.hide();
      
      final result = captionState.when(
        show: (text) => "表示: $text",
        hide: () => "消去",
        keep: () => "継続",
      );

      expect(result, "消去");
    });

    test('CaptionState.keepのwhenメソッド', () {
      const captionState = CaptionState.keep();
      
      final result = captionState.when(
        show: (text) => "表示: $text",
        hide: () => "消去",
        keep: () => "継続",
      );

      expect(result, "継続");
    });
  });
} 