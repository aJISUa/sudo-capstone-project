import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:oncare/core/network/dio_client.dart';
import 'package:oncare/features/account/data/repositories/dio_account_repository.dart';
import 'package:oncare/features/account/domain/entities/user_profile.dart';
import 'package:oncare/features/account/domain/repositories/account_repository.dart';

final accountRepositoryProvider = Provider<AccountRepository>(
  (ref) => DioAccountRepository(ref.watch(dioProvider)),
  name: 'accountRepository',
);

final profileProvider = FutureProvider<UserProfile>((ref) {
  return ref.watch(accountRepositoryProvider).fetchProfile();
}, name: 'profile');
