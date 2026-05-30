// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $BooksTable extends Books with TableInfo<$BooksTable, Book> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BooksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 36, maxTextLength: 36),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title =
      GeneratedColumn<String>('title', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
            minTextLength: 1,
          ),
          type: DriftSqlType.string,
          requiredDuringInsert: true,
          $customConstraints: 'COLLATE NOCASE NOT NULL');
  static const VerificationMeta _isbnMeta = const VerificationMeta('isbn');
  @override
  late final GeneratedColumn<String> isbn = GeneratedColumn<String>(
      'isbn', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _languageIdMeta =
      const VerificationMeta('languageId');
  @override
  late final GeneratedColumn<String> languageId = GeneratedColumn<String>(
      'language_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: 'REFERENCES language(id)');
  static const VerificationMeta _coverImagePathMeta =
      const VerificationMeta('coverImagePath');
  @override
  late final GeneratedColumn<String> coverImagePath = GeneratedColumn<String>(
      'cover_image_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _coverImageUrlMeta =
      const VerificationMeta('coverImageUrl');
  @override
  late final GeneratedColumn<String> coverImageUrl = GeneratedColumn<String>(
      'cover_image_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _publisherMeta =
      const VerificationMeta('publisher');
  @override
  late final GeneratedColumn<String> publisher = GeneratedColumn<String>(
      'publisher', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _editionMeta =
      const VerificationMeta('edition');
  @override
  late final GeneratedColumn<String> edition = GeneratedColumn<String>(
      'edition', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _publicationDateMeta =
      const VerificationMeta('publicationDate');
  @override
  late final GeneratedColumn<String> publicationDate = GeneratedColumn<String>(
      'publication_date', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<BookFormat?, String> format =
      GeneratedColumn<String>('format', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<BookFormat?>($BooksTable.$converterformatn);
  static const VerificationMeta _pageCountMeta =
      const VerificationMeta('pageCount');
  @override
  late final GeneratedColumn<int> pageCount = GeneratedColumn<int>(
      'page_count', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<BookCondition?, String>
      condition = GeneratedColumn<String>('condition', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<BookCondition?>($BooksTable.$converterconditionn);
  static const VerificationMeta _pricePaidMeta =
      const VerificationMeta('pricePaid');
  @override
  late final GeneratedColumn<double> pricePaid = GeneratedColumn<double>(
      'price_paid', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _purchaseDateMeta =
      const VerificationMeta('purchaseDate');
  @override
  late final GeneratedColumn<String> purchaseDate = GeneratedColumn<String>(
      'purchase_date', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<BookStatus, String> status =
      GeneratedColumn<String>('status', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('available'))
          .withConverter<BookStatus>($BooksTable.$converterstatus);
  static const VerificationMeta _checkedOutToMeta =
      const VerificationMeta('checkedOutTo');
  @override
  late final GeneratedColumn<String> checkedOutTo = GeneratedColumn<String>(
      'checked_out_to', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.now().toIso8601String());
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.now().toIso8601String());
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        isbn,
        languageId,
        coverImagePath,
        coverImageUrl,
        publisher,
        edition,
        publicationDate,
        format,
        pageCount,
        description,
        condition,
        pricePaid,
        purchaseDate,
        notes,
        status,
        checkedOutTo,
        isDeleted,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'book';
  @override
  VerificationContext validateIntegrity(Insertable<Book> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('isbn')) {
      context.handle(
          _isbnMeta, isbn.isAcceptableOrUnknown(data['isbn']!, _isbnMeta));
    }
    if (data.containsKey('language_id')) {
      context.handle(
          _languageIdMeta,
          languageId.isAcceptableOrUnknown(
              data['language_id']!, _languageIdMeta));
    }
    if (data.containsKey('cover_image_path')) {
      context.handle(
          _coverImagePathMeta,
          coverImagePath.isAcceptableOrUnknown(
              data['cover_image_path']!, _coverImagePathMeta));
    }
    if (data.containsKey('cover_image_url')) {
      context.handle(
          _coverImageUrlMeta,
          coverImageUrl.isAcceptableOrUnknown(
              data['cover_image_url']!, _coverImageUrlMeta));
    }
    if (data.containsKey('publisher')) {
      context.handle(_publisherMeta,
          publisher.isAcceptableOrUnknown(data['publisher']!, _publisherMeta));
    }
    if (data.containsKey('edition')) {
      context.handle(_editionMeta,
          edition.isAcceptableOrUnknown(data['edition']!, _editionMeta));
    }
    if (data.containsKey('publication_date')) {
      context.handle(
          _publicationDateMeta,
          publicationDate.isAcceptableOrUnknown(
              data['publication_date']!, _publicationDateMeta));
    }
    if (data.containsKey('page_count')) {
      context.handle(_pageCountMeta,
          pageCount.isAcceptableOrUnknown(data['page_count']!, _pageCountMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('price_paid')) {
      context.handle(_pricePaidMeta,
          pricePaid.isAcceptableOrUnknown(data['price_paid']!, _pricePaidMeta));
    }
    if (data.containsKey('purchase_date')) {
      context.handle(
          _purchaseDateMeta,
          purchaseDate.isAcceptableOrUnknown(
              data['purchase_date']!, _purchaseDateMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('checked_out_to')) {
      context.handle(
          _checkedOutToMeta,
          checkedOutTo.isAcceptableOrUnknown(
              data['checked_out_to']!, _checkedOutToMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Book map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Book(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      isbn: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}isbn']),
      languageId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}language_id']),
      coverImagePath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}cover_image_path']),
      coverImageUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cover_image_url']),
      publisher: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}publisher']),
      edition: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}edition']),
      publicationDate: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}publication_date']),
      format: $BooksTable.$converterformatn.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}format'])),
      pageCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}page_count']),
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      condition: $BooksTable.$converterconditionn.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}condition'])),
      pricePaid: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}price_paid']),
      purchaseDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}purchase_date']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      status: $BooksTable.$converterstatus.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!),
      checkedOutTo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}checked_out_to']),
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $BooksTable createAlias(String alias) {
    return $BooksTable(attachedDatabase, alias);
  }

  static TypeConverter<BookFormat, String> $converterformat =
      const BookFormatConverter();
  static TypeConverter<BookFormat?, String?> $converterformatn =
      NullAwareTypeConverter.wrap($converterformat);
  static TypeConverter<BookCondition, String> $convertercondition =
      const BookConditionConverter();
  static TypeConverter<BookCondition?, String?> $converterconditionn =
      NullAwareTypeConverter.wrap($convertercondition);
  static TypeConverter<BookStatus, String> $converterstatus =
      const BookStatusConverter();
}

class Book extends DataClass implements Insertable<Book> {
  final String id;
  final String title;
  final String? isbn;
  final String? languageId;
  final String? coverImagePath;
  final String? coverImageUrl;
  final String? publisher;
  final String? edition;
  final String? publicationDate;
  final BookFormat? format;
  final int? pageCount;
  final String? description;
  final BookCondition? condition;
  final double? pricePaid;
  final String? purchaseDate;
  final String? notes;
  final BookStatus status;
  final String? checkedOutTo;
  final bool isDeleted;
  final String createdAt;
  final String updatedAt;
  const Book(
      {required this.id,
      required this.title,
      this.isbn,
      this.languageId,
      this.coverImagePath,
      this.coverImageUrl,
      this.publisher,
      this.edition,
      this.publicationDate,
      this.format,
      this.pageCount,
      this.description,
      this.condition,
      this.pricePaid,
      this.purchaseDate,
      this.notes,
      required this.status,
      this.checkedOutTo,
      required this.isDeleted,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || isbn != null) {
      map['isbn'] = Variable<String>(isbn);
    }
    if (!nullToAbsent || languageId != null) {
      map['language_id'] = Variable<String>(languageId);
    }
    if (!nullToAbsent || coverImagePath != null) {
      map['cover_image_path'] = Variable<String>(coverImagePath);
    }
    if (!nullToAbsent || coverImageUrl != null) {
      map['cover_image_url'] = Variable<String>(coverImageUrl);
    }
    if (!nullToAbsent || publisher != null) {
      map['publisher'] = Variable<String>(publisher);
    }
    if (!nullToAbsent || edition != null) {
      map['edition'] = Variable<String>(edition);
    }
    if (!nullToAbsent || publicationDate != null) {
      map['publication_date'] = Variable<String>(publicationDate);
    }
    if (!nullToAbsent || format != null) {
      map['format'] =
          Variable<String>($BooksTable.$converterformatn.toSql(format));
    }
    if (!nullToAbsent || pageCount != null) {
      map['page_count'] = Variable<int>(pageCount);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || condition != null) {
      map['condition'] =
          Variable<String>($BooksTable.$converterconditionn.toSql(condition));
    }
    if (!nullToAbsent || pricePaid != null) {
      map['price_paid'] = Variable<double>(pricePaid);
    }
    if (!nullToAbsent || purchaseDate != null) {
      map['purchase_date'] = Variable<String>(purchaseDate);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    {
      map['status'] =
          Variable<String>($BooksTable.$converterstatus.toSql(status));
    }
    if (!nullToAbsent || checkedOutTo != null) {
      map['checked_out_to'] = Variable<String>(checkedOutTo);
    }
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  BooksCompanion toCompanion(bool nullToAbsent) {
    return BooksCompanion(
      id: Value(id),
      title: Value(title),
      isbn: isbn == null && nullToAbsent ? const Value.absent() : Value(isbn),
      languageId: languageId == null && nullToAbsent
          ? const Value.absent()
          : Value(languageId),
      coverImagePath: coverImagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(coverImagePath),
      coverImageUrl: coverImageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(coverImageUrl),
      publisher: publisher == null && nullToAbsent
          ? const Value.absent()
          : Value(publisher),
      edition: edition == null && nullToAbsent
          ? const Value.absent()
          : Value(edition),
      publicationDate: publicationDate == null && nullToAbsent
          ? const Value.absent()
          : Value(publicationDate),
      format:
          format == null && nullToAbsent ? const Value.absent() : Value(format),
      pageCount: pageCount == null && nullToAbsent
          ? const Value.absent()
          : Value(pageCount),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      condition: condition == null && nullToAbsent
          ? const Value.absent()
          : Value(condition),
      pricePaid: pricePaid == null && nullToAbsent
          ? const Value.absent()
          : Value(pricePaid),
      purchaseDate: purchaseDate == null && nullToAbsent
          ? const Value.absent()
          : Value(purchaseDate),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      status: Value(status),
      checkedOutTo: checkedOutTo == null && nullToAbsent
          ? const Value.absent()
          : Value(checkedOutTo),
      isDeleted: Value(isDeleted),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Book.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Book(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      isbn: serializer.fromJson<String?>(json['isbn']),
      languageId: serializer.fromJson<String?>(json['languageId']),
      coverImagePath: serializer.fromJson<String?>(json['coverImagePath']),
      coverImageUrl: serializer.fromJson<String?>(json['coverImageUrl']),
      publisher: serializer.fromJson<String?>(json['publisher']),
      edition: serializer.fromJson<String?>(json['edition']),
      publicationDate: serializer.fromJson<String?>(json['publicationDate']),
      format: serializer.fromJson<BookFormat?>(json['format']),
      pageCount: serializer.fromJson<int?>(json['pageCount']),
      description: serializer.fromJson<String?>(json['description']),
      condition: serializer.fromJson<BookCondition?>(json['condition']),
      pricePaid: serializer.fromJson<double?>(json['pricePaid']),
      purchaseDate: serializer.fromJson<String?>(json['purchaseDate']),
      notes: serializer.fromJson<String?>(json['notes']),
      status: serializer.fromJson<BookStatus>(json['status']),
      checkedOutTo: serializer.fromJson<String?>(json['checkedOutTo']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'isbn': serializer.toJson<String?>(isbn),
      'languageId': serializer.toJson<String?>(languageId),
      'coverImagePath': serializer.toJson<String?>(coverImagePath),
      'coverImageUrl': serializer.toJson<String?>(coverImageUrl),
      'publisher': serializer.toJson<String?>(publisher),
      'edition': serializer.toJson<String?>(edition),
      'publicationDate': serializer.toJson<String?>(publicationDate),
      'format': serializer.toJson<BookFormat?>(format),
      'pageCount': serializer.toJson<int?>(pageCount),
      'description': serializer.toJson<String?>(description),
      'condition': serializer.toJson<BookCondition?>(condition),
      'pricePaid': serializer.toJson<double?>(pricePaid),
      'purchaseDate': serializer.toJson<String?>(purchaseDate),
      'notes': serializer.toJson<String?>(notes),
      'status': serializer.toJson<BookStatus>(status),
      'checkedOutTo': serializer.toJson<String?>(checkedOutTo),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  Book copyWith(
          {String? id,
          String? title,
          Value<String?> isbn = const Value.absent(),
          Value<String?> languageId = const Value.absent(),
          Value<String?> coverImagePath = const Value.absent(),
          Value<String?> coverImageUrl = const Value.absent(),
          Value<String?> publisher = const Value.absent(),
          Value<String?> edition = const Value.absent(),
          Value<String?> publicationDate = const Value.absent(),
          Value<BookFormat?> format = const Value.absent(),
          Value<int?> pageCount = const Value.absent(),
          Value<String?> description = const Value.absent(),
          Value<BookCondition?> condition = const Value.absent(),
          Value<double?> pricePaid = const Value.absent(),
          Value<String?> purchaseDate = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          BookStatus? status,
          Value<String?> checkedOutTo = const Value.absent(),
          bool? isDeleted,
          String? createdAt,
          String? updatedAt}) =>
      Book(
        id: id ?? this.id,
        title: title ?? this.title,
        isbn: isbn.present ? isbn.value : this.isbn,
        languageId: languageId.present ? languageId.value : this.languageId,
        coverImagePath:
            coverImagePath.present ? coverImagePath.value : this.coverImagePath,
        coverImageUrl:
            coverImageUrl.present ? coverImageUrl.value : this.coverImageUrl,
        publisher: publisher.present ? publisher.value : this.publisher,
        edition: edition.present ? edition.value : this.edition,
        publicationDate: publicationDate.present
            ? publicationDate.value
            : this.publicationDate,
        format: format.present ? format.value : this.format,
        pageCount: pageCount.present ? pageCount.value : this.pageCount,
        description: description.present ? description.value : this.description,
        condition: condition.present ? condition.value : this.condition,
        pricePaid: pricePaid.present ? pricePaid.value : this.pricePaid,
        purchaseDate:
            purchaseDate.present ? purchaseDate.value : this.purchaseDate,
        notes: notes.present ? notes.value : this.notes,
        status: status ?? this.status,
        checkedOutTo:
            checkedOutTo.present ? checkedOutTo.value : this.checkedOutTo,
        isDeleted: isDeleted ?? this.isDeleted,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Book copyWithCompanion(BooksCompanion data) {
    return Book(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      isbn: data.isbn.present ? data.isbn.value : this.isbn,
      languageId:
          data.languageId.present ? data.languageId.value : this.languageId,
      coverImagePath: data.coverImagePath.present
          ? data.coverImagePath.value
          : this.coverImagePath,
      coverImageUrl: data.coverImageUrl.present
          ? data.coverImageUrl.value
          : this.coverImageUrl,
      publisher: data.publisher.present ? data.publisher.value : this.publisher,
      edition: data.edition.present ? data.edition.value : this.edition,
      publicationDate: data.publicationDate.present
          ? data.publicationDate.value
          : this.publicationDate,
      format: data.format.present ? data.format.value : this.format,
      pageCount: data.pageCount.present ? data.pageCount.value : this.pageCount,
      description:
          data.description.present ? data.description.value : this.description,
      condition: data.condition.present ? data.condition.value : this.condition,
      pricePaid: data.pricePaid.present ? data.pricePaid.value : this.pricePaid,
      purchaseDate: data.purchaseDate.present
          ? data.purchaseDate.value
          : this.purchaseDate,
      notes: data.notes.present ? data.notes.value : this.notes,
      status: data.status.present ? data.status.value : this.status,
      checkedOutTo: data.checkedOutTo.present
          ? data.checkedOutTo.value
          : this.checkedOutTo,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Book(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('isbn: $isbn, ')
          ..write('languageId: $languageId, ')
          ..write('coverImagePath: $coverImagePath, ')
          ..write('coverImageUrl: $coverImageUrl, ')
          ..write('publisher: $publisher, ')
          ..write('edition: $edition, ')
          ..write('publicationDate: $publicationDate, ')
          ..write('format: $format, ')
          ..write('pageCount: $pageCount, ')
          ..write('description: $description, ')
          ..write('condition: $condition, ')
          ..write('pricePaid: $pricePaid, ')
          ..write('purchaseDate: $purchaseDate, ')
          ..write('notes: $notes, ')
          ..write('status: $status, ')
          ..write('checkedOutTo: $checkedOutTo, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        title,
        isbn,
        languageId,
        coverImagePath,
        coverImageUrl,
        publisher,
        edition,
        publicationDate,
        format,
        pageCount,
        description,
        condition,
        pricePaid,
        purchaseDate,
        notes,
        status,
        checkedOutTo,
        isDeleted,
        createdAt,
        updatedAt
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Book &&
          other.id == this.id &&
          other.title == this.title &&
          other.isbn == this.isbn &&
          other.languageId == this.languageId &&
          other.coverImagePath == this.coverImagePath &&
          other.coverImageUrl == this.coverImageUrl &&
          other.publisher == this.publisher &&
          other.edition == this.edition &&
          other.publicationDate == this.publicationDate &&
          other.format == this.format &&
          other.pageCount == this.pageCount &&
          other.description == this.description &&
          other.condition == this.condition &&
          other.pricePaid == this.pricePaid &&
          other.purchaseDate == this.purchaseDate &&
          other.notes == this.notes &&
          other.status == this.status &&
          other.checkedOutTo == this.checkedOutTo &&
          other.isDeleted == this.isDeleted &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class BooksCompanion extends UpdateCompanion<Book> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> isbn;
  final Value<String?> languageId;
  final Value<String?> coverImagePath;
  final Value<String?> coverImageUrl;
  final Value<String?> publisher;
  final Value<String?> edition;
  final Value<String?> publicationDate;
  final Value<BookFormat?> format;
  final Value<int?> pageCount;
  final Value<String?> description;
  final Value<BookCondition?> condition;
  final Value<double?> pricePaid;
  final Value<String?> purchaseDate;
  final Value<String?> notes;
  final Value<BookStatus> status;
  final Value<String?> checkedOutTo;
  final Value<bool> isDeleted;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<int> rowid;
  const BooksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.isbn = const Value.absent(),
    this.languageId = const Value.absent(),
    this.coverImagePath = const Value.absent(),
    this.coverImageUrl = const Value.absent(),
    this.publisher = const Value.absent(),
    this.edition = const Value.absent(),
    this.publicationDate = const Value.absent(),
    this.format = const Value.absent(),
    this.pageCount = const Value.absent(),
    this.description = const Value.absent(),
    this.condition = const Value.absent(),
    this.pricePaid = const Value.absent(),
    this.purchaseDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.status = const Value.absent(),
    this.checkedOutTo = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BooksCompanion.insert({
    required String id,
    required String title,
    this.isbn = const Value.absent(),
    this.languageId = const Value.absent(),
    this.coverImagePath = const Value.absent(),
    this.coverImageUrl = const Value.absent(),
    this.publisher = const Value.absent(),
    this.edition = const Value.absent(),
    this.publicationDate = const Value.absent(),
    this.format = const Value.absent(),
    this.pageCount = const Value.absent(),
    this.description = const Value.absent(),
    this.condition = const Value.absent(),
    this.pricePaid = const Value.absent(),
    this.purchaseDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.status = const Value.absent(),
    this.checkedOutTo = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title);
  static Insertable<Book> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? isbn,
    Expression<String>? languageId,
    Expression<String>? coverImagePath,
    Expression<String>? coverImageUrl,
    Expression<String>? publisher,
    Expression<String>? edition,
    Expression<String>? publicationDate,
    Expression<String>? format,
    Expression<int>? pageCount,
    Expression<String>? description,
    Expression<String>? condition,
    Expression<double>? pricePaid,
    Expression<String>? purchaseDate,
    Expression<String>? notes,
    Expression<String>? status,
    Expression<String>? checkedOutTo,
    Expression<bool>? isDeleted,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (isbn != null) 'isbn': isbn,
      if (languageId != null) 'language_id': languageId,
      if (coverImagePath != null) 'cover_image_path': coverImagePath,
      if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
      if (publisher != null) 'publisher': publisher,
      if (edition != null) 'edition': edition,
      if (publicationDate != null) 'publication_date': publicationDate,
      if (format != null) 'format': format,
      if (pageCount != null) 'page_count': pageCount,
      if (description != null) 'description': description,
      if (condition != null) 'condition': condition,
      if (pricePaid != null) 'price_paid': pricePaid,
      if (purchaseDate != null) 'purchase_date': purchaseDate,
      if (notes != null) 'notes': notes,
      if (status != null) 'status': status,
      if (checkedOutTo != null) 'checked_out_to': checkedOutTo,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BooksCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<String?>? isbn,
      Value<String?>? languageId,
      Value<String?>? coverImagePath,
      Value<String?>? coverImageUrl,
      Value<String?>? publisher,
      Value<String?>? edition,
      Value<String?>? publicationDate,
      Value<BookFormat?>? format,
      Value<int?>? pageCount,
      Value<String?>? description,
      Value<BookCondition?>? condition,
      Value<double?>? pricePaid,
      Value<String?>? purchaseDate,
      Value<String?>? notes,
      Value<BookStatus>? status,
      Value<String?>? checkedOutTo,
      Value<bool>? isDeleted,
      Value<String>? createdAt,
      Value<String>? updatedAt,
      Value<int>? rowid}) {
    return BooksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      isbn: isbn ?? this.isbn,
      languageId: languageId ?? this.languageId,
      coverImagePath: coverImagePath ?? this.coverImagePath,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      publisher: publisher ?? this.publisher,
      edition: edition ?? this.edition,
      publicationDate: publicationDate ?? this.publicationDate,
      format: format ?? this.format,
      pageCount: pageCount ?? this.pageCount,
      description: description ?? this.description,
      condition: condition ?? this.condition,
      pricePaid: pricePaid ?? this.pricePaid,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      checkedOutTo: checkedOutTo ?? this.checkedOutTo,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (isbn.present) {
      map['isbn'] = Variable<String>(isbn.value);
    }
    if (languageId.present) {
      map['language_id'] = Variable<String>(languageId.value);
    }
    if (coverImagePath.present) {
      map['cover_image_path'] = Variable<String>(coverImagePath.value);
    }
    if (coverImageUrl.present) {
      map['cover_image_url'] = Variable<String>(coverImageUrl.value);
    }
    if (publisher.present) {
      map['publisher'] = Variable<String>(publisher.value);
    }
    if (edition.present) {
      map['edition'] = Variable<String>(edition.value);
    }
    if (publicationDate.present) {
      map['publication_date'] = Variable<String>(publicationDate.value);
    }
    if (format.present) {
      map['format'] =
          Variable<String>($BooksTable.$converterformatn.toSql(format.value));
    }
    if (pageCount.present) {
      map['page_count'] = Variable<int>(pageCount.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (condition.present) {
      map['condition'] = Variable<String>(
          $BooksTable.$converterconditionn.toSql(condition.value));
    }
    if (pricePaid.present) {
      map['price_paid'] = Variable<double>(pricePaid.value);
    }
    if (purchaseDate.present) {
      map['purchase_date'] = Variable<String>(purchaseDate.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (status.present) {
      map['status'] =
          Variable<String>($BooksTable.$converterstatus.toSql(status.value));
    }
    if (checkedOutTo.present) {
      map['checked_out_to'] = Variable<String>(checkedOutTo.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BooksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('isbn: $isbn, ')
          ..write('languageId: $languageId, ')
          ..write('coverImagePath: $coverImagePath, ')
          ..write('coverImageUrl: $coverImageUrl, ')
          ..write('publisher: $publisher, ')
          ..write('edition: $edition, ')
          ..write('publicationDate: $publicationDate, ')
          ..write('format: $format, ')
          ..write('pageCount: $pageCount, ')
          ..write('description: $description, ')
          ..write('condition: $condition, ')
          ..write('pricePaid: $pricePaid, ')
          ..write('purchaseDate: $purchaseDate, ')
          ..write('notes: $notes, ')
          ..write('status: $status, ')
          ..write('checkedOutTo: $checkedOutTo, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AuthorsTable extends Authors with TableInfo<$AuthorsTable, Author> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AuthorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 36, maxTextLength: 36),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _rawNameMeta =
      const VerificationMeta('rawName');
  @override
  late final GeneratedColumn<String> rawName =
      GeneratedColumn<String>('raw_name', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
            minTextLength: 1,
          ),
          type: DriftSqlType.string,
          requiredDuringInsert: true,
          $customConstraints: 'COLLATE NOCASE NOT NULL');
  static const VerificationMeta _normalizedNameMeta =
      const VerificationMeta('normalizedName');
  @override
  late final GeneratedColumn<String> normalizedName =
      GeneratedColumn<String>('normalized_name', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
            minTextLength: 1,
          ),
          type: DriftSqlType.string,
          requiredDuringInsert: true,
          $customConstraints: 'COLLATE NOCASE NOT NULL UNIQUE');
  static const VerificationMeta _disambiguationMeta =
      const VerificationMeta('disambiguation');
  @override
  late final GeneratedColumn<String> disambiguation = GeneratedColumn<String>(
      'disambiguation', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, rawName, normalizedName, disambiguation];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'author';
  @override
  VerificationContext validateIntegrity(Insertable<Author> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('raw_name')) {
      context.handle(_rawNameMeta,
          rawName.isAcceptableOrUnknown(data['raw_name']!, _rawNameMeta));
    } else if (isInserting) {
      context.missing(_rawNameMeta);
    }
    if (data.containsKey('normalized_name')) {
      context.handle(
          _normalizedNameMeta,
          normalizedName.isAcceptableOrUnknown(
              data['normalized_name']!, _normalizedNameMeta));
    } else if (isInserting) {
      context.missing(_normalizedNameMeta);
    }
    if (data.containsKey('disambiguation')) {
      context.handle(
          _disambiguationMeta,
          disambiguation.isAcceptableOrUnknown(
              data['disambiguation']!, _disambiguationMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Author map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Author(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      rawName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}raw_name'])!,
      normalizedName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}normalized_name'])!,
      disambiguation: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}disambiguation']),
    );
  }

  @override
  $AuthorsTable createAlias(String alias) {
    return $AuthorsTable(attachedDatabase, alias);
  }
}

class Author extends DataClass implements Insertable<Author> {
  final String id;
  final String rawName;
  final String normalizedName;
  final String? disambiguation;
  const Author(
      {required this.id,
      required this.rawName,
      required this.normalizedName,
      this.disambiguation});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['raw_name'] = Variable<String>(rawName);
    map['normalized_name'] = Variable<String>(normalizedName);
    if (!nullToAbsent || disambiguation != null) {
      map['disambiguation'] = Variable<String>(disambiguation);
    }
    return map;
  }

  AuthorsCompanion toCompanion(bool nullToAbsent) {
    return AuthorsCompanion(
      id: Value(id),
      rawName: Value(rawName),
      normalizedName: Value(normalizedName),
      disambiguation: disambiguation == null && nullToAbsent
          ? const Value.absent()
          : Value(disambiguation),
    );
  }

  factory Author.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Author(
      id: serializer.fromJson<String>(json['id']),
      rawName: serializer.fromJson<String>(json['rawName']),
      normalizedName: serializer.fromJson<String>(json['normalizedName']),
      disambiguation: serializer.fromJson<String?>(json['disambiguation']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'rawName': serializer.toJson<String>(rawName),
      'normalizedName': serializer.toJson<String>(normalizedName),
      'disambiguation': serializer.toJson<String?>(disambiguation),
    };
  }

  Author copyWith(
          {String? id,
          String? rawName,
          String? normalizedName,
          Value<String?> disambiguation = const Value.absent()}) =>
      Author(
        id: id ?? this.id,
        rawName: rawName ?? this.rawName,
        normalizedName: normalizedName ?? this.normalizedName,
        disambiguation:
            disambiguation.present ? disambiguation.value : this.disambiguation,
      );
  Author copyWithCompanion(AuthorsCompanion data) {
    return Author(
      id: data.id.present ? data.id.value : this.id,
      rawName: data.rawName.present ? data.rawName.value : this.rawName,
      normalizedName: data.normalizedName.present
          ? data.normalizedName.value
          : this.normalizedName,
      disambiguation: data.disambiguation.present
          ? data.disambiguation.value
          : this.disambiguation,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Author(')
          ..write('id: $id, ')
          ..write('rawName: $rawName, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('disambiguation: $disambiguation')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, rawName, normalizedName, disambiguation);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Author &&
          other.id == this.id &&
          other.rawName == this.rawName &&
          other.normalizedName == this.normalizedName &&
          other.disambiguation == this.disambiguation);
}

class AuthorsCompanion extends UpdateCompanion<Author> {
  final Value<String> id;
  final Value<String> rawName;
  final Value<String> normalizedName;
  final Value<String?> disambiguation;
  final Value<int> rowid;
  const AuthorsCompanion({
    this.id = const Value.absent(),
    this.rawName = const Value.absent(),
    this.normalizedName = const Value.absent(),
    this.disambiguation = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AuthorsCompanion.insert({
    required String id,
    required String rawName,
    required String normalizedName,
    this.disambiguation = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        rawName = Value(rawName),
        normalizedName = Value(normalizedName);
  static Insertable<Author> custom({
    Expression<String>? id,
    Expression<String>? rawName,
    Expression<String>? normalizedName,
    Expression<String>? disambiguation,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (rawName != null) 'raw_name': rawName,
      if (normalizedName != null) 'normalized_name': normalizedName,
      if (disambiguation != null) 'disambiguation': disambiguation,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AuthorsCompanion copyWith(
      {Value<String>? id,
      Value<String>? rawName,
      Value<String>? normalizedName,
      Value<String?>? disambiguation,
      Value<int>? rowid}) {
    return AuthorsCompanion(
      id: id ?? this.id,
      rawName: rawName ?? this.rawName,
      normalizedName: normalizedName ?? this.normalizedName,
      disambiguation: disambiguation ?? this.disambiguation,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (rawName.present) {
      map['raw_name'] = Variable<String>(rawName.value);
    }
    if (normalizedName.present) {
      map['normalized_name'] = Variable<String>(normalizedName.value);
    }
    if (disambiguation.present) {
      map['disambiguation'] = Variable<String>(disambiguation.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AuthorsCompanion(')
          ..write('id: $id, ')
          ..write('rawName: $rawName, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('disambiguation: $disambiguation, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BookAuthorsTable extends BookAuthors
    with TableInfo<$BookAuthorsTable, BookAuthor> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookAuthorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
      'book_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'REFERENCES book(id)');
  static const VerificationMeta _authorIdMeta =
      const VerificationMeta('authorId');
  @override
  late final GeneratedColumn<String> authorId = GeneratedColumn<String>(
      'author_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'REFERENCES author(id)');
  @override
  List<GeneratedColumn> get $columns => [bookId, authorId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'book_author';
  @override
  VerificationContext validateIntegrity(Insertable<BookAuthor> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('book_id')) {
      context.handle(_bookIdMeta,
          bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta));
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('author_id')) {
      context.handle(_authorIdMeta,
          authorId.isAcceptableOrUnknown(data['author_id']!, _authorIdMeta));
    } else if (isInserting) {
      context.missing(_authorIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {bookId, authorId};
  @override
  BookAuthor map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookAuthor(
      bookId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}book_id'])!,
      authorId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}author_id'])!,
    );
  }

  @override
  $BookAuthorsTable createAlias(String alias) {
    return $BookAuthorsTable(attachedDatabase, alias);
  }
}

class BookAuthor extends DataClass implements Insertable<BookAuthor> {
  final String bookId;
  final String authorId;
  const BookAuthor({required this.bookId, required this.authorId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['book_id'] = Variable<String>(bookId);
    map['author_id'] = Variable<String>(authorId);
    return map;
  }

  BookAuthorsCompanion toCompanion(bool nullToAbsent) {
    return BookAuthorsCompanion(
      bookId: Value(bookId),
      authorId: Value(authorId),
    );
  }

  factory BookAuthor.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookAuthor(
      bookId: serializer.fromJson<String>(json['bookId']),
      authorId: serializer.fromJson<String>(json['authorId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'bookId': serializer.toJson<String>(bookId),
      'authorId': serializer.toJson<String>(authorId),
    };
  }

  BookAuthor copyWith({String? bookId, String? authorId}) => BookAuthor(
        bookId: bookId ?? this.bookId,
        authorId: authorId ?? this.authorId,
      );
  BookAuthor copyWithCompanion(BookAuthorsCompanion data) {
    return BookAuthor(
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      authorId: data.authorId.present ? data.authorId.value : this.authorId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookAuthor(')
          ..write('bookId: $bookId, ')
          ..write('authorId: $authorId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(bookId, authorId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookAuthor &&
          other.bookId == this.bookId &&
          other.authorId == this.authorId);
}

class BookAuthorsCompanion extends UpdateCompanion<BookAuthor> {
  final Value<String> bookId;
  final Value<String> authorId;
  final Value<int> rowid;
  const BookAuthorsCompanion({
    this.bookId = const Value.absent(),
    this.authorId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BookAuthorsCompanion.insert({
    required String bookId,
    required String authorId,
    this.rowid = const Value.absent(),
  })  : bookId = Value(bookId),
        authorId = Value(authorId);
  static Insertable<BookAuthor> custom({
    Expression<String>? bookId,
    Expression<String>? authorId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (bookId != null) 'book_id': bookId,
      if (authorId != null) 'author_id': authorId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BookAuthorsCompanion copyWith(
      {Value<String>? bookId, Value<String>? authorId, Value<int>? rowid}) {
    return BookAuthorsCompanion(
      bookId: bookId ?? this.bookId,
      authorId: authorId ?? this.authorId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (authorId.present) {
      map['author_id'] = Variable<String>(authorId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookAuthorsCompanion(')
          ..write('bookId: $bookId, ')
          ..write('authorId: $authorId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GenresTable extends Genres with TableInfo<$GenresTable, Genre> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GenresTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 36, maxTextLength: 36),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name =
      GeneratedColumn<String>('name', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
            minTextLength: 1,
          ),
          type: DriftSqlType.string,
          requiredDuringInsert: true,
          $customConstraints: 'COLLATE NOCASE NOT NULL UNIQUE');
  static const VerificationMeta _isCustomMeta =
      const VerificationMeta('isCustom');
  @override
  late final GeneratedColumn<bool> isCustom = GeneratedColumn<bool>(
      'is_custom', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_custom" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [id, name, isCustom];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'genre';
  @override
  VerificationContext validateIntegrity(Insertable<Genre> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('is_custom')) {
      context.handle(_isCustomMeta,
          isCustom.isAcceptableOrUnknown(data['is_custom']!, _isCustomMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Genre map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Genre(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      isCustom: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_custom'])!,
    );
  }

  @override
  $GenresTable createAlias(String alias) {
    return $GenresTable(attachedDatabase, alias);
  }
}

class Genre extends DataClass implements Insertable<Genre> {
  final String id;
  final String name;
  final bool isCustom;
  const Genre({required this.id, required this.name, required this.isCustom});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['is_custom'] = Variable<bool>(isCustom);
    return map;
  }

  GenresCompanion toCompanion(bool nullToAbsent) {
    return GenresCompanion(
      id: Value(id),
      name: Value(name),
      isCustom: Value(isCustom),
    );
  }

  factory Genre.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Genre(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      isCustom: serializer.fromJson<bool>(json['isCustom']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'isCustom': serializer.toJson<bool>(isCustom),
    };
  }

  Genre copyWith({String? id, String? name, bool? isCustom}) => Genre(
        id: id ?? this.id,
        name: name ?? this.name,
        isCustom: isCustom ?? this.isCustom,
      );
  Genre copyWithCompanion(GenresCompanion data) {
    return Genre(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      isCustom: data.isCustom.present ? data.isCustom.value : this.isCustom,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Genre(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isCustom: $isCustom')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, isCustom);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Genre &&
          other.id == this.id &&
          other.name == this.name &&
          other.isCustom == this.isCustom);
}

class GenresCompanion extends UpdateCompanion<Genre> {
  final Value<String> id;
  final Value<String> name;
  final Value<bool> isCustom;
  final Value<int> rowid;
  const GenresCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.isCustom = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GenresCompanion.insert({
    required String id,
    required String name,
    this.isCustom = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name);
  static Insertable<Genre> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<bool>? isCustom,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (isCustom != null) 'is_custom': isCustom,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GenresCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<bool>? isCustom,
      Value<int>? rowid}) {
    return GenresCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      isCustom: isCustom ?? this.isCustom,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (isCustom.present) {
      map['is_custom'] = Variable<bool>(isCustom.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GenresCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isCustom: $isCustom, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BookGenresTable extends BookGenres
    with TableInfo<$BookGenresTable, BookGenre> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookGenresTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
      'book_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'REFERENCES book(id)');
  static const VerificationMeta _genreIdMeta =
      const VerificationMeta('genreId');
  @override
  late final GeneratedColumn<String> genreId = GeneratedColumn<String>(
      'genre_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'REFERENCES genre(id)');
  @override
  List<GeneratedColumn> get $columns => [bookId, genreId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'book_genre';
  @override
  VerificationContext validateIntegrity(Insertable<BookGenre> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('book_id')) {
      context.handle(_bookIdMeta,
          bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta));
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('genre_id')) {
      context.handle(_genreIdMeta,
          genreId.isAcceptableOrUnknown(data['genre_id']!, _genreIdMeta));
    } else if (isInserting) {
      context.missing(_genreIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {bookId, genreId};
  @override
  BookGenre map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookGenre(
      bookId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}book_id'])!,
      genreId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}genre_id'])!,
    );
  }

  @override
  $BookGenresTable createAlias(String alias) {
    return $BookGenresTable(attachedDatabase, alias);
  }
}

class BookGenre extends DataClass implements Insertable<BookGenre> {
  final String bookId;
  final String genreId;
  const BookGenre({required this.bookId, required this.genreId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['book_id'] = Variable<String>(bookId);
    map['genre_id'] = Variable<String>(genreId);
    return map;
  }

  BookGenresCompanion toCompanion(bool nullToAbsent) {
    return BookGenresCompanion(
      bookId: Value(bookId),
      genreId: Value(genreId),
    );
  }

  factory BookGenre.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookGenre(
      bookId: serializer.fromJson<String>(json['bookId']),
      genreId: serializer.fromJson<String>(json['genreId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'bookId': serializer.toJson<String>(bookId),
      'genreId': serializer.toJson<String>(genreId),
    };
  }

  BookGenre copyWith({String? bookId, String? genreId}) => BookGenre(
        bookId: bookId ?? this.bookId,
        genreId: genreId ?? this.genreId,
      );
  BookGenre copyWithCompanion(BookGenresCompanion data) {
    return BookGenre(
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      genreId: data.genreId.present ? data.genreId.value : this.genreId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookGenre(')
          ..write('bookId: $bookId, ')
          ..write('genreId: $genreId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(bookId, genreId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookGenre &&
          other.bookId == this.bookId &&
          other.genreId == this.genreId);
}

class BookGenresCompanion extends UpdateCompanion<BookGenre> {
  final Value<String> bookId;
  final Value<String> genreId;
  final Value<int> rowid;
  const BookGenresCompanion({
    this.bookId = const Value.absent(),
    this.genreId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BookGenresCompanion.insert({
    required String bookId,
    required String genreId,
    this.rowid = const Value.absent(),
  })  : bookId = Value(bookId),
        genreId = Value(genreId);
  static Insertable<BookGenre> custom({
    Expression<String>? bookId,
    Expression<String>? genreId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (bookId != null) 'book_id': bookId,
      if (genreId != null) 'genre_id': genreId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BookGenresCompanion copyWith(
      {Value<String>? bookId, Value<String>? genreId, Value<int>? rowid}) {
    return BookGenresCompanion(
      bookId: bookId ?? this.bookId,
      genreId: genreId ?? this.genreId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (genreId.present) {
      map['genre_id'] = Variable<String>(genreId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookGenresCompanion(')
          ..write('bookId: $bookId, ')
          ..write('genreId: $genreId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TagsTable extends Tags with TableInfo<$TagsTable, Tag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 36, maxTextLength: 36),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name =
      GeneratedColumn<String>('name', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
            minTextLength: 1,
          ),
          type: DriftSqlType.string,
          requiredDuringInsert: true,
          defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tag';
  @override
  VerificationContext validateIntegrity(Insertable<Tag> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tag(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
    );
  }

  @override
  $TagsTable createAlias(String alias) {
    return $TagsTable(attachedDatabase, alias);
  }
}

class Tag extends DataClass implements Insertable<Tag> {
  final String id;
  final String name;
  const Tag({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  TagsCompanion toCompanion(bool nullToAbsent) {
    return TagsCompanion(
      id: Value(id),
      name: Value(name),
    );
  }

  factory Tag.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tag(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  Tag copyWith({String? id, String? name}) => Tag(
        id: id ?? this.id,
        name: name ?? this.name,
      );
  Tag copyWithCompanion(TagsCompanion data) {
    return Tag(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tag(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tag && other.id == this.id && other.name == this.name);
}

class TagsCompanion extends UpdateCompanion<Tag> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> rowid;
  const TagsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TagsCompanion.insert({
    required String id,
    required String name,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name);
  static Insertable<Tag> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TagsCompanion copyWith(
      {Value<String>? id, Value<String>? name, Value<int>? rowid}) {
    return TagsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BookTagsTable extends BookTags with TableInfo<$BookTagsTable, BookTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
      'book_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'REFERENCES book(id)');
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<String> tagId = GeneratedColumn<String>(
      'tag_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'REFERENCES tag(id)');
  @override
  List<GeneratedColumn> get $columns => [bookId, tagId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'book_tag';
  @override
  VerificationContext validateIntegrity(Insertable<BookTag> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('book_id')) {
      context.handle(_bookIdMeta,
          bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta));
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
          _tagIdMeta, tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta));
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {bookId, tagId};
  @override
  BookTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookTag(
      bookId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}book_id'])!,
      tagId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tag_id'])!,
    );
  }

  @override
  $BookTagsTable createAlias(String alias) {
    return $BookTagsTable(attachedDatabase, alias);
  }
}

class BookTag extends DataClass implements Insertable<BookTag> {
  final String bookId;
  final String tagId;
  const BookTag({required this.bookId, required this.tagId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['book_id'] = Variable<String>(bookId);
    map['tag_id'] = Variable<String>(tagId);
    return map;
  }

  BookTagsCompanion toCompanion(bool nullToAbsent) {
    return BookTagsCompanion(
      bookId: Value(bookId),
      tagId: Value(tagId),
    );
  }

  factory BookTag.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookTag(
      bookId: serializer.fromJson<String>(json['bookId']),
      tagId: serializer.fromJson<String>(json['tagId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'bookId': serializer.toJson<String>(bookId),
      'tagId': serializer.toJson<String>(tagId),
    };
  }

  BookTag copyWith({String? bookId, String? tagId}) => BookTag(
        bookId: bookId ?? this.bookId,
        tagId: tagId ?? this.tagId,
      );
  BookTag copyWithCompanion(BookTagsCompanion data) {
    return BookTag(
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookTag(')
          ..write('bookId: $bookId, ')
          ..write('tagId: $tagId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(bookId, tagId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookTag &&
          other.bookId == this.bookId &&
          other.tagId == this.tagId);
}

class BookTagsCompanion extends UpdateCompanion<BookTag> {
  final Value<String> bookId;
  final Value<String> tagId;
  final Value<int> rowid;
  const BookTagsCompanion({
    this.bookId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BookTagsCompanion.insert({
    required String bookId,
    required String tagId,
    this.rowid = const Value.absent(),
  })  : bookId = Value(bookId),
        tagId = Value(tagId);
  static Insertable<BookTag> custom({
    Expression<String>? bookId,
    Expression<String>? tagId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (bookId != null) 'book_id': bookId,
      if (tagId != null) 'tag_id': tagId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BookTagsCompanion copyWith(
      {Value<String>? bookId, Value<String>? tagId, Value<int>? rowid}) {
    return BookTagsCompanion(
      bookId: bookId ?? this.bookId,
      tagId: tagId ?? this.tagId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<String>(tagId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookTagsCompanion(')
          ..write('bookId: $bookId, ')
          ..write('tagId: $tagId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LanguagesTable extends Languages
    with TableInfo<$LanguagesTable, Language> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LanguagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 36, maxTextLength: 36),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name =
      GeneratedColumn<String>('name', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
            minTextLength: 1,
          ),
          type: DriftSqlType.string,
          requiredDuringInsert: true,
          $customConstraints: 'COLLATE NOCASE NOT NULL UNIQUE');
  static const VerificationMeta _isBuiltinMeta =
      const VerificationMeta('isBuiltin');
  @override
  late final GeneratedColumn<bool> isBuiltin = GeneratedColumn<bool>(
      'is_builtin', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_builtin" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [id, name, isBuiltin];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'language';
  @override
  VerificationContext validateIntegrity(Insertable<Language> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('is_builtin')) {
      context.handle(_isBuiltinMeta,
          isBuiltin.isAcceptableOrUnknown(data['is_builtin']!, _isBuiltinMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Language map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Language(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      isBuiltin: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_builtin'])!,
    );
  }

  @override
  $LanguagesTable createAlias(String alias) {
    return $LanguagesTable(attachedDatabase, alias);
  }
}

class Language extends DataClass implements Insertable<Language> {
  final String id;
  final String name;
  final bool isBuiltin;
  const Language(
      {required this.id, required this.name, required this.isBuiltin});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['is_builtin'] = Variable<bool>(isBuiltin);
    return map;
  }

  LanguagesCompanion toCompanion(bool nullToAbsent) {
    return LanguagesCompanion(
      id: Value(id),
      name: Value(name),
      isBuiltin: Value(isBuiltin),
    );
  }

  factory Language.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Language(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      isBuiltin: serializer.fromJson<bool>(json['isBuiltin']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'isBuiltin': serializer.toJson<bool>(isBuiltin),
    };
  }

  Language copyWith({String? id, String? name, bool? isBuiltin}) => Language(
        id: id ?? this.id,
        name: name ?? this.name,
        isBuiltin: isBuiltin ?? this.isBuiltin,
      );
  Language copyWithCompanion(LanguagesCompanion data) {
    return Language(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      isBuiltin: data.isBuiltin.present ? data.isBuiltin.value : this.isBuiltin,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Language(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isBuiltin: $isBuiltin')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, isBuiltin);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Language &&
          other.id == this.id &&
          other.name == this.name &&
          other.isBuiltin == this.isBuiltin);
}

class LanguagesCompanion extends UpdateCompanion<Language> {
  final Value<String> id;
  final Value<String> name;
  final Value<bool> isBuiltin;
  final Value<int> rowid;
  const LanguagesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.isBuiltin = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LanguagesCompanion.insert({
    required String id,
    required String name,
    this.isBuiltin = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name);
  static Insertable<Language> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<bool>? isBuiltin,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (isBuiltin != null) 'is_builtin': isBuiltin,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LanguagesCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<bool>? isBuiltin,
      Value<int>? rowid}) {
    return LanguagesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      isBuiltin: isBuiltin ?? this.isBuiltin,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (isBuiltin.present) {
      map['is_builtin'] = Variable<bool>(isBuiltin.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LanguagesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isBuiltin: $isBuiltin, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BookLoansTable extends BookLoans
    with TableInfo<$BookLoansTable, BookLoan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookLoansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 36, maxTextLength: 36),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
      'book_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'REFERENCES book(id)');
  static const VerificationMeta _borrowerNameMeta =
      const VerificationMeta('borrowerName');
  @override
  late final GeneratedColumn<String> borrowerName =
      GeneratedColumn<String>('borrower_name', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
            minTextLength: 1,
          ),
          type: DriftSqlType.string,
          requiredDuringInsert: true);
  static const VerificationMeta _borrowerContactMeta =
      const VerificationMeta('borrowerContact');
  @override
  late final GeneratedColumn<String> borrowerContact = GeneratedColumn<String>(
      'borrower_contact', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _loanedDateMeta =
      const VerificationMeta('loanedDate');
  @override
  late final GeneratedColumn<String> loanedDate = GeneratedColumn<String>(
      'loaned_date', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.now().toIso8601String());
  static const VerificationMeta _dueDateMeta =
      const VerificationMeta('dueDate');
  @override
  late final GeneratedColumn<String> dueDate = GeneratedColumn<String>(
      'due_date', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _returnedDateMeta =
      const VerificationMeta('returnedDate');
  @override
  late final GeneratedColumn<String> returnedDate = GeneratedColumn<String>(
      'returned_date', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.now().toIso8601String());
  static const VerificationMeta _createdByMeta =
      const VerificationMeta('createdBy');
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
      'created_by', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        bookId,
        borrowerName,
        borrowerContact,
        loanedDate,
        dueDate,
        returnedDate,
        notes,
        createdAt,
        createdBy
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'book_loan';
  @override
  VerificationContext validateIntegrity(Insertable<BookLoan> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('book_id')) {
      context.handle(_bookIdMeta,
          bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta));
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('borrower_name')) {
      context.handle(
          _borrowerNameMeta,
          borrowerName.isAcceptableOrUnknown(
              data['borrower_name']!, _borrowerNameMeta));
    } else if (isInserting) {
      context.missing(_borrowerNameMeta);
    }
    if (data.containsKey('borrower_contact')) {
      context.handle(
          _borrowerContactMeta,
          borrowerContact.isAcceptableOrUnknown(
              data['borrower_contact']!, _borrowerContactMeta));
    }
    if (data.containsKey('loaned_date')) {
      context.handle(
          _loanedDateMeta,
          loanedDate.isAcceptableOrUnknown(
              data['loaned_date']!, _loanedDateMeta));
    }
    if (data.containsKey('due_date')) {
      context.handle(_dueDateMeta,
          dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta));
    }
    if (data.containsKey('returned_date')) {
      context.handle(
          _returnedDateMeta,
          returnedDate.isAcceptableOrUnknown(
              data['returned_date']!, _returnedDateMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('created_by')) {
      context.handle(_createdByMeta,
          createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BookLoan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookLoan(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      bookId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}book_id'])!,
      borrowerName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}borrower_name'])!,
      borrowerContact: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}borrower_contact']),
      loanedDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}loaned_date'])!,
      dueDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}due_date']),
      returnedDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}returned_date']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      createdBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_by']),
    );
  }

  @override
  $BookLoansTable createAlias(String alias) {
    return $BookLoansTable(attachedDatabase, alias);
  }
}

class BookLoan extends DataClass implements Insertable<BookLoan> {
  final String id;
  final String bookId;
  final String borrowerName;
  final String? borrowerContact;
  final String loanedDate;
  final String? dueDate;
  final String? returnedDate;
  final String? notes;
  final String createdAt;
  final String? createdBy;
  const BookLoan(
      {required this.id,
      required this.bookId,
      required this.borrowerName,
      this.borrowerContact,
      required this.loanedDate,
      this.dueDate,
      this.returnedDate,
      this.notes,
      required this.createdAt,
      this.createdBy});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['book_id'] = Variable<String>(bookId);
    map['borrower_name'] = Variable<String>(borrowerName);
    if (!nullToAbsent || borrowerContact != null) {
      map['borrower_contact'] = Variable<String>(borrowerContact);
    }
    map['loaned_date'] = Variable<String>(loanedDate);
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<String>(dueDate);
    }
    if (!nullToAbsent || returnedDate != null) {
      map['returned_date'] = Variable<String>(returnedDate);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<String>(createdAt);
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    return map;
  }

  BookLoansCompanion toCompanion(bool nullToAbsent) {
    return BookLoansCompanion(
      id: Value(id),
      bookId: Value(bookId),
      borrowerName: Value(borrowerName),
      borrowerContact: borrowerContact == null && nullToAbsent
          ? const Value.absent()
          : Value(borrowerContact),
      loanedDate: Value(loanedDate),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      returnedDate: returnedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(returnedDate),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
    );
  }

  factory BookLoan.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookLoan(
      id: serializer.fromJson<String>(json['id']),
      bookId: serializer.fromJson<String>(json['bookId']),
      borrowerName: serializer.fromJson<String>(json['borrowerName']),
      borrowerContact: serializer.fromJson<String?>(json['borrowerContact']),
      loanedDate: serializer.fromJson<String>(json['loanedDate']),
      dueDate: serializer.fromJson<String?>(json['dueDate']),
      returnedDate: serializer.fromJson<String?>(json['returnedDate']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'bookId': serializer.toJson<String>(bookId),
      'borrowerName': serializer.toJson<String>(borrowerName),
      'borrowerContact': serializer.toJson<String?>(borrowerContact),
      'loanedDate': serializer.toJson<String>(loanedDate),
      'dueDate': serializer.toJson<String?>(dueDate),
      'returnedDate': serializer.toJson<String?>(returnedDate),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<String>(createdAt),
      'createdBy': serializer.toJson<String?>(createdBy),
    };
  }

  BookLoan copyWith(
          {String? id,
          String? bookId,
          String? borrowerName,
          Value<String?> borrowerContact = const Value.absent(),
          String? loanedDate,
          Value<String?> dueDate = const Value.absent(),
          Value<String?> returnedDate = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          String? createdAt,
          Value<String?> createdBy = const Value.absent()}) =>
      BookLoan(
        id: id ?? this.id,
        bookId: bookId ?? this.bookId,
        borrowerName: borrowerName ?? this.borrowerName,
        borrowerContact: borrowerContact.present
            ? borrowerContact.value
            : this.borrowerContact,
        loanedDate: loanedDate ?? this.loanedDate,
        dueDate: dueDate.present ? dueDate.value : this.dueDate,
        returnedDate:
            returnedDate.present ? returnedDate.value : this.returnedDate,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
        createdBy: createdBy.present ? createdBy.value : this.createdBy,
      );
  BookLoan copyWithCompanion(BookLoansCompanion data) {
    return BookLoan(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      borrowerName: data.borrowerName.present
          ? data.borrowerName.value
          : this.borrowerName,
      borrowerContact: data.borrowerContact.present
          ? data.borrowerContact.value
          : this.borrowerContact,
      loanedDate:
          data.loanedDate.present ? data.loanedDate.value : this.loanedDate,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      returnedDate: data.returnedDate.present
          ? data.returnedDate.value
          : this.returnedDate,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookLoan(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('borrowerName: $borrowerName, ')
          ..write('borrowerContact: $borrowerContact, ')
          ..write('loanedDate: $loanedDate, ')
          ..write('dueDate: $dueDate, ')
          ..write('returnedDate: $returnedDate, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdBy: $createdBy')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, bookId, borrowerName, borrowerContact,
      loanedDate, dueDate, returnedDate, notes, createdAt, createdBy);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookLoan &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.borrowerName == this.borrowerName &&
          other.borrowerContact == this.borrowerContact &&
          other.loanedDate == this.loanedDate &&
          other.dueDate == this.dueDate &&
          other.returnedDate == this.returnedDate &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.createdBy == this.createdBy);
}

class BookLoansCompanion extends UpdateCompanion<BookLoan> {
  final Value<String> id;
  final Value<String> bookId;
  final Value<String> borrowerName;
  final Value<String?> borrowerContact;
  final Value<String> loanedDate;
  final Value<String?> dueDate;
  final Value<String?> returnedDate;
  final Value<String?> notes;
  final Value<String> createdAt;
  final Value<String?> createdBy;
  final Value<int> rowid;
  const BookLoansCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.borrowerName = const Value.absent(),
    this.borrowerContact = const Value.absent(),
    this.loanedDate = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.returnedDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BookLoansCompanion.insert({
    required String id,
    required String bookId,
    required String borrowerName,
    this.borrowerContact = const Value.absent(),
    this.loanedDate = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.returnedDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        bookId = Value(bookId),
        borrowerName = Value(borrowerName);
  static Insertable<BookLoan> custom({
    Expression<String>? id,
    Expression<String>? bookId,
    Expression<String>? borrowerName,
    Expression<String>? borrowerContact,
    Expression<String>? loanedDate,
    Expression<String>? dueDate,
    Expression<String>? returnedDate,
    Expression<String>? notes,
    Expression<String>? createdAt,
    Expression<String>? createdBy,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (borrowerName != null) 'borrower_name': borrowerName,
      if (borrowerContact != null) 'borrower_contact': borrowerContact,
      if (loanedDate != null) 'loaned_date': loanedDate,
      if (dueDate != null) 'due_date': dueDate,
      if (returnedDate != null) 'returned_date': returnedDate,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (createdBy != null) 'created_by': createdBy,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BookLoansCompanion copyWith(
      {Value<String>? id,
      Value<String>? bookId,
      Value<String>? borrowerName,
      Value<String?>? borrowerContact,
      Value<String>? loanedDate,
      Value<String?>? dueDate,
      Value<String?>? returnedDate,
      Value<String?>? notes,
      Value<String>? createdAt,
      Value<String?>? createdBy,
      Value<int>? rowid}) {
    return BookLoansCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      borrowerName: borrowerName ?? this.borrowerName,
      borrowerContact: borrowerContact ?? this.borrowerContact,
      loanedDate: loanedDate ?? this.loanedDate,
      dueDate: dueDate ?? this.dueDate,
      returnedDate: returnedDate ?? this.returnedDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (borrowerName.present) {
      map['borrower_name'] = Variable<String>(borrowerName.value);
    }
    if (borrowerContact.present) {
      map['borrower_contact'] = Variable<String>(borrowerContact.value);
    }
    if (loanedDate.present) {
      map['loaned_date'] = Variable<String>(loanedDate.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<String>(dueDate.value);
    }
    if (returnedDate.present) {
      map['returned_date'] = Variable<String>(returnedDate.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookLoansCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('borrowerName: $borrowerName, ')
          ..write('borrowerContact: $borrowerContact, ')
          ..write('loanedDate: $loanedDate, ')
          ..write('dueDate: $dueDate, ')
          ..write('returnedDate: $returnedDate, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RoomsTable extends Rooms with TableInfo<$RoomsTable, Room> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoomsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 36, maxTextLength: 36),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name =
      GeneratedColumn<String>('name', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
            minTextLength: 1,
          ),
          type: DriftSqlType.string,
          requiredDuringInsert: true,
          $customConstraints: 'COLLATE NOCASE NOT NULL UNIQUE');
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'room';
  @override
  VerificationContext validateIntegrity(Insertable<Room> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Room map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Room(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
    );
  }

  @override
  $RoomsTable createAlias(String alias) {
    return $RoomsTable(attachedDatabase, alias);
  }
}

class Room extends DataClass implements Insertable<Room> {
  final String id;
  final String name;
  const Room({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  RoomsCompanion toCompanion(bool nullToAbsent) {
    return RoomsCompanion(
      id: Value(id),
      name: Value(name),
    );
  }

  factory Room.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Room(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  Room copyWith({String? id, String? name}) => Room(
        id: id ?? this.id,
        name: name ?? this.name,
      );
  Room copyWithCompanion(RoomsCompanion data) {
    return Room(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Room(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Room && other.id == this.id && other.name == this.name);
}

class RoomsCompanion extends UpdateCompanion<Room> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> rowid;
  const RoomsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RoomsCompanion.insert({
    required String id,
    required String name,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name);
  static Insertable<Room> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RoomsCompanion copyWith(
      {Value<String>? id, Value<String>? name, Value<int>? rowid}) {
    return RoomsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoomsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CupboardsTable extends Cupboards
    with TableInfo<$CupboardsTable, Cupboard> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CupboardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 36, maxTextLength: 36),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name =
      GeneratedColumn<String>('name', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
            minTextLength: 1,
          ),
          type: DriftSqlType.string,
          requiredDuringInsert: true);
  static const VerificationMeta _roomIdMeta = const VerificationMeta('roomId');
  @override
  late final GeneratedColumn<String> roomId = GeneratedColumn<String>(
      'room_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'REFERENCES room(id)');
  @override
  List<GeneratedColumn> get $columns => [id, name, roomId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cupboard';
  @override
  VerificationContext validateIntegrity(Insertable<Cupboard> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('room_id')) {
      context.handle(_roomIdMeta,
          roomId.isAcceptableOrUnknown(data['room_id']!, _roomIdMeta));
    } else if (isInserting) {
      context.missing(_roomIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Cupboard map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Cupboard(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      roomId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}room_id'])!,
    );
  }

  @override
  $CupboardsTable createAlias(String alias) {
    return $CupboardsTable(attachedDatabase, alias);
  }
}

class Cupboard extends DataClass implements Insertable<Cupboard> {
  final String id;
  final String name;
  final String roomId;
  const Cupboard({required this.id, required this.name, required this.roomId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['room_id'] = Variable<String>(roomId);
    return map;
  }

  CupboardsCompanion toCompanion(bool nullToAbsent) {
    return CupboardsCompanion(
      id: Value(id),
      name: Value(name),
      roomId: Value(roomId),
    );
  }

  factory Cupboard.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Cupboard(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      roomId: serializer.fromJson<String>(json['roomId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'roomId': serializer.toJson<String>(roomId),
    };
  }

  Cupboard copyWith({String? id, String? name, String? roomId}) => Cupboard(
        id: id ?? this.id,
        name: name ?? this.name,
        roomId: roomId ?? this.roomId,
      );
  Cupboard copyWithCompanion(CupboardsCompanion data) {
    return Cupboard(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      roomId: data.roomId.present ? data.roomId.value : this.roomId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Cupboard(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('roomId: $roomId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, roomId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Cupboard &&
          other.id == this.id &&
          other.name == this.name &&
          other.roomId == this.roomId);
}

class CupboardsCompanion extends UpdateCompanion<Cupboard> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> roomId;
  final Value<int> rowid;
  const CupboardsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.roomId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CupboardsCompanion.insert({
    required String id,
    required String name,
    required String roomId,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        roomId = Value(roomId);
  static Insertable<Cupboard> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? roomId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (roomId != null) 'room_id': roomId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CupboardsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? roomId,
      Value<int>? rowid}) {
    return CupboardsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      roomId: roomId ?? this.roomId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (roomId.present) {
      map['room_id'] = Variable<String>(roomId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CupboardsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('roomId: $roomId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ShelvesTable extends Shelves with TableInfo<$ShelvesTable, Shelve> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShelvesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 36, maxTextLength: 36),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name =
      GeneratedColumn<String>('name', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
            minTextLength: 1,
          ),
          type: DriftSqlType.string,
          requiredDuringInsert: true);
  static const VerificationMeta _cupboardIdMeta =
      const VerificationMeta('cupboardId');
  @override
  late final GeneratedColumn<String> cupboardId = GeneratedColumn<String>(
      'cupboard_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'REFERENCES cupboard(id)');
  @override
  List<GeneratedColumn> get $columns => [id, name, cupboardId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shelf';
  @override
  VerificationContext validateIntegrity(Insertable<Shelve> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('cupboard_id')) {
      context.handle(
          _cupboardIdMeta,
          cupboardId.isAcceptableOrUnknown(
              data['cupboard_id']!, _cupboardIdMeta));
    } else if (isInserting) {
      context.missing(_cupboardIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Shelve map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Shelve(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      cupboardId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cupboard_id'])!,
    );
  }

  @override
  $ShelvesTable createAlias(String alias) {
    return $ShelvesTable(attachedDatabase, alias);
  }
}

class Shelve extends DataClass implements Insertable<Shelve> {
  final String id;
  final String name;
  final String cupboardId;
  const Shelve(
      {required this.id, required this.name, required this.cupboardId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['cupboard_id'] = Variable<String>(cupboardId);
    return map;
  }

  ShelvesCompanion toCompanion(bool nullToAbsent) {
    return ShelvesCompanion(
      id: Value(id),
      name: Value(name),
      cupboardId: Value(cupboardId),
    );
  }

  factory Shelve.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Shelve(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      cupboardId: serializer.fromJson<String>(json['cupboardId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'cupboardId': serializer.toJson<String>(cupboardId),
    };
  }

  Shelve copyWith({String? id, String? name, String? cupboardId}) => Shelve(
        id: id ?? this.id,
        name: name ?? this.name,
        cupboardId: cupboardId ?? this.cupboardId,
      );
  Shelve copyWithCompanion(ShelvesCompanion data) {
    return Shelve(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      cupboardId:
          data.cupboardId.present ? data.cupboardId.value : this.cupboardId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Shelve(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('cupboardId: $cupboardId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, cupboardId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Shelve &&
          other.id == this.id &&
          other.name == this.name &&
          other.cupboardId == this.cupboardId);
}

class ShelvesCompanion extends UpdateCompanion<Shelve> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> cupboardId;
  final Value<int> rowid;
  const ShelvesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.cupboardId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ShelvesCompanion.insert({
    required String id,
    required String name,
    required String cupboardId,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        cupboardId = Value(cupboardId);
  static Insertable<Shelve> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? cupboardId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (cupboardId != null) 'cupboard_id': cupboardId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ShelvesCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? cupboardId,
      Value<int>? rowid}) {
    return ShelvesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      cupboardId: cupboardId ?? this.cupboardId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (cupboardId.present) {
      map['cupboard_id'] = Variable<String>(cupboardId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShelvesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('cupboardId: $cupboardId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BookShelvesTable extends BookShelves
    with TableInfo<$BookShelvesTable, BookShelve> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookShelvesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
      'book_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'REFERENCES book(id)');
  static const VerificationMeta _shelfIdMeta =
      const VerificationMeta('shelfId');
  @override
  late final GeneratedColumn<String> shelfId = GeneratedColumn<String>(
      'shelf_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: 'REFERENCES shelf(id)');
  @override
  List<GeneratedColumn> get $columns => [bookId, shelfId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'book_shelf';
  @override
  VerificationContext validateIntegrity(Insertable<BookShelve> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('book_id')) {
      context.handle(_bookIdMeta,
          bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta));
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('shelf_id')) {
      context.handle(_shelfIdMeta,
          shelfId.isAcceptableOrUnknown(data['shelf_id']!, _shelfIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {bookId};
  @override
  BookShelve map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookShelve(
      bookId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}book_id'])!,
      shelfId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}shelf_id']),
    );
  }

  @override
  $BookShelvesTable createAlias(String alias) {
    return $BookShelvesTable(attachedDatabase, alias);
  }
}

class BookShelve extends DataClass implements Insertable<BookShelve> {
  final String bookId;
  final String? shelfId;
  const BookShelve({required this.bookId, this.shelfId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['book_id'] = Variable<String>(bookId);
    if (!nullToAbsent || shelfId != null) {
      map['shelf_id'] = Variable<String>(shelfId);
    }
    return map;
  }

  BookShelvesCompanion toCompanion(bool nullToAbsent) {
    return BookShelvesCompanion(
      bookId: Value(bookId),
      shelfId: shelfId == null && nullToAbsent
          ? const Value.absent()
          : Value(shelfId),
    );
  }

  factory BookShelve.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookShelve(
      bookId: serializer.fromJson<String>(json['bookId']),
      shelfId: serializer.fromJson<String?>(json['shelfId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'bookId': serializer.toJson<String>(bookId),
      'shelfId': serializer.toJson<String?>(shelfId),
    };
  }

  BookShelve copyWith(
          {String? bookId, Value<String?> shelfId = const Value.absent()}) =>
      BookShelve(
        bookId: bookId ?? this.bookId,
        shelfId: shelfId.present ? shelfId.value : this.shelfId,
      );
  BookShelve copyWithCompanion(BookShelvesCompanion data) {
    return BookShelve(
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      shelfId: data.shelfId.present ? data.shelfId.value : this.shelfId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookShelve(')
          ..write('bookId: $bookId, ')
          ..write('shelfId: $shelfId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(bookId, shelfId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookShelve &&
          other.bookId == this.bookId &&
          other.shelfId == this.shelfId);
}

class BookShelvesCompanion extends UpdateCompanion<BookShelve> {
  final Value<String> bookId;
  final Value<String?> shelfId;
  final Value<int> rowid;
  const BookShelvesCompanion({
    this.bookId = const Value.absent(),
    this.shelfId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BookShelvesCompanion.insert({
    required String bookId,
    this.shelfId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : bookId = Value(bookId);
  static Insertable<BookShelve> custom({
    Expression<String>? bookId,
    Expression<String>? shelfId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (bookId != null) 'book_id': bookId,
      if (shelfId != null) 'shelf_id': shelfId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BookShelvesCompanion copyWith(
      {Value<String>? bookId, Value<String?>? shelfId, Value<int>? rowid}) {
    return BookShelvesCompanion(
      bookId: bookId ?? this.bookId,
      shelfId: shelfId ?? this.shelfId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (shelfId.present) {
      map['shelf_id'] = Variable<String>(shelfId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookShelvesCompanion(')
          ..write('bookId: $bookId, ')
          ..write('shelfId: $shelfId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChangeLogEventsTable extends ChangeLogEvents
    with TableInfo<$ChangeLogEventsTable, ChangeLogEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChangeLogEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _eventIdMeta =
      const VerificationMeta('eventId');
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
      'event_id', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 36, maxTextLength: 36),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _entityTypeMeta =
      const VerificationMeta('entityType');
  @override
  late final GeneratedColumn<String> entityType =
      GeneratedColumn<String>('entity_type', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
            minTextLength: 1,
          ),
          type: DriftSqlType.string,
          requiredDuringInsert: true);
  static const VerificationMeta _entityIdMeta =
      const VerificationMeta('entityId');
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
      'entity_id', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 36, maxTextLength: 36),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _fieldNameMeta =
      const VerificationMeta('fieldName');
  @override
  late final GeneratedColumn<String> fieldName =
      GeneratedColumn<String>('field_name', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
            minTextLength: 1,
          ),
          type: DriftSqlType.string,
          requiredDuringInsert: true);
  static const VerificationMeta _oldValueMeta =
      const VerificationMeta('oldValue');
  @override
  late final GeneratedColumn<String> oldValue = GeneratedColumn<String>(
      'old_value', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _newValueMeta =
      const VerificationMeta('newValue');
  @override
  late final GeneratedColumn<String> newValue = GeneratedColumn<String>(
      'new_value', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<String> timestamp = GeneratedColumn<String>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.now().toIso8601String());
  static const VerificationMeta _deviceUserMeta =
      const VerificationMeta('deviceUser');
  @override
  late final GeneratedColumn<String> deviceUser =
      GeneratedColumn<String>('device_user', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
            minTextLength: 1,
          ),
          type: DriftSqlType.string,
          requiredDuringInsert: true);
  static const VerificationMeta _eventTypeMeta =
      const VerificationMeta('eventType');
  @override
  late final GeneratedColumn<String> eventType =
      GeneratedColumn<String>('event_type', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
            minTextLength: 1,
          ),
          type: DriftSqlType.string,
          requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        eventId,
        entityType,
        entityId,
        fieldName,
        oldValue,
        newValue,
        timestamp,
        deviceUser,
        eventType
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'change_log';
  @override
  VerificationContext validateIntegrity(Insertable<ChangeLogEvent> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('event_id')) {
      context.handle(_eventIdMeta,
          eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta));
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
          _entityTypeMeta,
          entityType.isAcceptableOrUnknown(
              data['entity_type']!, _entityTypeMeta));
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(_entityIdMeta,
          entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta));
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('field_name')) {
      context.handle(_fieldNameMeta,
          fieldName.isAcceptableOrUnknown(data['field_name']!, _fieldNameMeta));
    } else if (isInserting) {
      context.missing(_fieldNameMeta);
    }
    if (data.containsKey('old_value')) {
      context.handle(_oldValueMeta,
          oldValue.isAcceptableOrUnknown(data['old_value']!, _oldValueMeta));
    }
    if (data.containsKey('new_value')) {
      context.handle(_newValueMeta,
          newValue.isAcceptableOrUnknown(data['new_value']!, _newValueMeta));
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    }
    if (data.containsKey('device_user')) {
      context.handle(
          _deviceUserMeta,
          deviceUser.isAcceptableOrUnknown(
              data['device_user']!, _deviceUserMeta));
    } else if (isInserting) {
      context.missing(_deviceUserMeta);
    }
    if (data.containsKey('event_type')) {
      context.handle(_eventTypeMeta,
          eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta));
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {eventId};
  @override
  ChangeLogEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChangeLogEvent(
      eventId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}event_id'])!,
      entityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_type'])!,
      entityId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_id'])!,
      fieldName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}field_name'])!,
      oldValue: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}old_value']),
      newValue: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}new_value']),
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}timestamp'])!,
      deviceUser: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_user'])!,
      eventType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}event_type'])!,
    );
  }

  @override
  $ChangeLogEventsTable createAlias(String alias) {
    return $ChangeLogEventsTable(attachedDatabase, alias);
  }
}

class ChangeLogEvent extends DataClass implements Insertable<ChangeLogEvent> {
  final String eventId;
  final String entityType;
  final String entityId;
  final String fieldName;
  final String? oldValue;
  final String? newValue;
  final String timestamp;
  final String deviceUser;
  final String eventType;
  const ChangeLogEvent(
      {required this.eventId,
      required this.entityType,
      required this.entityId,
      required this.fieldName,
      this.oldValue,
      this.newValue,
      required this.timestamp,
      required this.deviceUser,
      required this.eventType});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['event_id'] = Variable<String>(eventId);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['field_name'] = Variable<String>(fieldName);
    if (!nullToAbsent || oldValue != null) {
      map['old_value'] = Variable<String>(oldValue);
    }
    if (!nullToAbsent || newValue != null) {
      map['new_value'] = Variable<String>(newValue);
    }
    map['timestamp'] = Variable<String>(timestamp);
    map['device_user'] = Variable<String>(deviceUser);
    map['event_type'] = Variable<String>(eventType);
    return map;
  }

  ChangeLogEventsCompanion toCompanion(bool nullToAbsent) {
    return ChangeLogEventsCompanion(
      eventId: Value(eventId),
      entityType: Value(entityType),
      entityId: Value(entityId),
      fieldName: Value(fieldName),
      oldValue: oldValue == null && nullToAbsent
          ? const Value.absent()
          : Value(oldValue),
      newValue: newValue == null && nullToAbsent
          ? const Value.absent()
          : Value(newValue),
      timestamp: Value(timestamp),
      deviceUser: Value(deviceUser),
      eventType: Value(eventType),
    );
  }

  factory ChangeLogEvent.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChangeLogEvent(
      eventId: serializer.fromJson<String>(json['eventId']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      fieldName: serializer.fromJson<String>(json['fieldName']),
      oldValue: serializer.fromJson<String?>(json['oldValue']),
      newValue: serializer.fromJson<String?>(json['newValue']),
      timestamp: serializer.fromJson<String>(json['timestamp']),
      deviceUser: serializer.fromJson<String>(json['deviceUser']),
      eventType: serializer.fromJson<String>(json['eventType']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'eventId': serializer.toJson<String>(eventId),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'fieldName': serializer.toJson<String>(fieldName),
      'oldValue': serializer.toJson<String?>(oldValue),
      'newValue': serializer.toJson<String?>(newValue),
      'timestamp': serializer.toJson<String>(timestamp),
      'deviceUser': serializer.toJson<String>(deviceUser),
      'eventType': serializer.toJson<String>(eventType),
    };
  }

  ChangeLogEvent copyWith(
          {String? eventId,
          String? entityType,
          String? entityId,
          String? fieldName,
          Value<String?> oldValue = const Value.absent(),
          Value<String?> newValue = const Value.absent(),
          String? timestamp,
          String? deviceUser,
          String? eventType}) =>
      ChangeLogEvent(
        eventId: eventId ?? this.eventId,
        entityType: entityType ?? this.entityType,
        entityId: entityId ?? this.entityId,
        fieldName: fieldName ?? this.fieldName,
        oldValue: oldValue.present ? oldValue.value : this.oldValue,
        newValue: newValue.present ? newValue.value : this.newValue,
        timestamp: timestamp ?? this.timestamp,
        deviceUser: deviceUser ?? this.deviceUser,
        eventType: eventType ?? this.eventType,
      );
  ChangeLogEvent copyWithCompanion(ChangeLogEventsCompanion data) {
    return ChangeLogEvent(
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      entityType:
          data.entityType.present ? data.entityType.value : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      fieldName: data.fieldName.present ? data.fieldName.value : this.fieldName,
      oldValue: data.oldValue.present ? data.oldValue.value : this.oldValue,
      newValue: data.newValue.present ? data.newValue.value : this.newValue,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      deviceUser:
          data.deviceUser.present ? data.deviceUser.value : this.deviceUser,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChangeLogEvent(')
          ..write('eventId: $eventId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('fieldName: $fieldName, ')
          ..write('oldValue: $oldValue, ')
          ..write('newValue: $newValue, ')
          ..write('timestamp: $timestamp, ')
          ..write('deviceUser: $deviceUser, ')
          ..write('eventType: $eventType')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(eventId, entityType, entityId, fieldName,
      oldValue, newValue, timestamp, deviceUser, eventType);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChangeLogEvent &&
          other.eventId == this.eventId &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.fieldName == this.fieldName &&
          other.oldValue == this.oldValue &&
          other.newValue == this.newValue &&
          other.timestamp == this.timestamp &&
          other.deviceUser == this.deviceUser &&
          other.eventType == this.eventType);
}

class ChangeLogEventsCompanion extends UpdateCompanion<ChangeLogEvent> {
  final Value<String> eventId;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> fieldName;
  final Value<String?> oldValue;
  final Value<String?> newValue;
  final Value<String> timestamp;
  final Value<String> deviceUser;
  final Value<String> eventType;
  final Value<int> rowid;
  const ChangeLogEventsCompanion({
    this.eventId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.fieldName = const Value.absent(),
    this.oldValue = const Value.absent(),
    this.newValue = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.deviceUser = const Value.absent(),
    this.eventType = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChangeLogEventsCompanion.insert({
    required String eventId,
    required String entityType,
    required String entityId,
    required String fieldName,
    this.oldValue = const Value.absent(),
    this.newValue = const Value.absent(),
    this.timestamp = const Value.absent(),
    required String deviceUser,
    required String eventType,
    this.rowid = const Value.absent(),
  })  : eventId = Value(eventId),
        entityType = Value(entityType),
        entityId = Value(entityId),
        fieldName = Value(fieldName),
        deviceUser = Value(deviceUser),
        eventType = Value(eventType);
  static Insertable<ChangeLogEvent> custom({
    Expression<String>? eventId,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? fieldName,
    Expression<String>? oldValue,
    Expression<String>? newValue,
    Expression<String>? timestamp,
    Expression<String>? deviceUser,
    Expression<String>? eventType,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (eventId != null) 'event_id': eventId,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (fieldName != null) 'field_name': fieldName,
      if (oldValue != null) 'old_value': oldValue,
      if (newValue != null) 'new_value': newValue,
      if (timestamp != null) 'timestamp': timestamp,
      if (deviceUser != null) 'device_user': deviceUser,
      if (eventType != null) 'event_type': eventType,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChangeLogEventsCompanion copyWith(
      {Value<String>? eventId,
      Value<String>? entityType,
      Value<String>? entityId,
      Value<String>? fieldName,
      Value<String?>? oldValue,
      Value<String?>? newValue,
      Value<String>? timestamp,
      Value<String>? deviceUser,
      Value<String>? eventType,
      Value<int>? rowid}) {
    return ChangeLogEventsCompanion(
      eventId: eventId ?? this.eventId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      fieldName: fieldName ?? this.fieldName,
      oldValue: oldValue ?? this.oldValue,
      newValue: newValue ?? this.newValue,
      timestamp: timestamp ?? this.timestamp,
      deviceUser: deviceUser ?? this.deviceUser,
      eventType: eventType ?? this.eventType,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (fieldName.present) {
      map['field_name'] = Variable<String>(fieldName.value);
    }
    if (oldValue.present) {
      map['old_value'] = Variable<String>(oldValue.value);
    }
    if (newValue.present) {
      map['new_value'] = Variable<String>(newValue.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<String>(timestamp.value);
    }
    if (deviceUser.present) {
      map['device_user'] = Variable<String>(deviceUser.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChangeLogEventsCompanion(')
          ..write('eventId: $eventId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('fieldName: $fieldName, ')
          ..write('oldValue: $oldValue, ')
          ..write('newValue: $newValue, ')
          ..write('timestamp: $timestamp, ')
          ..write('deviceUser: $deviceUser, ')
          ..write('eventType: $eventType, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppMetadataTable extends AppMetadata
    with TableInfo<$AppMetadataTable, AppMetadataData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppMetadataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _schemaVersionMeta =
      const VerificationMeta('schemaVersion');
  @override
  late final GeneratedColumn<int> schemaVersion = GeneratedColumn<int>(
      'schema_version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  @override
  List<GeneratedColumn> get $columns => [schemaVersion];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_metadata';
  @override
  VerificationContext validateIntegrity(Insertable<AppMetadataData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('schema_version')) {
      context.handle(
          _schemaVersionMeta,
          schemaVersion.isAcceptableOrUnknown(
              data['schema_version']!, _schemaVersionMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {schemaVersion};
  @override
  AppMetadataData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppMetadataData(
      schemaVersion: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}schema_version'])!,
    );
  }

  @override
  $AppMetadataTable createAlias(String alias) {
    return $AppMetadataTable(attachedDatabase, alias);
  }
}

class AppMetadataData extends DataClass implements Insertable<AppMetadataData> {
  final int schemaVersion;
  const AppMetadataData({required this.schemaVersion});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['schema_version'] = Variable<int>(schemaVersion);
    return map;
  }

  AppMetadataCompanion toCompanion(bool nullToAbsent) {
    return AppMetadataCompanion(
      schemaVersion: Value(schemaVersion),
    );
  }

  factory AppMetadataData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppMetadataData(
      schemaVersion: serializer.fromJson<int>(json['schemaVersion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'schemaVersion': serializer.toJson<int>(schemaVersion),
    };
  }

  AppMetadataData copyWith({int? schemaVersion}) => AppMetadataData(
        schemaVersion: schemaVersion ?? this.schemaVersion,
      );
  AppMetadataData copyWithCompanion(AppMetadataCompanion data) {
    return AppMetadataData(
      schemaVersion: data.schemaVersion.present
          ? data.schemaVersion.value
          : this.schemaVersion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppMetadataData(')
          ..write('schemaVersion: $schemaVersion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => schemaVersion.hashCode;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppMetadataData && other.schemaVersion == this.schemaVersion);
}

class AppMetadataCompanion extends UpdateCompanion<AppMetadataData> {
  final Value<int> schemaVersion;
  const AppMetadataCompanion({
    this.schemaVersion = const Value.absent(),
  });
  AppMetadataCompanion.insert({
    this.schemaVersion = const Value.absent(),
  });
  static Insertable<AppMetadataData> custom({
    Expression<int>? schemaVersion,
  }) {
    return RawValuesInsertable({
      if (schemaVersion != null) 'schema_version': schemaVersion,
    });
  }

  AppMetadataCompanion copyWith({Value<int>? schemaVersion}) {
    return AppMetadataCompanion(
      schemaVersion: schemaVersion ?? this.schemaVersion,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (schemaVersion.present) {
      map['schema_version'] = Variable<int>(schemaVersion.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppMetadataCompanion(')
          ..write('schemaVersion: $schemaVersion')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  late final $BooksTable books = $BooksTable(this);
  late final $AuthorsTable authors = $AuthorsTable(this);
  late final $BookAuthorsTable bookAuthors = $BookAuthorsTable(this);
  late final $GenresTable genres = $GenresTable(this);
  late final $BookGenresTable bookGenres = $BookGenresTable(this);
  late final $TagsTable tags = $TagsTable(this);
  late final $BookTagsTable bookTags = $BookTagsTable(this);
  late final $LanguagesTable languages = $LanguagesTable(this);
  late final $BookLoansTable bookLoans = $BookLoansTable(this);
  late final $RoomsTable rooms = $RoomsTable(this);
  late final $CupboardsTable cupboards = $CupboardsTable(this);
  late final $ShelvesTable shelves = $ShelvesTable(this);
  late final $BookShelvesTable bookShelves = $BookShelvesTable(this);
  late final $ChangeLogEventsTable changeLogEvents =
      $ChangeLogEventsTable(this);
  late final $AppMetadataTable appMetadata = $AppMetadataTable(this);
  late final Index idxBookTitle =
      Index('idx_book_title', 'CREATE INDEX idx_book_title ON book (title)');
  late final Index idxBookIsbn =
      Index('idx_book_isbn', 'CREATE INDEX idx_book_isbn ON book (isbn)');
  late final Index idxBookLanguageId = Index('idx_book_language_id',
      'CREATE INDEX idx_book_language_id ON book (language_id)');
  late final Index idxBookFormat =
      Index('idx_book_format', 'CREATE INDEX idx_book_format ON book (format)');
  late final Index idxBookCondition = Index('idx_book_condition',
      'CREATE INDEX idx_book_condition ON book (condition)');
  late final Index idxBookPurchaseDate = Index('idx_book_purchase_date',
      'CREATE INDEX idx_book_purchase_date ON book (purchase_date)');
  late final Index idxBookCreatedAt = Index('idx_book_created_at',
      'CREATE INDEX idx_book_created_at ON book (created_at)');
  late final Index idxBookStatus =
      Index('idx_book_status', 'CREATE INDEX idx_book_status ON book (status)');
  late final Index idxBookCheckedOutTo = Index('idx_book_checked_out_to',
      'CREATE INDEX idx_book_checked_out_to ON book (checked_out_to)');
  late final Index idxAuthorNormalizedName = Index('idx_author_normalized_name',
      'CREATE INDEX idx_author_normalized_name ON author (normalized_name)');
  late final Index idxAuthorRawName = Index('idx_author_raw_name',
      'CREATE INDEX idx_author_raw_name ON author (raw_name)');
  late final Index idxBookAuthorBookId = Index('idx_book_author_book_id',
      'CREATE INDEX idx_book_author_book_id ON book_author (book_id)');
  late final Index idxBookAuthorAuthorId = Index('idx_book_author_author_id',
      'CREATE INDEX idx_book_author_author_id ON book_author (author_id)');
  late final Index idxGenreName =
      Index('idx_genre_name', 'CREATE INDEX idx_genre_name ON genre (name)');
  late final Index idxBookGenreBookId = Index('idx_book_genre_book_id',
      'CREATE INDEX idx_book_genre_book_id ON book_genre (book_id)');
  late final Index idxBookGenreGenreId = Index('idx_book_genre_genre_id',
      'CREATE INDEX idx_book_genre_genre_id ON book_genre (genre_id)');
  late final Index idxBookTagBookId = Index('idx_book_tag_book_id',
      'CREATE INDEX idx_book_tag_book_id ON book_tag (book_id)');
  late final Index idxBookTagTagId = Index('idx_book_tag_tag_id',
      'CREATE INDEX idx_book_tag_tag_id ON book_tag (tag_id)');
  late final Index idxLanguageName = Index(
      'idx_language_name', 'CREATE INDEX idx_language_name ON language (name)');
  late final Index idxBookLoanBookReturned = Index(
      'idx_book_loan_book_returned',
      'CREATE INDEX idx_book_loan_book_returned ON book_loan (book_id, returned_date)');
  late final Index idxBookLoanBorrowerName = Index(
      'idx_book_loan_borrower_name',
      'CREATE INDEX idx_book_loan_borrower_name ON book_loan (borrower_name)');
  late final Index idxRoomName =
      Index('idx_room_name', 'CREATE INDEX idx_room_name ON room (name)');
  late final Index idxCupboardRoomId = Index('idx_cupboard_room_id',
      'CREATE INDEX idx_cupboard_room_id ON cupboard (room_id)');
  late final Index idxShelfCupboardId = Index('idx_shelf_cupboard_id',
      'CREATE INDEX idx_shelf_cupboard_id ON shelf (cupboard_id)');
  late final Index idxChangeLogEntityTimestamp = Index(
      'idx_change_log_entity_timestamp',
      'CREATE INDEX idx_change_log_entity_timestamp ON change_log (entity_type, timestamp)');
  late final Index idxChangeLogEntityIdTimestamp = Index(
      'idx_change_log_entity_id_timestamp',
      'CREATE INDEX idx_change_log_entity_id_timestamp ON change_log (entity_type, entity_id, timestamp)');
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        books,
        authors,
        bookAuthors,
        genres,
        bookGenres,
        tags,
        bookTags,
        languages,
        bookLoans,
        rooms,
        cupboards,
        shelves,
        bookShelves,
        changeLogEvents,
        appMetadata,
        idxBookTitle,
        idxBookIsbn,
        idxBookLanguageId,
        idxBookFormat,
        idxBookCondition,
        idxBookPurchaseDate,
        idxBookCreatedAt,
        idxBookStatus,
        idxBookCheckedOutTo,
        idxAuthorNormalizedName,
        idxAuthorRawName,
        idxBookAuthorBookId,
        idxBookAuthorAuthorId,
        idxGenreName,
        idxBookGenreBookId,
        idxBookGenreGenreId,
        idxBookTagBookId,
        idxBookTagTagId,
        idxLanguageName,
        idxBookLoanBookReturned,
        idxBookLoanBorrowerName,
        idxRoomName,
        idxCupboardRoomId,
        idxShelfCupboardId,
        idxChangeLogEntityTimestamp,
        idxChangeLogEntityIdTimestamp
      ];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}
