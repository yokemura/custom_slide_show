import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'slide_item.dart';

class SlideshowSettingsScreen extends StatefulWidget {
  final String folderPath;
  final List<SlideItem> slideshowData;
  final int currentSlideIndex;

  const SlideshowSettingsScreen({
    super.key,
    required this.folderPath,
    required this.slideshowData,
    required this.currentSlideIndex,
  });

  @override
  State<SlideshowSettingsScreen> createState() => _SlideshowSettingsScreenState();
}

class _SlideshowSettingsScreenState extends State<SlideshowSettingsScreen> {
  late List<SlideItem> _slideshowData;
  late int _selectedSlideIndex;
  bool _hasChanges = false;
  
  // TextEditingControllerを管理
  late TextEditingController _textController;
  late TextEditingController _durationController;
  late TextEditingController _scaleController;
  late TextEditingController _xoffsetController;
  late TextEditingController _yoffsetController;

  @override
  void initState() {
    super.initState();
    _slideshowData = List.from(widget.slideshowData);
    _selectedSlideIndex = widget.currentSlideIndex;
    
    // TextEditingControllerを初期化
    _textController = TextEditingController();
    _durationController = TextEditingController();
    _scaleController = TextEditingController();
    _xoffsetController = TextEditingController();
    _yoffsetController = TextEditingController();
    
    // 初期値を設定
    _updateControllers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('スライドショー設定'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_hasChanges) ...[
            TextButton(
              onPressed: _discardChanges,
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: _saveChanges,
              child: const Text('保存'),
            ),
          ] else ...[
            TextButton(
              onPressed: _returnToSlideshow,
              child: const Text('戻る'),
            ),
          ],
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
                        'スライド一覧 (${_slideshowData.length})',
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
                    itemCount: _slideshowData.length,
                    itemBuilder: (context, index) {
                      final slide = _slideshowData[index];
                      final isSelected = index == _selectedSlideIndex;
                      
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
                          setState(() {
                            _selectedSlideIndex = index;
                          });
                          _updateControllers();
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
            child: _buildSettingsEditor(),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsEditor() {
    if (_slideshowData.isEmpty) {
      return const Center(
        child: Text('スライドがありません'),
      );
    }

    final currentSlide = _slideshowData[_selectedSlideIndex];
    
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
                'スライド ${_selectedSlideIndex + 1} の設定',
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
            onChanged: (value) => _updateSlide(
              currentSlide.copyWith(image: value),
            ),
            enabled: false, // ファイル名は変更不可
          ),
          const SizedBox(height: 16),

          // キャプションテキスト
          _buildTextField(
            label: 'キャプションテキスト',
            controller: _textController,
            onChanged: (value) => _updateSlide(
              currentSlide.copyWith(caption: value.isEmpty ? null : CaptionState.show(value)),
            ),
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
              _updateSlide(currentSlide.copyWith(pan: pan));
            },
          ),
          const SizedBox(height: 16),

          // 表示時間
          _buildNumberField(
            label: '表示時間 (秒)',
            controller: _durationController,
            onChanged: (value) {
              final duration = double.tryParse(value);
              _updateSlide(currentSlide.copyWith(duration: duration));
            },
            hint: '例: 5.0',
          ),
          const SizedBox(height: 16),

          // スケール
          _buildNumberField(
            label: 'スケール',
            controller: _scaleController,
            onChanged: (value) {
              final scale = double.tryParse(value);
              _updateSlide(currentSlide.copyWith(scale: scale));
            },
            hint: '例: 1.2',
          ),
          const SizedBox(height: 16),

          // Xオフセット
          _buildNumberField(
            label: 'Xオフセット',
            controller: _xoffsetController,
            onChanged: (value) {
              final xoffset = double.tryParse(value);
              _updateSlide(currentSlide.copyWith(xoffset: xoffset));
            },
            hint: '例: 0.1',
          ),
          const SizedBox(height: 16),

          // Yオフセット
          _buildNumberField(
            label: 'Yオフセット',
            controller: _yoffsetController,
            onChanged: (value) {
              final yoffset = double.tryParse(value);
              _updateSlide(currentSlide.copyWith(yoffset: yoffset));
            },
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
    required ValueChanged<String> onChanged,
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
          key: ValueKey('${label}_$_selectedSlideIndex'),
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
          ),
        ),
      ],
    );
  }

  Widget _buildNumberField({
    required String label,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
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
          key: ValueKey('${label}_$_selectedSlideIndex'),
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

  void _updateSlide(SlideItem newSlide) {
    setState(() {
      _slideshowData[_selectedSlideIndex] = newSlide;
      _hasChanges = true;
    });
  }

  void _updateControllers() {
    if (_slideshowData.isNotEmpty) {
      final currentSlide = _slideshowData[_selectedSlideIndex];
      if (currentSlide.caption is CaptionShow) {
        _textController.text = (currentSlide.caption as CaptionShow).text;
      } else {
        _textController.text = '';
      }
      _durationController.text = currentSlide.duration?.toString() ?? '';
      _scaleController.text = currentSlide.scale?.toString() ?? '';
      _xoffsetController.text = currentSlide.xoffset?.toString() ?? '';
      _yoffsetController.text = currentSlide.yoffset?.toString() ?? '';
    }
  }

  String _getCaptionDisplayText(CaptionState? caption) {
    return caption?.when(
      show: (text) => '表示: $text',
      hide: () => '消去',
      keep: () => '継続',
    ) ?? '未設定';
  }

  @override
  void dispose() {
    _textController.dispose();
    _durationController.dispose();
    _scaleController.dispose();
    _xoffsetController.dispose();
    _yoffsetController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    try {
      final slideshowPath = path.join(widget.folderPath, 'slideshow.json');
      final slideshowFile = File(slideshowPath);
      
      // JSONに変換して保存
      final jsonString = const JsonEncoder.withIndent('  ').convert(
        _slideshowData.map((item) => item.toFileJson()).toList(),
      );
      await slideshowFile.writeAsString(jsonString);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('設定を保存しました'),
            backgroundColor: Colors.green,
          ),
        );
        
        setState(() {
          _hasChanges = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('保存エラー: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _discardChanges() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('変更を破棄'),
        content: const Text('変更を破棄してスライドショーに戻りますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _returnToSlideshow();
            },
            child: const Text('破棄'),
          ),
        ],
      ),
    );
  }

  void _returnToSlideshow() {
    Navigator.of(context).pop({
      'slideshowData': _slideshowData,
      'currentSlideIndex': _selectedSlideIndex,
    });
  }
} 