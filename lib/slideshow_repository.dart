import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'slide_item.dart';

class SlideshowRepository {
  // メモリ上のデータ保持
  List<SlideItem> _slideshowData = [];
  
  // 保存済みのファイルパス
  String? _filePath;
  
  // 基底ディレクトリパス（画像ファイルの相対パス解決用）
  String? _baseDirectory;
  
  // computed propertyとして初期化状態を判定
  bool get isInitialized => _filePath != null;
  
  // ファイルパスを取得
  String? get filePath => _filePath;
  
  // 基底ディレクトリパスを取得
  String? get baseDirectory => _baseDirectory;
  
  // 初期化：ファイルパスを指定してJSON読み込みとメモリ配置
  Future<void> initialize(String filePath) async {
    try {
      // JSONファイルの読み込み
      final file = File(filePath);
      if (!await file.exists()) {
        throw SlideshowRepositoryException('ファイルが見つかりません: $filePath');
      }
      
      // 基底ディレクトリを設定（JSONファイルの親ディレクトリ）
      _baseDirectory = path.dirname(filePath);
      
      final jsonString = await file.readAsString();
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      
      // JSONデータをSlideItemのリストに変換
      _slideshowData = jsonList
          .map((json) => SlideItem.fromJson(json as Map<String, dynamic>))
          .toList();
      
      // ファイルパスを保持
      _filePath = filePath;
      
    } catch (e) {
      throw SlideshowRepositoryException('初期化に失敗しました: $e');
    }
  }
  
  // データ取り出し：メモリ上のデータを同期的に返す
  List<SlideItem> getSlideshowData() {
    if (!isInitialized) {
      throw SlideshowRepositoryException('Repositoryが初期化されていません');
    }
    return List.unmodifiable(_slideshowData);
  }
  
  // 画像の絶対パスを取得
  String getImagePath(String imageName) {
    if (_baseDirectory == null) {
      throw SlideshowRepositoryException('基底ディレクトリが設定されていません');
    }
    return path.join(_baseDirectory!, imageName);
  }
  
  // データ保存：新しいデータでメモリ更新とJSON書き出し
  Future<void> saveSlideshowData(List<SlideItem> data) async {
    if (!isInitialized) {
      throw SlideshowRepositoryException('Repositoryが初期化されていません');
    }
    
    try {
      // メモリ上のデータを更新
      _slideshowData = List.from(data);
      
      // JSONファイルへの書き出し
      final file = File(_filePath!);
      final jsonList = data.map((item) => item.toFileJson()).toList();
      final jsonString = jsonEncode(jsonList);
      
      await file.writeAsString(jsonString);
      
    } catch (e) {
      throw SlideshowRepositoryException('データの保存に失敗しました: $e');
    }
  }
}

class SlideshowRepositoryException implements Exception {
  final String message;
  
  SlideshowRepositoryException(this.message);
  
  @override
  String toString() => 'SlideshowRepositoryException: $message';
}
