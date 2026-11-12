import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uhjiyyah/core/providers/players_provider.dart';
import 'package:uhjiyyah/main.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  test('GlobalPlayerListNotifier adds and removes players correctly', () {
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
    );
    addTearDown(container.dispose);

    // Initial state is empty
    expect(container.read(playersProvider), isEmpty);

    // Add player
    container.read(playersProvider.notifier).addPlayer('سارة');
    expect(container.read(playersProvider).length, 1);
    expect(container.read(playersProvider).first.name, 'سارة');

    // Add another player
    container.read(playersProvider.notifier).addPlayer('أحمد');
    expect(container.read(playersProvider).length, 2);

    // Remove first player
    final firstId = container.read(playersProvider).first.id;
    container.read(playersProvider.notifier).removePlayer(firstId);
    expect(container.read(playersProvider).length, 1);
    expect(container.read(playersProvider).first.name, 'أحمد');

    // Clear all
    container.read(playersProvider.notifier).clearAll();
    expect(container.read(playersProvider), isEmpty);
  });

  test('GlobalPlayerListNotifier persists and reloads players from storage', () async {
    final container1 = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
    );
    container1.read(playersProvider.notifier).addPlayer('يوسف');
    container1.read(playersProvider.notifier).addPlayer('مريم');
    container1.dispose();

    // Create a second container using the same SharedPreferences instance (simulating restart)
    final container2 = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
    );
    addTearDown(container2.dispose);

    final reloaded = container2.read(playersProvider);
    expect(reloaded.length, 2);
    expect(reloaded[0].name, 'يوسف');
    expect(reloaded[1].name, 'مريم');
  });

  testWidgets('UhjiyyahApp renders initial players setup screen', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const UhjiyyahApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('إعداد طاقم اللعبة '), findsOneWidget);
    expect(find.text('قائمة اللاعبين'), findsOneWidget);
  });
}
