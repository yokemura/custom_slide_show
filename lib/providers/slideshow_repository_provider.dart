import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../slideshow_repository.dart';

final slideshowRepositoryProvider = Provider<SlideshowRepository>((ref) {
  return SlideshowRepository();
});
