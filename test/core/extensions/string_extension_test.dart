import 'package:flutter_test/flutter_test.dart';
import 'package:lg_hair_refresher/core/extensions/string_extension.dart';

void main() {
  group('StringExtension.softWrapWords', () {
    test('inserts zero-width joiner between non-whitespace characters', () {
      expect('abc'.softWrapWords(), 'a\u200Db\u200Dc');
    });

    test('preserves whitespace boundaries', () {
      expect('a b'.softWrapWords(), 'a b');
      expect(
        'hello world'.softWrapWords(),
        'h\u200De\u200Dl\u200Dl\u200Do w\u200Do\u200Dr\u200Dl\u200Dd',
      );
    });

    test('returns empty string unchanged', () {
      expect(''.softWrapWords(), '');
    });

    test('handles multiline text', () {
      expect(
        '자주 쓰는 리프레시를\n홈에 등록해보세요.'.softWrapWords(),
        '자\u200D주 쓰\u200D는 리\u200D프\u200D레\u200D시\u200D를\n'
        '홈\u200D에 등\u200D록\u200D해\u200D보\u200D세\u200D요\u200D.',
      );
    });

    test('softWrapDescription breaks on sentence endings', () {
      final result = '첫 번째 문장입니다. 두 번째 문장입니다.'.softWrapDescription();

      expect(result, contains('\n'));
      expect(result.split('\n').length, 2);
    });

    test('softWrapDescription breaks after commas', () {
      final result = '모발 컨디션이 양호해요, 가벼운 관리로 충분해요.'.softWrapDescription();

      expect(result.split('\n'), hasLength(2));
      expect(result.split('\n').first.endsWith(','), isTrue);
      expect(result.split('\n').last.endsWith('.'), isTrue);
    });

    test('softWrapDescription keeps single sentence on one logical line', () {
      final result = '한 문장으로만 구성된 설명이에요.'.softWrapDescription();

      expect(result.split('\n'), hasLength(1));
      expect(result, isNot(contains('\n\n')));
    });
  });
}
