import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:threatlensia/core/security/secure_storage_service.dart';
import 'package:threatlensia/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:threatlensia/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:threatlensia/features/dashboard/presentation/providers/dashboard_providers.dart';

class MockDashboardRepository extends Mock implements DashboardRepository {}
class MockSecureStorageService extends Mock implements SecureStorageService {}

void main() {
  late MockDashboardRepository mockRepository;
  late MockSecureStorageService mockStorage;

  setUp(() {
    mockRepository = MockDashboardRepository();
    mockStorage = MockSecureStorageService();

    if (GetIt.instance.isRegistered<SecureStorageService>()) {
      GetIt.instance.unregister<SecureStorageService>();
    }
    GetIt.instance.registerSingleton<SecureStorageService>(mockStorage);
  });

  tearDown(() {
    GetIt.instance.reset();
  });

  ProviderContainer createContainer() {
    final container = ProviderContainer(
      overrides: [
        dashboardRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('dashboardStatsProvider emits data successfully', () async {
    final container = createContainer();

    when(() => mockStorage.getUserId()).thenAnswer((_) async => 'user-123');
    
    final mockStats = const DashboardStats(
      totalAnalyses: 10,
      totalThreats: 20,
      criticalThreats: 5,
      highThreats: 15,
      reportsGenerated: 8,
      recentAnalyses: [],
    );
    
    when(() => mockRepository.getDashboardStats('user-123'))
        .thenAnswer((_) async => mockStats);

    // Initial state is loading
    expect(
      container.read(dashboardStatsProvider),
      const AsyncValue<DashboardStats>.loading(),
    );

    // Wait for the future to complete
    final result = await container.read(dashboardStatsProvider.future);

    expect(result, equals(mockStats));
    verify(() => mockStorage.getUserId()).called(1);
    verify(() => mockRepository.getDashboardStats('user-123')).called(1);
  });

  test('dashboardStatsProvider emits error if user is not authenticated', () async {
    final container = createContainer();

    when(() => mockStorage.getUserId()).thenAnswer((_) async => null);

    // Wait for the future to complete and catch error
    await expectLater(
      container.read(dashboardStatsProvider.future),
      throwsA(isA<Exception>().having((e) => e.toString(), 'toString', contains('User is not authenticated'))),
    );

    verify(() => mockStorage.getUserId()).called(1);
    verifyNever(() => mockRepository.getDashboardStats(any()));
  });

  test('dashboardStatsProvider emits error if repository fails', () async {
    final container = createContainer();

    when(() => mockStorage.getUserId()).thenAnswer((_) async => 'user-123');
    when(() => mockRepository.getDashboardStats('user-123'))
        .thenThrow(Exception('Repository error'));

    await expectLater(
      container.read(dashboardStatsProvider.future),
      throwsA(isA<Exception>().having((e) => e.toString(), 'toString', contains('Repository error'))),
    );
  });
}
