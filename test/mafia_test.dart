import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uhjiyyah/core/models/player.dart';
import 'package:uhjiyyah/features/mafia_mode/models/mafia_game_state.dart';
import 'package:uhjiyyah/features/mafia_mode/models/mafia_role.dart';
import 'package:uhjiyyah/features/mafia_mode/providers/mafia_game_provider.dart';

void main() {
  group('MafiaGameNotifier Tests', () {
    test('Distributes roles correctly for 6 players', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final testPlayers = List.generate(
        6,
        (i) => Player(id: 'p$i', name: 'Player $i'),
      );

      final notifier = container.read(mafiaGameProvider.notifier);
      notifier.startNewGame(testPlayers);

      final state = container.read(mafiaGameProvider);
      expect(state.players.length, 6);
      expect(state.phase, MafiaPhase.revealRoles);

      final mafia = state.players.where((p) => p.role == MafiaRole.mafia);
      final doctor = state.players.where((p) => p.role == MafiaRole.doctor);
      final detective = state.players.where((p) => p.role == MafiaRole.detective);
      final citizens = state.players.where((p) => p.role == MafiaRole.citizen);

      expect(mafia.length, 1);
      expect(doctor.length, 1);
      expect(detective.length, 1);
      expect(citizens.length, 3);
    });

    test('Turn-by-turn Night Phase passes to all players and doctor protects target', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final testPlayers = List.generate(
        4,
        (i) => Player(id: 'p$i', name: 'Player $i'),
      );

      final notifier = container.read(mafiaGameProvider.notifier);
      notifier.startNewGame(testPlayers);

      // Finish role reveal
      for (int i = 0; i < 4; i++) {
        notifier.toggleRevealCard();
        notifier.nextRoleReveal();
      }

      var state = container.read(mafiaGameProvider);
      expect(state.phase, MafiaPhase.nightTurns);

      // In night turns, every alive player takes the phone
      for (int i = 0; i < 4; i++) {
        state = container.read(mafiaGameProvider);
        expect(state.phase, MafiaPhase.nightTurns);
        final player = state.currentNightPlayer!;
        notifier.revealNightAction();

        if (player.role == MafiaRole.mafia) {
          // Mafia targets p1
          notifier.submitCurrentNightTurn(selectedTargetId: 'p1');
        } else if (player.role == MafiaRole.doctor) {
          // Doctor protects p1
          notifier.submitCurrentNightTurn(selectedTargetId: 'p1');
        } else if (player.role == MafiaRole.detective) {
          // Detective inspects p0
          notifier.submitCurrentNightTurn(selectedTargetId: 'p0');
        } else {
          // Citizen simply finishes turn
          notifier.submitCurrentNightTurn();
        }
      }

      // After all 4 players took their turn -> Dawn Report
      state = container.read(mafiaGameProvider);
      expect(state.phase, MafiaPhase.dawnReport);
      expect(state.wasSavedByDoctor, isTrue);
      expect(state.alivePlayers.length, 4); // All survived
    });
  });
}
