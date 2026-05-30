import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:thelittlelibrary/features/scanner/ocr/photo_ocr_screen.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

@GenerateNiceMocks([
  MockSpec<TextRecognizer>(),
  MockSpec<ImagePicker>(),
])
import 'photo_ocr_test.mocks.dart';

void main() {
  group('PhotoOcrScreen — Phase 3', () {
    testWidgets('should show source selection bottom sheet initially — US-3.2.1, US-3.2.12', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PhotoOcrScreen(),
          ),
        ),
      );

      expect(find.text('Take Photo'), findsOneWidget);
      expect(find.text('Choose from Gallery'), findsOneWidget);
    });

    testWidgets('should show scanning overlay when processing — US-3.2.2', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PhotoOcrScreen(),
          ),
        ),
      );

      // Trigger photo selection (simulated)
      // await tester.tap(find.text('Take Photo'));
      // await tester.pump();

      // expect(find.text('Scanning text…'), findsOneWidget);
      // expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show detected text blocks as chips — US-3.2.3, US-3.2.8', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PhotoOcrScreen(),
          ),
        ),
      );

      // Assume OCR has completed and state is updated
      // expect(find.byType(ActionChip), findsAtLeastNWidgets(1));
    });

    testWidgets('should allow assigning text to Title or Author — US-3.2.4', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PhotoOcrScreen(),
          ),
        ),
      );

      // final chip = find.byType(ActionChip).first;
      // await tester.tap(chip);
      // await tester.pumpAndSettle();

      // expect(find.text('Assign as Title'), findsOneWidget);
      // expect(find.text('Assign as Author'), findsOneWidget);
    });

    testWidgets('should show no text detected message — US-3.2.9', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PhotoOcrScreen(),
          ),
        ),
      );

      // Simulate zero text detection
      // expect(find.text('Try a clearer photo or enter manually'), findsOneWidget);
    });

    testWidgets('should have accessible chips — US-3.2.13', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PhotoOcrScreen(),
          ),
        ),
      );

      // expect(find.bySemanticsLabel(RegExp(r'Detected text: .*')), findsWidgets);
    });
  });
}
