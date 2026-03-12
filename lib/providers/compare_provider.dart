import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class CompareState {
  final List<int> ids;

  CompareState({this.ids = const []});

  CompareState copyWith({List<int>? ids}) {
    return CompareState(ids: ids ?? this.ids);
  }
}

class CompareNotifier extends Notifier<CompareState> {
  @override
  CompareState build() {
    return CompareState();
  }

  void addId(int id) {
    if (state.ids.length < 3 && !state.ids.contains(id)) {
      state = state.copyWith(ids: [...state.ids, id]);
    }
  }

  void removeId(int id) {
    state = state.copyWith(
      ids: state.ids.where((element) => element != id).toList(),
    );
  }

  void clear() {
    state = CompareState();
  }
}

final compareIdsProvider = NotifierProvider<CompareNotifier, CompareState>(() {
  return CompareNotifier();
});

final compareDataProvider = FutureProvider<CompareResponse>((ref) async {
  final ids = ref.watch(compareIdsProvider).ids;
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getCompareData(ids);
});
