import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';

final profileProvider = FutureProvider<User>((ref) async {
  final authState = ref.watch(authProvider);
  if (!authState.isAuthenticated) {
    throw Exception('User not authenticated');
  }

  final apiService = ref.watch(apiServiceProvider);
  return apiService.getProfile();
});
