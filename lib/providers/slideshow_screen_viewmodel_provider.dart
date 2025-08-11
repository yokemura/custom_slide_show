import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../screens/slideshow_screen_viewmodel.dart';
import 'slideshow_repository_provider.dart';

final slideshowScreenViewModelProvider = ChangeNotifierProvider.autoDispose.family<SlideshowScreenViewModel, String>((ref, folderPath) {
  final repository = ref.watch(slideshowRepositoryProvider);
  return SlideshowScreenViewModel(repository);
});
