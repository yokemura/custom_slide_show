enum PanDirection {
  up,
  down,
  left,
  right,
}

class SlideItem {
  final String image;
  final String? text;
  final PanDirection? pan;
  final double? duration;
  final double? scale;
  final double? xoffset;
  final double? yoffset;

  const SlideItem({
    required this.image,
    this.text,
    this.pan,
    this.duration,
    this.scale,
    this.xoffset,
    this.yoffset,
  });

  factory SlideItem.fromJson(Map<String, dynamic> json) {
    return SlideItem(
      image: json['image'] as String,
      text: json['text'] as String?,
      pan: json['pan'] != null ? _parsePanDirection(json['pan'] as String) : null,
      duration: json['duration'] != null ? (json['duration'] as num).toDouble() : null,
      scale: json['scale'] != null ? (json['scale'] as num).toDouble() : null,
      xoffset: json['xoffset'] != null ? (json['xoffset'] as num).toDouble() : null,
      yoffset: json['yoffset'] != null ? (json['yoffset'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'image': image,
      if (text != null) 'text': text,
      if (pan != null) 'pan': pan!.name,
      if (duration != null) 'duration': duration,
      if (scale != null) 'scale': scale,
      if (xoffset != null) 'xoffset': xoffset,
      if (yoffset != null) 'yoffset': yoffset,
    };
  }

  static PanDirection _parsePanDirection(String value) {
    switch (value.toLowerCase()) {
      case 'up':
        return PanDirection.up;
      case 'down':
        return PanDirection.down;
      case 'left':
        return PanDirection.left;
      case 'right':
        return PanDirection.right;
      default:
        throw ArgumentError('Invalid pan direction: $value');
    }
  }

  SlideItem copyWith({
    String? image,
    String? text,
    PanDirection? pan,
    double? duration,
    double? scale,
    double? xoffset,
    double? yoffset,
  }) {
    return SlideItem(
      image: image ?? this.image,
      text: text ?? this.text,
      pan: pan ?? this.pan,
      duration: duration ?? this.duration,
      scale: scale ?? this.scale,
      xoffset: xoffset ?? this.xoffset,
      yoffset: yoffset ?? this.yoffset,
    );
  }

  @override
  String toString() {
    return 'SlideItem(image: $image, text: $text, pan: $pan, duration: $duration, scale: $scale, xoffset: $xoffset, yoffset: $yoffset)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SlideItem &&
        other.image == image &&
        other.text == text &&
        other.pan == pan &&
        other.duration == duration &&
        other.scale == scale &&
        other.xoffset == xoffset &&
        other.yoffset == yoffset;
  }

  @override
  int get hashCode {
    return Object.hash(image, text, pan, duration, scale, xoffset, yoffset);
  }
} 