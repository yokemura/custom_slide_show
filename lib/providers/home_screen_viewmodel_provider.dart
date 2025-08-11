import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../screens/home_screen_viewmodel.dart';

final homeScreenViewModelProvider = ChangeNotifierProvider.autoDispose<HomeScreenViewModel>((ref) {
  return HomeScreenViewModel();
});
