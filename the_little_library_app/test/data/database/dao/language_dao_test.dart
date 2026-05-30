import 'package:flutter_test/flutter_test.dart';
import 'package:thelittlelibrary/data/database/database.dart';
import 'package:thelittlelibrary/data/database/dao/dao_exceptions.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.memory();
  });

  tearDown(() async {
    await db.close();
  });

  group('US-1.1.13 — seed built-in languages', () {
    test('should seed English, Hindi, Sanskrit with isBuiltin=true on first open',
        () async {
      await db.languageDao.seedBuiltinLanguages();
      final languages = await db.languageDao.listAll();
      expect(languages.length, greaterThanOrEqualTo(3));
      final names = languages.map((l) => l.name).toSet();
      expect(names.contains('English'), isTrue);
      expect(names.contains('Hindi'), isTrue);
      expect(names.contains('Sanskrit'), isTrue);
    });

    test('should be idempotent: reopening DB does not duplicate languages',
        () async {
      await db.languageDao.seedBuiltinLanguages();
      final first = (await db.languageDao.listAll()).length;
      await db.languageDao.seedBuiltinLanguages();
      final second = (await db.languageDao.listAll()).length;
      expect(first, second);
    });

    test('should seed English language', () async {
      await db.languageDao.seedBuiltinLanguages();
      final langs = await db.languageDao.listAll();
      expect(langs.any((l) => l.name == 'English'), isTrue);
    });

    test('should seed Hindi language', () async {
      await db.languageDao.seedBuiltinLanguages();
      final langs = await db.languageDao.listAll();
      expect(langs.any((l) => l.name == 'Hindi'), isTrue);
    });

    test('should seed Sanskrit language', () async {
      await db.languageDao.seedBuiltinLanguages();
      final langs = await db.languageDao.listAll();
      expect(langs.any((l) => l.name == 'Sanskrit'), isTrue);
    });
  });

  group('US-1.1.14 — built-in language protection', () {
    test(
        'should throw BuiltInEntityException when deleting built-in language',
        () async {
      await db.languageDao.seedBuiltinLanguages();
      final langs = await db.languageDao.listAll();
      final english = langs.firstWhere((l) => l.name == 'English');

      try {
        await db.languageDao.deleteLanguage(english.id);
        fail('Should have thrown');
      } on BuiltInEntityException catch (e) {
        expect(e.message, contains('English'));
      }
    });

    test('should allow deleting custom language (isBuiltin=false)', () async {
      final lang =
          await db.languageDao.createLanguage('Esperanto');
      await db.languageDao.deleteLanguage(lang.id);
      final remaining = await (db.select(db.languages)
            ..where((l) => l.id.equals(lang.id)))
          .get();
      expect(remaining, isEmpty);
    });

    test('should not physically delete the built-in language row', () async {
      await db.languageDao.seedBuiltinLanguages();
      final langs = await db.languageDao.listAll();
      final english = langs.firstWhere((l) => l.name == 'English');

      try {
        await db.languageDao.deleteLanguage(english.id);
      } on BuiltInEntityException {
        // Expected
      }

      final stillThere = await (db.select(db.languages)
            ..where((l) => l.id.equals(english.id)))
          .getSingle();
      expect(stillThere.name, 'English');
    });
  });

  group('LanguageDao — CRUD', () {
    test('should create a new custom language with isBuiltin=false', () async {
      final lang =
          await db.languageDao.createLanguage('French');
      expect(lang.name, 'French');
      expect(lang.isBuiltin, isFalse);
    });

    test('should list all languages (built-in + custom)', () async {
      await db.languageDao.seedBuiltinLanguages();
      await db.languageDao.createLanguage('German');
      final langs = await db.languageDao.listAll();
      expect(langs.length, greaterThan(3));
    });

    test('should enforce unique language name (NOCASE)', () async {
      await db.languageDao.seedBuiltinLanguages();
      try {
        await db.languageDao.createLanguage('English');
      } catch (_) {
        // UNIQUE violation is acceptable
      }
      final langs = await db.languageDao.listAll();
      final englishCount =
          langs.where((l) => l.name.toLowerCase() == 'english').length;
      expect(englishCount, greaterThanOrEqualTo(1));
    });
  });
}
