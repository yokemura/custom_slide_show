import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'home_screen_viewmodel.dart';
import 'slideshow_screen.dart';

class HomeScreenNew extends HookConsumerWidget {
  const HomeScreenNew({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = useMemoized(() => HomeScreenViewModel());
    
    useEffect(() {
      // キーボードショートカットの設定
      final handler = (KeyEvent event) {
        if (event is KeyDownEvent) {
          if (HardwareKeyboard.instance.isMetaPressed &&
              event.logicalKey == LogicalKeyboardKey.keyO) {
            viewModel.openFolder();
            return true;
          }
        }
        return false;
      };
      
      HardwareKeyboard.instance.addHandler(handler);
      
      return () {
        HardwareKeyboard.instance.removeHandler(handler);
      };
    }, []);
    
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: Text(title),
            actions: [
              IconButton(
                icon: const Icon(Icons.folder_open),
                onPressed: viewModel.openFolder,
                tooltip: 'Open Folder',
              ),
            ],
          ),
          body: _buildBody(context, viewModel),
          floatingActionButton: FloatingActionButton(
            onPressed: viewModel.openFolder,
            tooltip: 'Open Folder',
            child: const Icon(Icons.folder_open),
          ),
        );
      },
    );
  }
  
  Widget _buildBody(BuildContext context, HomeScreenViewModel viewModel) {
    // エラー表示
    if (viewModel.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'エラーが発生しました',
              style: const TextStyle(fontSize: 18, color: Colors.red),
            ),
            const SizedBox(height: 8),
            Text(
              '${viewModel.error}',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // エラーをクリアして再試行
                viewModel.clearError();
              },
              child: const Text('再試行'),
            ),
          ],
        ),
      );
    }
    
    // ローディング中
    if (viewModel.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('フォルダを処理中...'),
          ],
        ),
      );
    }
    
    // イニシャライズ前
    if (!viewModel.isInitialized) {
      return _buildUninitializedView(context, viewModel);
    }
    
    // イニシャライズ後
    return _buildInitializedView(context, viewModel);
  }
  
  // イニシャライズ前の画面
  Widget _buildUninitializedView(BuildContext context, HomeScreenViewModel viewModel) {
    return DropTarget(
      onDragDone: (detail) async {
        if (detail.files.isNotEmpty) {
          final file = detail.files.first;
          final filePath = file.path;
          
          // ディレクトリかチェック
          final directory = Directory(filePath);
          if (await directory.exists()) {
            await viewModel.initializeFromFolder(filePath);
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('フォルダをドロップしてください'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          }
        }
      },
      onDragEntered: (detail) {
        // ドラッグエンター
      },
      onDragExited: (detail) {
        // ドラッグエグジット
      },
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 3,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(16),
                color: Colors.grey.withOpacity(0.05),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.folder_open,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'フォルダが選択されていません',
                    style: TextStyle(
                      fontSize: 18, 
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '画像を含むフォルダをここにドラッグ＆ドロップ\nまたは下のボタンをクリックしてください',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: viewModel.openFolder,
              icon: const Icon(Icons.folder_open),
              label: const Text('フォルダを開く'),
            ),
          ],
        ),
      ),
    );
  }
  
  // イニシャライズ後の画面
  Widget _buildInitializedView(BuildContext context, HomeScreenViewModel viewModel) {
    final slideshowData = viewModel.slideshowData;
    
    if (slideshowData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.image_not_supported,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              '画像が見つかりません',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'フォルダに画像ファイルが含まれていることを確認してください',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: viewModel.openFolder,
              child: const Text('別のフォルダを選択'),
            ),
          ],
        ),
      );
    }
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.folder, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: const Text(
                  'フォルダが選択されています',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                '${slideshowData.length} 枚の画像',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: [
              // スライドショー開始ボタン
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  onPressed: slideshowData.isNotEmpty ? () => _startSlideshow(context, viewModel) : null,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('スライドショー開始'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              
              // 画像リスト
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: slideshowData.length,
                  itemBuilder: (context, index) {
                    final item = slideshowData[index];
                    final imageName = item.image;
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(Icons.image, color: Colors.blue),
                        title: Text(imageName),
                        subtitle: Text(
                            '画像 ${index + 1} / ${slideshowData.length}'),
                        trailing: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        onTap: () => _startSlideshowFromIndex(context, viewModel, index),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  void _startSlideshow(BuildContext context, HomeScreenViewModel viewModel) {
    final slideshowData = viewModel.slideshowData;
    if (slideshowData.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SlideshowScreen(
            folderPath: viewModel.selectedFolderPath ?? '',
            slideshowData: slideshowData,
          ),
        ),
      );
    }
  }
  
  void _startSlideshowFromIndex(BuildContext context, HomeScreenViewModel viewModel, int startIndex) {
    final slideshowData = viewModel.slideshowData;
    if (slideshowData.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SlideshowScreen(
            folderPath: viewModel.selectedFolderPath ?? '',
            slideshowData: slideshowData,
            startIndex: startIndex,
          ),
        ),
      );
    }
  }
}
