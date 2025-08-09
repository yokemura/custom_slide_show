import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'slide_item.dart';

// Provider定義
final slideshowSettingsProvider = ChangeNotifierProvider.autoDispose.family<SlideshowSettingsNotifier, SlideshowSettingsParams>((ref, params) {
  return SlideshowSettingsNotifier(
    slideshowData: params.slideshowData,
    currentSlideIndex: params.currentSlideIndex,
    folderPath: params.folderPath,
  );
});

// パラメータクラス
class SlideshowSettingsParams {
  final List<SlideItem> slideshowData;
  final int currentSlideIndex;
  final String folderPath;
  
  SlideshowSettingsParams({
    required this.slideshowData,
    required this.currentSlideIndex,
    required this.folderPath,
  });
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SlideshowSettingsParams &&
          runtimeType == other.runtimeType &&
          slideshowData == other.slideshowData &&
          currentSlideIndex == other.currentSlideIndex &&
          folderPath == other.folderPath;

  @override
  int get hashCode => Object.hash(slideshowData, currentSlideIndex, folderPath);
}

// ChangeNotifierクラス定義
class SlideshowSettingsNotifier extends ChangeNotifier {
  List<SlideItem> _slideshowData;
  int _currentSlideIndex;
  final String folderPath;
  
  SlideshowSettingsNotifier({
    required List<SlideItem> slideshowData,
    required int currentSlideIndex,
    required this.folderPath,
  }) : _slideshowData = slideshowData,
       _currentSlideIndex = currentSlideIndex;
  
  List<SlideItem> get slideshowData => _slideshowData;
  int get currentSlideIndex => _currentSlideIndex;
  
  // 現在のスライドを取得
  SlideItem? get currentSlide => 
      _slideshowData.isNotEmpty ? _slideshowData[_currentSlideIndex] : null;
  
  // スライドデータを更新（notifyListenersなし）
  void updateSlideData({
    CaptionState? caption,
    double? duration,
    double? scale,
    double? xoffset,
    double? yoffset,
    PanDirection? pan,
  }) {
    if (currentSlide == null) return;
    
    final updatedSlide = currentSlide!.copyWith(
      caption: caption,
      duration: duration,
      scale: scale,
      xoffset: xoffset,
      yoffset: yoffset,
      pan: pan,
    );

    _slideshowData = List<SlideItem>.from(_slideshowData);
    _slideshowData[_currentSlideIndex] = updatedSlide;
  }
  
  // 現在の入力値のバリデーション
  String? validateCurrentInputs({
    required String durationText,
    required String scaleText,
    required String xoffsetText,
    required String yoffsetText,
  }) {
    final List<String> invalidFields = [];
    
    // 空文字列は有効（未設定を意味する）
    if (durationText.isNotEmpty && double.tryParse(durationText) == null) {
      invalidFields.add('表示時間');
    }
    if (scaleText.isNotEmpty && double.tryParse(scaleText) == null) {
      invalidFields.add('スケール');
    }
    if (xoffsetText.isNotEmpty && double.tryParse(xoffsetText) == null) {
      invalidFields.add('Xオフセット');
    }
    if (yoffsetText.isNotEmpty && double.tryParse(yoffsetText) == null) {
      invalidFields.add('Yオフセット');
    }
    
    if (invalidFields.isEmpty) {
      return null;
    }
    
    return '${invalidFields.join(', ')}に無効な値が入力されています';
  }
  
  // スライドを切り替え（notifyListenersあり）
  void selectSlide(int index) {
    if (index >= 0 && index < _slideshowData.length) {
      _currentSlideIndex = index;
      notifyListeners();
    }
  }
  
  // JSONファイルに保存
  Future<void> saveToJsonFile() async {
    try {
      final slideshowPath = path.join(folderPath, 'slideshow.json');
      final slideshowFile = File(slideshowPath);
      
      // Convert to JSON with pretty formatting
      final jsonString = const JsonEncoder.withIndent('  ').convert(
          _slideshowData.map((item) => item.toFileJson()).toList());
      await slideshowFile.writeAsString(jsonString);
    } catch (e) {
      throw Exception('JSONファイルの保存に失敗しました: $e');
    }
  }
}

class SlideshowSettingsScreenHooks extends HookConsumerWidget {
  final String folderPath;
  final List<SlideItem> slideshowData;
  final int currentSlideIndex;

