import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:convert';

import '../slideshow_repository.dart';
import '../slide_item.dart';

class HomeScreenViewModel extends ChangeNotifier {
  final SlideshowRepository _repository;
  
  HomeScreenViewModel(this._repository);
  
  // プロパティ
  bool _isLoading = false;
  Object? _error;
  
  // Getters
  bool get isLoading => _isLoading;
  Object? get error => _error;
  SlideshowRepository get repository => _repository;
  
  // Repositoryの値を中継するcomputed property
  bool get isInitialized => _repository.isInitialized;
  List<SlideItem> get slideshowData {
    if (!isInitialized) return [];
    try {
      return _repository.getSlideshowData();
    } catch (e) {
      _error = e;
      notifyListeners();
      return [];
    }
  }
  
  String? get selectedFolderPath {
    if (!isInitialized) return null;
    try {
      final filePath = _repository.filePath;
      if (filePath != null) {
        return path.dirname(filePath);
      }
      return null;
    } catch (e) {
      _error = e;
      notifyListeners();
      return null;
    }
  }
  
  // ファイルパスを指定してrepositoryのイニシャライズを行う処理
  Future<void> initializeFromFolder(String folderPath) async {
    _setLoading(true);
    _error = null;
    
    try {
      final slideshowPath = path.join(folderPath, 'slideshow.json');
      final slideshowFile = File(slideshowPath);
      
      // slideshow.jsonが存在する場合は読み込み
      if (await slideshowFile.exists()) {
        await _repository.initialize(slideshowPath);
      } else {
        // 新しくslideshow.jsonを作成
        await _createNewSlideshow(folderPath, slideshowFile);
      }
      
      notifyListeners();
    } catch (e) {
      _error = e;
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }
  
  // フォルダ選択ダイアログを開いてイニシャライズ
  Future<void> openFolder() async {
    _setLoading(true);
    _error = null;
    
    try {
      String? result;
      
      try {
        const MethodChannel channel = MethodChannel('custom_slide_show/file_picker');
        result = await channel.invokeMethod<String>('pickFolder');
      } catch (e) {
        result = await FilePicker.platform.getDirectoryPath(
          dialogTitle: 'Select a folder containing images for your slide show',
        );
      }
      
      if (result != null) {
        await initializeFromFolder(result);
      }
    } catch (e) {
      _error = e;
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }
  
  // 新しくslideshow.jsonを作成
  Future<void> _createNewSlideshow(String folderPath, File slideshowFile) async {
    final directory = Directory(folderPath);
    final imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'tiff', 'webp'];
    final List<String> imageFiles = [];
    
    await for (final entity in directory.list()) {
      if (entity is File) {
        final extension = path.extension(entity.path).toLowerCase().replaceAll('.', '');
        if (imageExtensions.contains(extension)) {
          imageFiles.add(path.basename(entity.path));
        }
      }
    }
    
    imageFiles.sort();
    
    final slideshowData = imageFiles
        .map((imageFile) => SlideItem(image: imageFile))
        .toList();
    
    final jsonString = const JsonEncoder.withIndent('  ').convert(
        slideshowData.map((item) => item.toFileJson()).toList());
    await slideshowFile.writeAsString(jsonString);
    
    await _repository.initialize(slideshowFile.path);
  }
  
  // エラーをクリア
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
