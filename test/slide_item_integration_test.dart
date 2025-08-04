import 'package:flutter_test/flutter_test.dart';
import 'package:custom_slide_show/slide_item.dart';
import 'dart:convert';
import 'dart:io';

void main() {
  group('SlideItem 統合テスト（実際のJSONファイル）', () {
    test('test_images/slideshow.jsonが正しくデコード・エンコードされる', () {
      // テスト用のJSONファイルパス
      const jsonFilePath = 'test_images/slideshow.json';
      
      // ファイルが存在することを確認
      final file = File(jsonFilePath);
      expect(file.existsSync(), true, reason: 'テストファイルが存在しません: $jsonFilePath');

      // ファイルを読み込み
      final jsonString = file.readAsStringSync();
      final jsonData = json.decode(jsonString) as List<dynamic>;

      // デコードテスト
      final slideItems = jsonData
          .map((json) => SlideItem.fromJson(json as Map<String, dynamic>))
          .toList();

      // 基本的な検証
      expect(slideItems.length, 5);
      expect(slideItems.every((item) => item.image.isNotEmpty), true);

      // 各スライドの詳細検証
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

      // エンコードテスト
      final encodedJsonData = slideItems.map((item) => item.toFileJson()).toList();
      final encodedJsonString = const JsonEncoder.withIndent('  ').convert(encodedJsonData);

      // エンコードされたJSONを再度デコード
      final decodedJsonData = json.decode(encodedJsonString) as List<dynamic>;
      final decodedSlideItems = decodedJsonData
          .map((json) => SlideItem.fromJson(json as Map<String, dynamic>))
          .toList();

      // 往復テスト：元のデータと一致することを確認
      for (int i = 0; i < slideItems.length; i++) {
        final original = slideItems[i];
        final decoded = decodedSlideItems[i];

        expect(decoded.image, original.image);
        expect(decoded.caption, original.caption);
        expect(decoded.pan, original.pan);
        expect(decoded.duration, original.duration);
        expect(decoded.scale, original.scale);
        expect(decoded.xoffset, original.xoffset);
        expect(decoded.yoffset, original.yoffset);
      }

      // JSONの構造が元のファイルと一致することを確認
      final originalJsonData = jsonData.cast<Map<String, dynamic>>();
      expect(encodedJsonData.length, originalJsonData.length);

      for (int i = 0; i < encodedJsonData.length; i++) {
        final original = originalJsonData[i];
        final encoded = encodedJsonData[i];

        // 必須フィールドの確認
        expect(encoded["image"], original["image"]);

        // オプションフィールドの確認
        if (original.containsKey("text")) {
          expect(encoded["text"], original["text"]);
        } else {
          expect(encoded.containsKey("text"), false);
        }

        if (original.containsKey("pan")) {
          expect(encoded["pan"], original["pan"]);
        } else {
          expect(encoded.containsKey("pan"), false);
        }

        if (original.containsKey("duration")) {
          expect(encoded["duration"], original["duration"]);
        } else {
          expect(encoded.containsKey("duration"), false);
        }

        if (original.containsKey("scale")) {
          expect(encoded["scale"], original["scale"]);
        } else {
          expect(encoded.containsKey("scale"), false);
        }

        if (original.containsKey("xoffset")) {
          expect(encoded["xoffset"], original["xoffset"]);
        } else {
          expect(encoded.containsKey("xoffset"), false);
        }

        if (original.containsKey("yoffset")) {
          expect(encoded["yoffset"], original["yoffset"]);
        } else {
          expect(encoded.containsKey("yoffset"), false);
        }
      }
    });

    test('新しいキャプション状態でJSONを生成・保存できる', () {
      // 新しい構造でSlideItemを作成
      final newSlideItems = [
        SlideItem(
          image: "new1.png",
          caption: CaptionState.show("新しいキャプション1"),
          pan: PanDirection.up,
          duration: 6.0,
        ),
        SlideItem(
          image: "new2.jpg",
          caption: const CaptionState.hide(), // キャプションを消去
          scale: 1.3,
        ),
        SlideItem(
          image: "new3.gif",
          caption: const CaptionState.keep(), // キャプションを継続
          pan: PanDirection.right,
          duration: 4.5,
        ),
      ];

      // toFileJsonでエンコード
      final jsonData = newSlideItems.map((item) => item.toFileJson()).toList();
      final jsonString = const JsonEncoder.withIndent('  ').convert(jsonData);

      // 期待されるJSON構造
      final expectedJson = [
        {
          "image": "new1.png",
          "text": "新しいキャプション1",
          "pan": "up",
          "duration": 6.0,
        },
        {
          "image": "new2.jpg",
          "text": "",
          "scale": 1.3,
        },
        {
          "image": "new3.gif",
          "pan": "right",
          "duration": 4.5,
        },
      ];

      // デコードして検証
      final decodedJsonData = json.decode(jsonString) as List<dynamic>;
      expect(decodedJsonData.length, expectedJson.length);

      for (int i = 0; i < decodedJsonData.length; i++) {
        final decoded = decodedJsonData[i] as Map<String, dynamic>;
        final expected = expectedJson[i];

        expect(decoded["image"], expected["image"]);

        if (expected.containsKey("text")) {
          expect(decoded["text"], expected["text"]);
        } else {
          expect(decoded.containsKey("text"), false);
        }

        if (expected.containsKey("pan")) {
          expect(decoded["pan"], expected["pan"]);
        }

        if (expected.containsKey("duration")) {
          expect(decoded["duration"], expected["duration"]);
        }

        if (expected.containsKey("scale")) {
          expect(decoded["scale"], expected["scale"]);
        }
      }

      // 再度デコードしてSlideItemに変換
      final decodedSlideItems = decodedJsonData
          .map((json) => SlideItem.fromJson(json as Map<String, dynamic>))
          .toList();

      // キャプション状態が正しく復元されることを確認
      expect(decodedSlideItems[0].caption, isA<CaptionShow>());
      expect((decodedSlideItems[0].caption as CaptionShow).text, "新しいキャプション1");

      expect(decodedSlideItems[1].caption, isA<CaptionHide>());

      expect(decodedSlideItems[2].caption, isA<CaptionKeep>());
    });
  });
} 