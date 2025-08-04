import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'slide_item.dart';

// Stateクラス定義
class SlideshowSettingsState {
  final List<SlideItem> slideshowData;
  final int currentSlideIndex;
  
  SlideshowSettingsState({
    required this.slideshowData,
    required this.currentSlideIndex,
  });
  
  SlideshowSettingsState copyWith({
    List<SlideItem>? slideshowData,
    int? currentSlideIndex,
  }) {
    return SlideshowSettingsState(
      slideshowData: slideshowData ?? this.slideshowData,
      currentSlideIndex: currentSlideIndex ?? this.currentSlideIndex,
    );
  }
}

// Provider定義
final slideshowSettingsProvider = StateProvider<SlideshowSettingsState>((ref) {
  return SlideshowSettingsState(
    slideshowData: [],
    currentSlideIndex: 0,
  );
});

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
    // TextEditingControllerを管理
    final textController = useTextEditingController();
    final durationController = useTextEditingController();
    final scaleController = useTextEditingController();
    final xoffsetController = useTextEditingController();
    final yoffsetController = useTextEditingController();

    // Providerの初期化とフィールド初期値設定（初回のみ）
    useEffect(() {
      Future.microtask(() {
        ref.read(slideshowSettingsProvider.notifier).state = SlideshowSettingsState(
          slideshowData: slideshowData,
          currentSlideIndex: currentSlideIndex,
        );
        
        // 初期値設定もここで行う
        if (slideshowData.isNotEmpty) {
          final initialSlide = slideshowData[currentSlideIndex];
          textController.text = initialSlide.text ?? '';
          durationController.text = initialSlide.duration?.toString() ?? '';
          scaleController.text = initialSlide.scale?.toString() ?? '';
          xoffsetController.text = initialSlide.xoffset?.toString() ?? '';
          yoffsetController.text = initialSlide.yoffset?.toString() ?? '';
        }
      });
      return null;
    }, []);

    final state = ref.watch(slideshowSettingsProvider);

    // 現在のスライドデータを取得
    final currentSlide = state.slideshowData.isNotEmpty 
        ? state.slideshowData[state.currentSlideIndex] 
        : null;

    // 入力フィールドの値を更新（スライド切り替え時のみ）
    useEffect(() {
      if (currentSlide != null) {
        textController.text = currentSlide.text ?? '';
        durationController.text = currentSlide.duration?.toString() ?? '';
        scaleController.text = currentSlide.scale?.toString() ?? '';
        xoffsetController.text = currentSlide.xoffset?.toString() ?? '';
        yoffsetController.text = currentSlide.yoffset?.toString() ?? '';
      }
      return null;
    }, [state.currentSlideIndex]);

    // スライドデータ更新関数
    void updateSlideData({
      String? text,
      double? duration,
      double? scale,
      double? xoffset,
      double? yoffset,
      PanDirection? pan,
    }) {
      if (currentSlide == null) return;
      
      final updatedSlide = currentSlide.copyWith(
        text: text != null ? (text.isEmpty ? null : text) : currentSlide.text,
        duration: duration,
        scale: scale,
        xoffset: xoffset,
        yoffset: yoffset,
        pan: pan,
      );

      final newSlideshowData = List<SlideItem>.from(state.slideshowData);
      newSlideshowData[state.currentSlideIndex] = updatedSlide;
      
      ref.read(slideshowSettingsProvider.notifier).state = 
        state.copyWith(slideshowData: newSlideshowData);
    }

    // スライド選択時の処理
    void selectSlide(int index) {
      // 現在の入力内容を確定
      updateSlideData(
        text: textController.text,
        duration: double.tryParse(durationController.text),
        scale: double.tryParse(scaleController.text),
        xoffset: double.tryParse(xoffsetController.text),
        yoffset: double.tryParse(yoffsetController.text),
      );
      
      // スライドを切り替え
      ref.read(slideshowSettingsProvider.notifier).state = 
        state.copyWith(currentSlideIndex: index);
    }

    // 戻るボタンの処理
    void onBackPressed() {
      // 現在の入力内容を確定
      updateSlideData(
        text: textController.text,
        duration: double.tryParse(durationController.text),
        scale: double.tryParse(scaleController.text),
        xoffset: double.tryParse(xoffsetController.text),
        yoffset: double.tryParse(yoffsetController.text),
      );
      
      // データを返してpop
      final currentState = ref.read(slideshowSettingsProvider);
      Navigator.of(context).pop({
        'slideshowData': currentState.slideshowData,
        'currentSlideIndex': currentState.currentSlideIndex,
      });
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
                        'スライド一覧 (${state.slideshowData.length})',
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
                    itemCount: state.slideshowData.length,
                    itemBuilder: (context, index) {
                      final slide = state.slideshowData[index];
                      final isSelected = index == state.currentSlideIndex;
                      
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
                        onTap: () => selectSlide(index),
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
              updateSlideData,
              state,
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
    Function({
      String? text,
      double? duration,
      double? scale,
      double? xoffset,
      double? yoffset,
      PanDirection? pan,
    }) updateSlideData,
    SlideshowSettingsState state,
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
                'スライド ${state.currentSlideIndex + 1} の設定',
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

          // キャプションテキスト
          _buildTextField(
            label: 'キャプションテキスト',
            controller: textController,
            onSubmitted: (value) => updateSlideData(text: value),
            onEditingComplete: () => updateSlideData(text: textController.text),
            maxLines: 3,
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
              updateSlideData(pan: pan);
            },
          ),
          const SizedBox(height: 16),

          // 表示時間
          _buildNumberField(
            label: '表示時間 (秒)',
            controller: durationController,
            onSubmitted: (value) => updateSlideData(duration: double.tryParse(value)),
            onEditingComplete: () => updateSlideData(duration: double.tryParse(durationController.text)),
            hint: '例: 5.0',
          ),
          const SizedBox(height: 16),

          // スケール
          _buildNumberField(
            label: 'スケール',
            controller: scaleController,
            onSubmitted: (value) => updateSlideData(scale: double.tryParse(value)),
            onEditingComplete: () => updateSlideData(scale: double.tryParse(scaleController.text)),
            hint: '例: 1.2',
          ),
          const SizedBox(height: 16),

          // Xオフセット
          _buildNumberField(
            label: 'Xオフセット',
            controller: xoffsetController,
            onSubmitted: (value) => updateSlideData(xoffset: double.tryParse(value)),
            onEditingComplete: () => updateSlideData(xoffset: double.tryParse(xoffsetController.text)),
            hint: '例: 0.1',
          ),
          const SizedBox(height: 16),

          // Yオフセット
          _buildNumberField(
            label: 'Yオフセット',
            controller: yoffsetController,
            onSubmitted: (value) => updateSlideData(yoffset: double.tryParse(value)),
            onEditingComplete: () => updateSlideData(yoffset: double.tryParse(yoffsetController.text)),
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
    Function(String)? onSubmitted,
    VoidCallback? onEditingComplete,
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
          onSubmitted: onSubmitted,
          onEditingComplete: onEditingComplete,
          enabled: enabled,
          maxLines: maxLines,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNumberField({
    required String label,
    required TextEditingController controller,
    Function(String)? onSubmitted,
    VoidCallback? onEditingComplete,
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
          onSubmitted: onSubmitted,
          onEditingComplete: onEditingComplete,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: hint,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
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
          if (slide.text != null) Text('キャプション: ${slide.text}'),
          if (slide.pan != null) Text('パン: ${slide.pan!.name}'),
          if (slide.duration != null) Text('表示時間: ${slide.duration}秒'),
          if (slide.scale != null) Text('スケール: ${slide.scale}'),
          if (slide.xoffset != null) Text('Xオフセット: ${slide.xoffset}'),
          if (slide.yoffset != null) Text('Yオフセット: ${slide.yoffset}'),
        ],
      ),
    );
  }
} 