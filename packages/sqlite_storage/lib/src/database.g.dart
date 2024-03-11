// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class KeyValue extends Table with TableInfo<KeyValue, KeyValueData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  KeyValue(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL PRIMARY KEY');
  late final GeneratedColumn<DriftAny> value = GeneratedColumn<DriftAny>(
      'value', aliasedName, true,
      type: DriftSqlType.any,
      requiredDuringInsert: false,
      $customConstraints: '');
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'key_value';
  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {key},
      ];
  @override
  KeyValueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KeyValueData(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.any, data['${effectivePrefix}value']),
    );
  }

  @override
  KeyValue createAlias(String alias) {
    return KeyValue(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
  @override
  List<String> get customConstraints => const ['UNIQUE("key")'];
  @override
  bool get dontWriteConstraints => true;
}

class KeyValueData extends DataClass implements Insertable<KeyValueData> {
  String key;
  DriftAny? value;
  KeyValueData({required this.key, this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    if (!nullToAbsent || value != null) {
      map['value'] = Variable<DriftAny>(value);
    }
    return map;
  }

  KeyValueCompanion toCompanion(bool nullToAbsent) {
    return KeyValueCompanion(
      key: Value(key),
      value:
          value == null && nullToAbsent ? const Value.absent() : Value(value),
    );
  }

  factory KeyValueData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KeyValueData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<DriftAny?>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<DriftAny?>(value),
    };
  }

  KeyValueData copyWith(
          {String? key, Value<DriftAny?> value = const Value.absent()}) =>
      KeyValueData(
        key: key ?? this.key,
        value: value.present ? value.value : this.value,
      );
  @override
  String toString() {
    return (StringBuffer('KeyValueData(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KeyValueData &&
          other.key == this.key &&
          other.value == this.value);
}

class KeyValueCompanion extends UpdateCompanion<KeyValueData> {
  Value<String> key;
  Value<DriftAny?> value;
  Value<int> rowid;
  KeyValueCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  KeyValueCompanion.insert({
    required String key,
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key);
  static Insertable<KeyValueData> custom({
    Expression<String>? key,
    Expression<DriftAny>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  KeyValueCompanion copyWith(
      {Value<String>? key, Value<DriftAny?>? value, Value<int>? rowid}) {
    return KeyValueCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<DriftAny>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KeyValueCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Documents extends Table with TableInfo<Documents, Doc> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Documents(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
      'path', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL PRIMARY KEY');
  late final GeneratedColumnWithTypeConverter<Map<String, dynamic>, String>
      data = GeneratedColumn<String>('data', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: true,
              $customConstraints: 'NOT NULL')
          .withConverter<Map<String, dynamic>>(Documents.$converterdata);
  late final GeneratedColumn<int> ttl = GeneratedColumn<int>(
      'ttl', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: '');
  late final GeneratedColumn<int> created = GeneratedColumn<int>(
      'created', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  late final GeneratedColumn<int> updated = GeneratedColumn<int>(
      'updated', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  @override
  List<GeneratedColumn> get $columns => [path, data, ttl, created, updated];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'documents';
  @override
  Set<GeneratedColumn> get $primaryKey => {path};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {path},
      ];
  @override
  Doc map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Doc(
      path: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}path'])!,
      data: Documents.$converterdata.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}data'])!),
      ttl: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ttl']),
      created: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created'])!,
      updated: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated'])!,
    );
  }

  @override
  Documents createAlias(String alias) {
    return Documents(attachedDatabase, alias);
  }

  static TypeConverter<Map<String, dynamic>, String> $converterdata =
      const JsonMapConverter();
  @override
  List<String> get customConstraints => const ['UNIQUE(path)'];
  @override
  bool get dontWriteConstraints => true;
}

class Doc extends DataClass implements Insertable<Doc> {
  String path;
  Map<String, dynamic> data;
  int? ttl;
  int created;
  int updated;
  Doc(
      {required this.path,
      required this.data,
      this.ttl,
      required this.created,
      required this.updated});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['path'] = Variable<String>(path);
    {
      map['data'] = Variable<String>(Documents.$converterdata.toSql(data));
    }
    if (!nullToAbsent || ttl != null) {
      map['ttl'] = Variable<int>(ttl);
    }
    map['created'] = Variable<int>(created);
    map['updated'] = Variable<int>(updated);
    return map;
  }

  DocumentsCompanion toCompanion(bool nullToAbsent) {
    return DocumentsCompanion(
      path: Value(path),
      data: Value(data),
      ttl: ttl == null && nullToAbsent ? const Value.absent() : Value(ttl),
      created: Value(created),
      updated: Value(updated),
    );
  }

  factory Doc.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Doc(
      path: serializer.fromJson<String>(json['path']),
      data: serializer.fromJson<Map<String, dynamic>>(json['data']),
      ttl: serializer.fromJson<int?>(json['ttl']),
      created: serializer.fromJson<int>(json['created']),
      updated: serializer.fromJson<int>(json['updated']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'path': serializer.toJson<String>(path),
      'data': serializer.toJson<Map<String, dynamic>>(data),
      'ttl': serializer.toJson<int?>(ttl),
      'created': serializer.toJson<int>(created),
      'updated': serializer.toJson<int>(updated),
    };
  }

  Doc copyWith(
          {String? path,
          Map<String, dynamic>? data,
          Value<int?> ttl = const Value.absent(),
          int? created,
          int? updated}) =>
      Doc(
        path: path ?? this.path,
        data: data ?? this.data,
        ttl: ttl.present ? ttl.value : this.ttl,
        created: created ?? this.created,
        updated: updated ?? this.updated,
      );
  @override
  String toString() {
    return (StringBuffer('Doc(')
          ..write('path: $path, ')
          ..write('data: $data, ')
          ..write('ttl: $ttl, ')
          ..write('created: $created, ')
          ..write('updated: $updated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(path, data, ttl, created, updated);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Doc &&
          other.path == this.path &&
          other.data == this.data &&
          other.ttl == this.ttl &&
          other.created == this.created &&
          other.updated == this.updated);
}

class DocumentsCompanion extends UpdateCompanion<Doc> {
  Value<String> path;
  Value<Map<String, dynamic>> data;
  Value<int?> ttl;
  Value<int> created;
  Value<int> updated;
  Value<int> rowid;
  DocumentsCompanion({
    this.path = const Value.absent(),
    this.data = const Value.absent(),
    this.ttl = const Value.absent(),
    this.created = const Value.absent(),
    this.updated = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DocumentsCompanion.insert({
    required String path,
    required Map<String, dynamic> data,
    this.ttl = const Value.absent(),
    required int created,
    required int updated,
    this.rowid = const Value.absent(),
  })  : path = Value(path),
        data = Value(data),
        created = Value(created),
        updated = Value(updated);
  static Insertable<Doc> custom({
    Expression<String>? path,
    Expression<String>? data,
    Expression<int>? ttl,
    Expression<int>? created,
    Expression<int>? updated,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (path != null) 'path': path,
      if (data != null) 'data': data,
      if (ttl != null) 'ttl': ttl,
      if (created != null) 'created': created,
      if (updated != null) 'updated': updated,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DocumentsCompanion copyWith(
      {Value<String>? path,
      Value<Map<String, dynamic>>? data,
      Value<int?>? ttl,
      Value<int>? created,
      Value<int>? updated,
      Value<int>? rowid}) {
    return DocumentsCompanion(
      path: path ?? this.path,
      data: data ?? this.data,
      ttl: ttl ?? this.ttl,
      created: created ?? this.created,
      updated: updated ?? this.updated,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (data.present) {
      map['data'] =
          Variable<String>(Documents.$converterdata.toSql(data.value));
    }
    if (ttl.present) {
      map['ttl'] = Variable<int>(ttl.value);
    }
    if (created.present) {
      map['created'] = Variable<int>(created.value);
    }
    if (updated.present) {
      map['updated'] = Variable<int>(updated.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DocumentsCompanion(')
          ..write('path: $path, ')
          ..write('data: $data, ')
          ..write('ttl: $ttl, ')
          ..write('created: $created, ')
          ..write('updated: $updated, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Analytics extends Table with TableInfo<Analytics, AnalyticsEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Analytics(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: 'PRIMARY KEY AUTOINCREMENT');
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  late final GeneratedColumnWithTypeConverter<Map<String, dynamic>, String>
      parameters = GeneratedColumn<String>('parameters', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: true,
              $customConstraints: 'NOT NULL')
          .withConverter<Map<String, dynamic>>(Analytics.$converterparameters);
  late final GeneratedColumn<int> date = GeneratedColumn<int>(
      'date', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  @override
  List<GeneratedColumn> get $columns => [id, type, parameters, date];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'analytics';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AnalyticsEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AnalyticsEvent(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      parameters: Analytics.$converterparameters.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}parameters'])!),
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}date'])!,
    );
  }

  @override
  Analytics createAlias(String alias) {
    return Analytics(attachedDatabase, alias);
  }

  static TypeConverter<Map<String, dynamic>, String> $converterparameters =
      const JsonMapConverter();
  @override
  bool get dontWriteConstraints => true;
}

class AnalyticsEvent extends DataClass implements Insertable<AnalyticsEvent> {
  int id;
  String type;
  Map<String, dynamic> parameters;
  int date;
  AnalyticsEvent(
      {required this.id,
      required this.type,
      required this.parameters,
      required this.date});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['type'] = Variable<String>(type);
    {
      map['parameters'] =
          Variable<String>(Analytics.$converterparameters.toSql(parameters));
    }
    map['date'] = Variable<int>(date);
    return map;
  }

  AnalyticsCompanion toCompanion(bool nullToAbsent) {
    return AnalyticsCompanion(
      id: Value(id),
      type: Value(type),
      parameters: Value(parameters),
      date: Value(date),
    );
  }

  factory AnalyticsEvent.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AnalyticsEvent(
      id: serializer.fromJson<int>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      parameters: serializer.fromJson<Map<String, dynamic>>(json['parameters']),
      date: serializer.fromJson<int>(json['date']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'type': serializer.toJson<String>(type),
      'parameters': serializer.toJson<Map<String, dynamic>>(parameters),
      'date': serializer.toJson<int>(date),
    };
  }

  AnalyticsEvent copyWith(
          {int? id,
          String? type,
          Map<String, dynamic>? parameters,
          int? date}) =>
      AnalyticsEvent(
        id: id ?? this.id,
        type: type ?? this.type,
        parameters: parameters ?? this.parameters,
        date: date ?? this.date,
      );
  @override
  String toString() {
    return (StringBuffer('AnalyticsEvent(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('parameters: $parameters, ')
          ..write('date: $date')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, type, parameters, date);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AnalyticsEvent &&
          other.id == this.id &&
          other.type == this.type &&
          other.parameters == this.parameters &&
          other.date == this.date);
}

class AnalyticsCompanion extends UpdateCompanion<AnalyticsEvent> {
  Value<int> id;
  Value<String> type;
  Value<Map<String, dynamic>> parameters;
  Value<int> date;
  AnalyticsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.parameters = const Value.absent(),
    this.date = const Value.absent(),
  });
  AnalyticsCompanion.insert({
    this.id = const Value.absent(),
    required String type,
    required Map<String, dynamic> parameters,
    required int date,
  })  : type = Value(type),
        parameters = Value(parameters),
        date = Value(date);
  static Insertable<AnalyticsEvent> custom({
    Expression<int>? id,
    Expression<String>? type,
    Expression<String>? parameters,
    Expression<int>? date,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (parameters != null) 'parameters': parameters,
      if (date != null) 'date': date,
    });
  }

  AnalyticsCompanion copyWith(
      {Value<int>? id,
      Value<String>? type,
      Value<Map<String, dynamic>>? parameters,
      Value<int>? date}) {
    return AnalyticsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      parameters: parameters ?? this.parameters,
      date: date ?? this.date,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (parameters.present) {
      map['parameters'] = Variable<String>(
          Analytics.$converterparameters.toSql(parameters.value));
    }
    if (date.present) {
      map['date'] = Variable<int>(date.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AnalyticsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('parameters: $parameters, ')
          ..write('date: $date')
          ..write(')'))
        .toString();
  }
}

class Files extends Table with TableInfo<Files, FileData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Files(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
      'path', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL PRIMARY KEY');
  late final GeneratedColumn<Uint8List> data = GeneratedColumn<Uint8List>(
      'data', aliasedName, true,
      type: DriftSqlType.blob,
      requiredDuringInsert: false,
      $customConstraints: '');
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
      'mime_type', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  late final GeneratedColumn<int> size = GeneratedColumn<int>(
      'size', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: '');
  late final GeneratedColumn<String> hash = GeneratedColumn<String>(
      'hash', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  late final GeneratedColumn<int> created = GeneratedColumn<int>(
      'created', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  late final GeneratedColumn<int> updated = GeneratedColumn<int>(
      'updated', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  @override
  List<GeneratedColumn> get $columns =>
      [path, data, mimeType, size, hash, created, updated];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'files';
  @override
  Set<GeneratedColumn> get $primaryKey => {path};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {path},
      ];
  @override
  FileData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FileData(
      path: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}path'])!,
      data: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}data']),
      mimeType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mime_type']),
      size: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}size']),
      hash: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}hash']),
      created: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created'])!,
      updated: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated'])!,
    );
  }

  @override
  Files createAlias(String alias) {
    return Files(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const ['UNIQUE(path)'];
  @override
  bool get dontWriteConstraints => true;
}

class FileData extends DataClass implements Insertable<FileData> {
  String path;
  Uint8List? data;
  String? mimeType;
  int? size;
  String? hash;
  int created;
  int updated;
  FileData(
      {required this.path,
      this.data,
      this.mimeType,
      this.size,
      this.hash,
      required this.created,
      required this.updated});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['path'] = Variable<String>(path);
    if (!nullToAbsent || data != null) {
      map['data'] = Variable<Uint8List>(data);
    }
    if (!nullToAbsent || mimeType != null) {
      map['mime_type'] = Variable<String>(mimeType);
    }
    if (!nullToAbsent || size != null) {
      map['size'] = Variable<int>(size);
    }
    if (!nullToAbsent || hash != null) {
      map['hash'] = Variable<String>(hash);
    }
    map['created'] = Variable<int>(created);
    map['updated'] = Variable<int>(updated);
    return map;
  }

  FilesCompanion toCompanion(bool nullToAbsent) {
    return FilesCompanion(
      path: Value(path),
      data: data == null && nullToAbsent ? const Value.absent() : Value(data),
      mimeType: mimeType == null && nullToAbsent
          ? const Value.absent()
          : Value(mimeType),
      size: size == null && nullToAbsent ? const Value.absent() : Value(size),
      hash: hash == null && nullToAbsent ? const Value.absent() : Value(hash),
      created: Value(created),
      updated: Value(updated),
    );
  }

  factory FileData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FileData(
      path: serializer.fromJson<String>(json['path']),
      data: serializer.fromJson<Uint8List?>(json['data']),
      mimeType: serializer.fromJson<String?>(json['mime_type']),
      size: serializer.fromJson<int?>(json['size']),
      hash: serializer.fromJson<String?>(json['hash']),
      created: serializer.fromJson<int>(json['created']),
      updated: serializer.fromJson<int>(json['updated']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'path': serializer.toJson<String>(path),
      'data': serializer.toJson<Uint8List?>(data),
      'mime_type': serializer.toJson<String?>(mimeType),
      'size': serializer.toJson<int?>(size),
      'hash': serializer.toJson<String?>(hash),
      'created': serializer.toJson<int>(created),
      'updated': serializer.toJson<int>(updated),
    };
  }

  FileData copyWith(
          {String? path,
          Value<Uint8List?> data = const Value.absent(),
          Value<String?> mimeType = const Value.absent(),
          Value<int?> size = const Value.absent(),
          Value<String?> hash = const Value.absent(),
          int? created,
          int? updated}) =>
      FileData(
        path: path ?? this.path,
        data: data.present ? data.value : this.data,
        mimeType: mimeType.present ? mimeType.value : this.mimeType,
        size: size.present ? size.value : this.size,
        hash: hash.present ? hash.value : this.hash,
        created: created ?? this.created,
        updated: updated ?? this.updated,
      );
  @override
  String toString() {
    return (StringBuffer('FileData(')
          ..write('path: $path, ')
          ..write('data: $data, ')
          ..write('mimeType: $mimeType, ')
          ..write('size: $size, ')
          ..write('hash: $hash, ')
          ..write('created: $created, ')
          ..write('updated: $updated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(path, $driftBlobEquality.hash(data), mimeType,
      size, hash, created, updated);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FileData &&
          other.path == this.path &&
          $driftBlobEquality.equals(other.data, this.data) &&
          other.mimeType == this.mimeType &&
          other.size == this.size &&
          other.hash == this.hash &&
          other.created == this.created &&
          other.updated == this.updated);
}

class FilesCompanion extends UpdateCompanion<FileData> {
  Value<String> path;
  Value<Uint8List?> data;
  Value<String?> mimeType;
  Value<int?> size;
  Value<String?> hash;
  Value<int> created;
  Value<int> updated;
  Value<int> rowid;
  FilesCompanion({
    this.path = const Value.absent(),
    this.data = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.size = const Value.absent(),
    this.hash = const Value.absent(),
    this.created = const Value.absent(),
    this.updated = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FilesCompanion.insert({
    required String path,
    this.data = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.size = const Value.absent(),
    this.hash = const Value.absent(),
    required int created,
    required int updated,
    this.rowid = const Value.absent(),
  })  : path = Value(path),
        created = Value(created),
        updated = Value(updated);
  static Insertable<FileData> custom({
    Expression<String>? path,
    Expression<Uint8List>? data,
    Expression<String>? mimeType,
    Expression<int>? size,
    Expression<String>? hash,
    Expression<int>? created,
    Expression<int>? updated,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (path != null) 'path': path,
      if (data != null) 'data': data,
      if (mimeType != null) 'mime_type': mimeType,
      if (size != null) 'size': size,
      if (hash != null) 'hash': hash,
      if (created != null) 'created': created,
      if (updated != null) 'updated': updated,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FilesCompanion copyWith(
      {Value<String>? path,
      Value<Uint8List?>? data,
      Value<String?>? mimeType,
      Value<int?>? size,
      Value<String?>? hash,
      Value<int>? created,
      Value<int>? updated,
      Value<int>? rowid}) {
    return FilesCompanion(
      path: path ?? this.path,
      data: data ?? this.data,
      mimeType: mimeType ?? this.mimeType,
      size: size ?? this.size,
      hash: hash ?? this.hash,
      created: created ?? this.created,
      updated: updated ?? this.updated,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (data.present) {
      map['data'] = Variable<Uint8List>(data.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (size.present) {
      map['size'] = Variable<int>(size.value);
    }
    if (hash.present) {
      map['hash'] = Variable<String>(hash.value);
    }
    if (created.present) {
      map['created'] = Variable<int>(created.value);
    }
    if (updated.present) {
      map['updated'] = Variable<int>(updated.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FilesCompanion(')
          ..write('path: $path, ')
          ..write('data: $data, ')
          ..write('mimeType: $mimeType, ')
          ..write('size: $size, ')
          ..write('hash: $hash, ')
          ..write('created: $created, ')
          ..write('updated: $updated, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Nodes extends Table with TableInfo<Nodes, DatabaseNode> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Nodes(this.attachedDatabase, [this._alias]);
  late final GeneratedColumnWithTypeConverter<Map<String, dynamic>, String>
      body = GeneratedColumn<String>('body', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: true,
              $customConstraints: 'NOT NULL')
          .withConverter<Map<String, dynamic>>(Nodes.$converterbody);
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      generatedAs: GeneratedAs(
          const CustomExpression('json_extract(body, \'\$.id\')'), false),
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints:
          'GENERATED ALWAYS AS (json_extract(body, \'\$.id\')) VIRTUAL NOT NULL UNIQUE');
  @override
  List<GeneratedColumn> get $columns => [body, id];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'nodes';
  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  DatabaseNode map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DatabaseNode(
      body: Nodes.$converterbody.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}body'])!),
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
    );
  }

  @override
  Nodes createAlias(String alias) {
    return Nodes(attachedDatabase, alias);
  }

  static TypeConverter<Map<String, dynamic>, String> $converterbody =
      const JsonMapConverter();
  @override
  bool get dontWriteConstraints => true;
}

class DatabaseNode extends DataClass implements Insertable<DatabaseNode> {
  Map<String, dynamic> body;
  String id;
  DatabaseNode({required this.body, required this.id});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['body'] = Variable<String>(Nodes.$converterbody.toSql(body));
    }
    return map;
  }

  NodesCompanion toCompanion(bool nullToAbsent) {
    return NodesCompanion(
      body: Value(body),
    );
  }

  factory DatabaseNode.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DatabaseNode(
      body: serializer.fromJson<Map<String, dynamic>>(json['body']),
      id: serializer.fromJson<String>(json['id']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'body': serializer.toJson<Map<String, dynamic>>(body),
      'id': serializer.toJson<String>(id),
    };
  }

  DatabaseNode copyWith({Map<String, dynamic>? body, String? id}) =>
      DatabaseNode(
        body: body ?? this.body,
        id: id ?? this.id,
      );
  @override
  String toString() {
    return (StringBuffer('DatabaseNode(')
          ..write('body: $body, ')
          ..write('id: $id')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(body, id);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DatabaseNode && other.body == this.body && other.id == this.id);
}

class NodesCompanion extends UpdateCompanion<DatabaseNode> {
  Value<Map<String, dynamic>> body;
  Value<int> rowid;
  NodesCompanion({
    this.body = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NodesCompanion.insert({
    required Map<String, dynamic> body,
    this.rowid = const Value.absent(),
  }) : body = Value(body);
  static Insertable<DatabaseNode> custom({
    Expression<String>? body,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (body != null) 'body': body,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NodesCompanion copyWith(
      {Value<Map<String, dynamic>>? body, Value<int>? rowid}) {
    return NodesCompanion(
      body: body ?? this.body,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (body.present) {
      map['body'] = Variable<String>(Nodes.$converterbody.toSql(body.value));
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NodesCompanion(')
          ..write('body: $body, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Edges extends Table with TableInfo<Edges, DatabaseEdge> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Edges(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  late final GeneratedColumn<String> target = GeneratedColumn<String>(
      'target', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  late final GeneratedColumnWithTypeConverter<Map<String, dynamic>, String>
      properties = GeneratedColumn<String>('properties', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: true,
              $customConstraints: 'NOT NULL')
          .withConverter<Map<String, dynamic>>(Edges.$converterproperties);
  @override
  List<GeneratedColumn> get $columns => [source, target, properties];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'edges';
  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {source, target, properties},
      ];
  @override
  DatabaseEdge map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DatabaseEdge(
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source'])!,
      target: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}target'])!,
      properties: Edges.$converterproperties.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}properties'])!),
    );
  }

  @override
  Edges createAlias(String alias) {
    return Edges(attachedDatabase, alias);
  }

  static TypeConverter<Map<String, dynamic>, String> $converterproperties =
      const JsonMapConverter();
  @override
  List<String> get customConstraints => const [
        'UNIQUE(source, target, properties)ON CONFLICT REPLACE',
        'FOREIGN KEY(source)REFERENCES nodes(id)',
        'FOREIGN KEY(target)REFERENCES nodes(id)'
      ];
  @override
  bool get dontWriteConstraints => true;
}

class DatabaseEdge extends DataClass implements Insertable<DatabaseEdge> {
  String source;
  String target;
  Map<String, dynamic> properties;
  DatabaseEdge(
      {required this.source, required this.target, required this.properties});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['source'] = Variable<String>(source);
    map['target'] = Variable<String>(target);
    {
      map['properties'] =
          Variable<String>(Edges.$converterproperties.toSql(properties));
    }
    return map;
  }

  EdgesCompanion toCompanion(bool nullToAbsent) {
    return EdgesCompanion(
      source: Value(source),
      target: Value(target),
      properties: Value(properties),
    );
  }

  factory DatabaseEdge.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DatabaseEdge(
      source: serializer.fromJson<String>(json['source']),
      target: serializer.fromJson<String>(json['target']),
      properties: serializer.fromJson<Map<String, dynamic>>(json['properties']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'source': serializer.toJson<String>(source),
      'target': serializer.toJson<String>(target),
      'properties': serializer.toJson<Map<String, dynamic>>(properties),
    };
  }

  DatabaseEdge copyWith(
          {String? source, String? target, Map<String, dynamic>? properties}) =>
      DatabaseEdge(
        source: source ?? this.source,
        target: target ?? this.target,
        properties: properties ?? this.properties,
      );
  @override
  String toString() {
    return (StringBuffer('DatabaseEdge(')
          ..write('source: $source, ')
          ..write('target: $target, ')
          ..write('properties: $properties')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(source, target, properties);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DatabaseEdge &&
          other.source == this.source &&
          other.target == this.target &&
          other.properties == this.properties);
}

class EdgesCompanion extends UpdateCompanion<DatabaseEdge> {
  Value<String> source;
  Value<String> target;
  Value<Map<String, dynamic>> properties;
  Value<int> rowid;
  EdgesCompanion({
    this.source = const Value.absent(),
    this.target = const Value.absent(),
    this.properties = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EdgesCompanion.insert({
    required String source,
    required String target,
    required Map<String, dynamic> properties,
    this.rowid = const Value.absent(),
  })  : source = Value(source),
        target = Value(target),
        properties = Value(properties);
  static Insertable<DatabaseEdge> custom({
    Expression<String>? source,
    Expression<String>? target,
    Expression<String>? properties,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (source != null) 'source': source,
      if (target != null) 'target': target,
      if (properties != null) 'properties': properties,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EdgesCompanion copyWith(
      {Value<String>? source,
      Value<String>? target,
      Value<Map<String, dynamic>>? properties,
      Value<int>? rowid}) {
    return EdgesCompanion(
      source: source ?? this.source,
      target: target ?? this.target,
      properties: properties ?? this.properties,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (target.present) {
      map['target'] = Variable<String>(target.value);
    }
    if (properties.present) {
      map['properties'] =
          Variable<String>(Edges.$converterproperties.toSql(properties.value));
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EdgesCompanion(')
          ..write('source: $source, ')
          ..write('target: $target, ')
          ..write('properties: $properties, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Logging extends Table with TableInfo<Logging, Log> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Logging(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: 'PRIMARY KEY AUTOINCREMENT');
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
      'message', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  late final GeneratedColumn<int> date = GeneratedColumn<int>(
      'date', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  late final GeneratedColumn<int> sequenceNumber = GeneratedColumn<int>(
      'sequence_number', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: '');
  late final GeneratedColumn<int> level = GeneratedColumn<int>(
      'level', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  late final GeneratedColumn<String> error = GeneratedColumn<String>(
      'error', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  late final GeneratedColumn<String> stackTrace = GeneratedColumn<String>(
      'stack_trace', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  @override
  List<GeneratedColumn> get $columns =>
      [id, message, date, sequenceNumber, level, name, error, stackTrace];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'logging';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Log map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Log(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      message: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}message']),
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}date'])!,
      sequenceNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sequence_number']),
      level: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}level'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      error: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}error']),
      stackTrace: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}stack_trace']),
    );
  }

  @override
  Logging createAlias(String alias) {
    return Logging(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class Log extends DataClass implements Insertable<Log> {
  int id;
  String? message;
  int date;
  int? sequenceNumber;
  int level;
  String name;
  String? error;
  String? stackTrace;
  Log(
      {required this.id,
      this.message,
      required this.date,
      this.sequenceNumber,
      required this.level,
      required this.name,
      this.error,
      this.stackTrace});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || message != null) {
      map['message'] = Variable<String>(message);
    }
    map['date'] = Variable<int>(date);
    if (!nullToAbsent || sequenceNumber != null) {
      map['sequence_number'] = Variable<int>(sequenceNumber);
    }
    map['level'] = Variable<int>(level);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || error != null) {
      map['error'] = Variable<String>(error);
    }
    if (!nullToAbsent || stackTrace != null) {
      map['stack_trace'] = Variable<String>(stackTrace);
    }
    return map;
  }

  LoggingCompanion toCompanion(bool nullToAbsent) {
    return LoggingCompanion(
      id: Value(id),
      message: message == null && nullToAbsent
          ? const Value.absent()
          : Value(message),
      date: Value(date),
      sequenceNumber: sequenceNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(sequenceNumber),
      level: Value(level),
      name: Value(name),
      error:
          error == null && nullToAbsent ? const Value.absent() : Value(error),
      stackTrace: stackTrace == null && nullToAbsent
          ? const Value.absent()
          : Value(stackTrace),
    );
  }

  factory Log.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Log(
      id: serializer.fromJson<int>(json['id']),
      message: serializer.fromJson<String?>(json['message']),
      date: serializer.fromJson<int>(json['date']),
      sequenceNumber: serializer.fromJson<int?>(json['sequence_number']),
      level: serializer.fromJson<int>(json['level']),
      name: serializer.fromJson<String>(json['name']),
      error: serializer.fromJson<String?>(json['error']),
      stackTrace: serializer.fromJson<String?>(json['stack_trace']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'message': serializer.toJson<String?>(message),
      'date': serializer.toJson<int>(date),
      'sequence_number': serializer.toJson<int?>(sequenceNumber),
      'level': serializer.toJson<int>(level),
      'name': serializer.toJson<String>(name),
      'error': serializer.toJson<String?>(error),
      'stack_trace': serializer.toJson<String?>(stackTrace),
    };
  }

  Log copyWith(
          {int? id,
          Value<String?> message = const Value.absent(),
          int? date,
          Value<int?> sequenceNumber = const Value.absent(),
          int? level,
          String? name,
          Value<String?> error = const Value.absent(),
          Value<String?> stackTrace = const Value.absent()}) =>
      Log(
        id: id ?? this.id,
        message: message.present ? message.value : this.message,
        date: date ?? this.date,
        sequenceNumber:
            sequenceNumber.present ? sequenceNumber.value : this.sequenceNumber,
        level: level ?? this.level,
        name: name ?? this.name,
        error: error.present ? error.value : this.error,
        stackTrace: stackTrace.present ? stackTrace.value : this.stackTrace,
      );
  @override
  String toString() {
    return (StringBuffer('Log(')
          ..write('id: $id, ')
          ..write('message: $message, ')
          ..write('date: $date, ')
          ..write('sequenceNumber: $sequenceNumber, ')
          ..write('level: $level, ')
          ..write('name: $name, ')
          ..write('error: $error, ')
          ..write('stackTrace: $stackTrace')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, message, date, sequenceNumber, level, name, error, stackTrace);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Log &&
          other.id == this.id &&
          other.message == this.message &&
          other.date == this.date &&
          other.sequenceNumber == this.sequenceNumber &&
          other.level == this.level &&
          other.name == this.name &&
          other.error == this.error &&
          other.stackTrace == this.stackTrace);
}

class LoggingCompanion extends UpdateCompanion<Log> {
  Value<int> id;
  Value<String?> message;
  Value<int> date;
  Value<int?> sequenceNumber;
  Value<int> level;
  Value<String> name;
  Value<String?> error;
  Value<String?> stackTrace;
  LoggingCompanion({
    this.id = const Value.absent(),
    this.message = const Value.absent(),
    this.date = const Value.absent(),
    this.sequenceNumber = const Value.absent(),
    this.level = const Value.absent(),
    this.name = const Value.absent(),
    this.error = const Value.absent(),
    this.stackTrace = const Value.absent(),
  });
  LoggingCompanion.insert({
    this.id = const Value.absent(),
    this.message = const Value.absent(),
    required int date,
    this.sequenceNumber = const Value.absent(),
    required int level,
    required String name,
    this.error = const Value.absent(),
    this.stackTrace = const Value.absent(),
  })  : date = Value(date),
        level = Value(level),
        name = Value(name);
  static Insertable<Log> custom({
    Expression<int>? id,
    Expression<String>? message,
    Expression<int>? date,
    Expression<int>? sequenceNumber,
    Expression<int>? level,
    Expression<String>? name,
    Expression<String>? error,
    Expression<String>? stackTrace,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (message != null) 'message': message,
      if (date != null) 'date': date,
      if (sequenceNumber != null) 'sequence_number': sequenceNumber,
      if (level != null) 'level': level,
      if (name != null) 'name': name,
      if (error != null) 'error': error,
      if (stackTrace != null) 'stack_trace': stackTrace,
    });
  }

  LoggingCompanion copyWith(
      {Value<int>? id,
      Value<String?>? message,
      Value<int>? date,
      Value<int?>? sequenceNumber,
      Value<int>? level,
      Value<String>? name,
      Value<String?>? error,
      Value<String?>? stackTrace}) {
    return LoggingCompanion(
      id: id ?? this.id,
      message: message ?? this.message,
      date: date ?? this.date,
      sequenceNumber: sequenceNumber ?? this.sequenceNumber,
      level: level ?? this.level,
      name: name ?? this.name,
      error: error ?? this.error,
      stackTrace: stackTrace ?? this.stackTrace,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (date.present) {
      map['date'] = Variable<int>(date.value);
    }
    if (sequenceNumber.present) {
      map['sequence_number'] = Variable<int>(sequenceNumber.value);
    }
    if (level.present) {
      map['level'] = Variable<int>(level.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (error.present) {
      map['error'] = Variable<String>(error.value);
    }
    if (stackTrace.present) {
      map['stack_trace'] = Variable<String>(stackTrace.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LoggingCompanion(')
          ..write('id: $id, ')
          ..write('message: $message, ')
          ..write('date: $date, ')
          ..write('sequenceNumber: $sequenceNumber, ')
          ..write('level: $level, ')
          ..write('name: $name, ')
          ..write('error: $error, ')
          ..write('stackTrace: $stackTrace')
          ..write(')'))
        .toString();
  }
}

class Requests extends Table with TableInfo<Requests, CachedRequest> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Requests(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: 'PRIMARY KEY AUTOINCREMENT NOT NULL');
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
      'url', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  late final GeneratedColumn<String> headers = GeneratedColumn<String>(
      'headers', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  late final GeneratedColumn<Uint8List> body = GeneratedColumn<Uint8List>(
      'body', aliasedName, true,
      type: DriftSqlType.blob,
      requiredDuringInsert: false,
      $customConstraints: '');
  late final GeneratedColumn<int> date = GeneratedColumn<int>(
      'date', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  @override
  List<GeneratedColumn> get $columns => [id, url, headers, body, date];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'requests';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {url},
      ];
  @override
  CachedRequest map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedRequest(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      url: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}url'])!,
      headers: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}headers'])!,
      body: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}body']),
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}date'])!,
    );
  }

  @override
  Requests createAlias(String alias) {
    return Requests(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const ['UNIQUE(url)'];
  @override
  bool get dontWriteConstraints => true;
}

class CachedRequest extends DataClass implements Insertable<CachedRequest> {
  int id;
  String url;
  String headers;
  Uint8List? body;
  int date;
  CachedRequest(
      {required this.id,
      required this.url,
      required this.headers,
      this.body,
      required this.date});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['url'] = Variable<String>(url);
    map['headers'] = Variable<String>(headers);
    if (!nullToAbsent || body != null) {
      map['body'] = Variable<Uint8List>(body);
    }
    map['date'] = Variable<int>(date);
    return map;
  }

  RequestsCompanion toCompanion(bool nullToAbsent) {
    return RequestsCompanion(
      id: Value(id),
      url: Value(url),
      headers: Value(headers),
      body: body == null && nullToAbsent ? const Value.absent() : Value(body),
      date: Value(date),
    );
  }

  factory CachedRequest.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedRequest(
      id: serializer.fromJson<int>(json['id']),
      url: serializer.fromJson<String>(json['url']),
      headers: serializer.fromJson<String>(json['headers']),
      body: serializer.fromJson<Uint8List?>(json['body']),
      date: serializer.fromJson<int>(json['date']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'url': serializer.toJson<String>(url),
      'headers': serializer.toJson<String>(headers),
      'body': serializer.toJson<Uint8List?>(body),
      'date': serializer.toJson<int>(date),
    };
  }

  CachedRequest copyWith(
          {int? id,
          String? url,
          String? headers,
          Value<Uint8List?> body = const Value.absent(),
          int? date}) =>
      CachedRequest(
        id: id ?? this.id,
        url: url ?? this.url,
        headers: headers ?? this.headers,
        body: body.present ? body.value : this.body,
        date: date ?? this.date,
      );
  @override
  String toString() {
    return (StringBuffer('CachedRequest(')
          ..write('id: $id, ')
          ..write('url: $url, ')
          ..write('headers: $headers, ')
          ..write('body: $body, ')
          ..write('date: $date')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, url, headers, $driftBlobEquality.hash(body), date);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedRequest &&
          other.id == this.id &&
          other.url == this.url &&
          other.headers == this.headers &&
          $driftBlobEquality.equals(other.body, this.body) &&
          other.date == this.date);
}

class RequestsCompanion extends UpdateCompanion<CachedRequest> {
  Value<int> id;
  Value<String> url;
  Value<String> headers;
  Value<Uint8List?> body;
  Value<int> date;
  RequestsCompanion({
    this.id = const Value.absent(),
    this.url = const Value.absent(),
    this.headers = const Value.absent(),
    this.body = const Value.absent(),
    this.date = const Value.absent(),
  });
  RequestsCompanion.insert({
    this.id = const Value.absent(),
    required String url,
    required String headers,
    this.body = const Value.absent(),
    required int date,
  })  : url = Value(url),
        headers = Value(headers),
        date = Value(date);
  static Insertable<CachedRequest> custom({
    Expression<int>? id,
    Expression<String>? url,
    Expression<String>? headers,
    Expression<Uint8List>? body,
    Expression<int>? date,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (url != null) 'url': url,
      if (headers != null) 'headers': headers,
      if (body != null) 'body': body,
      if (date != null) 'date': date,
    });
  }

  RequestsCompanion copyWith(
      {Value<int>? id,
      Value<String>? url,
      Value<String>? headers,
      Value<Uint8List?>? body,
      Value<int>? date}) {
    return RequestsCompanion(
      id: id ?? this.id,
      url: url ?? this.url,
      headers: headers ?? this.headers,
      body: body ?? this.body,
      date: date ?? this.date,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (headers.present) {
      map['headers'] = Variable<String>(headers.value);
    }
    if (body.present) {
      map['body'] = Variable<Uint8List>(body.value);
    }
    if (date.present) {
      map['date'] = Variable<int>(date.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RequestsCompanion(')
          ..write('id: $id, ')
          ..write('url: $url, ')
          ..write('headers: $headers, ')
          ..write('body: $body, ')
          ..write('date: $date')
          ..write(')'))
        .toString();
  }
}

class RequestsQueue extends Table
    with TableInfo<RequestsQueue, RequestsQueueData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  RequestsQueue(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: 'PRIMARY KEY AUTOINCREMENT');
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
      'url', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  late final GeneratedColumn<String> method = GeneratedColumn<String>(
      'method', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  late final GeneratedColumn<Uint8List> body = GeneratedColumn<Uint8List>(
      'body', aliasedName, true,
      type: DriftSqlType.blob,
      requiredDuringInsert: false,
      $customConstraints: '');
  late final GeneratedColumnWithTypeConverter<Map<String, dynamic>, String>
      headers = GeneratedColumn<String>('headers', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: true,
              $customConstraints: 'NOT NULL')
          .withConverter<Map<String, dynamic>>(RequestsQueue.$converterheaders);
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
      'retry_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: 'NOT NULL DEFAULT 0',
      defaultValue: const CustomExpression('0'));
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  late final GeneratedColumn<int> date = GeneratedColumn<int>(
      'date', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  @override
  List<GeneratedColumn> get $columns =>
      [id, url, method, body, headers, retryCount, description, date];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'requests_queue';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RequestsQueueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RequestsQueueData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      url: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}url'])!,
      method: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}method'])!,
      body: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}body']),
      headers: RequestsQueue.$converterheaders.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}headers'])!),
      retryCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}retry_count'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}date'])!,
    );
  }

  @override
  RequestsQueue createAlias(String alias) {
    return RequestsQueue(attachedDatabase, alias);
  }

  static TypeConverter<Map<String, dynamic>, String> $converterheaders =
      const JsonMapConverter();
  @override
  bool get dontWriteConstraints => true;
}

class RequestsQueueData extends DataClass
    implements Insertable<RequestsQueueData> {
  int id;
  String url;
  String method;
  Uint8List? body;
  Map<String, dynamic> headers;
  int retryCount;
  String? description;
  int date;
  RequestsQueueData(
      {required this.id,
      required this.url,
      required this.method,
      this.body,
      required this.headers,
      required this.retryCount,
      this.description,
      required this.date});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['url'] = Variable<String>(url);
    map['method'] = Variable<String>(method);
    if (!nullToAbsent || body != null) {
      map['body'] = Variable<Uint8List>(body);
    }
    {
      map['headers'] =
          Variable<String>(RequestsQueue.$converterheaders.toSql(headers));
    }
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['date'] = Variable<int>(date);
    return map;
  }

  RequestsQueueCompanion toCompanion(bool nullToAbsent) {
    return RequestsQueueCompanion(
      id: Value(id),
      url: Value(url),
      method: Value(method),
      body: body == null && nullToAbsent ? const Value.absent() : Value(body),
      headers: Value(headers),
      retryCount: Value(retryCount),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      date: Value(date),
    );
  }

  factory RequestsQueueData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RequestsQueueData(
      id: serializer.fromJson<int>(json['id']),
      url: serializer.fromJson<String>(json['url']),
      method: serializer.fromJson<String>(json['method']),
      body: serializer.fromJson<Uint8List?>(json['body']),
      headers: serializer.fromJson<Map<String, dynamic>>(json['headers']),
      retryCount: serializer.fromJson<int>(json['retry_count']),
      description: serializer.fromJson<String?>(json['description']),
      date: serializer.fromJson<int>(json['date']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'url': serializer.toJson<String>(url),
      'method': serializer.toJson<String>(method),
      'body': serializer.toJson<Uint8List?>(body),
      'headers': serializer.toJson<Map<String, dynamic>>(headers),
      'retry_count': serializer.toJson<int>(retryCount),
      'description': serializer.toJson<String?>(description),
      'date': serializer.toJson<int>(date),
    };
  }

  RequestsQueueData copyWith(
          {int? id,
          String? url,
          String? method,
          Value<Uint8List?> body = const Value.absent(),
          Map<String, dynamic>? headers,
          int? retryCount,
          Value<String?> description = const Value.absent(),
          int? date}) =>
      RequestsQueueData(
        id: id ?? this.id,
        url: url ?? this.url,
        method: method ?? this.method,
        body: body.present ? body.value : this.body,
        headers: headers ?? this.headers,
        retryCount: retryCount ?? this.retryCount,
        description: description.present ? description.value : this.description,
        date: date ?? this.date,
      );
  @override
  String toString() {
    return (StringBuffer('RequestsQueueData(')
          ..write('id: $id, ')
          ..write('url: $url, ')
          ..write('method: $method, ')
          ..write('body: $body, ')
          ..write('headers: $headers, ')
          ..write('retryCount: $retryCount, ')
          ..write('description: $description, ')
          ..write('date: $date')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, url, method,
      $driftBlobEquality.hash(body), headers, retryCount, description, date);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RequestsQueueData &&
          other.id == this.id &&
          other.url == this.url &&
          other.method == this.method &&
          $driftBlobEquality.equals(other.body, this.body) &&
          other.headers == this.headers &&
          other.retryCount == this.retryCount &&
          other.description == this.description &&
          other.date == this.date);
}

class RequestsQueueCompanion extends UpdateCompanion<RequestsQueueData> {
  Value<int> id;
  Value<String> url;
  Value<String> method;
  Value<Uint8List?> body;
  Value<Map<String, dynamic>> headers;
  Value<int> retryCount;
  Value<String?> description;
  Value<int> date;
  RequestsQueueCompanion({
    this.id = const Value.absent(),
    this.url = const Value.absent(),
    this.method = const Value.absent(),
    this.body = const Value.absent(),
    this.headers = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.description = const Value.absent(),
    this.date = const Value.absent(),
  });
  RequestsQueueCompanion.insert({
    this.id = const Value.absent(),
    required String url,
    required String method,
    this.body = const Value.absent(),
    required Map<String, dynamic> headers,
    this.retryCount = const Value.absent(),
    this.description = const Value.absent(),
    required int date,
  })  : url = Value(url),
        method = Value(method),
        headers = Value(headers),
        date = Value(date);
  static Insertable<RequestsQueueData> custom({
    Expression<int>? id,
    Expression<String>? url,
    Expression<String>? method,
    Expression<Uint8List>? body,
    Expression<String>? headers,
    Expression<int>? retryCount,
    Expression<String>? description,
    Expression<int>? date,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (url != null) 'url': url,
      if (method != null) 'method': method,
      if (body != null) 'body': body,
      if (headers != null) 'headers': headers,
      if (retryCount != null) 'retry_count': retryCount,
      if (description != null) 'description': description,
      if (date != null) 'date': date,
    });
  }

  RequestsQueueCompanion copyWith(
      {Value<int>? id,
      Value<String>? url,
      Value<String>? method,
      Value<Uint8List?>? body,
      Value<Map<String, dynamic>>? headers,
      Value<int>? retryCount,
      Value<String?>? description,
      Value<int>? date}) {
    return RequestsQueueCompanion(
      id: id ?? this.id,
      url: url ?? this.url,
      method: method ?? this.method,
      body: body ?? this.body,
      headers: headers ?? this.headers,
      retryCount: retryCount ?? this.retryCount,
      description: description ?? this.description,
      date: date ?? this.date,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(method.value);
    }
    if (body.present) {
      map['body'] = Variable<Uint8List>(body.value);
    }
    if (headers.present) {
      map['headers'] = Variable<String>(
          RequestsQueue.$converterheaders.toSql(headers.value));
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (date.present) {
      map['date'] = Variable<int>(date.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RequestsQueueCompanion(')
          ..write('id: $id, ')
          ..write('url: $url, ')
          ..write('method: $method, ')
          ..write('body: $body, ')
          ..write('headers: $headers, ')
          ..write('retryCount: $retryCount, ')
          ..write('description: $description, ')
          ..write('date: $date')
          ..write(')'))
        .toString();
  }
}

class RequestsQueueFiles extends Table
    with TableInfo<RequestsQueueFiles, RequestsQueueFile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  RequestsQueueFiles(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: 'PRIMARY KEY AUTOINCREMENT');
  late final GeneratedColumn<int> requestsQueueId = GeneratedColumn<int>(
      'requests_queue_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL REFERENCES requests_queue(id)');
  late final GeneratedColumn<String> field = GeneratedColumn<String>(
      'field', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  late final GeneratedColumn<Uint8List> value = GeneratedColumn<Uint8List>(
      'value', aliasedName, false,
      type: DriftSqlType.blob,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  @override
  List<GeneratedColumn> get $columns => [id, requestsQueueId, field, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'requests_queue_files';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RequestsQueueFile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RequestsQueueFile(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      requestsQueueId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}requests_queue_id'])!,
      field: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}field'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}value'])!,
    );
  }

  @override
  RequestsQueueFiles createAlias(String alias) {
    return RequestsQueueFiles(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class RequestsQueueFile extends DataClass
    implements Insertable<RequestsQueueFile> {
  int id;
  int requestsQueueId;
  String field;
  Uint8List value;
  RequestsQueueFile(
      {required this.id,
      required this.requestsQueueId,
      required this.field,
      required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['requests_queue_id'] = Variable<int>(requestsQueueId);
    map['field'] = Variable<String>(field);
    map['value'] = Variable<Uint8List>(value);
    return map;
  }

  RequestsQueueFilesCompanion toCompanion(bool nullToAbsent) {
    return RequestsQueueFilesCompanion(
      id: Value(id),
      requestsQueueId: Value(requestsQueueId),
      field: Value(field),
      value: Value(value),
    );
  }

  factory RequestsQueueFile.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RequestsQueueFile(
      id: serializer.fromJson<int>(json['id']),
      requestsQueueId: serializer.fromJson<int>(json['requests_queue_id']),
      field: serializer.fromJson<String>(json['field']),
      value: serializer.fromJson<Uint8List>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'requests_queue_id': serializer.toJson<int>(requestsQueueId),
      'field': serializer.toJson<String>(field),
      'value': serializer.toJson<Uint8List>(value),
    };
  }

  RequestsQueueFile copyWith(
          {int? id, int? requestsQueueId, String? field, Uint8List? value}) =>
      RequestsQueueFile(
        id: id ?? this.id,
        requestsQueueId: requestsQueueId ?? this.requestsQueueId,
        field: field ?? this.field,
        value: value ?? this.value,
      );
  @override
  String toString() {
    return (StringBuffer('RequestsQueueFile(')
          ..write('id: $id, ')
          ..write('requestsQueueId: $requestsQueueId, ')
          ..write('field: $field, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, requestsQueueId, field, $driftBlobEquality.hash(value));
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RequestsQueueFile &&
          other.id == this.id &&
          other.requestsQueueId == this.requestsQueueId &&
          other.field == this.field &&
          $driftBlobEquality.equals(other.value, this.value));
}

class RequestsQueueFilesCompanion extends UpdateCompanion<RequestsQueueFile> {
  Value<int> id;
  Value<int> requestsQueueId;
  Value<String> field;
  Value<Uint8List> value;
  RequestsQueueFilesCompanion({
    this.id = const Value.absent(),
    this.requestsQueueId = const Value.absent(),
    this.field = const Value.absent(),
    this.value = const Value.absent(),
  });
  RequestsQueueFilesCompanion.insert({
    this.id = const Value.absent(),
    required int requestsQueueId,
    required String field,
    required Uint8List value,
  })  : requestsQueueId = Value(requestsQueueId),
        field = Value(field),
        value = Value(value);
  static Insertable<RequestsQueueFile> custom({
    Expression<int>? id,
    Expression<int>? requestsQueueId,
    Expression<String>? field,
    Expression<Uint8List>? value,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (requestsQueueId != null) 'requests_queue_id': requestsQueueId,
      if (field != null) 'field': field,
      if (value != null) 'value': value,
    });
  }

  RequestsQueueFilesCompanion copyWith(
      {Value<int>? id,
      Value<int>? requestsQueueId,
      Value<String>? field,
      Value<Uint8List>? value}) {
    return RequestsQueueFilesCompanion(
      id: id ?? this.id,
      requestsQueueId: requestsQueueId ?? this.requestsQueueId,
      field: field ?? this.field,
      value: value ?? this.value,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (requestsQueueId.present) {
      map['requests_queue_id'] = Variable<int>(requestsQueueId.value);
    }
    if (field.present) {
      map['field'] = Variable<String>(field.value);
    }
    if (value.present) {
      map['value'] = Variable<Uint8List>(value.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RequestsQueueFilesCompanion(')
          ..write('id: $id, ')
          ..write('requestsQueueId: $requestsQueueId, ')
          ..write('field: $field, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }
}

abstract class _$DriftStorage extends GeneratedDatabase {
  _$DriftStorage(QueryExecutor e) : super(e);
  late final KeyValue keyValue = KeyValue(this);
  late final Documents documents = Documents(this);
  late final Analytics analytics = Analytics(this);
  late final Files files = Files(this);
  late final Nodes nodes = Nodes(this);
  late final Index idIdx =
      Index('id_idx', 'CREATE INDEX IF NOT EXISTS id_idx ON nodes (id)');
  late final Edges edges = Edges(this);
  late final Index sourceIdx = Index(
      'source_idx', 'CREATE INDEX IF NOT EXISTS source_idx ON edges (source)');
  late final Index targetIdx = Index(
      'target_idx', 'CREATE INDEX IF NOT EXISTS target_idx ON edges (target)');
  late final Logging logging = Logging(this);
  late final Requests requests = Requests(this);
  late final RequestsQueue requestsQueue = RequestsQueue(this);
  late final RequestsQueueFiles requestsQueueFiles = RequestsQueueFiles(this);
  late final KeyValueDao keyValueDao = KeyValueDao(this as DriftStorage);
  late final DocumentsDao documentsDao = DocumentsDao(this as DriftStorage);
  late final FilesDao filesDao = FilesDao(this as DriftStorage);
  late final AnalyticsDao analyticsDao = AnalyticsDao(this as DriftStorage);
  late final GraphDao graphDao = GraphDao(this as DriftStorage);
  late final LoggingDao loggingDao = LoggingDao(this as DriftStorage);
  late final RequestsDao requestsDao = RequestsDao(this as DriftStorage);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        keyValue,
        documents,
        analytics,
        files,
        nodes,
        idIdx,
        edges,
        sourceIdx,
        targetIdx,
        logging,
        requests,
        requestsQueue,
        requestsQueueFiles
      ];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}
