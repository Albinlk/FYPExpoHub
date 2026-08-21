import 'package:flutter_test/flutter_test.dart';
import 'package:fyp_expo_hub/core/state/fypms_state_providers.dart';

void main() {
  group('F14-F16 feature gating', () {
    test('always-enabled form codes are present', () {
      expect(fypmsAlwaysEnabledFormCodes, contains('F1'));
      expect(fypmsAlwaysEnabledFormCodes, contains('F7'));
      expect(fypmsAlwaysEnabledFormCodes, contains('F13'));
    });

    test('special evaluation form codes are F14, F15, F16', () {
      expect(fypmsSpecialEvaluationFormCodes, ['F14', 'F15', 'F16']);
    });

    test('enabled features include special evaluation codes', () {
      final enabled = {
        ...fypmsAlwaysEnabledFormCodes,
        ...fypmsSpecialEvaluationFormCodes,
      };
      expect(enabled, contains('F14'));
      expect(enabled, contains('F16'));
    });

    test('disabled features exclude special evaluation codes', () {
      final disabled = {...fypmsAlwaysEnabledFormCodes};
      expect(disabled, isNot(contains('F14')));
      expect(disabled, isNot(contains('F16')));
    });
  });

  group('FypmsFeatures', () {
    test('defaults special evaluation to false', () {
      const features = FypmsFeatures();
      expect(features.specialEvaluationEnabled, isFalse);
    });

    test('parses from json', () {
      final features = FypmsFeatures.fromJson({'special_evaluation_enabled': true});
      expect(features.specialEvaluationEnabled, isTrue);
    });
  });
}