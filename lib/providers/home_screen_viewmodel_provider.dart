import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../screens/home_screen_viewmodel.dart';
import 'slideshow_repository_provider.dart';

final homeScreenViewModelProvider = ChangeNotifierProvider.autoDispose<HomeScreenViewModel>((ref) {
  final repository = ref.watch(slideshowRepositoryProvider);
  return HomeScreenViewModel(repository);
});
