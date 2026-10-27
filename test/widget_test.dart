import 'package:baggage_track_shell/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('muestra el catalogo inicial', (tester) async {
    await tester.pumpWidget(const BaggageTrackApp());

    expect(find.text('BaggageTrack'), findsOneWidget);
    expect(find.text('BG-1001'), findsOneWidget);
    expect(find.text('Sin eventos'), findsWidgets);
  });
}
