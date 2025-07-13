# Custom Slide Show

A Flutter macOS application for creating and displaying slide shows.

## 概要

Custom Slide Showは、macOS用のスライドショー作成・表示アプリケーションです。Flutterフレームワークを使用して開発されており、美しいUIと使いやすいインターフェースを提供します。

## 機能

- スライドショーの作成と編集
- 画像の表示と管理
- 美しいUI/UX
- macOSネイティブアプリケーション

## 開発環境

- Flutter 3.5.0以上
- Dart SDK
- macOS 10.14以上
- Xcode 12.0以上

## セットアップ

1. プロジェクトをクローンまたはダウンロード
2. 依存関係をインストール:
   ```bash
   flutter pub get
   ```

## ビルドと実行

### 開発モードで実行
```bash
flutter run -d macos
```

### リリースビルド
```bash
flutter build macos
```

### アプリの実行
ビルド後、`build/macos/Build/Products/Release/Custom Slide Show.app`を実行できます。

## プロジェクト構造

```
custom_slide_show/
├── lib/                    # Dartソースコード
│   └── main.dart          # アプリケーションのエントリーポイント
├── macos/                  # macOS固有の設定
│   └── Runner/            # macOSアプリケーション設定
├── test/                   # テストファイル
└── pubspec.yaml           # プロジェクト設定と依存関係
```

## ライセンス

このプロジェクトはMITライセンスの下で公開されています。

## 貢献

プルリクエストやイシューの報告を歓迎します。