  const SlideshowSettingsScreenHooks({
    super.key,
    required this.folderPath,
    required this.slideshowData,
    required this.currentSlideIndex,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Providerからnotifierを取得
    final params = SlideshowSettingsParams(
      slideshowData: slideshowData,
      currentSlideIndex: currentSlideIndex,
      folderPath: folderPath,
    );
    final notifier = ref.watch(slideshowSettingsProvider(params));

    // TextEditingControllerを管理
    final textController = useTextEditingController();
    final durationController = useTextEditingController();
    final scaleController = useTextEditingController();
    final xoffsetController = useTextEditingController();
    final yoffsetController = useTextEditingController();

    // 初期値設定とスライド切り替え時のフィールド更新
    useEffect(() {
      if (notifier.currentSlide != null) {
        final slide = notifier.currentSlide!;
        if (slide.caption is CaptionShow) {
          textController.text = (slide.caption as CaptionShow).text;
        } else {
          textController.text = '';
        }
        durationController.text = slide.duration?.toString() ?? '';
        scaleController.text = slide.scale?.toString() ?? '';
        xoffsetController.text = slide.xoffset?.toString() ?? '';
        yoffsetController.text = slide.yoffset?.toString() ?? '';
      }
      return null;
    }, [notifier.currentSlideIndex]);

    // 現在のスライドデータを取得
    final currentSlide = notifier.currentSlide;

    // 戻るボタンの処理
    void onBackPressed() async {
      // 現在の入力値をバリデーション
      final validationError = notifier.validateCurrentInputs(
        durationText: durationController.text,
        scaleText: scaleController.text,
        xoffsetText: xoffsetController.text,
        yoffsetText: yoffsetController.text,
      );
      if (validationError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(validationError),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      try {
        await notifier.saveToJsonFile();
        if (context.mounted) {
          Navigator.of(context).pop({
            'slideshowData': notifier.slideshowData,
            'currentSlideIndex': notifier.currentSlideIndex,
          });
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('保存に失敗しました: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }

    // キャンセルボタンの処理
    void onCancelPressed() {
      Navigator.of(context).pop(null);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('スライドショー設定'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBackPressed,
        ),
        actions: [
          TextButton(
            onPressed: onCancelPressed,
            child: const Text('キャンセル'),
          ),
        ],
      ),
      body: Row(
        children: [
          // 左側：スライド一覧
          Container(
            width: 300,
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.list, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        'スライド一覧 (${notifier.slideshowData.length})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: notifier.slideshowData.length,
                    itemBuilder: (context, index) {
                      final slide = notifier.slideshowData[index];
                      final isSelected = index == notifier.currentSlideIndex;
                      
                      return ListTile(
                        selected: isSelected,
                        leading: const Icon(Icons.image, color: Colors.blue),
                        title: Text(
                          slide.image,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text('スライド ${index + 1}'),
                        trailing: isSelected 
                          ? const Icon(Icons.check, color: Colors.blue)
                          : null,
                        onTap: () {
                          // 現在の入力値をバリデーション
                          final validationError = notifier.validateCurrentInputs(
                            durationText: durationController.text,
                            scaleText: scaleController.text,
                            xoffsetText: xoffsetController.text,
                            yoffsetText: yoffsetController.text,
                          );
                          if (validationError != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(validationError),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          notifier.selectSlide(index);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // 右側：設定編集エリア
          Expanded(
            child: _buildSettingsEditor(
              currentSlide,
              textController,
              durationController,
              scaleController,
              xoffsetController,
              yoffsetController,
              notifier,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsEditor(
    SlideItem? currentSlide,
    TextEditingController textController,
    TextEditingController durationController,
    TextEditingController scaleController,
    TextEditingController xoffsetController,
    TextEditingController yoffsetController,
    SlideshowSettingsNotifier notifier,
  ) {
    if (currentSlide == null) {
      return const Center(
        child: Text('スライドがありません'),
      );
    }
    
    // 数値フィールドの更新
    void updateNumericField(String value, Function(double?) updateFunction) {
      final doubleValue = double.tryParse(value);
      updateFunction(doubleValue);
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ヘッダー
          Row(
            children: [
              const Icon(Icons.edit, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                'スライド ${notifier.currentSlideIndex + 1} の設定',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'ファイル: ${currentSlide.image}',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 32),

          // 画像ファイル名
          _buildTextField(
            label: '画像ファイル名',
            controller: TextEditingController(text: currentSlide.image),
            enabled: false, // ファイル名は変更不可
          ),
          const SizedBox(height: 16),

          // キャプション設定
          _buildCaptionSection(
            currentSlide,
            textController,
            notifier,
          ),
          const SizedBox(height: 16),

          // パン方向
          _buildDropdownField(
            label: 'パン方向',
            value: currentSlide.pan?.name,
            items: const [
              DropdownMenuItem(value: null, child: Text('なし')),
              DropdownMenuItem(value: 'up', child: Text('上')),
              DropdownMenuItem(value: 'down', child: Text('下')),
              DropdownMenuItem(value: 'left', child: Text('左')),
              DropdownMenuItem(value: 'right', child: Text('右')),
            ],
            onChanged: (value) {
              PanDirection? pan;
              if (value != null) {
                switch (value) {
                  case 'up':
                    pan = PanDirection.up;
                    break;
                  case 'down':
                    pan = PanDirection.down;
                    break;
                  case 'left':
                    pan = PanDirection.left;
                    break;
                  case 'right':
                    pan = PanDirection.right;
                    break;
                }
              }
              notifier.updateSlideData(pan: pan);
            },
          ),
          const SizedBox(height: 16),

          // 表示時間
          _buildNumberField(
            label: '表示時間 (秒)',
            controller: durationController,
            onChanged: (value) => updateNumericField(
              value,
              (doubleValue) => notifier.updateSlideData(duration: doubleValue),
            ),
            hint: '例: 5.0',
          ),
          const SizedBox(height: 16),

          // スケール
          _buildNumberField(
            label: 'スケール',
            controller: scaleController,
            onChanged: (value) => updateNumericField(
              value,
              (doubleValue) => notifier.updateSlideData(scale: doubleValue),
            ),
            hint: '例: 1.2',
          ),
          const SizedBox(height: 16),

          // Xオフセット
          _buildNumberField(
            label: 'Xオフセット',
            controller: xoffsetController,
            onChanged: (value) => updateNumericField(
              value,
              (doubleValue) => notifier.updateSlideData(xoffset: doubleValue),
            ),
            hint: '例: 0.1',
          ),
          const SizedBox(height: 16),

          // Yオフセット
          _buildNumberField(
            label: 'Yオフセット',
            controller: yoffsetController,
            onChanged: (value) => updateNumericField(
              value,
              (doubleValue) => notifier.updateSlideData(yoffset: doubleValue),
            ),
            hint: '例: -0.05',
          ),
          const SizedBox(height: 32),

          // プレビュー
          _buildPreviewSection(currentSlide),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    Function(String)? onChanged,
    bool enabled = true,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          onChanged: onChanged,
          enabled: enabled,
          maxLines: maxLines,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            hintStyle: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNumberField({
    required String label,
    required TextEditingController controller,
    Function(String)? onChanged,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: hint,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            hintStyle: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<DropdownMenuItem<String?>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String?>(
          value: value,
          items: items,
          onChanged: onChanged,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            hintStyle: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCaptionSection(
    SlideItem? currentSlide,
    TextEditingController textController,
    SlideshowSettingsNotifier notifier,
  ) {
    // キャプション状態の管理
    final captionState = useState<CaptionState?>(currentSlide?.caption ?? const CaptionState.keep());
    
    // スライドが切り替わった時にcaptionStateを更新
    useEffect(() {
      captionState.value = currentSlide?.caption ?? const CaptionState.keep();
      return null;
    }, [currentSlide?.caption]);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'キャプション設定',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        
        // ラジオボタンで3つの状態を選択
        RadioListTile<CaptionState>(
          title: const Text('キャプションを表示'),
          value: CaptionState.show(textController.text),
          groupValue: captionState.value is CaptionShow ? captionState.value : null,
          onChanged: (value) {
            captionState.value = value;
            notifier.updateSlideData(caption: value);
          },
        ),
        RadioListTile<CaptionState>(
          title: const Text('キャプションを消去'),
          value: const CaptionState.hide(),
          groupValue: captionState.value is CaptionHide ? captionState.value : null,
          onChanged: (value) {
            captionState.value = value;
            notifier.updateSlideData(caption: value);
          },
        ),
        RadioListTile<CaptionState>(
          title: const Text('キャプションを継続'),
          value: const CaptionState.keep(),
          groupValue: captionState.value is CaptionKeep ? captionState.value : null,
          onChanged: (value) {
            captionState.value = value;
            notifier.updateSlideData(caption: value);
          },
        ),
        
        // キャプション表示が選択されている場合のみテキストフィールドを表示
        if (captionState.value is CaptionShow)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextField(
              controller: textController,
              onChanged: (value) {
                final newState = CaptionState.show(value);
                captionState.value = newState;
                notifier.updateSlideData(caption: newState);
              },
              decoration: const InputDecoration(
                labelText: 'キャプション',
                hintText: 'キャプションを入力してください',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ),
      ],
    );
  }

  Widget _buildPreviewSection(SlideItem slide) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '設定プレビュー',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text('画像: ${slide.image}'),
          Text('キャプション: ${_getCaptionDisplayText(slide.caption)}'),
          if (slide.pan != null) Text('パン: ${slide.pan!.name}'),
          if (slide.duration != null) Text('表示時間: ${slide.duration}秒'),
          if (slide.scale != null) Text('スケール: ${slide.scale}'),
          if (slide.xoffset != null) Text('Xオフセット: ${slide.xoffset}'),
          if (slide.yoffset != null) Text('Yオフセット: ${slide.yoffset}'),
        ],
      ),
    );
  }

  String _getCaptionDisplayText(CaptionState? caption) {
    return caption?.when(
      show: (text) => '表示: $text',
      hide: () => '消去',
      keep: () => '継続',
    ) ?? '未設定';
  }
} 