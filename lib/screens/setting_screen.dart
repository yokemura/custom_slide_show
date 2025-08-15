import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../slide_item.dart';
import '../constants/slideshow_constants.dart';
import 'setting_screen_viewmodel.dart';

class SettingScreen extends HookConsumerWidget {
  final int currentSlideIndex;

  const SettingScreen({
    super.key,
    required this.currentSlideIndex,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Providerからnotifierを取得
    final params = SlideshowSettingsParams(
      currentSlideIndex: currentSlideIndex,
    );
    final notifier = ref.watch(slideshowSettingsProvider(params));

    // 共通のエラー表示関数
    void showValidationErrorSnackBar(String message) {
      final displayMessage = '現在のスライドにエラーがあります: $message';
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(displayMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }

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
      // バリデーションエラーチェック
      if (notifier.validationError != null) {
        showValidationErrorSnackBar(notifier.validationError!);
        return; // 操作をブロック
      }
      
      try {
        await notifier.saveToRepository();
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
                          // バリデーションエラーチェック
                          if (notifier.validationError != null) {
                            showValidationErrorSnackBar(notifier.validationError!);
                            return; // 操作をブロック
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

          // バリデーションエラー表示
          if (notifier.validationError != null)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                border: Border.all(color: Colors.red.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.error, color: Colors.red.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      notifier.validationError!,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ),
                ],
              ),
            ),

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
            onChanged: (value) => notifier.updateSlideData(
              duration: notifier.parseNumericValue(value, SlideshowConstants.invalidDuration),
            ),
            hint: '例: 5.0',
          ),
          const SizedBox(height: 16),

          // スケール
          _buildNumberField(
            label: 'スケール',
            controller: scaleController,
            onChanged: (value) => notifier.updateSlideData(
              scale: notifier.parseNumericValue(value, SlideshowConstants.invalidScale),
            ),
            hint: '例: 1.2',
          ),
          const SizedBox(height: 16),

          // Xオフセット
          _buildNumberField(
            label: 'Xオフセット',
            controller: xoffsetController,
            onChanged: (value) => notifier.updateSlideData(
              xoffset: notifier.parseNumericValue(value, SlideshowConstants.invalidOffset),
            ),
            hint: '例: 0.1',
          ),
          const SizedBox(height: 16),

          // Yオフセット
          _buildNumberField(
            label: 'Yオフセット',
            controller: yoffsetController,
            onChanged: (value) => notifier.updateSlideData(
              yoffset: notifier.parseNumericValue(value, SlideshowConstants.invalidOffset),
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
          groupValue: notifier.currentSlide?.caption is CaptionShow ? notifier.currentSlide?.caption : null,
          onChanged: (value) {
            notifier.updateSlideData(caption: value);
          },
        ),
        RadioListTile<CaptionState>(
          title: const Text('キャプションを消去'),
          value: const CaptionState.hide(),
          groupValue: notifier.currentSlide?.caption is CaptionHide ? notifier.currentSlide?.caption : null,
          onChanged: (value) {
            notifier.updateSlideData(caption: value);
          },
        ),
        RadioListTile<CaptionState>(
          title: const Text('キャプションを継続'),
          value: const CaptionState.keep(),
          groupValue: notifier.currentSlide?.caption is CaptionKeep ? notifier.currentSlide?.caption : null,
          onChanged: (value) {
            notifier.updateSlideData(caption: value);
          },
        ),
        
        // キャプション表示が選択されている場合のみテキストフィールドを表示
        if (notifier.currentSlide?.caption is CaptionShow)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextField(
              controller: textController,
              onChanged: (value) {
                final newState = CaptionState.show(value);
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
          if (slide.duration != null) Text('表示時間: ${slide.duration == SlideshowConstants.invalidDuration ? "無効な値" : slide.duration}秒'),
          if (slide.scale != null) Text('スケール: ${slide.scale == SlideshowConstants.invalidScale ? "無効な値" : slide.scale}'),
          if (slide.xoffset != null) Text('Xオフセット: ${slide.xoffset == SlideshowConstants.invalidOffset ? "無効な値" : slide.xoffset}'),
          if (slide.yoffset != null) Text('Yオフセット: ${slide.yoffset == SlideshowConstants.invalidOffset ? "無効な値" : slide.yoffset}'),
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
