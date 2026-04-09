import 'package:flutter_test/flutter_test.dart';
import 'package:photoid/services/face_detection_service.dart';

void main() {
  group('ComplianceResult', () {
    test('empty result has all checks failing', () {
      final result = ComplianceResult.empty;
      expect(result.faceDetected, false);
      expect(result.headStraight, false);
      expect(result.properDistance, false);
      expect(result.eyesOpen, false);
      expect(result.neutralExpression, false);
      expect(result.allPassing, false);
      expect(result.passingCount, 0);
    });

    test('allPassing is true when all checks pass', () {
      final result = ComplianceResult(
        faceDetected: true,
        headStraight: true,
        properDistance: true,
        eyesOpen: true,
        neutralExpression: true,
      );
      expect(result.allPassing, true);
      expect(result.passingCount, 5);
    });

    test('allPassing is false with one failing check', () {
      final result = ComplianceResult(
        faceDetected: true,
        headStraight: true,
        properDistance: false,
        eyesOpen: true,
        neutralExpression: true,
      );
      expect(result.allPassing, false);
      expect(result.passingCount, 4);
    });

    test('passingCount is correct with mixed results', () {
      final result = ComplianceResult(
        faceDetected: true,
        headStraight: false,
        properDistance: true,
        eyesOpen: false,
        neutralExpression: true,
      );
      expect(result.passingCount, 3);
    });

    test('distanceHint is null when distance is proper', () {
      final result = ComplianceResult(
        faceDetected: true,
        headStraight: true,
        properDistance: true,
        eyesOpen: true,
        neutralExpression: true,
      );
      expect(result.distanceHint, isNull);
    });

    test('distanceHint can be set', () {
      final result = ComplianceResult(
        faceDetected: true,
        headStraight: true,
        properDistance: false,
        eyesOpen: true,
        neutralExpression: true,
        distanceHint: 'Move closer',
      );
      expect(result.distanceHint, 'Move closer');
    });

    test('no face detected means nothing else passes allPassing', () {
      final result = ComplianceResult(
        faceDetected: false,
        headStraight: true,
        properDistance: true,
        eyesOpen: true,
        neutralExpression: true,
      );
      // allPassing requires all 5, including faceDetected
      expect(result.allPassing, false);
      expect(result.passingCount, 4);
    });
  });
}
