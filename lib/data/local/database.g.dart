// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $PrayerZonesTable extends PrayerZones
    with TableInfo<$PrayerZonesTable, PrayerZoneRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PrayerZonesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 4,
      maxTextLength: 8,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _areasMeta = const VerificationMeta('areas');
  @override
  late final GeneratedColumn<String> areas = GeneratedColumn<String>(
    'areas',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
    'lat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lngMeta = const VerificationMeta('lng');
  @override
  late final GeneratedColumn<double> lng = GeneratedColumn<double>(
    'lng',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    code,
    state,
    areas,
    lat,
    lng,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'prayer_zones';
  @override
  VerificationContext validateIntegrity(
    Insertable<PrayerZoneRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('areas')) {
      context.handle(
        _areasMeta,
        areas.isAcceptableOrUnknown(data['areas']!, _areasMeta),
      );
    } else if (isInserting) {
      context.missing(_areasMeta);
    }
    if (data.containsKey('lat')) {
      context.handle(
        _latMeta,
        lat.isAcceptableOrUnknown(data['lat']!, _latMeta),
      );
    }
    if (data.containsKey('lng')) {
      context.handle(
        _lngMeta,
        lng.isAcceptableOrUnknown(data['lng']!, _lngMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {code};
  @override
  PrayerZoneRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PrayerZoneRow(
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      areas: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}areas'],
      )!,
      lat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lat'],
      ),
      lng: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lng'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PrayerZonesTable createAlias(String alias) {
    return $PrayerZonesTable(attachedDatabase, alias);
  }
}

class PrayerZoneRow extends DataClass implements Insertable<PrayerZoneRow> {
  final String code;
  final String state;
  final String areas;
  final double? lat;
  final double? lng;
  final DateTime updatedAt;
  const PrayerZoneRow({
    required this.code,
    required this.state,
    required this.areas,
    this.lat,
    this.lng,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['code'] = Variable<String>(code);
    map['state'] = Variable<String>(state);
    map['areas'] = Variable<String>(areas);
    if (!nullToAbsent || lat != null) {
      map['lat'] = Variable<double>(lat);
    }
    if (!nullToAbsent || lng != null) {
      map['lng'] = Variable<double>(lng);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PrayerZonesCompanion toCompanion(bool nullToAbsent) {
    return PrayerZonesCompanion(
      code: Value(code),
      state: Value(state),
      areas: Value(areas),
      lat: lat == null && nullToAbsent ? const Value.absent() : Value(lat),
      lng: lng == null && nullToAbsent ? const Value.absent() : Value(lng),
      updatedAt: Value(updatedAt),
    );
  }

  factory PrayerZoneRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PrayerZoneRow(
      code: serializer.fromJson<String>(json['code']),
      state: serializer.fromJson<String>(json['state']),
      areas: serializer.fromJson<String>(json['areas']),
      lat: serializer.fromJson<double?>(json['lat']),
      lng: serializer.fromJson<double?>(json['lng']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'code': serializer.toJson<String>(code),
      'state': serializer.toJson<String>(state),
      'areas': serializer.toJson<String>(areas),
      'lat': serializer.toJson<double?>(lat),
      'lng': serializer.toJson<double?>(lng),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PrayerZoneRow copyWith({
    String? code,
    String? state,
    String? areas,
    Value<double?> lat = const Value.absent(),
    Value<double?> lng = const Value.absent(),
    DateTime? updatedAt,
  }) => PrayerZoneRow(
    code: code ?? this.code,
    state: state ?? this.state,
    areas: areas ?? this.areas,
    lat: lat.present ? lat.value : this.lat,
    lng: lng.present ? lng.value : this.lng,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PrayerZoneRow copyWithCompanion(PrayerZonesCompanion data) {
    return PrayerZoneRow(
      code: data.code.present ? data.code.value : this.code,
      state: data.state.present ? data.state.value : this.state,
      areas: data.areas.present ? data.areas.value : this.areas,
      lat: data.lat.present ? data.lat.value : this.lat,
      lng: data.lng.present ? data.lng.value : this.lng,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PrayerZoneRow(')
          ..write('code: $code, ')
          ..write('state: $state, ')
          ..write('areas: $areas, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(code, state, areas, lat, lng, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PrayerZoneRow &&
          other.code == this.code &&
          other.state == this.state &&
          other.areas == this.areas &&
          other.lat == this.lat &&
          other.lng == this.lng &&
          other.updatedAt == this.updatedAt);
}

class PrayerZonesCompanion extends UpdateCompanion<PrayerZoneRow> {
  final Value<String> code;
  final Value<String> state;
  final Value<String> areas;
  final Value<double?> lat;
  final Value<double?> lng;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PrayerZonesCompanion({
    this.code = const Value.absent(),
    this.state = const Value.absent(),
    this.areas = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PrayerZonesCompanion.insert({
    required String code,
    required String state,
    required String areas,
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : code = Value(code),
       state = Value(state),
       areas = Value(areas);
  static Insertable<PrayerZoneRow> custom({
    Expression<String>? code,
    Expression<String>? state,
    Expression<String>? areas,
    Expression<double>? lat,
    Expression<double>? lng,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (code != null) 'code': code,
      if (state != null) 'state': state,
      if (areas != null) 'areas': areas,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PrayerZonesCompanion copyWith({
    Value<String>? code,
    Value<String>? state,
    Value<String>? areas,
    Value<double?>? lat,
    Value<double?>? lng,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return PrayerZonesCompanion(
      code: code ?? this.code,
      state: state ?? this.state,
      areas: areas ?? this.areas,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (areas.present) {
      map['areas'] = Variable<String>(areas.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lng.present) {
      map['lng'] = Variable<double>(lng.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PrayerZonesCompanion(')
          ..write('code: $code, ')
          ..write('state: $state, ')
          ..write('areas: $areas, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PrayerTimesTable extends PrayerTimes
    with TableInfo<$PrayerTimesTable, PrayerTimeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PrayerTimesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _zoneMeta = const VerificationMeta('zone');
  @override
  late final GeneratedColumn<String> zone = GeneratedColumn<String>(
    'zone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES prayer_zones (code)',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imsakMeta = const VerificationMeta('imsak');
  @override
  late final GeneratedColumn<int> imsak = GeneratedColumn<int>(
    'imsak',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _subuhMeta = const VerificationMeta('subuh');
  @override
  late final GeneratedColumn<int> subuh = GeneratedColumn<int>(
    'subuh',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syurukMeta = const VerificationMeta('syuruk');
  @override
  late final GeneratedColumn<int> syuruk = GeneratedColumn<int>(
    'syuruk',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _zohorMeta = const VerificationMeta('zohor');
  @override
  late final GeneratedColumn<int> zohor = GeneratedColumn<int>(
    'zohor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _asarMeta = const VerificationMeta('asar');
  @override
  late final GeneratedColumn<int> asar = GeneratedColumn<int>(
    'asar',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _maghribMeta = const VerificationMeta(
    'maghrib',
  );
  @override
  late final GeneratedColumn<int> maghrib = GeneratedColumn<int>(
    'maghrib',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isyakMeta = const VerificationMeta('isyak');
  @override
  late final GeneratedColumn<int> isyak = GeneratedColumn<int>(
    'isyak',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hijriMeta = const VerificationMeta('hijri');
  @override
  late final GeneratedColumn<String> hijri = GeneratedColumn<String>(
    'hijri',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    zone,
    date,
    imsak,
    subuh,
    syuruk,
    zohor,
    asar,
    maghrib,
    isyak,
    hijri,
    source,
    fetchedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'prayer_times';
  @override
  VerificationContext validateIntegrity(
    Insertable<PrayerTimeRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('zone')) {
      context.handle(
        _zoneMeta,
        zone.isAcceptableOrUnknown(data['zone']!, _zoneMeta),
      );
    } else if (isInserting) {
      context.missing(_zoneMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('imsak')) {
      context.handle(
        _imsakMeta,
        imsak.isAcceptableOrUnknown(data['imsak']!, _imsakMeta),
      );
    }
    if (data.containsKey('subuh')) {
      context.handle(
        _subuhMeta,
        subuh.isAcceptableOrUnknown(data['subuh']!, _subuhMeta),
      );
    } else if (isInserting) {
      context.missing(_subuhMeta);
    }
    if (data.containsKey('syuruk')) {
      context.handle(
        _syurukMeta,
        syuruk.isAcceptableOrUnknown(data['syuruk']!, _syurukMeta),
      );
    } else if (isInserting) {
      context.missing(_syurukMeta);
    }
    if (data.containsKey('zohor')) {
      context.handle(
        _zohorMeta,
        zohor.isAcceptableOrUnknown(data['zohor']!, _zohorMeta),
      );
    } else if (isInserting) {
      context.missing(_zohorMeta);
    }
    if (data.containsKey('asar')) {
      context.handle(
        _asarMeta,
        asar.isAcceptableOrUnknown(data['asar']!, _asarMeta),
      );
    } else if (isInserting) {
      context.missing(_asarMeta);
    }
    if (data.containsKey('maghrib')) {
      context.handle(
        _maghribMeta,
        maghrib.isAcceptableOrUnknown(data['maghrib']!, _maghribMeta),
      );
    } else if (isInserting) {
      context.missing(_maghribMeta);
    }
    if (data.containsKey('isyak')) {
      context.handle(
        _isyakMeta,
        isyak.isAcceptableOrUnknown(data['isyak']!, _isyakMeta),
      );
    } else if (isInserting) {
      context.missing(_isyakMeta);
    }
    if (data.containsKey('hijri')) {
      context.handle(
        _hijriMeta,
        hijri.isAcceptableOrUnknown(data['hijri']!, _hijriMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PrayerTimeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PrayerTimeRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      zone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}zone'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      imsak: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}imsak'],
      ),
      subuh: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}subuh'],
      )!,
      syuruk: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}syuruk'],
      )!,
      zohor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}zohor'],
      )!,
      asar: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}asar'],
      )!,
      maghrib: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}maghrib'],
      )!,
      isyak: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}isyak'],
      )!,
      hijri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hijri'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
    );
  }

  @override
  $PrayerTimesTable createAlias(String alias) {
    return $PrayerTimesTable(attachedDatabase, alias);
  }
}

class PrayerTimeRow extends DataClass implements Insertable<PrayerTimeRow> {
  final int id;
  final String zone;
  final String date;
  final int? imsak;
  final int subuh;
  final int syuruk;
  final int zohor;
  final int asar;
  final int maghrib;
  final int isyak;
  final String? hijri;
  final String source;
  final DateTime fetchedAt;
  const PrayerTimeRow({
    required this.id,
    required this.zone,
    required this.date,
    this.imsak,
    required this.subuh,
    required this.syuruk,
    required this.zohor,
    required this.asar,
    required this.maghrib,
    required this.isyak,
    this.hijri,
    required this.source,
    required this.fetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['zone'] = Variable<String>(zone);
    map['date'] = Variable<String>(date);
    if (!nullToAbsent || imsak != null) {
      map['imsak'] = Variable<int>(imsak);
    }
    map['subuh'] = Variable<int>(subuh);
    map['syuruk'] = Variable<int>(syuruk);
    map['zohor'] = Variable<int>(zohor);
    map['asar'] = Variable<int>(asar);
    map['maghrib'] = Variable<int>(maghrib);
    map['isyak'] = Variable<int>(isyak);
    if (!nullToAbsent || hijri != null) {
      map['hijri'] = Variable<String>(hijri);
    }
    map['source'] = Variable<String>(source);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    return map;
  }

  PrayerTimesCompanion toCompanion(bool nullToAbsent) {
    return PrayerTimesCompanion(
      id: Value(id),
      zone: Value(zone),
      date: Value(date),
      imsak: imsak == null && nullToAbsent
          ? const Value.absent()
          : Value(imsak),
      subuh: Value(subuh),
      syuruk: Value(syuruk),
      zohor: Value(zohor),
      asar: Value(asar),
      maghrib: Value(maghrib),
      isyak: Value(isyak),
      hijri: hijri == null && nullToAbsent
          ? const Value.absent()
          : Value(hijri),
      source: Value(source),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory PrayerTimeRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PrayerTimeRow(
      id: serializer.fromJson<int>(json['id']),
      zone: serializer.fromJson<String>(json['zone']),
      date: serializer.fromJson<String>(json['date']),
      imsak: serializer.fromJson<int?>(json['imsak']),
      subuh: serializer.fromJson<int>(json['subuh']),
      syuruk: serializer.fromJson<int>(json['syuruk']),
      zohor: serializer.fromJson<int>(json['zohor']),
      asar: serializer.fromJson<int>(json['asar']),
      maghrib: serializer.fromJson<int>(json['maghrib']),
      isyak: serializer.fromJson<int>(json['isyak']),
      hijri: serializer.fromJson<String?>(json['hijri']),
      source: serializer.fromJson<String>(json['source']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'zone': serializer.toJson<String>(zone),
      'date': serializer.toJson<String>(date),
      'imsak': serializer.toJson<int?>(imsak),
      'subuh': serializer.toJson<int>(subuh),
      'syuruk': serializer.toJson<int>(syuruk),
      'zohor': serializer.toJson<int>(zohor),
      'asar': serializer.toJson<int>(asar),
      'maghrib': serializer.toJson<int>(maghrib),
      'isyak': serializer.toJson<int>(isyak),
      'hijri': serializer.toJson<String?>(hijri),
      'source': serializer.toJson<String>(source),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
    };
  }

  PrayerTimeRow copyWith({
    int? id,
    String? zone,
    String? date,
    Value<int?> imsak = const Value.absent(),
    int? subuh,
    int? syuruk,
    int? zohor,
    int? asar,
    int? maghrib,
    int? isyak,
    Value<String?> hijri = const Value.absent(),
    String? source,
    DateTime? fetchedAt,
  }) => PrayerTimeRow(
    id: id ?? this.id,
    zone: zone ?? this.zone,
    date: date ?? this.date,
    imsak: imsak.present ? imsak.value : this.imsak,
    subuh: subuh ?? this.subuh,
    syuruk: syuruk ?? this.syuruk,
    zohor: zohor ?? this.zohor,
    asar: asar ?? this.asar,
    maghrib: maghrib ?? this.maghrib,
    isyak: isyak ?? this.isyak,
    hijri: hijri.present ? hijri.value : this.hijri,
    source: source ?? this.source,
    fetchedAt: fetchedAt ?? this.fetchedAt,
  );
  PrayerTimeRow copyWithCompanion(PrayerTimesCompanion data) {
    return PrayerTimeRow(
      id: data.id.present ? data.id.value : this.id,
      zone: data.zone.present ? data.zone.value : this.zone,
      date: data.date.present ? data.date.value : this.date,
      imsak: data.imsak.present ? data.imsak.value : this.imsak,
      subuh: data.subuh.present ? data.subuh.value : this.subuh,
      syuruk: data.syuruk.present ? data.syuruk.value : this.syuruk,
      zohor: data.zohor.present ? data.zohor.value : this.zohor,
      asar: data.asar.present ? data.asar.value : this.asar,
      maghrib: data.maghrib.present ? data.maghrib.value : this.maghrib,
      isyak: data.isyak.present ? data.isyak.value : this.isyak,
      hijri: data.hijri.present ? data.hijri.value : this.hijri,
      source: data.source.present ? data.source.value : this.source,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PrayerTimeRow(')
          ..write('id: $id, ')
          ..write('zone: $zone, ')
          ..write('date: $date, ')
          ..write('imsak: $imsak, ')
          ..write('subuh: $subuh, ')
          ..write('syuruk: $syuruk, ')
          ..write('zohor: $zohor, ')
          ..write('asar: $asar, ')
          ..write('maghrib: $maghrib, ')
          ..write('isyak: $isyak, ')
          ..write('hijri: $hijri, ')
          ..write('source: $source, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    zone,
    date,
    imsak,
    subuh,
    syuruk,
    zohor,
    asar,
    maghrib,
    isyak,
    hijri,
    source,
    fetchedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PrayerTimeRow &&
          other.id == this.id &&
          other.zone == this.zone &&
          other.date == this.date &&
          other.imsak == this.imsak &&
          other.subuh == this.subuh &&
          other.syuruk == this.syuruk &&
          other.zohor == this.zohor &&
          other.asar == this.asar &&
          other.maghrib == this.maghrib &&
          other.isyak == this.isyak &&
          other.hijri == this.hijri &&
          other.source == this.source &&
          other.fetchedAt == this.fetchedAt);
}

class PrayerTimesCompanion extends UpdateCompanion<PrayerTimeRow> {
  final Value<int> id;
  final Value<String> zone;
  final Value<String> date;
  final Value<int?> imsak;
  final Value<int> subuh;
  final Value<int> syuruk;
  final Value<int> zohor;
  final Value<int> asar;
  final Value<int> maghrib;
  final Value<int> isyak;
  final Value<String?> hijri;
  final Value<String> source;
  final Value<DateTime> fetchedAt;
  const PrayerTimesCompanion({
    this.id = const Value.absent(),
    this.zone = const Value.absent(),
    this.date = const Value.absent(),
    this.imsak = const Value.absent(),
    this.subuh = const Value.absent(),
    this.syuruk = const Value.absent(),
    this.zohor = const Value.absent(),
    this.asar = const Value.absent(),
    this.maghrib = const Value.absent(),
    this.isyak = const Value.absent(),
    this.hijri = const Value.absent(),
    this.source = const Value.absent(),
    this.fetchedAt = const Value.absent(),
  });
  PrayerTimesCompanion.insert({
    this.id = const Value.absent(),
    required String zone,
    required String date,
    this.imsak = const Value.absent(),
    required int subuh,
    required int syuruk,
    required int zohor,
    required int asar,
    required int maghrib,
    required int isyak,
    this.hijri = const Value.absent(),
    required String source,
    required DateTime fetchedAt,
  }) : zone = Value(zone),
       date = Value(date),
       subuh = Value(subuh),
       syuruk = Value(syuruk),
       zohor = Value(zohor),
       asar = Value(asar),
       maghrib = Value(maghrib),
       isyak = Value(isyak),
       source = Value(source),
       fetchedAt = Value(fetchedAt);
  static Insertable<PrayerTimeRow> custom({
    Expression<int>? id,
    Expression<String>? zone,
    Expression<String>? date,
    Expression<int>? imsak,
    Expression<int>? subuh,
    Expression<int>? syuruk,
    Expression<int>? zohor,
    Expression<int>? asar,
    Expression<int>? maghrib,
    Expression<int>? isyak,
    Expression<String>? hijri,
    Expression<String>? source,
    Expression<DateTime>? fetchedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (zone != null) 'zone': zone,
      if (date != null) 'date': date,
      if (imsak != null) 'imsak': imsak,
      if (subuh != null) 'subuh': subuh,
      if (syuruk != null) 'syuruk': syuruk,
      if (zohor != null) 'zohor': zohor,
      if (asar != null) 'asar': asar,
      if (maghrib != null) 'maghrib': maghrib,
      if (isyak != null) 'isyak': isyak,
      if (hijri != null) 'hijri': hijri,
      if (source != null) 'source': source,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
    });
  }

  PrayerTimesCompanion copyWith({
    Value<int>? id,
    Value<String>? zone,
    Value<String>? date,
    Value<int?>? imsak,
    Value<int>? subuh,
    Value<int>? syuruk,
    Value<int>? zohor,
    Value<int>? asar,
    Value<int>? maghrib,
    Value<int>? isyak,
    Value<String?>? hijri,
    Value<String>? source,
    Value<DateTime>? fetchedAt,
  }) {
    return PrayerTimesCompanion(
      id: id ?? this.id,
      zone: zone ?? this.zone,
      date: date ?? this.date,
      imsak: imsak ?? this.imsak,
      subuh: subuh ?? this.subuh,
      syuruk: syuruk ?? this.syuruk,
      zohor: zohor ?? this.zohor,
      asar: asar ?? this.asar,
      maghrib: maghrib ?? this.maghrib,
      isyak: isyak ?? this.isyak,
      hijri: hijri ?? this.hijri,
      source: source ?? this.source,
      fetchedAt: fetchedAt ?? this.fetchedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (zone.present) {
      map['zone'] = Variable<String>(zone.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (imsak.present) {
      map['imsak'] = Variable<int>(imsak.value);
    }
    if (subuh.present) {
      map['subuh'] = Variable<int>(subuh.value);
    }
    if (syuruk.present) {
      map['syuruk'] = Variable<int>(syuruk.value);
    }
    if (zohor.present) {
      map['zohor'] = Variable<int>(zohor.value);
    }
    if (asar.present) {
      map['asar'] = Variable<int>(asar.value);
    }
    if (maghrib.present) {
      map['maghrib'] = Variable<int>(maghrib.value);
    }
    if (isyak.present) {
      map['isyak'] = Variable<int>(isyak.value);
    }
    if (hijri.present) {
      map['hijri'] = Variable<String>(hijri.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PrayerTimesCompanion(')
          ..write('id: $id, ')
          ..write('zone: $zone, ')
          ..write('date: $date, ')
          ..write('imsak: $imsak, ')
          ..write('subuh: $subuh, ')
          ..write('syuruk: $syuruk, ')
          ..write('zohor: $zohor, ')
          ..write('asar: $asar, ')
          ..write('maghrib: $maghrib, ')
          ..write('isyak: $isyak, ')
          ..write('hijri: $hijri, ')
          ..write('source: $source, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }
}

class $IslamicEventsTable extends IslamicEvents
    with TableInfo<$IslamicEventsTable, IslamicEventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IslamicEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _eventKeyMeta = const VerificationMeta(
    'eventKey',
  );
  @override
  late final GeneratedColumn<String> eventKey = GeneratedColumn<String>(
    'event_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hijriYearMeta = const VerificationMeta(
    'hijriYear',
  );
  @override
  late final GeneratedColumn<int> hijriYear = GeneratedColumn<int>(
    'hijri_year',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gregorianDateMeta = const VerificationMeta(
    'gregorianDate',
  );
  @override
  late final GeneratedColumn<String> gregorianDate = GeneratedColumn<String>(
    'gregorian_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    eventKey,
    hijriYear,
    gregorianDate,
    source,
    note,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'islamic_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<IslamicEventRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('event_key')) {
      context.handle(
        _eventKeyMeta,
        eventKey.isAcceptableOrUnknown(data['event_key']!, _eventKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_eventKeyMeta);
    }
    if (data.containsKey('hijri_year')) {
      context.handle(
        _hijriYearMeta,
        hijriYear.isAcceptableOrUnknown(data['hijri_year']!, _hijriYearMeta),
      );
    } else if (isInserting) {
      context.missing(_hijriYearMeta);
    }
    if (data.containsKey('gregorian_date')) {
      context.handle(
        _gregorianDateMeta,
        gregorianDate.isAcceptableOrUnknown(
          data['gregorian_date']!,
          _gregorianDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_gregorianDateMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  IslamicEventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IslamicEventRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      eventKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_key'],
      )!,
      hijriYear: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hijri_year'],
      )!,
      gregorianDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gregorian_date'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $IslamicEventsTable createAlias(String alias) {
    return $IslamicEventsTable(attachedDatabase, alias);
  }
}

class IslamicEventRow extends DataClass implements Insertable<IslamicEventRow> {
  final int id;
  final String eventKey;
  final int hijriYear;
  final String gregorianDate;
  final String source;
  final String? note;
  final DateTime createdAt;
  const IslamicEventRow({
    required this.id,
    required this.eventKey,
    required this.hijriYear,
    required this.gregorianDate,
    required this.source,
    this.note,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['event_key'] = Variable<String>(eventKey);
    map['hijri_year'] = Variable<int>(hijriYear);
    map['gregorian_date'] = Variable<String>(gregorianDate);
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  IslamicEventsCompanion toCompanion(bool nullToAbsent) {
    return IslamicEventsCompanion(
      id: Value(id),
      eventKey: Value(eventKey),
      hijriYear: Value(hijriYear),
      gregorianDate: Value(gregorianDate),
      source: Value(source),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
    );
  }

  factory IslamicEventRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IslamicEventRow(
      id: serializer.fromJson<int>(json['id']),
      eventKey: serializer.fromJson<String>(json['eventKey']),
      hijriYear: serializer.fromJson<int>(json['hijriYear']),
      gregorianDate: serializer.fromJson<String>(json['gregorianDate']),
      source: serializer.fromJson<String>(json['source']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'eventKey': serializer.toJson<String>(eventKey),
      'hijriYear': serializer.toJson<int>(hijriYear),
      'gregorianDate': serializer.toJson<String>(gregorianDate),
      'source': serializer.toJson<String>(source),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  IslamicEventRow copyWith({
    int? id,
    String? eventKey,
    int? hijriYear,
    String? gregorianDate,
    String? source,
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
  }) => IslamicEventRow(
    id: id ?? this.id,
    eventKey: eventKey ?? this.eventKey,
    hijriYear: hijriYear ?? this.hijriYear,
    gregorianDate: gregorianDate ?? this.gregorianDate,
    source: source ?? this.source,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
  );
  IslamicEventRow copyWithCompanion(IslamicEventsCompanion data) {
    return IslamicEventRow(
      id: data.id.present ? data.id.value : this.id,
      eventKey: data.eventKey.present ? data.eventKey.value : this.eventKey,
      hijriYear: data.hijriYear.present ? data.hijriYear.value : this.hijriYear,
      gregorianDate: data.gregorianDate.present
          ? data.gregorianDate.value
          : this.gregorianDate,
      source: data.source.present ? data.source.value : this.source,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IslamicEventRow(')
          ..write('id: $id, ')
          ..write('eventKey: $eventKey, ')
          ..write('hijriYear: $hijriYear, ')
          ..write('gregorianDate: $gregorianDate, ')
          ..write('source: $source, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    eventKey,
    hijriYear,
    gregorianDate,
    source,
    note,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IslamicEventRow &&
          other.id == this.id &&
          other.eventKey == this.eventKey &&
          other.hijriYear == this.hijriYear &&
          other.gregorianDate == this.gregorianDate &&
          other.source == this.source &&
          other.note == this.note &&
          other.createdAt == this.createdAt);
}

class IslamicEventsCompanion extends UpdateCompanion<IslamicEventRow> {
  final Value<int> id;
  final Value<String> eventKey;
  final Value<int> hijriYear;
  final Value<String> gregorianDate;
  final Value<String> source;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  const IslamicEventsCompanion({
    this.id = const Value.absent(),
    this.eventKey = const Value.absent(),
    this.hijriYear = const Value.absent(),
    this.gregorianDate = const Value.absent(),
    this.source = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  IslamicEventsCompanion.insert({
    this.id = const Value.absent(),
    required String eventKey,
    required int hijriYear,
    required String gregorianDate,
    required String source,
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : eventKey = Value(eventKey),
       hijriYear = Value(hijriYear),
       gregorianDate = Value(gregorianDate),
       source = Value(source);
  static Insertable<IslamicEventRow> custom({
    Expression<int>? id,
    Expression<String>? eventKey,
    Expression<int>? hijriYear,
    Expression<String>? gregorianDate,
    Expression<String>? source,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (eventKey != null) 'event_key': eventKey,
      if (hijriYear != null) 'hijri_year': hijriYear,
      if (gregorianDate != null) 'gregorian_date': gregorianDate,
      if (source != null) 'source': source,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  IslamicEventsCompanion copyWith({
    Value<int>? id,
    Value<String>? eventKey,
    Value<int>? hijriYear,
    Value<String>? gregorianDate,
    Value<String>? source,
    Value<String?>? note,
    Value<DateTime>? createdAt,
  }) {
    return IslamicEventsCompanion(
      id: id ?? this.id,
      eventKey: eventKey ?? this.eventKey,
      hijriYear: hijriYear ?? this.hijriYear,
      gregorianDate: gregorianDate ?? this.gregorianDate,
      source: source ?? this.source,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (eventKey.present) {
      map['event_key'] = Variable<String>(eventKey.value);
    }
    if (hijriYear.present) {
      map['hijri_year'] = Variable<int>(hijriYear.value);
    }
    if (gregorianDate.present) {
      map['gregorian_date'] = Variable<String>(gregorianDate.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IslamicEventsCompanion(')
          ..write('id: $id, ')
          ..write('eventKey: $eventKey, ')
          ..write('hijriYear: $hijriYear, ')
          ..write('gregorianDate: $gregorianDate, ')
          ..write('source: $source, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $IslamicCalendarTable extends IslamicCalendar
    with TableInfo<$IslamicCalendarTable, HijriAdjustmentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IslamicCalendarTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _hijriYearMeta = const VerificationMeta(
    'hijriYear',
  );
  @override
  late final GeneratedColumn<int> hijriYear = GeneratedColumn<int>(
    'hijri_year',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hijriMonthMeta = const VerificationMeta(
    'hijriMonth',
  );
  @override
  late final GeneratedColumn<int> hijriMonth = GeneratedColumn<int>(
    'hijri_month',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _adjustDaysMeta = const VerificationMeta(
    'adjustDays',
  );
  @override
  late final GeneratedColumn<int> adjustDays = GeneratedColumn<int>(
    'adjust_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('user'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    hijriYear,
    hijriMonth,
    adjustDays,
    source,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'islamic_calendar';
  @override
  VerificationContext validateIntegrity(
    Insertable<HijriAdjustmentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('hijri_year')) {
      context.handle(
        _hijriYearMeta,
        hijriYear.isAcceptableOrUnknown(data['hijri_year']!, _hijriYearMeta),
      );
    } else if (isInserting) {
      context.missing(_hijriYearMeta);
    }
    if (data.containsKey('hijri_month')) {
      context.handle(
        _hijriMonthMeta,
        hijriMonth.isAcceptableOrUnknown(data['hijri_month']!, _hijriMonthMeta),
      );
    } else if (isInserting) {
      context.missing(_hijriMonthMeta);
    }
    if (data.containsKey('adjust_days')) {
      context.handle(
        _adjustDaysMeta,
        adjustDays.isAcceptableOrUnknown(data['adjust_days']!, _adjustDaysMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {hijriYear, hijriMonth};
  @override
  HijriAdjustmentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HijriAdjustmentRow(
      hijriYear: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hijri_year'],
      )!,
      hijriMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hijri_month'],
      )!,
      adjustDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}adjust_days'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
    );
  }

  @override
  $IslamicCalendarTable createAlias(String alias) {
    return $IslamicCalendarTable(attachedDatabase, alias);
  }
}

class HijriAdjustmentRow extends DataClass
    implements Insertable<HijriAdjustmentRow> {
  final int hijriYear;
  final int hijriMonth;
  final int adjustDays;
  final String source;
  const HijriAdjustmentRow({
    required this.hijriYear,
    required this.hijriMonth,
    required this.adjustDays,
    required this.source,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['hijri_year'] = Variable<int>(hijriYear);
    map['hijri_month'] = Variable<int>(hijriMonth);
    map['adjust_days'] = Variable<int>(adjustDays);
    map['source'] = Variable<String>(source);
    return map;
  }

  IslamicCalendarCompanion toCompanion(bool nullToAbsent) {
    return IslamicCalendarCompanion(
      hijriYear: Value(hijriYear),
      hijriMonth: Value(hijriMonth),
      adjustDays: Value(adjustDays),
      source: Value(source),
    );
  }

  factory HijriAdjustmentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HijriAdjustmentRow(
      hijriYear: serializer.fromJson<int>(json['hijriYear']),
      hijriMonth: serializer.fromJson<int>(json['hijriMonth']),
      adjustDays: serializer.fromJson<int>(json['adjustDays']),
      source: serializer.fromJson<String>(json['source']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'hijriYear': serializer.toJson<int>(hijriYear),
      'hijriMonth': serializer.toJson<int>(hijriMonth),
      'adjustDays': serializer.toJson<int>(adjustDays),
      'source': serializer.toJson<String>(source),
    };
  }

  HijriAdjustmentRow copyWith({
    int? hijriYear,
    int? hijriMonth,
    int? adjustDays,
    String? source,
  }) => HijriAdjustmentRow(
    hijriYear: hijriYear ?? this.hijriYear,
    hijriMonth: hijriMonth ?? this.hijriMonth,
    adjustDays: adjustDays ?? this.adjustDays,
    source: source ?? this.source,
  );
  HijriAdjustmentRow copyWithCompanion(IslamicCalendarCompanion data) {
    return HijriAdjustmentRow(
      hijriYear: data.hijriYear.present ? data.hijriYear.value : this.hijriYear,
      hijriMonth: data.hijriMonth.present
          ? data.hijriMonth.value
          : this.hijriMonth,
      adjustDays: data.adjustDays.present
          ? data.adjustDays.value
          : this.adjustDays,
      source: data.source.present ? data.source.value : this.source,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HijriAdjustmentRow(')
          ..write('hijriYear: $hijriYear, ')
          ..write('hijriMonth: $hijriMonth, ')
          ..write('adjustDays: $adjustDays, ')
          ..write('source: $source')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(hijriYear, hijriMonth, adjustDays, source);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HijriAdjustmentRow &&
          other.hijriYear == this.hijriYear &&
          other.hijriMonth == this.hijriMonth &&
          other.adjustDays == this.adjustDays &&
          other.source == this.source);
}

class IslamicCalendarCompanion extends UpdateCompanion<HijriAdjustmentRow> {
  final Value<int> hijriYear;
  final Value<int> hijriMonth;
  final Value<int> adjustDays;
  final Value<String> source;
  final Value<int> rowid;
  const IslamicCalendarCompanion({
    this.hijriYear = const Value.absent(),
    this.hijriMonth = const Value.absent(),
    this.adjustDays = const Value.absent(),
    this.source = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IslamicCalendarCompanion.insert({
    required int hijriYear,
    required int hijriMonth,
    this.adjustDays = const Value.absent(),
    this.source = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : hijriYear = Value(hijriYear),
       hijriMonth = Value(hijriMonth);
  static Insertable<HijriAdjustmentRow> custom({
    Expression<int>? hijriYear,
    Expression<int>? hijriMonth,
    Expression<int>? adjustDays,
    Expression<String>? source,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (hijriYear != null) 'hijri_year': hijriYear,
      if (hijriMonth != null) 'hijri_month': hijriMonth,
      if (adjustDays != null) 'adjust_days': adjustDays,
      if (source != null) 'source': source,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IslamicCalendarCompanion copyWith({
    Value<int>? hijriYear,
    Value<int>? hijriMonth,
    Value<int>? adjustDays,
    Value<String>? source,
    Value<int>? rowid,
  }) {
    return IslamicCalendarCompanion(
      hijriYear: hijriYear ?? this.hijriYear,
      hijriMonth: hijriMonth ?? this.hijriMonth,
      adjustDays: adjustDays ?? this.adjustDays,
      source: source ?? this.source,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (hijriYear.present) {
      map['hijri_year'] = Variable<int>(hijriYear.value);
    }
    if (hijriMonth.present) {
      map['hijri_month'] = Variable<int>(hijriMonth.value);
    }
    if (adjustDays.present) {
      map['adjust_days'] = Variable<int>(adjustDays.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IslamicCalendarCompanion(')
          ..write('hijriYear: $hijriYear, ')
          ..write('hijriMonth: $hijriMonth, ')
          ..write('adjustDays: $adjustDays, ')
          ..write('source: $source, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AudioLibraryTable extends AudioLibrary
    with TableInfo<$AudioLibraryTable, AudioRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AudioLibraryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _sourceUrlMeta = const VerificationMeta(
    'sourceUrl',
  );
  @override
  late final GeneratedColumn<String> sourceUrl = GeneratedColumn<String>(
    'source_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contentIdMeta = const VerificationMeta(
    'contentId',
  );
  @override
  late final GeneratedColumn<String> contentId = GeneratedColumn<String>(
    'content_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _licenseNoteMeta = const VerificationMeta(
    'licenseNote',
  );
  @override
  late final GeneratedColumn<String> licenseNote = GeneratedColumn<String>(
    'license_note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    category,
    filePath,
    sourceUrl,
    contentId,
    durationMs,
    licenseNote,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audio_library';
  @override
  VerificationContext validateIntegrity(
    Insertable<AudioRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('source_url')) {
      context.handle(
        _sourceUrlMeta,
        sourceUrl.isAcceptableOrUnknown(data['source_url']!, _sourceUrlMeta),
      );
    }
    if (data.containsKey('content_id')) {
      context.handle(
        _contentIdMeta,
        contentId.isAcceptableOrUnknown(data['content_id']!, _contentIdMeta),
      );
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('license_note')) {
      context.handle(
        _licenseNoteMeta,
        licenseNote.isAcceptableOrUnknown(
          data['license_note']!,
          _licenseNoteMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AudioRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AudioRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      sourceUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_url'],
      ),
      contentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_id'],
      ),
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      ),
      licenseNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}license_note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AudioLibraryTable createAlias(String alias) {
    return $AudioLibraryTable(attachedDatabase, alias);
  }
}

class AudioRow extends DataClass implements Insertable<AudioRow> {
  final int id;
  final String title;
  final String category;
  final String filePath;
  final String? sourceUrl;
  final String? contentId;
  final int? durationMs;
  final String? licenseNote;
  final DateTime createdAt;
  const AudioRow({
    required this.id,
    required this.title,
    required this.category,
    required this.filePath,
    this.sourceUrl,
    this.contentId,
    this.durationMs,
    this.licenseNote,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['category'] = Variable<String>(category);
    map['file_path'] = Variable<String>(filePath);
    if (!nullToAbsent || sourceUrl != null) {
      map['source_url'] = Variable<String>(sourceUrl);
    }
    if (!nullToAbsent || contentId != null) {
      map['content_id'] = Variable<String>(contentId);
    }
    if (!nullToAbsent || durationMs != null) {
      map['duration_ms'] = Variable<int>(durationMs);
    }
    if (!nullToAbsent || licenseNote != null) {
      map['license_note'] = Variable<String>(licenseNote);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AudioLibraryCompanion toCompanion(bool nullToAbsent) {
    return AudioLibraryCompanion(
      id: Value(id),
      title: Value(title),
      category: Value(category),
      filePath: Value(filePath),
      sourceUrl: sourceUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceUrl),
      contentId: contentId == null && nullToAbsent
          ? const Value.absent()
          : Value(contentId),
      durationMs: durationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMs),
      licenseNote: licenseNote == null && nullToAbsent
          ? const Value.absent()
          : Value(licenseNote),
      createdAt: Value(createdAt),
    );
  }

  factory AudioRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AudioRow(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      category: serializer.fromJson<String>(json['category']),
      filePath: serializer.fromJson<String>(json['filePath']),
      sourceUrl: serializer.fromJson<String?>(json['sourceUrl']),
      contentId: serializer.fromJson<String?>(json['contentId']),
      durationMs: serializer.fromJson<int?>(json['durationMs']),
      licenseNote: serializer.fromJson<String?>(json['licenseNote']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'category': serializer.toJson<String>(category),
      'filePath': serializer.toJson<String>(filePath),
      'sourceUrl': serializer.toJson<String?>(sourceUrl),
      'contentId': serializer.toJson<String?>(contentId),
      'durationMs': serializer.toJson<int?>(durationMs),
      'licenseNote': serializer.toJson<String?>(licenseNote),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  AudioRow copyWith({
    int? id,
    String? title,
    String? category,
    String? filePath,
    Value<String?> sourceUrl = const Value.absent(),
    Value<String?> contentId = const Value.absent(),
    Value<int?> durationMs = const Value.absent(),
    Value<String?> licenseNote = const Value.absent(),
    DateTime? createdAt,
  }) => AudioRow(
    id: id ?? this.id,
    title: title ?? this.title,
    category: category ?? this.category,
    filePath: filePath ?? this.filePath,
    sourceUrl: sourceUrl.present ? sourceUrl.value : this.sourceUrl,
    contentId: contentId.present ? contentId.value : this.contentId,
    durationMs: durationMs.present ? durationMs.value : this.durationMs,
    licenseNote: licenseNote.present ? licenseNote.value : this.licenseNote,
    createdAt: createdAt ?? this.createdAt,
  );
  AudioRow copyWithCompanion(AudioLibraryCompanion data) {
    return AudioRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      category: data.category.present ? data.category.value : this.category,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      sourceUrl: data.sourceUrl.present ? data.sourceUrl.value : this.sourceUrl,
      contentId: data.contentId.present ? data.contentId.value : this.contentId,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      licenseNote: data.licenseNote.present
          ? data.licenseNote.value
          : this.licenseNote,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AudioRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('category: $category, ')
          ..write('filePath: $filePath, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('contentId: $contentId, ')
          ..write('durationMs: $durationMs, ')
          ..write('licenseNote: $licenseNote, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    category,
    filePath,
    sourceUrl,
    contentId,
    durationMs,
    licenseNote,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AudioRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.category == this.category &&
          other.filePath == this.filePath &&
          other.sourceUrl == this.sourceUrl &&
          other.contentId == this.contentId &&
          other.durationMs == this.durationMs &&
          other.licenseNote == this.licenseNote &&
          other.createdAt == this.createdAt);
}

class AudioLibraryCompanion extends UpdateCompanion<AudioRow> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> category;
  final Value<String> filePath;
  final Value<String?> sourceUrl;
  final Value<String?> contentId;
  final Value<int?> durationMs;
  final Value<String?> licenseNote;
  final Value<DateTime> createdAt;
  const AudioLibraryCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.category = const Value.absent(),
    this.filePath = const Value.absent(),
    this.sourceUrl = const Value.absent(),
    this.contentId = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.licenseNote = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  AudioLibraryCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required String category,
    required String filePath,
    this.sourceUrl = const Value.absent(),
    this.contentId = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.licenseNote = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : title = Value(title),
       category = Value(category),
       filePath = Value(filePath);
  static Insertable<AudioRow> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? category,
    Expression<String>? filePath,
    Expression<String>? sourceUrl,
    Expression<String>? contentId,
    Expression<int>? durationMs,
    Expression<String>? licenseNote,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (category != null) 'category': category,
      if (filePath != null) 'file_path': filePath,
      if (sourceUrl != null) 'source_url': sourceUrl,
      if (contentId != null) 'content_id': contentId,
      if (durationMs != null) 'duration_ms': durationMs,
      if (licenseNote != null) 'license_note': licenseNote,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  AudioLibraryCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String>? category,
    Value<String>? filePath,
    Value<String?>? sourceUrl,
    Value<String?>? contentId,
    Value<int?>? durationMs,
    Value<String?>? licenseNote,
    Value<DateTime>? createdAt,
  }) {
    return AudioLibraryCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      filePath: filePath ?? this.filePath,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      contentId: contentId ?? this.contentId,
      durationMs: durationMs ?? this.durationMs,
      licenseNote: licenseNote ?? this.licenseNote,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (sourceUrl.present) {
      map['source_url'] = Variable<String>(sourceUrl.value);
    }
    if (contentId.present) {
      map['content_id'] = Variable<String>(contentId.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (licenseNote.present) {
      map['license_note'] = Variable<String>(licenseNote.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AudioLibraryCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('category: $category, ')
          ..write('filePath: $filePath, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('contentId: $contentId, ')
          ..write('durationMs: $durationMs, ')
          ..write('licenseNote: $licenseNote, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $AudioPlaylistsTable extends AudioPlaylists
    with TableInfo<$AudioPlaylistsTable, PlaylistRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AudioPlaylistsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audio_playlists';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlaylistRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlaylistRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaylistRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AudioPlaylistsTable createAlias(String alias) {
    return $AudioPlaylistsTable(attachedDatabase, alias);
  }
}

class PlaylistRow extends DataClass implements Insertable<PlaylistRow> {
  final int id;
  final String name;
  final DateTime createdAt;
  const PlaylistRow({
    required this.id,
    required this.name,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AudioPlaylistsCompanion toCompanion(bool nullToAbsent) {
    return AudioPlaylistsCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
    );
  }

  factory PlaylistRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaylistRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PlaylistRow copyWith({int? id, String? name, DateTime? createdAt}) =>
      PlaylistRow(
        id: id ?? this.id,
        name: name ?? this.name,
        createdAt: createdAt ?? this.createdAt,
      );
  PlaylistRow copyWithCompanion(AudioPlaylistsCompanion data) {
    return PlaylistRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaylistRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt);
}

class AudioPlaylistsCompanion extends UpdateCompanion<PlaylistRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<DateTime> createdAt;
  const AudioPlaylistsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  AudioPlaylistsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.createdAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<PlaylistRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  AudioPlaylistsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<DateTime>? createdAt,
  }) {
    return AudioPlaylistsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AudioPlaylistsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $AudioPlaylistItemsTable extends AudioPlaylistItems
    with TableInfo<$AudioPlaylistItemsTable, PlaylistItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AudioPlaylistItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _playlistIdMeta = const VerificationMeta(
    'playlistId',
  );
  @override
  late final GeneratedColumn<int> playlistId = GeneratedColumn<int>(
    'playlist_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES audio_playlists (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _audioIdMeta = const VerificationMeta(
    'audioId',
  );
  @override
  late final GeneratedColumn<int> audioId = GeneratedColumn<int>(
    'audio_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES audio_library (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, playlistId, audioId, position];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audio_playlist_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlaylistItemRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('playlist_id')) {
      context.handle(
        _playlistIdMeta,
        playlistId.isAcceptableOrUnknown(data['playlist_id']!, _playlistIdMeta),
      );
    } else if (isInserting) {
      context.missing(_playlistIdMeta);
    }
    if (data.containsKey('audio_id')) {
      context.handle(
        _audioIdMeta,
        audioId.isAcceptableOrUnknown(data['audio_id']!, _audioIdMeta),
      );
    } else if (isInserting) {
      context.missing(_audioIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlaylistItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaylistItemRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      playlistId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}playlist_id'],
      )!,
      audioId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}audio_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $AudioPlaylistItemsTable createAlias(String alias) {
    return $AudioPlaylistItemsTable(attachedDatabase, alias);
  }
}

class PlaylistItemRow extends DataClass implements Insertable<PlaylistItemRow> {
  final int id;
  final int playlistId;
  final int audioId;
  final int position;
  const PlaylistItemRow({
    required this.id,
    required this.playlistId,
    required this.audioId,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['playlist_id'] = Variable<int>(playlistId);
    map['audio_id'] = Variable<int>(audioId);
    map['position'] = Variable<int>(position);
    return map;
  }

  AudioPlaylistItemsCompanion toCompanion(bool nullToAbsent) {
    return AudioPlaylistItemsCompanion(
      id: Value(id),
      playlistId: Value(playlistId),
      audioId: Value(audioId),
      position: Value(position),
    );
  }

  factory PlaylistItemRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaylistItemRow(
      id: serializer.fromJson<int>(json['id']),
      playlistId: serializer.fromJson<int>(json['playlistId']),
      audioId: serializer.fromJson<int>(json['audioId']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'playlistId': serializer.toJson<int>(playlistId),
      'audioId': serializer.toJson<int>(audioId),
      'position': serializer.toJson<int>(position),
    };
  }

  PlaylistItemRow copyWith({
    int? id,
    int? playlistId,
    int? audioId,
    int? position,
  }) => PlaylistItemRow(
    id: id ?? this.id,
    playlistId: playlistId ?? this.playlistId,
    audioId: audioId ?? this.audioId,
    position: position ?? this.position,
  );
  PlaylistItemRow copyWithCompanion(AudioPlaylistItemsCompanion data) {
    return PlaylistItemRow(
      id: data.id.present ? data.id.value : this.id,
      playlistId: data.playlistId.present
          ? data.playlistId.value
          : this.playlistId,
      audioId: data.audioId.present ? data.audioId.value : this.audioId,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistItemRow(')
          ..write('id: $id, ')
          ..write('playlistId: $playlistId, ')
          ..write('audioId: $audioId, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, playlistId, audioId, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaylistItemRow &&
          other.id == this.id &&
          other.playlistId == this.playlistId &&
          other.audioId == this.audioId &&
          other.position == this.position);
}

class AudioPlaylistItemsCompanion extends UpdateCompanion<PlaylistItemRow> {
  final Value<int> id;
  final Value<int> playlistId;
  final Value<int> audioId;
  final Value<int> position;
  const AudioPlaylistItemsCompanion({
    this.id = const Value.absent(),
    this.playlistId = const Value.absent(),
    this.audioId = const Value.absent(),
    this.position = const Value.absent(),
  });
  AudioPlaylistItemsCompanion.insert({
    this.id = const Value.absent(),
    required int playlistId,
    required int audioId,
    required int position,
  }) : playlistId = Value(playlistId),
       audioId = Value(audioId),
       position = Value(position);
  static Insertable<PlaylistItemRow> custom({
    Expression<int>? id,
    Expression<int>? playlistId,
    Expression<int>? audioId,
    Expression<int>? position,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (playlistId != null) 'playlist_id': playlistId,
      if (audioId != null) 'audio_id': audioId,
      if (position != null) 'position': position,
    });
  }

  AudioPlaylistItemsCompanion copyWith({
    Value<int>? id,
    Value<int>? playlistId,
    Value<int>? audioId,
    Value<int>? position,
  }) {
    return AudioPlaylistItemsCompanion(
      id: id ?? this.id,
      playlistId: playlistId ?? this.playlistId,
      audioId: audioId ?? this.audioId,
      position: position ?? this.position,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (playlistId.present) {
      map['playlist_id'] = Variable<int>(playlistId.value);
    }
    if (audioId.present) {
      map['audio_id'] = Variable<int>(audioId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AudioPlaylistItemsCompanion(')
          ..write('id: $id, ')
          ..write('playlistId: $playlistId, ')
          ..write('audioId: $audioId, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }
}

class $AudioSchedulesTable extends AudioSchedules
    with TableInfo<$AudioSchedulesTable, AudioScheduleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AudioSchedulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _prayerMeta = const VerificationMeta('prayer');
  @override
  late final GeneratedColumn<String> prayer = GeneratedColumn<String>(
    'prayer',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _configJsonMeta = const VerificationMeta(
    'configJson',
  );
  @override
  late final GeneratedColumn<String> configJson = GeneratedColumn<String>(
    'config_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [prayer, configJson, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audio_schedules';
  @override
  VerificationContext validateIntegrity(
    Insertable<AudioScheduleRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('prayer')) {
      context.handle(
        _prayerMeta,
        prayer.isAcceptableOrUnknown(data['prayer']!, _prayerMeta),
      );
    } else if (isInserting) {
      context.missing(_prayerMeta);
    }
    if (data.containsKey('config_json')) {
      context.handle(
        _configJsonMeta,
        configJson.isAcceptableOrUnknown(data['config_json']!, _configJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_configJsonMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {prayer};
  @override
  AudioScheduleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AudioScheduleRow(
      prayer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prayer'],
      )!,
      configJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}config_json'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AudioSchedulesTable createAlias(String alias) {
    return $AudioSchedulesTable(attachedDatabase, alias);
  }
}

class AudioScheduleRow extends DataClass
    implements Insertable<AudioScheduleRow> {
  final String prayer;
  final String configJson;
  final DateTime updatedAt;
  const AudioScheduleRow({
    required this.prayer,
    required this.configJson,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['prayer'] = Variable<String>(prayer);
    map['config_json'] = Variable<String>(configJson);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AudioSchedulesCompanion toCompanion(bool nullToAbsent) {
    return AudioSchedulesCompanion(
      prayer: Value(prayer),
      configJson: Value(configJson),
      updatedAt: Value(updatedAt),
    );
  }

  factory AudioScheduleRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AudioScheduleRow(
      prayer: serializer.fromJson<String>(json['prayer']),
      configJson: serializer.fromJson<String>(json['configJson']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'prayer': serializer.toJson<String>(prayer),
      'configJson': serializer.toJson<String>(configJson),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AudioScheduleRow copyWith({
    String? prayer,
    String? configJson,
    DateTime? updatedAt,
  }) => AudioScheduleRow(
    prayer: prayer ?? this.prayer,
    configJson: configJson ?? this.configJson,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AudioScheduleRow copyWithCompanion(AudioSchedulesCompanion data) {
    return AudioScheduleRow(
      prayer: data.prayer.present ? data.prayer.value : this.prayer,
      configJson: data.configJson.present
          ? data.configJson.value
          : this.configJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AudioScheduleRow(')
          ..write('prayer: $prayer, ')
          ..write('configJson: $configJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(prayer, configJson, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AudioScheduleRow &&
          other.prayer == this.prayer &&
          other.configJson == this.configJson &&
          other.updatedAt == this.updatedAt);
}

class AudioSchedulesCompanion extends UpdateCompanion<AudioScheduleRow> {
  final Value<String> prayer;
  final Value<String> configJson;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AudioSchedulesCompanion({
    this.prayer = const Value.absent(),
    this.configJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AudioSchedulesCompanion.insert({
    required String prayer,
    required String configJson,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : prayer = Value(prayer),
       configJson = Value(configJson);
  static Insertable<AudioScheduleRow> custom({
    Expression<String>? prayer,
    Expression<String>? configJson,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (prayer != null) 'prayer': prayer,
      if (configJson != null) 'config_json': configJson,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AudioSchedulesCompanion copyWith({
    Value<String>? prayer,
    Value<String>? configJson,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return AudioSchedulesCompanion(
      prayer: prayer ?? this.prayer,
      configJson: configJson ?? this.configJson,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (prayer.present) {
      map['prayer'] = Variable<String>(prayer.value);
    }
    if (configJson.present) {
      map['config_json'] = Variable<String>(configJson.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AudioSchedulesCompanion(')
          ..write('prayer: $prayer, ')
          ..write('configJson: $configJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AudioPlaybackHistoryTable extends AudioPlaybackHistory
    with TableInfo<$AudioPlaybackHistoryTable, PlaybackHistoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AudioPlaybackHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _eventIdMeta = const VerificationMeta(
    'eventId',
  );
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
    'event_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _detailMeta = const VerificationMeta('detail');
  @override
  late final GeneratedColumn<String> detail = GeneratedColumn<String>(
    'detail',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    eventId,
    title,
    status,
    detail,
    startedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audio_playback_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlaybackHistoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('event_id')) {
      context.handle(
        _eventIdMeta,
        eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('detail')) {
      context.handle(
        _detailMeta,
        detail.isAcceptableOrUnknown(data['detail']!, _detailMeta),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {eventId, startedAt},
  ];
  @override
  PlaybackHistoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaybackHistoryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      eventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_id'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      detail: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}detail'],
      ),
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
    );
  }

  @override
  $AudioPlaybackHistoryTable createAlias(String alias) {
    return $AudioPlaybackHistoryTable(attachedDatabase, alias);
  }
}

class PlaybackHistoryRow extends DataClass
    implements Insertable<PlaybackHistoryRow> {
  final int id;
  final String? eventId;
  final String title;
  final String status;
  final String? detail;
  final DateTime startedAt;
  const PlaybackHistoryRow({
    required this.id,
    this.eventId,
    required this.title,
    required this.status,
    this.detail,
    required this.startedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || eventId != null) {
      map['event_id'] = Variable<String>(eventId);
    }
    map['title'] = Variable<String>(title);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || detail != null) {
      map['detail'] = Variable<String>(detail);
    }
    map['started_at'] = Variable<DateTime>(startedAt);
    return map;
  }

  AudioPlaybackHistoryCompanion toCompanion(bool nullToAbsent) {
    return AudioPlaybackHistoryCompanion(
      id: Value(id),
      eventId: eventId == null && nullToAbsent
          ? const Value.absent()
          : Value(eventId),
      title: Value(title),
      status: Value(status),
      detail: detail == null && nullToAbsent
          ? const Value.absent()
          : Value(detail),
      startedAt: Value(startedAt),
    );
  }

  factory PlaybackHistoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaybackHistoryRow(
      id: serializer.fromJson<int>(json['id']),
      eventId: serializer.fromJson<String?>(json['eventId']),
      title: serializer.fromJson<String>(json['title']),
      status: serializer.fromJson<String>(json['status']),
      detail: serializer.fromJson<String?>(json['detail']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'eventId': serializer.toJson<String?>(eventId),
      'title': serializer.toJson<String>(title),
      'status': serializer.toJson<String>(status),
      'detail': serializer.toJson<String?>(detail),
      'startedAt': serializer.toJson<DateTime>(startedAt),
    };
  }

  PlaybackHistoryRow copyWith({
    int? id,
    Value<String?> eventId = const Value.absent(),
    String? title,
    String? status,
    Value<String?> detail = const Value.absent(),
    DateTime? startedAt,
  }) => PlaybackHistoryRow(
    id: id ?? this.id,
    eventId: eventId.present ? eventId.value : this.eventId,
    title: title ?? this.title,
    status: status ?? this.status,
    detail: detail.present ? detail.value : this.detail,
    startedAt: startedAt ?? this.startedAt,
  );
  PlaybackHistoryRow copyWithCompanion(AudioPlaybackHistoryCompanion data) {
    return PlaybackHistoryRow(
      id: data.id.present ? data.id.value : this.id,
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      title: data.title.present ? data.title.value : this.title,
      status: data.status.present ? data.status.value : this.status,
      detail: data.detail.present ? data.detail.value : this.detail,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaybackHistoryRow(')
          ..write('id: $id, ')
          ..write('eventId: $eventId, ')
          ..write('title: $title, ')
          ..write('status: $status, ')
          ..write('detail: $detail, ')
          ..write('startedAt: $startedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, eventId, title, status, detail, startedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaybackHistoryRow &&
          other.id == this.id &&
          other.eventId == this.eventId &&
          other.title == this.title &&
          other.status == this.status &&
          other.detail == this.detail &&
          other.startedAt == this.startedAt);
}

class AudioPlaybackHistoryCompanion
    extends UpdateCompanion<PlaybackHistoryRow> {
  final Value<int> id;
  final Value<String?> eventId;
  final Value<String> title;
  final Value<String> status;
  final Value<String?> detail;
  final Value<DateTime> startedAt;
  const AudioPlaybackHistoryCompanion({
    this.id = const Value.absent(),
    this.eventId = const Value.absent(),
    this.title = const Value.absent(),
    this.status = const Value.absent(),
    this.detail = const Value.absent(),
    this.startedAt = const Value.absent(),
  });
  AudioPlaybackHistoryCompanion.insert({
    this.id = const Value.absent(),
    this.eventId = const Value.absent(),
    required String title,
    required String status,
    this.detail = const Value.absent(),
    required DateTime startedAt,
  }) : title = Value(title),
       status = Value(status),
       startedAt = Value(startedAt);
  static Insertable<PlaybackHistoryRow> custom({
    Expression<int>? id,
    Expression<String>? eventId,
    Expression<String>? title,
    Expression<String>? status,
    Expression<String>? detail,
    Expression<DateTime>? startedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (eventId != null) 'event_id': eventId,
      if (title != null) 'title': title,
      if (status != null) 'status': status,
      if (detail != null) 'detail': detail,
      if (startedAt != null) 'started_at': startedAt,
    });
  }

  AudioPlaybackHistoryCompanion copyWith({
    Value<int>? id,
    Value<String?>? eventId,
    Value<String>? title,
    Value<String>? status,
    Value<String?>? detail,
    Value<DateTime>? startedAt,
  }) {
    return AudioPlaybackHistoryCompanion(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      title: title ?? this.title,
      status: status ?? this.status,
      detail: detail ?? this.detail,
      startedAt: startedAt ?? this.startedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (detail.present) {
      map['detail'] = Variable<String>(detail.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AudioPlaybackHistoryCompanion(')
          ..write('id: $id, ')
          ..write('eventId: $eventId, ')
          ..write('title: $title, ')
          ..write('status: $status, ')
          ..write('detail: $detail, ')
          ..write('startedAt: $startedAt')
          ..write(')'))
        .toString();
  }
}

class $WallpapersTable extends Wallpapers
    with TableInfo<$WallpapersTable, WallpaperRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WallpapersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, filePath, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wallpapers';
  @override
  VerificationContext validateIntegrity(
    Insertable<WallpaperRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WallpaperRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WallpaperRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $WallpapersTable createAlias(String alias) {
    return $WallpapersTable(attachedDatabase, alias);
  }
}

class WallpaperRow extends DataClass implements Insertable<WallpaperRow> {
  final int id;
  final String name;
  final String filePath;
  final DateTime createdAt;
  const WallpaperRow({
    required this.id,
    required this.name,
    required this.filePath,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['file_path'] = Variable<String>(filePath);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  WallpapersCompanion toCompanion(bool nullToAbsent) {
    return WallpapersCompanion(
      id: Value(id),
      name: Value(name),
      filePath: Value(filePath),
      createdAt: Value(createdAt),
    );
  }

  factory WallpaperRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WallpaperRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      filePath: serializer.fromJson<String>(json['filePath']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'filePath': serializer.toJson<String>(filePath),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  WallpaperRow copyWith({
    int? id,
    String? name,
    String? filePath,
    DateTime? createdAt,
  }) => WallpaperRow(
    id: id ?? this.id,
    name: name ?? this.name,
    filePath: filePath ?? this.filePath,
    createdAt: createdAt ?? this.createdAt,
  );
  WallpaperRow copyWithCompanion(WallpapersCompanion data) {
    return WallpaperRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WallpaperRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('filePath: $filePath, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, filePath, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WallpaperRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.filePath == this.filePath &&
          other.createdAt == this.createdAt);
}

class WallpapersCompanion extends UpdateCompanion<WallpaperRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> filePath;
  final Value<DateTime> createdAt;
  const WallpapersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.filePath = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  WallpapersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String filePath,
    this.createdAt = const Value.absent(),
  }) : name = Value(name),
       filePath = Value(filePath);
  static Insertable<WallpaperRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? filePath,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (filePath != null) 'file_path': filePath,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  WallpapersCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? filePath,
    Value<DateTime>? createdAt,
  }) {
    return WallpapersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      filePath: filePath ?? this.filePath,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WallpapersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('filePath: $filePath, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $UserSettingsTable extends UserSettings
    with TableInfo<$UserSettingsTable, SettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $UserSettingsTable createAlias(String alias) {
    return $UserSettingsTable(attachedDatabase, alias);
  }
}

class SettingRow extends DataClass implements Insertable<SettingRow> {
  final String key;
  final String value;
  final DateTime updatedAt;
  const SettingRow({
    required this.key,
    required this.value,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UserSettingsCompanion toCompanion(bool nullToAbsent) {
    return UserSettingsCompanion(
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory SettingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SettingRow copyWith({String? key, String? value, DateTime? updatedAt}) =>
      SettingRow(
        key: key ?? this.key,
        value: value ?? this.value,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  SettingRow copyWithCompanion(UserSettingsCompanion data) {
    return SettingRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingRow(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingRow &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class UserSettingsCompanion extends UpdateCompanion<SettingRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const UserSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserSettingsCompanion.insert({
    required String key,
    required String value,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<SettingRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return UserSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
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
      map['value'] = Variable<String>(value.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FavoritesTable extends Favorites
    with TableInfo<$FavoritesTable, FavoriteRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FavoritesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _contentIdMeta = const VerificationMeta(
    'contentId',
  );
  @override
  late final GeneratedColumn<String> contentId = GeneratedColumn<String>(
    'content_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [contentId, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'favorites';
  @override
  VerificationContext validateIntegrity(
    Insertable<FavoriteRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('content_id')) {
      context.handle(
        _contentIdMeta,
        contentId.isAcceptableOrUnknown(data['content_id']!, _contentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_contentIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {contentId};
  @override
  FavoriteRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FavoriteRow(
      contentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $FavoritesTable createAlias(String alias) {
    return $FavoritesTable(attachedDatabase, alias);
  }
}

class FavoriteRow extends DataClass implements Insertable<FavoriteRow> {
  final String contentId;
  final DateTime createdAt;
  const FavoriteRow({required this.contentId, required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['content_id'] = Variable<String>(contentId);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  FavoritesCompanion toCompanion(bool nullToAbsent) {
    return FavoritesCompanion(
      contentId: Value(contentId),
      createdAt: Value(createdAt),
    );
  }

  factory FavoriteRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FavoriteRow(
      contentId: serializer.fromJson<String>(json['contentId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'contentId': serializer.toJson<String>(contentId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  FavoriteRow copyWith({String? contentId, DateTime? createdAt}) => FavoriteRow(
    contentId: contentId ?? this.contentId,
    createdAt: createdAt ?? this.createdAt,
  );
  FavoriteRow copyWithCompanion(FavoritesCompanion data) {
    return FavoriteRow(
      contentId: data.contentId.present ? data.contentId.value : this.contentId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteRow(')
          ..write('contentId: $contentId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(contentId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FavoriteRow &&
          other.contentId == this.contentId &&
          other.createdAt == this.createdAt);
}

class FavoritesCompanion extends UpdateCompanion<FavoriteRow> {
  final Value<String> contentId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const FavoritesCompanion({
    this.contentId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FavoritesCompanion.insert({
    required String contentId,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : contentId = Value(contentId);
  static Insertable<FavoriteRow> custom({
    Expression<String>? contentId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (contentId != null) 'content_id': contentId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FavoritesCompanion copyWith({
    Value<String>? contentId,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return FavoritesCompanion(
      contentId: contentId ?? this.contentId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (contentId.present) {
      map['content_id'] = Variable<String>(contentId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FavoritesCompanion(')
          ..write('contentId: $contentId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TasbihRecordsTable extends TasbihRecords
    with TableInfo<$TasbihRecordsTable, TasbihRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasbihRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _zikrMeta = const VerificationMeta('zikr');
  @override
  late final GeneratedColumn<String> zikr = GeneratedColumn<String>(
    'zikr',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _countMeta = const VerificationMeta('count');
  @override
  late final GeneratedColumn<int> count = GeneratedColumn<int>(
    'count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetMeta = const VerificationMeta('target');
  @override
  late final GeneratedColumn<int> target = GeneratedColumn<int>(
    'target',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    zikr,
    count,
    target,
    date,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasbih_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<TasbihRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('zikr')) {
      context.handle(
        _zikrMeta,
        zikr.isAcceptableOrUnknown(data['zikr']!, _zikrMeta),
      );
    } else if (isInserting) {
      context.missing(_zikrMeta);
    }
    if (data.containsKey('count')) {
      context.handle(
        _countMeta,
        count.isAcceptableOrUnknown(data['count']!, _countMeta),
      );
    } else if (isInserting) {
      context.missing(_countMeta);
    }
    if (data.containsKey('target')) {
      context.handle(
        _targetMeta,
        target.isAcceptableOrUnknown(data['target']!, _targetMeta),
      );
    } else if (isInserting) {
      context.missing(_targetMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TasbihRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TasbihRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      zikr: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}zikr'],
      )!,
      count: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}count'],
      )!,
      target: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TasbihRecordsTable createAlias(String alias) {
    return $TasbihRecordsTable(attachedDatabase, alias);
  }
}

class TasbihRow extends DataClass implements Insertable<TasbihRow> {
  final int id;
  final String zikr;
  final int count;
  final int target;
  final String date;
  final DateTime createdAt;
  const TasbihRow({
    required this.id,
    required this.zikr,
    required this.count,
    required this.target,
    required this.date,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['zikr'] = Variable<String>(zikr);
    map['count'] = Variable<int>(count);
    map['target'] = Variable<int>(target);
    map['date'] = Variable<String>(date);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TasbihRecordsCompanion toCompanion(bool nullToAbsent) {
    return TasbihRecordsCompanion(
      id: Value(id),
      zikr: Value(zikr),
      count: Value(count),
      target: Value(target),
      date: Value(date),
      createdAt: Value(createdAt),
    );
  }

  factory TasbihRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TasbihRow(
      id: serializer.fromJson<int>(json['id']),
      zikr: serializer.fromJson<String>(json['zikr']),
      count: serializer.fromJson<int>(json['count']),
      target: serializer.fromJson<int>(json['target']),
      date: serializer.fromJson<String>(json['date']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'zikr': serializer.toJson<String>(zikr),
      'count': serializer.toJson<int>(count),
      'target': serializer.toJson<int>(target),
      'date': serializer.toJson<String>(date),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  TasbihRow copyWith({
    int? id,
    String? zikr,
    int? count,
    int? target,
    String? date,
    DateTime? createdAt,
  }) => TasbihRow(
    id: id ?? this.id,
    zikr: zikr ?? this.zikr,
    count: count ?? this.count,
    target: target ?? this.target,
    date: date ?? this.date,
    createdAt: createdAt ?? this.createdAt,
  );
  TasbihRow copyWithCompanion(TasbihRecordsCompanion data) {
    return TasbihRow(
      id: data.id.present ? data.id.value : this.id,
      zikr: data.zikr.present ? data.zikr.value : this.zikr,
      count: data.count.present ? data.count.value : this.count,
      target: data.target.present ? data.target.value : this.target,
      date: data.date.present ? data.date.value : this.date,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TasbihRow(')
          ..write('id: $id, ')
          ..write('zikr: $zikr, ')
          ..write('count: $count, ')
          ..write('target: $target, ')
          ..write('date: $date, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, zikr, count, target, date, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TasbihRow &&
          other.id == this.id &&
          other.zikr == this.zikr &&
          other.count == this.count &&
          other.target == this.target &&
          other.date == this.date &&
          other.createdAt == this.createdAt);
}

class TasbihRecordsCompanion extends UpdateCompanion<TasbihRow> {
  final Value<int> id;
  final Value<String> zikr;
  final Value<int> count;
  final Value<int> target;
  final Value<String> date;
  final Value<DateTime> createdAt;
  const TasbihRecordsCompanion({
    this.id = const Value.absent(),
    this.zikr = const Value.absent(),
    this.count = const Value.absent(),
    this.target = const Value.absent(),
    this.date = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  TasbihRecordsCompanion.insert({
    this.id = const Value.absent(),
    required String zikr,
    required int count,
    required int target,
    required String date,
    this.createdAt = const Value.absent(),
  }) : zikr = Value(zikr),
       count = Value(count),
       target = Value(target),
       date = Value(date);
  static Insertable<TasbihRow> custom({
    Expression<int>? id,
    Expression<String>? zikr,
    Expression<int>? count,
    Expression<int>? target,
    Expression<String>? date,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (zikr != null) 'zikr': zikr,
      if (count != null) 'count': count,
      if (target != null) 'target': target,
      if (date != null) 'date': date,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  TasbihRecordsCompanion copyWith({
    Value<int>? id,
    Value<String>? zikr,
    Value<int>? count,
    Value<int>? target,
    Value<String>? date,
    Value<DateTime>? createdAt,
  }) {
    return TasbihRecordsCompanion(
      id: id ?? this.id,
      zikr: zikr ?? this.zikr,
      count: count ?? this.count,
      target: target ?? this.target,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (zikr.present) {
      map['zikr'] = Variable<String>(zikr.value);
    }
    if (count.present) {
      map['count'] = Variable<int>(count.value);
    }
    if (target.present) {
      map['target'] = Variable<int>(target.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasbihRecordsCompanion(')
          ..write('id: $id, ')
          ..write('zikr: $zikr, ')
          ..write('count: $count, ')
          ..write('target: $target, ')
          ..write('date: $date, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $NotificationSettingsTable extends NotificationSettings
    with TableInfo<$NotificationSettingsTable, NotificationSettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotificationSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _prayerMeta = const VerificationMeta('prayer');
  @override
  late final GeneratedColumn<String> prayer = GeneratedColumn<String>(
    'prayer',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _configJsonMeta = const VerificationMeta(
    'configJson',
  );
  @override
  late final GeneratedColumn<String> configJson = GeneratedColumn<String>(
    'config_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [prayer, configJson, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notification_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<NotificationSettingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('prayer')) {
      context.handle(
        _prayerMeta,
        prayer.isAcceptableOrUnknown(data['prayer']!, _prayerMeta),
      );
    } else if (isInserting) {
      context.missing(_prayerMeta);
    }
    if (data.containsKey('config_json')) {
      context.handle(
        _configJsonMeta,
        configJson.isAcceptableOrUnknown(data['config_json']!, _configJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_configJsonMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {prayer};
  @override
  NotificationSettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NotificationSettingRow(
      prayer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prayer'],
      )!,
      configJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}config_json'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $NotificationSettingsTable createAlias(String alias) {
    return $NotificationSettingsTable(attachedDatabase, alias);
  }
}

class NotificationSettingRow extends DataClass
    implements Insertable<NotificationSettingRow> {
  final String prayer;
  final String configJson;
  final DateTime updatedAt;
  const NotificationSettingRow({
    required this.prayer,
    required this.configJson,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['prayer'] = Variable<String>(prayer);
    map['config_json'] = Variable<String>(configJson);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  NotificationSettingsCompanion toCompanion(bool nullToAbsent) {
    return NotificationSettingsCompanion(
      prayer: Value(prayer),
      configJson: Value(configJson),
      updatedAt: Value(updatedAt),
    );
  }

  factory NotificationSettingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NotificationSettingRow(
      prayer: serializer.fromJson<String>(json['prayer']),
      configJson: serializer.fromJson<String>(json['configJson']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'prayer': serializer.toJson<String>(prayer),
      'configJson': serializer.toJson<String>(configJson),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  NotificationSettingRow copyWith({
    String? prayer,
    String? configJson,
    DateTime? updatedAt,
  }) => NotificationSettingRow(
    prayer: prayer ?? this.prayer,
    configJson: configJson ?? this.configJson,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  NotificationSettingRow copyWithCompanion(NotificationSettingsCompanion data) {
    return NotificationSettingRow(
      prayer: data.prayer.present ? data.prayer.value : this.prayer,
      configJson: data.configJson.present
          ? data.configJson.value
          : this.configJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NotificationSettingRow(')
          ..write('prayer: $prayer, ')
          ..write('configJson: $configJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(prayer, configJson, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NotificationSettingRow &&
          other.prayer == this.prayer &&
          other.configJson == this.configJson &&
          other.updatedAt == this.updatedAt);
}

class NotificationSettingsCompanion
    extends UpdateCompanion<NotificationSettingRow> {
  final Value<String> prayer;
  final Value<String> configJson;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const NotificationSettingsCompanion({
    this.prayer = const Value.absent(),
    this.configJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NotificationSettingsCompanion.insert({
    required String prayer,
    required String configJson,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : prayer = Value(prayer),
       configJson = Value(configJson);
  static Insertable<NotificationSettingRow> custom({
    Expression<String>? prayer,
    Expression<String>? configJson,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (prayer != null) 'prayer': prayer,
      if (configJson != null) 'config_json': configJson,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NotificationSettingsCompanion copyWith({
    Value<String>? prayer,
    Value<String>? configJson,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return NotificationSettingsCompanion(
      prayer: prayer ?? this.prayer,
      configJson: configJson ?? this.configJson,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (prayer.present) {
      map['prayer'] = Variable<String>(prayer.value);
    }
    if (configJson.present) {
      map['config_json'] = Variable<String>(configJson.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotificationSettingsCompanion(')
          ..write('prayer: $prayer, ')
          ..write('configJson: $configJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppDiagnosticsTable extends AppDiagnostics
    with TableInfo<$AppDiagnosticsTable, DiagnosticRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppDiagnosticsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<String> level = GeneratedColumn<String>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tagMeta = const VerificationMeta('tag');
  @override
  late final GeneratedColumn<String> tag = GeneratedColumn<String>(
    'tag',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _messageMeta = const VerificationMeta(
    'message',
  );
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
    'message',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, level, tag, message, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_diagnostics';
  @override
  VerificationContext validateIntegrity(
    Insertable<DiagnosticRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    } else if (isInserting) {
      context.missing(_levelMeta);
    }
    if (data.containsKey('tag')) {
      context.handle(
        _tagMeta,
        tag.isAcceptableOrUnknown(data['tag']!, _tagMeta),
      );
    } else if (isInserting) {
      context.missing(_tagMeta);
    }
    if (data.containsKey('message')) {
      context.handle(
        _messageMeta,
        message.isAcceptableOrUnknown(data['message']!, _messageMeta),
      );
    } else if (isInserting) {
      context.missing(_messageMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DiagnosticRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DiagnosticRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}level'],
      )!,
      tag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag'],
      )!,
      message: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AppDiagnosticsTable createAlias(String alias) {
    return $AppDiagnosticsTable(attachedDatabase, alias);
  }
}

class DiagnosticRow extends DataClass implements Insertable<DiagnosticRow> {
  final int id;
  final String level;
  final String tag;
  final String message;
  final DateTime createdAt;
  const DiagnosticRow({
    required this.id,
    required this.level,
    required this.tag,
    required this.message,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['level'] = Variable<String>(level);
    map['tag'] = Variable<String>(tag);
    map['message'] = Variable<String>(message);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AppDiagnosticsCompanion toCompanion(bool nullToAbsent) {
    return AppDiagnosticsCompanion(
      id: Value(id),
      level: Value(level),
      tag: Value(tag),
      message: Value(message),
      createdAt: Value(createdAt),
    );
  }

  factory DiagnosticRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DiagnosticRow(
      id: serializer.fromJson<int>(json['id']),
      level: serializer.fromJson<String>(json['level']),
      tag: serializer.fromJson<String>(json['tag']),
      message: serializer.fromJson<String>(json['message']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'level': serializer.toJson<String>(level),
      'tag': serializer.toJson<String>(tag),
      'message': serializer.toJson<String>(message),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DiagnosticRow copyWith({
    int? id,
    String? level,
    String? tag,
    String? message,
    DateTime? createdAt,
  }) => DiagnosticRow(
    id: id ?? this.id,
    level: level ?? this.level,
    tag: tag ?? this.tag,
    message: message ?? this.message,
    createdAt: createdAt ?? this.createdAt,
  );
  DiagnosticRow copyWithCompanion(AppDiagnosticsCompanion data) {
    return DiagnosticRow(
      id: data.id.present ? data.id.value : this.id,
      level: data.level.present ? data.level.value : this.level,
      tag: data.tag.present ? data.tag.value : this.tag,
      message: data.message.present ? data.message.value : this.message,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DiagnosticRow(')
          ..write('id: $id, ')
          ..write('level: $level, ')
          ..write('tag: $tag, ')
          ..write('message: $message, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, level, tag, message, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DiagnosticRow &&
          other.id == this.id &&
          other.level == this.level &&
          other.tag == this.tag &&
          other.message == this.message &&
          other.createdAt == this.createdAt);
}

class AppDiagnosticsCompanion extends UpdateCompanion<DiagnosticRow> {
  final Value<int> id;
  final Value<String> level;
  final Value<String> tag;
  final Value<String> message;
  final Value<DateTime> createdAt;
  const AppDiagnosticsCompanion({
    this.id = const Value.absent(),
    this.level = const Value.absent(),
    this.tag = const Value.absent(),
    this.message = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  AppDiagnosticsCompanion.insert({
    this.id = const Value.absent(),
    required String level,
    required String tag,
    required String message,
    this.createdAt = const Value.absent(),
  }) : level = Value(level),
       tag = Value(tag),
       message = Value(message);
  static Insertable<DiagnosticRow> custom({
    Expression<int>? id,
    Expression<String>? level,
    Expression<String>? tag,
    Expression<String>? message,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (level != null) 'level': level,
      if (tag != null) 'tag': tag,
      if (message != null) 'message': message,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  AppDiagnosticsCompanion copyWith({
    Value<int>? id,
    Value<String>? level,
    Value<String>? tag,
    Value<String>? message,
    Value<DateTime>? createdAt,
  }) {
    return AppDiagnosticsCompanion(
      id: id ?? this.id,
      level: level ?? this.level,
      tag: tag ?? this.tag,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (level.present) {
      map['level'] = Variable<String>(level.value);
    }
    if (tag.present) {
      map['tag'] = Variable<String>(tag.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppDiagnosticsCompanion(')
          ..write('id: $id, ')
          ..write('level: $level, ')
          ..write('tag: $tag, ')
          ..write('message: $message, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PrayerZonesTable prayerZones = $PrayerZonesTable(this);
  late final $PrayerTimesTable prayerTimes = $PrayerTimesTable(this);
  late final $IslamicEventsTable islamicEvents = $IslamicEventsTable(this);
  late final $IslamicCalendarTable islamicCalendar = $IslamicCalendarTable(
    this,
  );
  late final $AudioLibraryTable audioLibrary = $AudioLibraryTable(this);
  late final $AudioPlaylistsTable audioPlaylists = $AudioPlaylistsTable(this);
  late final $AudioPlaylistItemsTable audioPlaylistItems =
      $AudioPlaylistItemsTable(this);
  late final $AudioSchedulesTable audioSchedules = $AudioSchedulesTable(this);
  late final $AudioPlaybackHistoryTable audioPlaybackHistory =
      $AudioPlaybackHistoryTable(this);
  late final $WallpapersTable wallpapers = $WallpapersTable(this);
  late final $UserSettingsTable userSettings = $UserSettingsTable(this);
  late final $FavoritesTable favorites = $FavoritesTable(this);
  late final $TasbihRecordsTable tasbihRecords = $TasbihRecordsTable(this);
  late final $NotificationSettingsTable notificationSettings =
      $NotificationSettingsTable(this);
  late final $AppDiagnosticsTable appDiagnostics = $AppDiagnosticsTable(this);
  late final Index idxPrayerTimesZoneDate = Index(
    'idx_prayer_times_zone_date',
    'CREATE UNIQUE INDEX idx_prayer_times_zone_date ON prayer_times (zone, date)',
  );
  late final Index idxEventsKeyYear = Index(
    'idx_events_key_year',
    'CREATE UNIQUE INDEX idx_events_key_year ON islamic_events (event_key, hijri_year)',
  );
  late final Index idxAudioCategory = Index(
    'idx_audio_category',
    'CREATE INDEX idx_audio_category ON audio_library (category)',
  );
  late final Index idxPlaylistItemsPlaylist = Index(
    'idx_playlist_items_playlist',
    'CREATE INDEX idx_playlist_items_playlist ON audio_playlist_items (playlist_id, position)',
  );
  late final Index idxPlaybackStarted = Index(
    'idx_playback_started',
    'CREATE INDEX idx_playback_started ON audio_playback_history (started_at)',
  );
  late final Index idxTasbihDate = Index(
    'idx_tasbih_date',
    'CREATE INDEX idx_tasbih_date ON tasbih_records (date)',
  );
  late final Index idxDiagCreated = Index(
    'idx_diag_created',
    'CREATE INDEX idx_diag_created ON app_diagnostics (created_at)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    prayerZones,
    prayerTimes,
    islamicEvents,
    islamicCalendar,
    audioLibrary,
    audioPlaylists,
    audioPlaylistItems,
    audioSchedules,
    audioPlaybackHistory,
    wallpapers,
    userSettings,
    favorites,
    tasbihRecords,
    notificationSettings,
    appDiagnostics,
    idxPrayerTimesZoneDate,
    idxEventsKeyYear,
    idxAudioCategory,
    idxPlaylistItemsPlaylist,
    idxPlaybackStarted,
    idxTasbihDate,
    idxDiagCreated,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'audio_playlists',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('audio_playlist_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'audio_library',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('audio_playlist_items', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$PrayerZonesTableCreateCompanionBuilder =
    PrayerZonesCompanion Function({
      required String code,
      required String state,
      required String areas,
      Value<double?> lat,
      Value<double?> lng,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$PrayerZonesTableUpdateCompanionBuilder =
    PrayerZonesCompanion Function({
      Value<String> code,
      Value<String> state,
      Value<String> areas,
      Value<double?> lat,
      Value<double?> lng,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$PrayerZonesTableReferences
    extends BaseReferences<_$AppDatabase, $PrayerZonesTable, PrayerZoneRow> {
  $$PrayerZonesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PrayerTimesTable, List<PrayerTimeRow>>
  _prayerTimesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.prayerTimes,
    aliasName: 'prayer_zones__code__prayer_times__zone',
  );

  $$PrayerTimesTableProcessedTableManager get prayerTimesRefs {
    final manager = $$PrayerTimesTableTableManager(
      $_db,
      $_db.prayerTimes,
    ).filter((f) => f.zone.code.sqlEquals($_itemColumn<String>('code')!));

    final cache = $_typedResult.readTableOrNull(_prayerTimesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PrayerZonesTableFilterComposer
    extends Composer<_$AppDatabase, $PrayerZonesTable> {
  $$PrayerZonesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get areas => $composableBuilder(
    column: $table.areas,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> prayerTimesRefs(
    Expression<bool> Function($$PrayerTimesTableFilterComposer f) f,
  ) {
    final $$PrayerTimesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.code,
      referencedTable: $db.prayerTimes,
      getReferencedColumn: (t) => t.zone,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PrayerTimesTableFilterComposer(
            $db: $db,
            $table: $db.prayerTimes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PrayerZonesTableOrderingComposer
    extends Composer<_$AppDatabase, $PrayerZonesTable> {
  $$PrayerZonesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get areas => $composableBuilder(
    column: $table.areas,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PrayerZonesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PrayerZonesTable> {
  $$PrayerZonesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<String> get areas =>
      $composableBuilder(column: $table.areas, builder: (column) => column);

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lng =>
      $composableBuilder(column: $table.lng, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> prayerTimesRefs<T extends Object>(
    Expression<T> Function($$PrayerTimesTableAnnotationComposer a) f,
  ) {
    final $$PrayerTimesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.code,
      referencedTable: $db.prayerTimes,
      getReferencedColumn: (t) => t.zone,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PrayerTimesTableAnnotationComposer(
            $db: $db,
            $table: $db.prayerTimes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PrayerZonesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PrayerZonesTable,
          PrayerZoneRow,
          $$PrayerZonesTableFilterComposer,
          $$PrayerZonesTableOrderingComposer,
          $$PrayerZonesTableAnnotationComposer,
          $$PrayerZonesTableCreateCompanionBuilder,
          $$PrayerZonesTableUpdateCompanionBuilder,
          (PrayerZoneRow, $$PrayerZonesTableReferences),
          PrayerZoneRow,
          PrefetchHooks Function({bool prayerTimesRefs})
        > {
  $$PrayerZonesTableTableManager(_$AppDatabase db, $PrayerZonesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PrayerZonesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PrayerZonesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PrayerZonesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> code = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<String> areas = const Value.absent(),
                Value<double?> lat = const Value.absent(),
                Value<double?> lng = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PrayerZonesCompanion(
                code: code,
                state: state,
                areas: areas,
                lat: lat,
                lng: lng,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String code,
                required String state,
                required String areas,
                Value<double?> lat = const Value.absent(),
                Value<double?> lng = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PrayerZonesCompanion.insert(
                code: code,
                state: state,
                areas: areas,
                lat: lat,
                lng: lng,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PrayerZonesTable, PrayerZoneRow>(table),
                  $$PrayerZonesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({prayerTimesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (prayerTimesRefs) db.prayerTimes],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (prayerTimesRefs)
                    await $_getPrefetchedDataByColumns<
                      PrayerZoneRow,
                      $PrayerZonesTable,
                      PrayerTimeRow,
                      $PrayerTimesTable
                    >(
                      currentTable: table,
                      referencedTable: $$PrayerZonesTableReferences
                          ._prayerTimesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$PrayerZonesTableReferences(
                            db,
                            table,
                            p0,
                          ).prayerTimesRefs,
                      currentColumn: 'code',
                      referencedColumn: 'zone',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PrayerZonesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PrayerZonesTable,
      PrayerZoneRow,
      $$PrayerZonesTableFilterComposer,
      $$PrayerZonesTableOrderingComposer,
      $$PrayerZonesTableAnnotationComposer,
      $$PrayerZonesTableCreateCompanionBuilder,
      $$PrayerZonesTableUpdateCompanionBuilder,
      (PrayerZoneRow, $$PrayerZonesTableReferences),
      PrayerZoneRow,
      PrefetchHooks Function({bool prayerTimesRefs})
    >;
typedef $$PrayerTimesTableCreateCompanionBuilder =
    PrayerTimesCompanion Function({
      Value<int> id,
      required String zone,
      required String date,
      Value<int?> imsak,
      required int subuh,
      required int syuruk,
      required int zohor,
      required int asar,
      required int maghrib,
      required int isyak,
      Value<String?> hijri,
      required String source,
      required DateTime fetchedAt,
    });
typedef $$PrayerTimesTableUpdateCompanionBuilder =
    PrayerTimesCompanion Function({
      Value<int> id,
      Value<String> zone,
      Value<String> date,
      Value<int?> imsak,
      Value<int> subuh,
      Value<int> syuruk,
      Value<int> zohor,
      Value<int> asar,
      Value<int> maghrib,
      Value<int> isyak,
      Value<String?> hijri,
      Value<String> source,
      Value<DateTime> fetchedAt,
    });

final class $$PrayerTimesTableReferences
    extends BaseReferences<_$AppDatabase, $PrayerTimesTable, PrayerTimeRow> {
  $$PrayerTimesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PrayerZonesTable _zoneTable(_$AppDatabase db) =>
      db.prayerZones.createAlias('prayer_times__zone__prayer_zones__code');

  $$PrayerZonesTableProcessedTableManager get zone {
    final $_column = $_itemColumn<String>('zone')!;

    final manager = $$PrayerZonesTableTableManager(
      $_db,
      $_db.prayerZones,
    ).filter((f) => f.code.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_zoneTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PrayerTimesTableFilterComposer
    extends Composer<_$AppDatabase, $PrayerTimesTable> {
  $$PrayerTimesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get imsak => $composableBuilder(
    column: $table.imsak,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get subuh => $composableBuilder(
    column: $table.subuh,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syuruk => $composableBuilder(
    column: $table.syuruk,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get zohor => $composableBuilder(
    column: $table.zohor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get asar => $composableBuilder(
    column: $table.asar,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maghrib => $composableBuilder(
    column: $table.maghrib,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isyak => $composableBuilder(
    column: $table.isyak,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hijri => $composableBuilder(
    column: $table.hijri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PrayerZonesTableFilterComposer get zone {
    final $$PrayerZonesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.zone,
      referencedTable: $db.prayerZones,
      getReferencedColumn: (t) => t.code,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PrayerZonesTableFilterComposer(
            $db: $db,
            $table: $db.prayerZones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PrayerTimesTableOrderingComposer
    extends Composer<_$AppDatabase, $PrayerTimesTable> {
  $$PrayerTimesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get imsak => $composableBuilder(
    column: $table.imsak,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get subuh => $composableBuilder(
    column: $table.subuh,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syuruk => $composableBuilder(
    column: $table.syuruk,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get zohor => $composableBuilder(
    column: $table.zohor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get asar => $composableBuilder(
    column: $table.asar,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maghrib => $composableBuilder(
    column: $table.maghrib,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isyak => $composableBuilder(
    column: $table.isyak,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hijri => $composableBuilder(
    column: $table.hijri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PrayerZonesTableOrderingComposer get zone {
    final $$PrayerZonesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.zone,
      referencedTable: $db.prayerZones,
      getReferencedColumn: (t) => t.code,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PrayerZonesTableOrderingComposer(
            $db: $db,
            $table: $db.prayerZones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PrayerTimesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PrayerTimesTable> {
  $$PrayerTimesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get imsak =>
      $composableBuilder(column: $table.imsak, builder: (column) => column);

  GeneratedColumn<int> get subuh =>
      $composableBuilder(column: $table.subuh, builder: (column) => column);

  GeneratedColumn<int> get syuruk =>
      $composableBuilder(column: $table.syuruk, builder: (column) => column);

  GeneratedColumn<int> get zohor =>
      $composableBuilder(column: $table.zohor, builder: (column) => column);

  GeneratedColumn<int> get asar =>
      $composableBuilder(column: $table.asar, builder: (column) => column);

  GeneratedColumn<int> get maghrib =>
      $composableBuilder(column: $table.maghrib, builder: (column) => column);

  GeneratedColumn<int> get isyak =>
      $composableBuilder(column: $table.isyak, builder: (column) => column);

  GeneratedColumn<String> get hijri =>
      $composableBuilder(column: $table.hijri, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);

  $$PrayerZonesTableAnnotationComposer get zone {
    final $$PrayerZonesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.zone,
      referencedTable: $db.prayerZones,
      getReferencedColumn: (t) => t.code,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PrayerZonesTableAnnotationComposer(
            $db: $db,
            $table: $db.prayerZones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PrayerTimesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PrayerTimesTable,
          PrayerTimeRow,
          $$PrayerTimesTableFilterComposer,
          $$PrayerTimesTableOrderingComposer,
          $$PrayerTimesTableAnnotationComposer,
          $$PrayerTimesTableCreateCompanionBuilder,
          $$PrayerTimesTableUpdateCompanionBuilder,
          (PrayerTimeRow, $$PrayerTimesTableReferences),
          PrayerTimeRow,
          PrefetchHooks Function({bool zone})
        > {
  $$PrayerTimesTableTableManager(_$AppDatabase db, $PrayerTimesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PrayerTimesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PrayerTimesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PrayerTimesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> zone = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<int?> imsak = const Value.absent(),
                Value<int> subuh = const Value.absent(),
                Value<int> syuruk = const Value.absent(),
                Value<int> zohor = const Value.absent(),
                Value<int> asar = const Value.absent(),
                Value<int> maghrib = const Value.absent(),
                Value<int> isyak = const Value.absent(),
                Value<String?> hijri = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
              }) => PrayerTimesCompanion(
                id: id,
                zone: zone,
                date: date,
                imsak: imsak,
                subuh: subuh,
                syuruk: syuruk,
                zohor: zohor,
                asar: asar,
                maghrib: maghrib,
                isyak: isyak,
                hijri: hijri,
                source: source,
                fetchedAt: fetchedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String zone,
                required String date,
                Value<int?> imsak = const Value.absent(),
                required int subuh,
                required int syuruk,
                required int zohor,
                required int asar,
                required int maghrib,
                required int isyak,
                Value<String?> hijri = const Value.absent(),
                required String source,
                required DateTime fetchedAt,
              }) => PrayerTimesCompanion.insert(
                id: id,
                zone: zone,
                date: date,
                imsak: imsak,
                subuh: subuh,
                syuruk: syuruk,
                zohor: zohor,
                asar: asar,
                maghrib: maghrib,
                isyak: isyak,
                hijri: hijri,
                source: source,
                fetchedAt: fetchedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PrayerTimesTable, PrayerTimeRow>(table),
                  $$PrayerTimesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({zone = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (zone) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.zone,
                        referencedTable: $$PrayerTimesTableReferences
                            ._zoneTable(db),
                        referencedColumn: $$PrayerTimesTableReferences
                            ._zoneTable(db)
                            .code,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PrayerTimesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PrayerTimesTable,
      PrayerTimeRow,
      $$PrayerTimesTableFilterComposer,
      $$PrayerTimesTableOrderingComposer,
      $$PrayerTimesTableAnnotationComposer,
      $$PrayerTimesTableCreateCompanionBuilder,
      $$PrayerTimesTableUpdateCompanionBuilder,
      (PrayerTimeRow, $$PrayerTimesTableReferences),
      PrayerTimeRow,
      PrefetchHooks Function({bool zone})
    >;
typedef $$IslamicEventsTableCreateCompanionBuilder =
    IslamicEventsCompanion Function({
      Value<int> id,
      required String eventKey,
      required int hijriYear,
      required String gregorianDate,
      required String source,
      Value<String?> note,
      Value<DateTime> createdAt,
    });
typedef $$IslamicEventsTableUpdateCompanionBuilder =
    IslamicEventsCompanion Function({
      Value<int> id,
      Value<String> eventKey,
      Value<int> hijriYear,
      Value<String> gregorianDate,
      Value<String> source,
      Value<String?> note,
      Value<DateTime> createdAt,
    });

class $$IslamicEventsTableFilterComposer
    extends Composer<_$AppDatabase, $IslamicEventsTable> {
  $$IslamicEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventKey => $composableBuilder(
    column: $table.eventKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hijriYear => $composableBuilder(
    column: $table.hijriYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gregorianDate => $composableBuilder(
    column: $table.gregorianDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$IslamicEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $IslamicEventsTable> {
  $$IslamicEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventKey => $composableBuilder(
    column: $table.eventKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hijriYear => $composableBuilder(
    column: $table.hijriYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gregorianDate => $composableBuilder(
    column: $table.gregorianDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$IslamicEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $IslamicEventsTable> {
  $$IslamicEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get eventKey =>
      $composableBuilder(column: $table.eventKey, builder: (column) => column);

  GeneratedColumn<int> get hijriYear =>
      $composableBuilder(column: $table.hijriYear, builder: (column) => column);

  GeneratedColumn<String> get gregorianDate => $composableBuilder(
    column: $table.gregorianDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$IslamicEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IslamicEventsTable,
          IslamicEventRow,
          $$IslamicEventsTableFilterComposer,
          $$IslamicEventsTableOrderingComposer,
          $$IslamicEventsTableAnnotationComposer,
          $$IslamicEventsTableCreateCompanionBuilder,
          $$IslamicEventsTableUpdateCompanionBuilder,
          (
            IslamicEventRow,
            BaseReferences<_$AppDatabase, $IslamicEventsTable, IslamicEventRow>,
          ),
          IslamicEventRow,
          PrefetchHooks Function()
        > {
  $$IslamicEventsTableTableManager(_$AppDatabase db, $IslamicEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IslamicEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IslamicEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IslamicEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> eventKey = const Value.absent(),
                Value<int> hijriYear = const Value.absent(),
                Value<String> gregorianDate = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => IslamicEventsCompanion(
                id: id,
                eventKey: eventKey,
                hijriYear: hijriYear,
                gregorianDate: gregorianDate,
                source: source,
                note: note,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String eventKey,
                required int hijriYear,
                required String gregorianDate,
                required String source,
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => IslamicEventsCompanion.insert(
                id: id,
                eventKey: eventKey,
                hijriYear: hijriYear,
                gregorianDate: gregorianDate,
                source: source,
                note: note,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$IslamicEventsTable, IslamicEventRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $IslamicEventsTable,
                    IslamicEventRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$IslamicEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IslamicEventsTable,
      IslamicEventRow,
      $$IslamicEventsTableFilterComposer,
      $$IslamicEventsTableOrderingComposer,
      $$IslamicEventsTableAnnotationComposer,
      $$IslamicEventsTableCreateCompanionBuilder,
      $$IslamicEventsTableUpdateCompanionBuilder,
      (
        IslamicEventRow,
        BaseReferences<_$AppDatabase, $IslamicEventsTable, IslamicEventRow>,
      ),
      IslamicEventRow,
      PrefetchHooks Function()
    >;
typedef $$IslamicCalendarTableCreateCompanionBuilder =
    IslamicCalendarCompanion Function({
      required int hijriYear,
      required int hijriMonth,
      Value<int> adjustDays,
      Value<String> source,
      Value<int> rowid,
    });
typedef $$IslamicCalendarTableUpdateCompanionBuilder =
    IslamicCalendarCompanion Function({
      Value<int> hijriYear,
      Value<int> hijriMonth,
      Value<int> adjustDays,
      Value<String> source,
      Value<int> rowid,
    });

class $$IslamicCalendarTableFilterComposer
    extends Composer<_$AppDatabase, $IslamicCalendarTable> {
  $$IslamicCalendarTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get hijriYear => $composableBuilder(
    column: $table.hijriYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hijriMonth => $composableBuilder(
    column: $table.hijriMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get adjustDays => $composableBuilder(
    column: $table.adjustDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );
}

class $$IslamicCalendarTableOrderingComposer
    extends Composer<_$AppDatabase, $IslamicCalendarTable> {
  $$IslamicCalendarTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get hijriYear => $composableBuilder(
    column: $table.hijriYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hijriMonth => $composableBuilder(
    column: $table.hijriMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get adjustDays => $composableBuilder(
    column: $table.adjustDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$IslamicCalendarTableAnnotationComposer
    extends Composer<_$AppDatabase, $IslamicCalendarTable> {
  $$IslamicCalendarTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get hijriYear =>
      $composableBuilder(column: $table.hijriYear, builder: (column) => column);

  GeneratedColumn<int> get hijriMonth => $composableBuilder(
    column: $table.hijriMonth,
    builder: (column) => column,
  );

  GeneratedColumn<int> get adjustDays => $composableBuilder(
    column: $table.adjustDays,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);
}

class $$IslamicCalendarTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IslamicCalendarTable,
          HijriAdjustmentRow,
          $$IslamicCalendarTableFilterComposer,
          $$IslamicCalendarTableOrderingComposer,
          $$IslamicCalendarTableAnnotationComposer,
          $$IslamicCalendarTableCreateCompanionBuilder,
          $$IslamicCalendarTableUpdateCompanionBuilder,
          (
            HijriAdjustmentRow,
            BaseReferences<
              _$AppDatabase,
              $IslamicCalendarTable,
              HijriAdjustmentRow
            >,
          ),
          HijriAdjustmentRow,
          PrefetchHooks Function()
        > {
  $$IslamicCalendarTableTableManager(
    _$AppDatabase db,
    $IslamicCalendarTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IslamicCalendarTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IslamicCalendarTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IslamicCalendarTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> hijriYear = const Value.absent(),
                Value<int> hijriMonth = const Value.absent(),
                Value<int> adjustDays = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IslamicCalendarCompanion(
                hijriYear: hijriYear,
                hijriMonth: hijriMonth,
                adjustDays: adjustDays,
                source: source,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int hijriYear,
                required int hijriMonth,
                Value<int> adjustDays = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IslamicCalendarCompanion.insert(
                hijriYear: hijriYear,
                hijriMonth: hijriMonth,
                adjustDays: adjustDays,
                source: source,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$IslamicCalendarTable, HijriAdjustmentRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $IslamicCalendarTable,
                    HijriAdjustmentRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$IslamicCalendarTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IslamicCalendarTable,
      HijriAdjustmentRow,
      $$IslamicCalendarTableFilterComposer,
      $$IslamicCalendarTableOrderingComposer,
      $$IslamicCalendarTableAnnotationComposer,
      $$IslamicCalendarTableCreateCompanionBuilder,
      $$IslamicCalendarTableUpdateCompanionBuilder,
      (
        HijriAdjustmentRow,
        BaseReferences<
          _$AppDatabase,
          $IslamicCalendarTable,
          HijriAdjustmentRow
        >,
      ),
      HijriAdjustmentRow,
      PrefetchHooks Function()
    >;
typedef $$AudioLibraryTableCreateCompanionBuilder =
    AudioLibraryCompanion Function({
      Value<int> id,
      required String title,
      required String category,
      required String filePath,
      Value<String?> sourceUrl,
      Value<String?> contentId,
      Value<int?> durationMs,
      Value<String?> licenseNote,
      Value<DateTime> createdAt,
    });
typedef $$AudioLibraryTableUpdateCompanionBuilder =
    AudioLibraryCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<String> category,
      Value<String> filePath,
      Value<String?> sourceUrl,
      Value<String?> contentId,
      Value<int?> durationMs,
      Value<String?> licenseNote,
      Value<DateTime> createdAt,
    });

final class $$AudioLibraryTableReferences
    extends BaseReferences<_$AppDatabase, $AudioLibraryTable, AudioRow> {
  $$AudioLibraryTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$AudioPlaylistItemsTable, List<PlaylistItemRow>>
  _audioPlaylistItemsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.audioPlaylistItems,
        aliasName: 'audio_library__id__audio_playlist_items__audio_id',
      );

  $$AudioPlaylistItemsTableProcessedTableManager get audioPlaylistItemsRefs {
    final manager = $$AudioPlaylistItemsTableTableManager(
      $_db,
      $_db.audioPlaylistItems,
    ).filter((f) => f.audioId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _audioPlaylistItemsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AudioLibraryTableFilterComposer
    extends Composer<_$AppDatabase, $AudioLibraryTable> {
  $$AudioLibraryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentId => $composableBuilder(
    column: $table.contentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get licenseNote => $composableBuilder(
    column: $table.licenseNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> audioPlaylistItemsRefs(
    Expression<bool> Function($$AudioPlaylistItemsTableFilterComposer f) f,
  ) {
    final $$AudioPlaylistItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.audioPlaylistItems,
      getReferencedColumn: (t) => t.audioId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AudioPlaylistItemsTableFilterComposer(
            $db: $db,
            $table: $db.audioPlaylistItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AudioLibraryTableOrderingComposer
    extends Composer<_$AppDatabase, $AudioLibraryTable> {
  $$AudioLibraryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentId => $composableBuilder(
    column: $table.contentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get licenseNote => $composableBuilder(
    column: $table.licenseNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AudioLibraryTableAnnotationComposer
    extends Composer<_$AppDatabase, $AudioLibraryTable> {
  $$AudioLibraryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<String> get sourceUrl =>
      $composableBuilder(column: $table.sourceUrl, builder: (column) => column);

  GeneratedColumn<String> get contentId =>
      $composableBuilder(column: $table.contentId, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get licenseNote => $composableBuilder(
    column: $table.licenseNote,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> audioPlaylistItemsRefs<T extends Object>(
    Expression<T> Function($$AudioPlaylistItemsTableAnnotationComposer a) f,
  ) {
    final $$AudioPlaylistItemsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.audioPlaylistItems,
          getReferencedColumn: (t) => t.audioId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$AudioPlaylistItemsTableAnnotationComposer(
                $db: $db,
                $table: $db.audioPlaylistItems,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$AudioLibraryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AudioLibraryTable,
          AudioRow,
          $$AudioLibraryTableFilterComposer,
          $$AudioLibraryTableOrderingComposer,
          $$AudioLibraryTableAnnotationComposer,
          $$AudioLibraryTableCreateCompanionBuilder,
          $$AudioLibraryTableUpdateCompanionBuilder,
          (AudioRow, $$AudioLibraryTableReferences),
          AudioRow,
          PrefetchHooks Function({bool audioPlaylistItemsRefs})
        > {
  $$AudioLibraryTableTableManager(_$AppDatabase db, $AudioLibraryTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AudioLibraryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AudioLibraryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AudioLibraryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<String?> sourceUrl = const Value.absent(),
                Value<String?> contentId = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<String?> licenseNote = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => AudioLibraryCompanion(
                id: id,
                title: title,
                category: category,
                filePath: filePath,
                sourceUrl: sourceUrl,
                contentId: contentId,
                durationMs: durationMs,
                licenseNote: licenseNote,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                required String category,
                required String filePath,
                Value<String?> sourceUrl = const Value.absent(),
                Value<String?> contentId = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<String?> licenseNote = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => AudioLibraryCompanion.insert(
                id: id,
                title: title,
                category: category,
                filePath: filePath,
                sourceUrl: sourceUrl,
                contentId: contentId,
                durationMs: durationMs,
                licenseNote: licenseNote,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AudioLibraryTable, AudioRow>(table),
                  $$AudioLibraryTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({audioPlaylistItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (audioPlaylistItemsRefs) db.audioPlaylistItems,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (audioPlaylistItemsRefs)
                    await $_getPrefetchedDataByColumns<
                      AudioRow,
                      $AudioLibraryTable,
                      PlaylistItemRow,
                      $AudioPlaylistItemsTable
                    >(
                      currentTable: table,
                      referencedTable: $$AudioLibraryTableReferences
                          ._audioPlaylistItemsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$AudioLibraryTableReferences(
                            db,
                            table,
                            p0,
                          ).audioPlaylistItemsRefs,
                      currentColumn: 'id',
                      referencedColumn: 'audio_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$AudioLibraryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AudioLibraryTable,
      AudioRow,
      $$AudioLibraryTableFilterComposer,
      $$AudioLibraryTableOrderingComposer,
      $$AudioLibraryTableAnnotationComposer,
      $$AudioLibraryTableCreateCompanionBuilder,
      $$AudioLibraryTableUpdateCompanionBuilder,
      (AudioRow, $$AudioLibraryTableReferences),
      AudioRow,
      PrefetchHooks Function({bool audioPlaylistItemsRefs})
    >;
typedef $$AudioPlaylistsTableCreateCompanionBuilder =
    AudioPlaylistsCompanion Function({
      Value<int> id,
      required String name,
      Value<DateTime> createdAt,
    });
typedef $$AudioPlaylistsTableUpdateCompanionBuilder =
    AudioPlaylistsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<DateTime> createdAt,
    });

final class $$AudioPlaylistsTableReferences
    extends BaseReferences<_$AppDatabase, $AudioPlaylistsTable, PlaylistRow> {
  $$AudioPlaylistsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$AudioPlaylistItemsTable, List<PlaylistItemRow>>
  _audioPlaylistItemsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.audioPlaylistItems,
        aliasName: 'audio_playlists__id__audio_playlist_items__playlist_id',
      );

  $$AudioPlaylistItemsTableProcessedTableManager get audioPlaylistItemsRefs {
    final manager = $$AudioPlaylistItemsTableTableManager(
      $_db,
      $_db.audioPlaylistItems,
    ).filter((f) => f.playlistId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _audioPlaylistItemsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AudioPlaylistsTableFilterComposer
    extends Composer<_$AppDatabase, $AudioPlaylistsTable> {
  $$AudioPlaylistsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> audioPlaylistItemsRefs(
    Expression<bool> Function($$AudioPlaylistItemsTableFilterComposer f) f,
  ) {
    final $$AudioPlaylistItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.audioPlaylistItems,
      getReferencedColumn: (t) => t.playlistId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AudioPlaylistItemsTableFilterComposer(
            $db: $db,
            $table: $db.audioPlaylistItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AudioPlaylistsTableOrderingComposer
    extends Composer<_$AppDatabase, $AudioPlaylistsTable> {
  $$AudioPlaylistsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AudioPlaylistsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AudioPlaylistsTable> {
  $$AudioPlaylistsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> audioPlaylistItemsRefs<T extends Object>(
    Expression<T> Function($$AudioPlaylistItemsTableAnnotationComposer a) f,
  ) {
    final $$AudioPlaylistItemsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.audioPlaylistItems,
          getReferencedColumn: (t) => t.playlistId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$AudioPlaylistItemsTableAnnotationComposer(
                $db: $db,
                $table: $db.audioPlaylistItems,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$AudioPlaylistsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AudioPlaylistsTable,
          PlaylistRow,
          $$AudioPlaylistsTableFilterComposer,
          $$AudioPlaylistsTableOrderingComposer,
          $$AudioPlaylistsTableAnnotationComposer,
          $$AudioPlaylistsTableCreateCompanionBuilder,
          $$AudioPlaylistsTableUpdateCompanionBuilder,
          (PlaylistRow, $$AudioPlaylistsTableReferences),
          PlaylistRow,
          PrefetchHooks Function({bool audioPlaylistItemsRefs})
        > {
  $$AudioPlaylistsTableTableManager(
    _$AppDatabase db,
    $AudioPlaylistsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AudioPlaylistsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AudioPlaylistsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AudioPlaylistsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => AudioPlaylistsCompanion(
                id: id,
                name: name,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<DateTime> createdAt = const Value.absent(),
              }) => AudioPlaylistsCompanion.insert(
                id: id,
                name: name,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AudioPlaylistsTable, PlaylistRow>(table),
                  $$AudioPlaylistsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({audioPlaylistItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (audioPlaylistItemsRefs) db.audioPlaylistItems,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (audioPlaylistItemsRefs)
                    await $_getPrefetchedDataByColumns<
                      PlaylistRow,
                      $AudioPlaylistsTable,
                      PlaylistItemRow,
                      $AudioPlaylistItemsTable
                    >(
                      currentTable: table,
                      referencedTable: $$AudioPlaylistsTableReferences
                          ._audioPlaylistItemsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$AudioPlaylistsTableReferences(
                            db,
                            table,
                            p0,
                          ).audioPlaylistItemsRefs,
                      currentColumn: 'id',
                      referencedColumn: 'playlist_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$AudioPlaylistsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AudioPlaylistsTable,
      PlaylistRow,
      $$AudioPlaylistsTableFilterComposer,
      $$AudioPlaylistsTableOrderingComposer,
      $$AudioPlaylistsTableAnnotationComposer,
      $$AudioPlaylistsTableCreateCompanionBuilder,
      $$AudioPlaylistsTableUpdateCompanionBuilder,
      (PlaylistRow, $$AudioPlaylistsTableReferences),
      PlaylistRow,
      PrefetchHooks Function({bool audioPlaylistItemsRefs})
    >;
typedef $$AudioPlaylistItemsTableCreateCompanionBuilder =
    AudioPlaylistItemsCompanion Function({
      Value<int> id,
      required int playlistId,
      required int audioId,
      required int position,
    });
typedef $$AudioPlaylistItemsTableUpdateCompanionBuilder =
    AudioPlaylistItemsCompanion Function({
      Value<int> id,
      Value<int> playlistId,
      Value<int> audioId,
      Value<int> position,
    });

final class $$AudioPlaylistItemsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $AudioPlaylistItemsTable,
          PlaylistItemRow
        > {
  $$AudioPlaylistItemsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AudioPlaylistsTable _playlistIdTable(_$AppDatabase db) => db
      .audioPlaylists
      .createAlias('audio_playlist_items__playlist_id__audio_playlists__id');

  $$AudioPlaylistsTableProcessedTableManager get playlistId {
    final $_column = $_itemColumn<int>('playlist_id')!;

    final manager = $$AudioPlaylistsTableTableManager(
      $_db,
      $_db.audioPlaylists,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_playlistIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AudioLibraryTable _audioIdTable(_$AppDatabase db) => db.audioLibrary
      .createAlias('audio_playlist_items__audio_id__audio_library__id');

  $$AudioLibraryTableProcessedTableManager get audioId {
    final $_column = $_itemColumn<int>('audio_id')!;

    final manager = $$AudioLibraryTableTableManager(
      $_db,
      $_db.audioLibrary,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_audioIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AudioPlaylistItemsTableFilterComposer
    extends Composer<_$AppDatabase, $AudioPlaylistItemsTable> {
  $$AudioPlaylistItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  $$AudioPlaylistsTableFilterComposer get playlistId {
    final $$AudioPlaylistsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.audioPlaylists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AudioPlaylistsTableFilterComposer(
            $db: $db,
            $table: $db.audioPlaylists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AudioLibraryTableFilterComposer get audioId {
    final $$AudioLibraryTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.audioId,
      referencedTable: $db.audioLibrary,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AudioLibraryTableFilterComposer(
            $db: $db,
            $table: $db.audioLibrary,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AudioPlaylistItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $AudioPlaylistItemsTable> {
  $$AudioPlaylistItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  $$AudioPlaylistsTableOrderingComposer get playlistId {
    final $$AudioPlaylistsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.audioPlaylists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AudioPlaylistsTableOrderingComposer(
            $db: $db,
            $table: $db.audioPlaylists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AudioLibraryTableOrderingComposer get audioId {
    final $$AudioLibraryTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.audioId,
      referencedTable: $db.audioLibrary,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AudioLibraryTableOrderingComposer(
            $db: $db,
            $table: $db.audioLibrary,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AudioPlaylistItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AudioPlaylistItemsTable> {
  $$AudioPlaylistItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  $$AudioPlaylistsTableAnnotationComposer get playlistId {
    final $$AudioPlaylistsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.audioPlaylists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AudioPlaylistsTableAnnotationComposer(
            $db: $db,
            $table: $db.audioPlaylists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AudioLibraryTableAnnotationComposer get audioId {
    final $$AudioLibraryTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.audioId,
      referencedTable: $db.audioLibrary,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AudioLibraryTableAnnotationComposer(
            $db: $db,
            $table: $db.audioLibrary,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AudioPlaylistItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AudioPlaylistItemsTable,
          PlaylistItemRow,
          $$AudioPlaylistItemsTableFilterComposer,
          $$AudioPlaylistItemsTableOrderingComposer,
          $$AudioPlaylistItemsTableAnnotationComposer,
          $$AudioPlaylistItemsTableCreateCompanionBuilder,
          $$AudioPlaylistItemsTableUpdateCompanionBuilder,
          (PlaylistItemRow, $$AudioPlaylistItemsTableReferences),
          PlaylistItemRow,
          PrefetchHooks Function({bool playlistId, bool audioId})
        > {
  $$AudioPlaylistItemsTableTableManager(
    _$AppDatabase db,
    $AudioPlaylistItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AudioPlaylistItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AudioPlaylistItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AudioPlaylistItemsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> playlistId = const Value.absent(),
                Value<int> audioId = const Value.absent(),
                Value<int> position = const Value.absent(),
              }) => AudioPlaylistItemsCompanion(
                id: id,
                playlistId: playlistId,
                audioId: audioId,
                position: position,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int playlistId,
                required int audioId,
                required int position,
              }) => AudioPlaylistItemsCompanion.insert(
                id: id,
                playlistId: playlistId,
                audioId: audioId,
                position: position,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AudioPlaylistItemsTable, PlaylistItemRow>(table),
                  $$AudioPlaylistItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({playlistId = false, audioId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (playlistId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.playlistId,
                        referencedTable: $$AudioPlaylistItemsTableReferences
                            ._playlistIdTable(db),
                        referencedColumn: $$AudioPlaylistItemsTableReferences
                            ._playlistIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (audioId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.audioId,
                        referencedTable: $$AudioPlaylistItemsTableReferences
                            ._audioIdTable(db),
                        referencedColumn: $$AudioPlaylistItemsTableReferences
                            ._audioIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AudioPlaylistItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AudioPlaylistItemsTable,
      PlaylistItemRow,
      $$AudioPlaylistItemsTableFilterComposer,
      $$AudioPlaylistItemsTableOrderingComposer,
      $$AudioPlaylistItemsTableAnnotationComposer,
      $$AudioPlaylistItemsTableCreateCompanionBuilder,
      $$AudioPlaylistItemsTableUpdateCompanionBuilder,
      (PlaylistItemRow, $$AudioPlaylistItemsTableReferences),
      PlaylistItemRow,
      PrefetchHooks Function({bool playlistId, bool audioId})
    >;
typedef $$AudioSchedulesTableCreateCompanionBuilder =
    AudioSchedulesCompanion Function({
      required String prayer,
      required String configJson,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$AudioSchedulesTableUpdateCompanionBuilder =
    AudioSchedulesCompanion Function({
      Value<String> prayer,
      Value<String> configJson,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$AudioSchedulesTableFilterComposer
    extends Composer<_$AppDatabase, $AudioSchedulesTable> {
  $$AudioSchedulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get prayer => $composableBuilder(
    column: $table.prayer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get configJson => $composableBuilder(
    column: $table.configJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AudioSchedulesTableOrderingComposer
    extends Composer<_$AppDatabase, $AudioSchedulesTable> {
  $$AudioSchedulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get prayer => $composableBuilder(
    column: $table.prayer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get configJson => $composableBuilder(
    column: $table.configJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AudioSchedulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AudioSchedulesTable> {
  $$AudioSchedulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get prayer =>
      $composableBuilder(column: $table.prayer, builder: (column) => column);

  GeneratedColumn<String> get configJson => $composableBuilder(
    column: $table.configJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AudioSchedulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AudioSchedulesTable,
          AudioScheduleRow,
          $$AudioSchedulesTableFilterComposer,
          $$AudioSchedulesTableOrderingComposer,
          $$AudioSchedulesTableAnnotationComposer,
          $$AudioSchedulesTableCreateCompanionBuilder,
          $$AudioSchedulesTableUpdateCompanionBuilder,
          (
            AudioScheduleRow,
            BaseReferences<
              _$AppDatabase,
              $AudioSchedulesTable,
              AudioScheduleRow
            >,
          ),
          AudioScheduleRow,
          PrefetchHooks Function()
        > {
  $$AudioSchedulesTableTableManager(
    _$AppDatabase db,
    $AudioSchedulesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AudioSchedulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AudioSchedulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AudioSchedulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> prayer = const Value.absent(),
                Value<String> configJson = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AudioSchedulesCompanion(
                prayer: prayer,
                configJson: configJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String prayer,
                required String configJson,
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AudioSchedulesCompanion.insert(
                prayer: prayer,
                configJson: configJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AudioSchedulesTable, AudioScheduleRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $AudioSchedulesTable,
                    AudioScheduleRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AudioSchedulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AudioSchedulesTable,
      AudioScheduleRow,
      $$AudioSchedulesTableFilterComposer,
      $$AudioSchedulesTableOrderingComposer,
      $$AudioSchedulesTableAnnotationComposer,
      $$AudioSchedulesTableCreateCompanionBuilder,
      $$AudioSchedulesTableUpdateCompanionBuilder,
      (
        AudioScheduleRow,
        BaseReferences<_$AppDatabase, $AudioSchedulesTable, AudioScheduleRow>,
      ),
      AudioScheduleRow,
      PrefetchHooks Function()
    >;
typedef $$AudioPlaybackHistoryTableCreateCompanionBuilder =
    AudioPlaybackHistoryCompanion Function({
      Value<int> id,
      Value<String?> eventId,
      required String title,
      required String status,
      Value<String?> detail,
      required DateTime startedAt,
    });
typedef $$AudioPlaybackHistoryTableUpdateCompanionBuilder =
    AudioPlaybackHistoryCompanion Function({
      Value<int> id,
      Value<String?> eventId,
      Value<String> title,
      Value<String> status,
      Value<String?> detail,
      Value<DateTime> startedAt,
    });

class $$AudioPlaybackHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $AudioPlaybackHistoryTable> {
  $$AudioPlaybackHistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get detail => $composableBuilder(
    column: $table.detail,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AudioPlaybackHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $AudioPlaybackHistoryTable> {
  $$AudioPlaybackHistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get detail => $composableBuilder(
    column: $table.detail,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AudioPlaybackHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $AudioPlaybackHistoryTable> {
  $$AudioPlaybackHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get eventId =>
      $composableBuilder(column: $table.eventId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get detail =>
      $composableBuilder(column: $table.detail, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);
}

class $$AudioPlaybackHistoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AudioPlaybackHistoryTable,
          PlaybackHistoryRow,
          $$AudioPlaybackHistoryTableFilterComposer,
          $$AudioPlaybackHistoryTableOrderingComposer,
          $$AudioPlaybackHistoryTableAnnotationComposer,
          $$AudioPlaybackHistoryTableCreateCompanionBuilder,
          $$AudioPlaybackHistoryTableUpdateCompanionBuilder,
          (
            PlaybackHistoryRow,
            BaseReferences<
              _$AppDatabase,
              $AudioPlaybackHistoryTable,
              PlaybackHistoryRow
            >,
          ),
          PlaybackHistoryRow,
          PrefetchHooks Function()
        > {
  $$AudioPlaybackHistoryTableTableManager(
    _$AppDatabase db,
    $AudioPlaybackHistoryTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AudioPlaybackHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AudioPlaybackHistoryTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$AudioPlaybackHistoryTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> eventId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> detail = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
              }) => AudioPlaybackHistoryCompanion(
                id: id,
                eventId: eventId,
                title: title,
                status: status,
                detail: detail,
                startedAt: startedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> eventId = const Value.absent(),
                required String title,
                required String status,
                Value<String?> detail = const Value.absent(),
                required DateTime startedAt,
              }) => AudioPlaybackHistoryCompanion.insert(
                id: id,
                eventId: eventId,
                title: title,
                status: status,
                detail: detail,
                startedAt: startedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AudioPlaybackHistoryTable, PlaybackHistoryRow>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $AudioPlaybackHistoryTable,
                    PlaybackHistoryRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AudioPlaybackHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AudioPlaybackHistoryTable,
      PlaybackHistoryRow,
      $$AudioPlaybackHistoryTableFilterComposer,
      $$AudioPlaybackHistoryTableOrderingComposer,
      $$AudioPlaybackHistoryTableAnnotationComposer,
      $$AudioPlaybackHistoryTableCreateCompanionBuilder,
      $$AudioPlaybackHistoryTableUpdateCompanionBuilder,
      (
        PlaybackHistoryRow,
        BaseReferences<
          _$AppDatabase,
          $AudioPlaybackHistoryTable,
          PlaybackHistoryRow
        >,
      ),
      PlaybackHistoryRow,
      PrefetchHooks Function()
    >;
typedef $$WallpapersTableCreateCompanionBuilder = WallpapersCompanion Function({
  Value<int> id,
  required String name,
  required String filePath,
  Value<DateTime> createdAt,
});
typedef $$WallpapersTableUpdateCompanionBuilder = WallpapersCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> filePath,
  Value<DateTime> createdAt,
});

class $$WallpapersTableFilterComposer
    extends Composer<_$AppDatabase, $WallpapersTable> {
  $$WallpapersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WallpapersTableOrderingComposer
    extends Composer<_$AppDatabase, $WallpapersTable> {
  $$WallpapersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WallpapersTableAnnotationComposer
    extends Composer<_$AppDatabase, $WallpapersTable> {
  $$WallpapersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$WallpapersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WallpapersTable,
          WallpaperRow,
          $$WallpapersTableFilterComposer,
          $$WallpapersTableOrderingComposer,
          $$WallpapersTableAnnotationComposer,
          $$WallpapersTableCreateCompanionBuilder,
          $$WallpapersTableUpdateCompanionBuilder,
          (
            WallpaperRow,
            BaseReferences<_$AppDatabase, $WallpapersTable, WallpaperRow>,
          ),
          WallpaperRow,
          PrefetchHooks Function()
        > {
  $$WallpapersTableTableManager(_$AppDatabase db, $WallpapersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WallpapersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WallpapersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WallpapersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => WallpapersCompanion(
                id: id,
                name: name,
                filePath: filePath,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String filePath,
                Value<DateTime> createdAt = const Value.absent(),
              }) => WallpapersCompanion.insert(
                id: id,
                name: name,
                filePath: filePath,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WallpapersTable, WallpaperRow>(table),
                  BaseReferences<_$AppDatabase, $WallpapersTable, WallpaperRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WallpapersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WallpapersTable,
      WallpaperRow,
      $$WallpapersTableFilterComposer,
      $$WallpapersTableOrderingComposer,
      $$WallpapersTableAnnotationComposer,
      $$WallpapersTableCreateCompanionBuilder,
      $$WallpapersTableUpdateCompanionBuilder,
      (
        WallpaperRow,
        BaseReferences<_$AppDatabase, $WallpapersTable, WallpaperRow>,
      ),
      WallpaperRow,
      PrefetchHooks Function()
    >;
typedef $$UserSettingsTableCreateCompanionBuilder =
    UserSettingsCompanion Function({
      required String key,
      required String value,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$UserSettingsTableUpdateCompanionBuilder =
    UserSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$UserSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $UserSettingsTable> {
  $$UserSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $UserSettingsTable> {
  $$UserSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserSettingsTable> {
  $$UserSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UserSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserSettingsTable,
          SettingRow,
          $$UserSettingsTableFilterComposer,
          $$UserSettingsTableOrderingComposer,
          $$UserSettingsTableAnnotationComposer,
          $$UserSettingsTableCreateCompanionBuilder,
          $$UserSettingsTableUpdateCompanionBuilder,
          (
            SettingRow,
            BaseReferences<_$AppDatabase, $UserSettingsTable, SettingRow>,
          ),
          SettingRow,
          PrefetchHooks Function()
        > {
  $$UserSettingsTableTableManager(_$AppDatabase db, $UserSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserSettingsCompanion(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserSettingsCompanion.insert(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UserSettingsTable, SettingRow>(table),
                  BaseReferences<_$AppDatabase, $UserSettingsTable, SettingRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserSettingsTable,
      SettingRow,
      $$UserSettingsTableFilterComposer,
      $$UserSettingsTableOrderingComposer,
      $$UserSettingsTableAnnotationComposer,
      $$UserSettingsTableCreateCompanionBuilder,
      $$UserSettingsTableUpdateCompanionBuilder,
      (
        SettingRow,
        BaseReferences<_$AppDatabase, $UserSettingsTable, SettingRow>,
      ),
      SettingRow,
      PrefetchHooks Function()
    >;
typedef $$FavoritesTableCreateCompanionBuilder = FavoritesCompanion Function({
  required String contentId,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$FavoritesTableUpdateCompanionBuilder = FavoritesCompanion Function({
  Value<String> contentId,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$FavoritesTableFilterComposer
    extends Composer<_$AppDatabase, $FavoritesTable> {
  $$FavoritesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get contentId => $composableBuilder(
    column: $table.contentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FavoritesTableOrderingComposer
    extends Composer<_$AppDatabase, $FavoritesTable> {
  $$FavoritesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get contentId => $composableBuilder(
    column: $table.contentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FavoritesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FavoritesTable> {
  $$FavoritesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get contentId =>
      $composableBuilder(column: $table.contentId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$FavoritesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FavoritesTable,
          FavoriteRow,
          $$FavoritesTableFilterComposer,
          $$FavoritesTableOrderingComposer,
          $$FavoritesTableAnnotationComposer,
          $$FavoritesTableCreateCompanionBuilder,
          $$FavoritesTableUpdateCompanionBuilder,
          (
            FavoriteRow,
            BaseReferences<_$AppDatabase, $FavoritesTable, FavoriteRow>,
          ),
          FavoriteRow,
          PrefetchHooks Function()
        > {
  $$FavoritesTableTableManager(_$AppDatabase db, $FavoritesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FavoritesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FavoritesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FavoritesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> contentId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FavoritesCompanion(
                contentId: contentId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String contentId,
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FavoritesCompanion.insert(
                contentId: contentId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FavoritesTable, FavoriteRow>(table),
                  BaseReferences<_$AppDatabase, $FavoritesTable, FavoriteRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FavoritesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FavoritesTable,
      FavoriteRow,
      $$FavoritesTableFilterComposer,
      $$FavoritesTableOrderingComposer,
      $$FavoritesTableAnnotationComposer,
      $$FavoritesTableCreateCompanionBuilder,
      $$FavoritesTableUpdateCompanionBuilder,
      (
        FavoriteRow,
        BaseReferences<_$AppDatabase, $FavoritesTable, FavoriteRow>,
      ),
      FavoriteRow,
      PrefetchHooks Function()
    >;
typedef $$TasbihRecordsTableCreateCompanionBuilder =
    TasbihRecordsCompanion Function({
      Value<int> id,
      required String zikr,
      required int count,
      required int target,
      required String date,
      Value<DateTime> createdAt,
    });
typedef $$TasbihRecordsTableUpdateCompanionBuilder =
    TasbihRecordsCompanion Function({
      Value<int> id,
      Value<String> zikr,
      Value<int> count,
      Value<int> target,
      Value<String> date,
      Value<DateTime> createdAt,
    });

class $$TasbihRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $TasbihRecordsTable> {
  $$TasbihRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get zikr => $composableBuilder(
    column: $table.zikr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get target => $composableBuilder(
    column: $table.target,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TasbihRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $TasbihRecordsTable> {
  $$TasbihRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get zikr => $composableBuilder(
    column: $table.zikr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get target => $composableBuilder(
    column: $table.target,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TasbihRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasbihRecordsTable> {
  $$TasbihRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get zikr =>
      $composableBuilder(column: $table.zikr, builder: (column) => column);

  GeneratedColumn<int> get count =>
      $composableBuilder(column: $table.count, builder: (column) => column);

  GeneratedColumn<int> get target =>
      $composableBuilder(column: $table.target, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$TasbihRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TasbihRecordsTable,
          TasbihRow,
          $$TasbihRecordsTableFilterComposer,
          $$TasbihRecordsTableOrderingComposer,
          $$TasbihRecordsTableAnnotationComposer,
          $$TasbihRecordsTableCreateCompanionBuilder,
          $$TasbihRecordsTableUpdateCompanionBuilder,
          (
            TasbihRow,
            BaseReferences<_$AppDatabase, $TasbihRecordsTable, TasbihRow>,
          ),
          TasbihRow,
          PrefetchHooks Function()
        > {
  $$TasbihRecordsTableTableManager(_$AppDatabase db, $TasbihRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasbihRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasbihRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasbihRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> zikr = const Value.absent(),
                Value<int> count = const Value.absent(),
                Value<int> target = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => TasbihRecordsCompanion(
                id: id,
                zikr: zikr,
                count: count,
                target: target,
                date: date,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String zikr,
                required int count,
                required int target,
                required String date,
                Value<DateTime> createdAt = const Value.absent(),
              }) => TasbihRecordsCompanion.insert(
                id: id,
                zikr: zikr,
                count: count,
                target: target,
                date: date,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TasbihRecordsTable, TasbihRow>(table),
                  BaseReferences<_$AppDatabase, $TasbihRecordsTable, TasbihRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TasbihRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TasbihRecordsTable,
      TasbihRow,
      $$TasbihRecordsTableFilterComposer,
      $$TasbihRecordsTableOrderingComposer,
      $$TasbihRecordsTableAnnotationComposer,
      $$TasbihRecordsTableCreateCompanionBuilder,
      $$TasbihRecordsTableUpdateCompanionBuilder,
      (
        TasbihRow,
        BaseReferences<_$AppDatabase, $TasbihRecordsTable, TasbihRow>,
      ),
      TasbihRow,
      PrefetchHooks Function()
    >;
typedef $$NotificationSettingsTableCreateCompanionBuilder =
    NotificationSettingsCompanion Function({
      required String prayer,
      required String configJson,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$NotificationSettingsTableUpdateCompanionBuilder =
    NotificationSettingsCompanion Function({
      Value<String> prayer,
      Value<String> configJson,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$NotificationSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $NotificationSettingsTable> {
  $$NotificationSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get prayer => $composableBuilder(
    column: $table.prayer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get configJson => $composableBuilder(
    column: $table.configJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NotificationSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $NotificationSettingsTable> {
  $$NotificationSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get prayer => $composableBuilder(
    column: $table.prayer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get configJson => $composableBuilder(
    column: $table.configJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NotificationSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotificationSettingsTable> {
  $$NotificationSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get prayer =>
      $composableBuilder(column: $table.prayer, builder: (column) => column);

  GeneratedColumn<String> get configJson => $composableBuilder(
    column: $table.configJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$NotificationSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NotificationSettingsTable,
          NotificationSettingRow,
          $$NotificationSettingsTableFilterComposer,
          $$NotificationSettingsTableOrderingComposer,
          $$NotificationSettingsTableAnnotationComposer,
          $$NotificationSettingsTableCreateCompanionBuilder,
          $$NotificationSettingsTableUpdateCompanionBuilder,
          (
            NotificationSettingRow,
            BaseReferences<
              _$AppDatabase,
              $NotificationSettingsTable,
              NotificationSettingRow
            >,
          ),
          NotificationSettingRow,
          PrefetchHooks Function()
        > {
  $$NotificationSettingsTableTableManager(
    _$AppDatabase db,
    $NotificationSettingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotificationSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotificationSettingsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$NotificationSettingsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> prayer = const Value.absent(),
                Value<String> configJson = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotificationSettingsCompanion(
                prayer: prayer,
                configJson: configJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String prayer,
                required String configJson,
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotificationSettingsCompanion.insert(
                prayer: prayer,
                configJson: configJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $NotificationSettingsTable,
                    NotificationSettingRow
                  >(table),
                  BaseReferences<
                    _$AppDatabase,
                    $NotificationSettingsTable,
                    NotificationSettingRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NotificationSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NotificationSettingsTable,
      NotificationSettingRow,
      $$NotificationSettingsTableFilterComposer,
      $$NotificationSettingsTableOrderingComposer,
      $$NotificationSettingsTableAnnotationComposer,
      $$NotificationSettingsTableCreateCompanionBuilder,
      $$NotificationSettingsTableUpdateCompanionBuilder,
      (
        NotificationSettingRow,
        BaseReferences<
          _$AppDatabase,
          $NotificationSettingsTable,
          NotificationSettingRow
        >,
      ),
      NotificationSettingRow,
      PrefetchHooks Function()
    >;
typedef $$AppDiagnosticsTableCreateCompanionBuilder =
    AppDiagnosticsCompanion Function({
      Value<int> id,
      required String level,
      required String tag,
      required String message,
      Value<DateTime> createdAt,
    });
typedef $$AppDiagnosticsTableUpdateCompanionBuilder =
    AppDiagnosticsCompanion Function({
      Value<int> id,
      Value<String> level,
      Value<String> tag,
      Value<String> message,
      Value<DateTime> createdAt,
    });

class $$AppDiagnosticsTableFilterComposer
    extends Composer<_$AppDatabase, $AppDiagnosticsTable> {
  $$AppDiagnosticsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tag => $composableBuilder(
    column: $table.tag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppDiagnosticsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppDiagnosticsTable> {
  $$AppDiagnosticsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tag => $composableBuilder(
    column: $table.tag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppDiagnosticsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppDiagnosticsTable> {
  $$AppDiagnosticsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<String> get tag =>
      $composableBuilder(column: $table.tag, builder: (column) => column);

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$AppDiagnosticsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppDiagnosticsTable,
          DiagnosticRow,
          $$AppDiagnosticsTableFilterComposer,
          $$AppDiagnosticsTableOrderingComposer,
          $$AppDiagnosticsTableAnnotationComposer,
          $$AppDiagnosticsTableCreateCompanionBuilder,
          $$AppDiagnosticsTableUpdateCompanionBuilder,
          (
            DiagnosticRow,
            BaseReferences<_$AppDatabase, $AppDiagnosticsTable, DiagnosticRow>,
          ),
          DiagnosticRow,
          PrefetchHooks Function()
        > {
  $$AppDiagnosticsTableTableManager(
    _$AppDatabase db,
    $AppDiagnosticsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppDiagnosticsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppDiagnosticsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppDiagnosticsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> level = const Value.absent(),
                Value<String> tag = const Value.absent(),
                Value<String> message = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => AppDiagnosticsCompanion(
                id: id,
                level: level,
                tag: tag,
                message: message,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String level,
                required String tag,
                required String message,
                Value<DateTime> createdAt = const Value.absent(),
              }) => AppDiagnosticsCompanion.insert(
                id: id,
                level: level,
                tag: tag,
                message: message,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppDiagnosticsTable, DiagnosticRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $AppDiagnosticsTable,
                    DiagnosticRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppDiagnosticsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppDiagnosticsTable,
      DiagnosticRow,
      $$AppDiagnosticsTableFilterComposer,
      $$AppDiagnosticsTableOrderingComposer,
      $$AppDiagnosticsTableAnnotationComposer,
      $$AppDiagnosticsTableCreateCompanionBuilder,
      $$AppDiagnosticsTableUpdateCompanionBuilder,
      (
        DiagnosticRow,
        BaseReferences<_$AppDatabase, $AppDiagnosticsTable, DiagnosticRow>,
      ),
      DiagnosticRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PrayerZonesTableTableManager get prayerZones =>
      $$PrayerZonesTableTableManager(_db, _db.prayerZones);
  $$PrayerTimesTableTableManager get prayerTimes =>
      $$PrayerTimesTableTableManager(_db, _db.prayerTimes);
  $$IslamicEventsTableTableManager get islamicEvents =>
      $$IslamicEventsTableTableManager(_db, _db.islamicEvents);
  $$IslamicCalendarTableTableManager get islamicCalendar =>
      $$IslamicCalendarTableTableManager(_db, _db.islamicCalendar);
  $$AudioLibraryTableTableManager get audioLibrary =>
      $$AudioLibraryTableTableManager(_db, _db.audioLibrary);
  $$AudioPlaylistsTableTableManager get audioPlaylists =>
      $$AudioPlaylistsTableTableManager(_db, _db.audioPlaylists);
  $$AudioPlaylistItemsTableTableManager get audioPlaylistItems =>
      $$AudioPlaylistItemsTableTableManager(_db, _db.audioPlaylistItems);
  $$AudioSchedulesTableTableManager get audioSchedules =>
      $$AudioSchedulesTableTableManager(_db, _db.audioSchedules);
  $$AudioPlaybackHistoryTableTableManager get audioPlaybackHistory =>
      $$AudioPlaybackHistoryTableTableManager(_db, _db.audioPlaybackHistory);
  $$WallpapersTableTableManager get wallpapers =>
      $$WallpapersTableTableManager(_db, _db.wallpapers);
  $$UserSettingsTableTableManager get userSettings =>
      $$UserSettingsTableTableManager(_db, _db.userSettings);
  $$FavoritesTableTableManager get favorites =>
      $$FavoritesTableTableManager(_db, _db.favorites);
  $$TasbihRecordsTableTableManager get tasbihRecords =>
      $$TasbihRecordsTableTableManager(_db, _db.tasbihRecords);
  $$NotificationSettingsTableTableManager get notificationSettings =>
      $$NotificationSettingsTableTableManager(_db, _db.notificationSettings);
  $$AppDiagnosticsTableTableManager get appDiagnostics =>
      $$AppDiagnosticsTableTableManager(_db, _db.appDiagnostics);
}
