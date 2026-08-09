// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $VehiclesTable extends Vehicles with TableInfo<$VehiclesTable, Vehicle> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VehiclesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _marcaMeta = const VerificationMeta('marca');
  @override
  late final GeneratedColumn<String> marca = GeneratedColumn<String>(
    'marca',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 60,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modeloMeta = const VerificationMeta('modelo');
  @override
  late final GeneratedColumn<String> modelo = GeneratedColumn<String>(
    'modelo',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 60,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<String> version = GeneratedColumn<String>(
    'version',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _anioMeta = const VerificationMeta('anio');
  @override
  late final GeneratedColumn<int> anio = GeneratedColumn<int>(
    'anio',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _matriculaMeta = const VerificationMeta(
    'matricula',
  );
  @override
  late final GeneratedColumn<String> matricula = GeneratedColumn<String>(
    'matricula',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<FuelType, String> combustible =
      GeneratedColumn<String>(
        'combustible',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<FuelType>($VehiclesTable.$convertercombustible);
  static const VerificationMeta _fechaMatriculacionMeta =
      const VerificationMeta('fechaMatriculacion');
  @override
  late final GeneratedColumn<DateTime> fechaMatriculacion =
      GeneratedColumn<DateTime>(
        'fecha_matriculacion',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fotoPathMeta = const VerificationMeta(
    'fotoPath',
  );
  @override
  late final GeneratedColumn<String> fotoPath = GeneratedColumn<String>(
    'foto_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _vinMeta = const VerificationMeta('vin');
  @override
  late final GeneratedColumn<String> vin = GeneratedColumn<String>(
    'vin',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notasMeta = const VerificationMeta('notas');
  @override
  late final GeneratedColumn<String> notas = GeneratedColumn<String>(
    'notas',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _creadoEnMeta = const VerificationMeta(
    'creadoEn',
  );
  @override
  late final GeneratedColumn<DateTime> creadoEn = GeneratedColumn<DateTime>(
    'creado_en',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _archivadoMeta = const VerificationMeta(
    'archivado',
  );
  @override
  late final GeneratedColumn<bool> archivado = GeneratedColumn<bool>(
    'archivado',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archivado" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    marca,
    modelo,
    version,
    anio,
    matricula,
    combustible,
    fechaMatriculacion,
    color,
    fotoPath,
    vin,
    notas,
    creadoEn,
    archivado,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vehicles';
  @override
  VerificationContext validateIntegrity(
    Insertable<Vehicle> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('marca')) {
      context.handle(
        _marcaMeta,
        marca.isAcceptableOrUnknown(data['marca']!, _marcaMeta),
      );
    } else if (isInserting) {
      context.missing(_marcaMeta);
    }
    if (data.containsKey('modelo')) {
      context.handle(
        _modeloMeta,
        modelo.isAcceptableOrUnknown(data['modelo']!, _modeloMeta),
      );
    } else if (isInserting) {
      context.missing(_modeloMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('anio')) {
      context.handle(
        _anioMeta,
        anio.isAcceptableOrUnknown(data['anio']!, _anioMeta),
      );
    }
    if (data.containsKey('matricula')) {
      context.handle(
        _matriculaMeta,
        matricula.isAcceptableOrUnknown(data['matricula']!, _matriculaMeta),
      );
    }
    if (data.containsKey('fecha_matriculacion')) {
      context.handle(
        _fechaMatriculacionMeta,
        fechaMatriculacion.isAcceptableOrUnknown(
          data['fecha_matriculacion']!,
          _fechaMatriculacionMeta,
        ),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('foto_path')) {
      context.handle(
        _fotoPathMeta,
        fotoPath.isAcceptableOrUnknown(data['foto_path']!, _fotoPathMeta),
      );
    }
    if (data.containsKey('vin')) {
      context.handle(
        _vinMeta,
        vin.isAcceptableOrUnknown(data['vin']!, _vinMeta),
      );
    }
    if (data.containsKey('notas')) {
      context.handle(
        _notasMeta,
        notas.isAcceptableOrUnknown(data['notas']!, _notasMeta),
      );
    }
    if (data.containsKey('creado_en')) {
      context.handle(
        _creadoEnMeta,
        creadoEn.isAcceptableOrUnknown(data['creado_en']!, _creadoEnMeta),
      );
    }
    if (data.containsKey('archivado')) {
      context.handle(
        _archivadoMeta,
        archivado.isAcceptableOrUnknown(data['archivado']!, _archivadoMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Vehicle map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Vehicle(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      marca: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}marca'],
      )!,
      modelo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}modelo'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}version'],
      ),
      anio: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}anio'],
      ),
      matricula: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}matricula'],
      ),
      combustible: $VehiclesTable.$convertercombustible.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}combustible'],
        )!,
      ),
      fechaMatriculacion: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha_matriculacion'],
      ),
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      ),
      fotoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}foto_path'],
      ),
      vin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vin'],
      ),
      notas: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notas'],
      ),
      creadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}creado_en'],
      )!,
      archivado: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archivado'],
      )!,
    );
  }

  @override
  $VehiclesTable createAlias(String alias) {
    return $VehiclesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<FuelType, String, String> $convertercombustible =
      const EnumNameConverter<FuelType>(FuelType.values);
}

class Vehicle extends DataClass implements Insertable<Vehicle> {
  final int id;
  final String marca;
  final String modelo;
  final String? version;
  final int? anio;
  final String? matricula;
  final FuelType combustible;
  final DateTime? fechaMatriculacion;
  final String? color;
  final String? fotoPath;
  final String? vin;
  final String? notas;
  final DateTime creadoEn;
  final bool archivado;
  const Vehicle({
    required this.id,
    required this.marca,
    required this.modelo,
    this.version,
    this.anio,
    this.matricula,
    required this.combustible,
    this.fechaMatriculacion,
    this.color,
    this.fotoPath,
    this.vin,
    this.notas,
    required this.creadoEn,
    required this.archivado,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['marca'] = Variable<String>(marca);
    map['modelo'] = Variable<String>(modelo);
    if (!nullToAbsent || version != null) {
      map['version'] = Variable<String>(version);
    }
    if (!nullToAbsent || anio != null) {
      map['anio'] = Variable<int>(anio);
    }
    if (!nullToAbsent || matricula != null) {
      map['matricula'] = Variable<String>(matricula);
    }
    {
      map['combustible'] = Variable<String>(
        $VehiclesTable.$convertercombustible.toSql(combustible),
      );
    }
    if (!nullToAbsent || fechaMatriculacion != null) {
      map['fecha_matriculacion'] = Variable<DateTime>(fechaMatriculacion);
    }
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    if (!nullToAbsent || fotoPath != null) {
      map['foto_path'] = Variable<String>(fotoPath);
    }
    if (!nullToAbsent || vin != null) {
      map['vin'] = Variable<String>(vin);
    }
    if (!nullToAbsent || notas != null) {
      map['notas'] = Variable<String>(notas);
    }
    map['creado_en'] = Variable<DateTime>(creadoEn);
    map['archivado'] = Variable<bool>(archivado);
    return map;
  }

  VehiclesCompanion toCompanion(bool nullToAbsent) {
    return VehiclesCompanion(
      id: Value(id),
      marca: Value(marca),
      modelo: Value(modelo),
      version: version == null && nullToAbsent
          ? const Value.absent()
          : Value(version),
      anio: anio == null && nullToAbsent ? const Value.absent() : Value(anio),
      matricula: matricula == null && nullToAbsent
          ? const Value.absent()
          : Value(matricula),
      combustible: Value(combustible),
      fechaMatriculacion: fechaMatriculacion == null && nullToAbsent
          ? const Value.absent()
          : Value(fechaMatriculacion),
      color: color == null && nullToAbsent
          ? const Value.absent()
          : Value(color),
      fotoPath: fotoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(fotoPath),
      vin: vin == null && nullToAbsent ? const Value.absent() : Value(vin),
      notas: notas == null && nullToAbsent
          ? const Value.absent()
          : Value(notas),
      creadoEn: Value(creadoEn),
      archivado: Value(archivado),
    );
  }

  factory Vehicle.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Vehicle(
      id: serializer.fromJson<int>(json['id']),
      marca: serializer.fromJson<String>(json['marca']),
      modelo: serializer.fromJson<String>(json['modelo']),
      version: serializer.fromJson<String?>(json['version']),
      anio: serializer.fromJson<int?>(json['anio']),
      matricula: serializer.fromJson<String?>(json['matricula']),
      combustible: $VehiclesTable.$convertercombustible.fromJson(
        serializer.fromJson<String>(json['combustible']),
      ),
      fechaMatriculacion: serializer.fromJson<DateTime?>(
        json['fechaMatriculacion'],
      ),
      color: serializer.fromJson<String?>(json['color']),
      fotoPath: serializer.fromJson<String?>(json['fotoPath']),
      vin: serializer.fromJson<String?>(json['vin']),
      notas: serializer.fromJson<String?>(json['notas']),
      creadoEn: serializer.fromJson<DateTime>(json['creadoEn']),
      archivado: serializer.fromJson<bool>(json['archivado']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'marca': serializer.toJson<String>(marca),
      'modelo': serializer.toJson<String>(modelo),
      'version': serializer.toJson<String?>(version),
      'anio': serializer.toJson<int?>(anio),
      'matricula': serializer.toJson<String?>(matricula),
      'combustible': serializer.toJson<String>(
        $VehiclesTable.$convertercombustible.toJson(combustible),
      ),
      'fechaMatriculacion': serializer.toJson<DateTime?>(fechaMatriculacion),
      'color': serializer.toJson<String?>(color),
      'fotoPath': serializer.toJson<String?>(fotoPath),
      'vin': serializer.toJson<String?>(vin),
      'notas': serializer.toJson<String?>(notas),
      'creadoEn': serializer.toJson<DateTime>(creadoEn),
      'archivado': serializer.toJson<bool>(archivado),
    };
  }

  Vehicle copyWith({
    int? id,
    String? marca,
    String? modelo,
    Value<String?> version = const Value.absent(),
    Value<int?> anio = const Value.absent(),
    Value<String?> matricula = const Value.absent(),
    FuelType? combustible,
    Value<DateTime?> fechaMatriculacion = const Value.absent(),
    Value<String?> color = const Value.absent(),
    Value<String?> fotoPath = const Value.absent(),
    Value<String?> vin = const Value.absent(),
    Value<String?> notas = const Value.absent(),
    DateTime? creadoEn,
    bool? archivado,
  }) => Vehicle(
    id: id ?? this.id,
    marca: marca ?? this.marca,
    modelo: modelo ?? this.modelo,
    version: version.present ? version.value : this.version,
    anio: anio.present ? anio.value : this.anio,
    matricula: matricula.present ? matricula.value : this.matricula,
    combustible: combustible ?? this.combustible,
    fechaMatriculacion: fechaMatriculacion.present
        ? fechaMatriculacion.value
        : this.fechaMatriculacion,
    color: color.present ? color.value : this.color,
    fotoPath: fotoPath.present ? fotoPath.value : this.fotoPath,
    vin: vin.present ? vin.value : this.vin,
    notas: notas.present ? notas.value : this.notas,
    creadoEn: creadoEn ?? this.creadoEn,
    archivado: archivado ?? this.archivado,
  );
  Vehicle copyWithCompanion(VehiclesCompanion data) {
    return Vehicle(
      id: data.id.present ? data.id.value : this.id,
      marca: data.marca.present ? data.marca.value : this.marca,
      modelo: data.modelo.present ? data.modelo.value : this.modelo,
      version: data.version.present ? data.version.value : this.version,
      anio: data.anio.present ? data.anio.value : this.anio,
      matricula: data.matricula.present ? data.matricula.value : this.matricula,
      combustible: data.combustible.present
          ? data.combustible.value
          : this.combustible,
      fechaMatriculacion: data.fechaMatriculacion.present
          ? data.fechaMatriculacion.value
          : this.fechaMatriculacion,
      color: data.color.present ? data.color.value : this.color,
      fotoPath: data.fotoPath.present ? data.fotoPath.value : this.fotoPath,
      vin: data.vin.present ? data.vin.value : this.vin,
      notas: data.notas.present ? data.notas.value : this.notas,
      creadoEn: data.creadoEn.present ? data.creadoEn.value : this.creadoEn,
      archivado: data.archivado.present ? data.archivado.value : this.archivado,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Vehicle(')
          ..write('id: $id, ')
          ..write('marca: $marca, ')
          ..write('modelo: $modelo, ')
          ..write('version: $version, ')
          ..write('anio: $anio, ')
          ..write('matricula: $matricula, ')
          ..write('combustible: $combustible, ')
          ..write('fechaMatriculacion: $fechaMatriculacion, ')
          ..write('color: $color, ')
          ..write('fotoPath: $fotoPath, ')
          ..write('vin: $vin, ')
          ..write('notas: $notas, ')
          ..write('creadoEn: $creadoEn, ')
          ..write('archivado: $archivado')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    marca,
    modelo,
    version,
    anio,
    matricula,
    combustible,
    fechaMatriculacion,
    color,
    fotoPath,
    vin,
    notas,
    creadoEn,
    archivado,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Vehicle &&
          other.id == this.id &&
          other.marca == this.marca &&
          other.modelo == this.modelo &&
          other.version == this.version &&
          other.anio == this.anio &&
          other.matricula == this.matricula &&
          other.combustible == this.combustible &&
          other.fechaMatriculacion == this.fechaMatriculacion &&
          other.color == this.color &&
          other.fotoPath == this.fotoPath &&
          other.vin == this.vin &&
          other.notas == this.notas &&
          other.creadoEn == this.creadoEn &&
          other.archivado == this.archivado);
}

class VehiclesCompanion extends UpdateCompanion<Vehicle> {
  final Value<int> id;
  final Value<String> marca;
  final Value<String> modelo;
  final Value<String?> version;
  final Value<int?> anio;
  final Value<String?> matricula;
  final Value<FuelType> combustible;
  final Value<DateTime?> fechaMatriculacion;
  final Value<String?> color;
  final Value<String?> fotoPath;
  final Value<String?> vin;
  final Value<String?> notas;
  final Value<DateTime> creadoEn;
  final Value<bool> archivado;
  const VehiclesCompanion({
    this.id = const Value.absent(),
    this.marca = const Value.absent(),
    this.modelo = const Value.absent(),
    this.version = const Value.absent(),
    this.anio = const Value.absent(),
    this.matricula = const Value.absent(),
    this.combustible = const Value.absent(),
    this.fechaMatriculacion = const Value.absent(),
    this.color = const Value.absent(),
    this.fotoPath = const Value.absent(),
    this.vin = const Value.absent(),
    this.notas = const Value.absent(),
    this.creadoEn = const Value.absent(),
    this.archivado = const Value.absent(),
  });
  VehiclesCompanion.insert({
    this.id = const Value.absent(),
    required String marca,
    required String modelo,
    this.version = const Value.absent(),
    this.anio = const Value.absent(),
    this.matricula = const Value.absent(),
    required FuelType combustible,
    this.fechaMatriculacion = const Value.absent(),
    this.color = const Value.absent(),
    this.fotoPath = const Value.absent(),
    this.vin = const Value.absent(),
    this.notas = const Value.absent(),
    this.creadoEn = const Value.absent(),
    this.archivado = const Value.absent(),
  }) : marca = Value(marca),
       modelo = Value(modelo),
       combustible = Value(combustible);
  static Insertable<Vehicle> custom({
    Expression<int>? id,
    Expression<String>? marca,
    Expression<String>? modelo,
    Expression<String>? version,
    Expression<int>? anio,
    Expression<String>? matricula,
    Expression<String>? combustible,
    Expression<DateTime>? fechaMatriculacion,
    Expression<String>? color,
    Expression<String>? fotoPath,
    Expression<String>? vin,
    Expression<String>? notas,
    Expression<DateTime>? creadoEn,
    Expression<bool>? archivado,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (marca != null) 'marca': marca,
      if (modelo != null) 'modelo': modelo,
      if (version != null) 'version': version,
      if (anio != null) 'anio': anio,
      if (matricula != null) 'matricula': matricula,
      if (combustible != null) 'combustible': combustible,
      if (fechaMatriculacion != null) 'fecha_matriculacion': fechaMatriculacion,
      if (color != null) 'color': color,
      if (fotoPath != null) 'foto_path': fotoPath,
      if (vin != null) 'vin': vin,
      if (notas != null) 'notas': notas,
      if (creadoEn != null) 'creado_en': creadoEn,
      if (archivado != null) 'archivado': archivado,
    });
  }

  VehiclesCompanion copyWith({
    Value<int>? id,
    Value<String>? marca,
    Value<String>? modelo,
    Value<String?>? version,
    Value<int?>? anio,
    Value<String?>? matricula,
    Value<FuelType>? combustible,
    Value<DateTime?>? fechaMatriculacion,
    Value<String?>? color,
    Value<String?>? fotoPath,
    Value<String?>? vin,
    Value<String?>? notas,
    Value<DateTime>? creadoEn,
    Value<bool>? archivado,
  }) {
    return VehiclesCompanion(
      id: id ?? this.id,
      marca: marca ?? this.marca,
      modelo: modelo ?? this.modelo,
      version: version ?? this.version,
      anio: anio ?? this.anio,
      matricula: matricula ?? this.matricula,
      combustible: combustible ?? this.combustible,
      fechaMatriculacion: fechaMatriculacion ?? this.fechaMatriculacion,
      color: color ?? this.color,
      fotoPath: fotoPath ?? this.fotoPath,
      vin: vin ?? this.vin,
      notas: notas ?? this.notas,
      creadoEn: creadoEn ?? this.creadoEn,
      archivado: archivado ?? this.archivado,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (marca.present) {
      map['marca'] = Variable<String>(marca.value);
    }
    if (modelo.present) {
      map['modelo'] = Variable<String>(modelo.value);
    }
    if (version.present) {
      map['version'] = Variable<String>(version.value);
    }
    if (anio.present) {
      map['anio'] = Variable<int>(anio.value);
    }
    if (matricula.present) {
      map['matricula'] = Variable<String>(matricula.value);
    }
    if (combustible.present) {
      map['combustible'] = Variable<String>(
        $VehiclesTable.$convertercombustible.toSql(combustible.value),
      );
    }
    if (fechaMatriculacion.present) {
      map['fecha_matriculacion'] = Variable<DateTime>(fechaMatriculacion.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (fotoPath.present) {
      map['foto_path'] = Variable<String>(fotoPath.value);
    }
    if (vin.present) {
      map['vin'] = Variable<String>(vin.value);
    }
    if (notas.present) {
      map['notas'] = Variable<String>(notas.value);
    }
    if (creadoEn.present) {
      map['creado_en'] = Variable<DateTime>(creadoEn.value);
    }
    if (archivado.present) {
      map['archivado'] = Variable<bool>(archivado.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VehiclesCompanion(')
          ..write('id: $id, ')
          ..write('marca: $marca, ')
          ..write('modelo: $modelo, ')
          ..write('version: $version, ')
          ..write('anio: $anio, ')
          ..write('matricula: $matricula, ')
          ..write('combustible: $combustible, ')
          ..write('fechaMatriculacion: $fechaMatriculacion, ')
          ..write('color: $color, ')
          ..write('fotoPath: $fotoPath, ')
          ..write('vin: $vin, ')
          ..write('notas: $notas, ')
          ..write('creadoEn: $creadoEn, ')
          ..write('archivado: $archivado')
          ..write(')'))
        .toString();
  }
}

class $MileageReadingsTable extends MileageReadings
    with TableInfo<$MileageReadingsTable, MileageReading> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MileageReadingsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _vehicleIdMeta = const VerificationMeta(
    'vehicleId',
  );
  @override
  late final GeneratedColumn<int> vehicleId = GeneratedColumn<int>(
    'vehicle_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES vehicles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<DateTime> fecha = GeneratedColumn<DateTime>(
    'fecha',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kmMeta = const VerificationMeta('km');
  @override
  late final GeneratedColumn<int> km = GeneratedColumn<int>(
    'km',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<MileageOrigin, String> origen =
      GeneratedColumn<String>(
        'origen',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<MileageOrigin>($MileageReadingsTable.$converterorigen);
  @override
  List<GeneratedColumn> get $columns => [id, vehicleId, fecha, km, origen];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mileage_readings';
  @override
  VerificationContext validateIntegrity(
    Insertable<MileageReading> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('vehicle_id')) {
      context.handle(
        _vehicleIdMeta,
        vehicleId.isAcceptableOrUnknown(data['vehicle_id']!, _vehicleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_vehicleIdMeta);
    }
    if (data.containsKey('fecha')) {
      context.handle(
        _fechaMeta,
        fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta),
      );
    } else if (isInserting) {
      context.missing(_fechaMeta);
    }
    if (data.containsKey('km')) {
      context.handle(_kmMeta, km.isAcceptableOrUnknown(data['km']!, _kmMeta));
    } else if (isInserting) {
      context.missing(_kmMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {vehicleId, fecha},
  ];
  @override
  MileageReading map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MileageReading(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      vehicleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}vehicle_id'],
      )!,
      fecha: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha'],
      )!,
      km: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}km'],
      )!,
      origen: $MileageReadingsTable.$converterorigen.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}origen'],
        )!,
      ),
    );
  }

  @override
  $MileageReadingsTable createAlias(String alias) {
    return $MileageReadingsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<MileageOrigin, String, String> $converterorigen =
      const EnumNameConverter<MileageOrigin>(MileageOrigin.values);
}

class MileageReading extends DataClass implements Insertable<MileageReading> {
  final int id;
  final int vehicleId;
  final DateTime fecha;
  final int km;
  final MileageOrigin origen;
  const MileageReading({
    required this.id,
    required this.vehicleId,
    required this.fecha,
    required this.km,
    required this.origen,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['vehicle_id'] = Variable<int>(vehicleId);
    map['fecha'] = Variable<DateTime>(fecha);
    map['km'] = Variable<int>(km);
    {
      map['origen'] = Variable<String>(
        $MileageReadingsTable.$converterorigen.toSql(origen),
      );
    }
    return map;
  }

  MileageReadingsCompanion toCompanion(bool nullToAbsent) {
    return MileageReadingsCompanion(
      id: Value(id),
      vehicleId: Value(vehicleId),
      fecha: Value(fecha),
      km: Value(km),
      origen: Value(origen),
    );
  }

  factory MileageReading.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MileageReading(
      id: serializer.fromJson<int>(json['id']),
      vehicleId: serializer.fromJson<int>(json['vehicleId']),
      fecha: serializer.fromJson<DateTime>(json['fecha']),
      km: serializer.fromJson<int>(json['km']),
      origen: $MileageReadingsTable.$converterorigen.fromJson(
        serializer.fromJson<String>(json['origen']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'vehicleId': serializer.toJson<int>(vehicleId),
      'fecha': serializer.toJson<DateTime>(fecha),
      'km': serializer.toJson<int>(km),
      'origen': serializer.toJson<String>(
        $MileageReadingsTable.$converterorigen.toJson(origen),
      ),
    };
  }

  MileageReading copyWith({
    int? id,
    int? vehicleId,
    DateTime? fecha,
    int? km,
    MileageOrigin? origen,
  }) => MileageReading(
    id: id ?? this.id,
    vehicleId: vehicleId ?? this.vehicleId,
    fecha: fecha ?? this.fecha,
    km: km ?? this.km,
    origen: origen ?? this.origen,
  );
  MileageReading copyWithCompanion(MileageReadingsCompanion data) {
    return MileageReading(
      id: data.id.present ? data.id.value : this.id,
      vehicleId: data.vehicleId.present ? data.vehicleId.value : this.vehicleId,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      km: data.km.present ? data.km.value : this.km,
      origen: data.origen.present ? data.origen.value : this.origen,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MileageReading(')
          ..write('id: $id, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('fecha: $fecha, ')
          ..write('km: $km, ')
          ..write('origen: $origen')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, vehicleId, fecha, km, origen);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MileageReading &&
          other.id == this.id &&
          other.vehicleId == this.vehicleId &&
          other.fecha == this.fecha &&
          other.km == this.km &&
          other.origen == this.origen);
}

class MileageReadingsCompanion extends UpdateCompanion<MileageReading> {
  final Value<int> id;
  final Value<int> vehicleId;
  final Value<DateTime> fecha;
  final Value<int> km;
  final Value<MileageOrigin> origen;
  const MileageReadingsCompanion({
    this.id = const Value.absent(),
    this.vehicleId = const Value.absent(),
    this.fecha = const Value.absent(),
    this.km = const Value.absent(),
    this.origen = const Value.absent(),
  });
  MileageReadingsCompanion.insert({
    this.id = const Value.absent(),
    required int vehicleId,
    required DateTime fecha,
    required int km,
    required MileageOrigin origen,
  }) : vehicleId = Value(vehicleId),
       fecha = Value(fecha),
       km = Value(km),
       origen = Value(origen);
  static Insertable<MileageReading> custom({
    Expression<int>? id,
    Expression<int>? vehicleId,
    Expression<DateTime>? fecha,
    Expression<int>? km,
    Expression<String>? origen,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (fecha != null) 'fecha': fecha,
      if (km != null) 'km': km,
      if (origen != null) 'origen': origen,
    });
  }

  MileageReadingsCompanion copyWith({
    Value<int>? id,
    Value<int>? vehicleId,
    Value<DateTime>? fecha,
    Value<int>? km,
    Value<MileageOrigin>? origen,
  }) {
    return MileageReadingsCompanion(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      fecha: fecha ?? this.fecha,
      km: km ?? this.km,
      origen: origen ?? this.origen,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (vehicleId.present) {
      map['vehicle_id'] = Variable<int>(vehicleId.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<DateTime>(fecha.value);
    }
    if (km.present) {
      map['km'] = Variable<int>(km.value);
    }
    if (origen.present) {
      map['origen'] = Variable<String>(
        $MileageReadingsTable.$converterorigen.toSql(origen.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MileageReadingsCompanion(')
          ..write('id: $id, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('fecha: $fecha, ')
          ..write('km: $km, ')
          ..write('origen: $origen')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _avisoKmPorDefectoMeta = const VerificationMeta(
    'avisoKmPorDefecto',
  );
  @override
  late final GeneratedColumn<int> avisoKmPorDefecto = GeneratedColumn<int>(
    'aviso_km_por_defecto',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1000),
  );
  static const VerificationMeta _avisoDiasPorDefectoMeta =
      const VerificationMeta('avisoDiasPorDefecto');
  @override
  late final GeneratedColumn<int> avisoDiasPorDefecto = GeneratedColumn<int>(
    'aviso_dias_por_defecto',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(30),
  );
  static const VerificationMeta _diasRecordatorioLecturaMeta =
      const VerificationMeta('diasRecordatorioLectura');
  @override
  late final GeneratedColumn<int> diasRecordatorioLectura =
      GeneratedColumn<int>(
        'dias_recordatorio_lectura',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(15),
      );
  static const VerificationMeta _temaMeta = const VerificationMeta('tema');
  @override
  late final GeneratedColumn<String> tema = GeneratedColumn<String>(
    'tema',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('automatico'),
  );
  static const VerificationMeta _fechaUltimaCopiaMeta = const VerificationMeta(
    'fechaUltimaCopia',
  );
  @override
  late final GeneratedColumn<DateTime> fechaUltimaCopia =
      GeneratedColumn<DateTime>(
        'fecha_ultima_copia',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    avisoKmPorDefecto,
    avisoDiasPorDefecto,
    diasRecordatorioLectura,
    tema,
    fechaUltimaCopia,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Setting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('aviso_km_por_defecto')) {
      context.handle(
        _avisoKmPorDefectoMeta,
        avisoKmPorDefecto.isAcceptableOrUnknown(
          data['aviso_km_por_defecto']!,
          _avisoKmPorDefectoMeta,
        ),
      );
    }
    if (data.containsKey('aviso_dias_por_defecto')) {
      context.handle(
        _avisoDiasPorDefectoMeta,
        avisoDiasPorDefecto.isAcceptableOrUnknown(
          data['aviso_dias_por_defecto']!,
          _avisoDiasPorDefectoMeta,
        ),
      );
    }
    if (data.containsKey('dias_recordatorio_lectura')) {
      context.handle(
        _diasRecordatorioLecturaMeta,
        diasRecordatorioLectura.isAcceptableOrUnknown(
          data['dias_recordatorio_lectura']!,
          _diasRecordatorioLecturaMeta,
        ),
      );
    }
    if (data.containsKey('tema')) {
      context.handle(
        _temaMeta,
        tema.isAcceptableOrUnknown(data['tema']!, _temaMeta),
      );
    }
    if (data.containsKey('fecha_ultima_copia')) {
      context.handle(
        _fechaUltimaCopiaMeta,
        fechaUltimaCopia.isAcceptableOrUnknown(
          data['fecha_ultima_copia']!,
          _fechaUltimaCopiaMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      avisoKmPorDefecto: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}aviso_km_por_defecto'],
      )!,
      avisoDiasPorDefecto: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}aviso_dias_por_defecto'],
      )!,
      diasRecordatorioLectura: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dias_recordatorio_lectura'],
      )!,
      tema: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tema'],
      )!,
      fechaUltimaCopia: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha_ultima_copia'],
      ),
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  final int id;
  final int avisoKmPorDefecto;
  final int avisoDiasPorDefecto;
  final int diasRecordatorioLectura;
  final String tema;
  final DateTime? fechaUltimaCopia;
  const Setting({
    required this.id,
    required this.avisoKmPorDefecto,
    required this.avisoDiasPorDefecto,
    required this.diasRecordatorioLectura,
    required this.tema,
    this.fechaUltimaCopia,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['aviso_km_por_defecto'] = Variable<int>(avisoKmPorDefecto);
    map['aviso_dias_por_defecto'] = Variable<int>(avisoDiasPorDefecto);
    map['dias_recordatorio_lectura'] = Variable<int>(diasRecordatorioLectura);
    map['tema'] = Variable<String>(tema);
    if (!nullToAbsent || fechaUltimaCopia != null) {
      map['fecha_ultima_copia'] = Variable<DateTime>(fechaUltimaCopia);
    }
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(
      id: Value(id),
      avisoKmPorDefecto: Value(avisoKmPorDefecto),
      avisoDiasPorDefecto: Value(avisoDiasPorDefecto),
      diasRecordatorioLectura: Value(diasRecordatorioLectura),
      tema: Value(tema),
      fechaUltimaCopia: fechaUltimaCopia == null && nullToAbsent
          ? const Value.absent()
          : Value(fechaUltimaCopia),
    );
  }

  factory Setting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      id: serializer.fromJson<int>(json['id']),
      avisoKmPorDefecto: serializer.fromJson<int>(json['avisoKmPorDefecto']),
      avisoDiasPorDefecto: serializer.fromJson<int>(
        json['avisoDiasPorDefecto'],
      ),
      diasRecordatorioLectura: serializer.fromJson<int>(
        json['diasRecordatorioLectura'],
      ),
      tema: serializer.fromJson<String>(json['tema']),
      fechaUltimaCopia: serializer.fromJson<DateTime?>(
        json['fechaUltimaCopia'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'avisoKmPorDefecto': serializer.toJson<int>(avisoKmPorDefecto),
      'avisoDiasPorDefecto': serializer.toJson<int>(avisoDiasPorDefecto),
      'diasRecordatorioLectura': serializer.toJson<int>(
        diasRecordatorioLectura,
      ),
      'tema': serializer.toJson<String>(tema),
      'fechaUltimaCopia': serializer.toJson<DateTime?>(fechaUltimaCopia),
    };
  }

  Setting copyWith({
    int? id,
    int? avisoKmPorDefecto,
    int? avisoDiasPorDefecto,
    int? diasRecordatorioLectura,
    String? tema,
    Value<DateTime?> fechaUltimaCopia = const Value.absent(),
  }) => Setting(
    id: id ?? this.id,
    avisoKmPorDefecto: avisoKmPorDefecto ?? this.avisoKmPorDefecto,
    avisoDiasPorDefecto: avisoDiasPorDefecto ?? this.avisoDiasPorDefecto,
    diasRecordatorioLectura:
        diasRecordatorioLectura ?? this.diasRecordatorioLectura,
    tema: tema ?? this.tema,
    fechaUltimaCopia: fechaUltimaCopia.present
        ? fechaUltimaCopia.value
        : this.fechaUltimaCopia,
  );
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      id: data.id.present ? data.id.value : this.id,
      avisoKmPorDefecto: data.avisoKmPorDefecto.present
          ? data.avisoKmPorDefecto.value
          : this.avisoKmPorDefecto,
      avisoDiasPorDefecto: data.avisoDiasPorDefecto.present
          ? data.avisoDiasPorDefecto.value
          : this.avisoDiasPorDefecto,
      diasRecordatorioLectura: data.diasRecordatorioLectura.present
          ? data.diasRecordatorioLectura.value
          : this.diasRecordatorioLectura,
      tema: data.tema.present ? data.tema.value : this.tema,
      fechaUltimaCopia: data.fechaUltimaCopia.present
          ? data.fechaUltimaCopia.value
          : this.fechaUltimaCopia,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('id: $id, ')
          ..write('avisoKmPorDefecto: $avisoKmPorDefecto, ')
          ..write('avisoDiasPorDefecto: $avisoDiasPorDefecto, ')
          ..write('diasRecordatorioLectura: $diasRecordatorioLectura, ')
          ..write('tema: $tema, ')
          ..write('fechaUltimaCopia: $fechaUltimaCopia')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    avisoKmPorDefecto,
    avisoDiasPorDefecto,
    diasRecordatorioLectura,
    tema,
    fechaUltimaCopia,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting &&
          other.id == this.id &&
          other.avisoKmPorDefecto == this.avisoKmPorDefecto &&
          other.avisoDiasPorDefecto == this.avisoDiasPorDefecto &&
          other.diasRecordatorioLectura == this.diasRecordatorioLectura &&
          other.tema == this.tema &&
          other.fechaUltimaCopia == this.fechaUltimaCopia);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<int> id;
  final Value<int> avisoKmPorDefecto;
  final Value<int> avisoDiasPorDefecto;
  final Value<int> diasRecordatorioLectura;
  final Value<String> tema;
  final Value<DateTime?> fechaUltimaCopia;
  const SettingsCompanion({
    this.id = const Value.absent(),
    this.avisoKmPorDefecto = const Value.absent(),
    this.avisoDiasPorDefecto = const Value.absent(),
    this.diasRecordatorioLectura = const Value.absent(),
    this.tema = const Value.absent(),
    this.fechaUltimaCopia = const Value.absent(),
  });
  SettingsCompanion.insert({
    this.id = const Value.absent(),
    this.avisoKmPorDefecto = const Value.absent(),
    this.avisoDiasPorDefecto = const Value.absent(),
    this.diasRecordatorioLectura = const Value.absent(),
    this.tema = const Value.absent(),
    this.fechaUltimaCopia = const Value.absent(),
  });
  static Insertable<Setting> custom({
    Expression<int>? id,
    Expression<int>? avisoKmPorDefecto,
    Expression<int>? avisoDiasPorDefecto,
    Expression<int>? diasRecordatorioLectura,
    Expression<String>? tema,
    Expression<DateTime>? fechaUltimaCopia,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (avisoKmPorDefecto != null) 'aviso_km_por_defecto': avisoKmPorDefecto,
      if (avisoDiasPorDefecto != null)
        'aviso_dias_por_defecto': avisoDiasPorDefecto,
      if (diasRecordatorioLectura != null)
        'dias_recordatorio_lectura': diasRecordatorioLectura,
      if (tema != null) 'tema': tema,
      if (fechaUltimaCopia != null) 'fecha_ultima_copia': fechaUltimaCopia,
    });
  }

  SettingsCompanion copyWith({
    Value<int>? id,
    Value<int>? avisoKmPorDefecto,
    Value<int>? avisoDiasPorDefecto,
    Value<int>? diasRecordatorioLectura,
    Value<String>? tema,
    Value<DateTime?>? fechaUltimaCopia,
  }) {
    return SettingsCompanion(
      id: id ?? this.id,
      avisoKmPorDefecto: avisoKmPorDefecto ?? this.avisoKmPorDefecto,
      avisoDiasPorDefecto: avisoDiasPorDefecto ?? this.avisoDiasPorDefecto,
      diasRecordatorioLectura:
          diasRecordatorioLectura ?? this.diasRecordatorioLectura,
      tema: tema ?? this.tema,
      fechaUltimaCopia: fechaUltimaCopia ?? this.fechaUltimaCopia,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (avisoKmPorDefecto.present) {
      map['aviso_km_por_defecto'] = Variable<int>(avisoKmPorDefecto.value);
    }
    if (avisoDiasPorDefecto.present) {
      map['aviso_dias_por_defecto'] = Variable<int>(avisoDiasPorDefecto.value);
    }
    if (diasRecordatorioLectura.present) {
      map['dias_recordatorio_lectura'] = Variable<int>(
        diasRecordatorioLectura.value,
      );
    }
    if (tema.present) {
      map['tema'] = Variable<String>(tema.value);
    }
    if (fechaUltimaCopia.present) {
      map['fecha_ultima_copia'] = Variable<DateTime>(fechaUltimaCopia.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('id: $id, ')
          ..write('avisoKmPorDefecto: $avisoKmPorDefecto, ')
          ..write('avisoDiasPorDefecto: $avisoDiasPorDefecto, ')
          ..write('diasRecordatorioLectura: $diasRecordatorioLectura, ')
          ..write('tema: $tema, ')
          ..write('fechaUltimaCopia: $fechaUltimaCopia')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $VehiclesTable vehicles = $VehiclesTable(this);
  late final $MileageReadingsTable mileageReadings = $MileageReadingsTable(
    this,
  );
  late final $SettingsTable settings = $SettingsTable(this);
  late final VehicleDao vehicleDao = VehicleDao(this as AppDatabase);
  late final MileageDao mileageDao = MileageDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    vehicles,
    mileageReadings,
    settings,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'vehicles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('mileage_readings', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$VehiclesTableCreateCompanionBuilder =
    VehiclesCompanion Function({
      Value<int> id,
      required String marca,
      required String modelo,
      Value<String?> version,
      Value<int?> anio,
      Value<String?> matricula,
      required FuelType combustible,
      Value<DateTime?> fechaMatriculacion,
      Value<String?> color,
      Value<String?> fotoPath,
      Value<String?> vin,
      Value<String?> notas,
      Value<DateTime> creadoEn,
      Value<bool> archivado,
    });
typedef $$VehiclesTableUpdateCompanionBuilder =
    VehiclesCompanion Function({
      Value<int> id,
      Value<String> marca,
      Value<String> modelo,
      Value<String?> version,
      Value<int?> anio,
      Value<String?> matricula,
      Value<FuelType> combustible,
      Value<DateTime?> fechaMatriculacion,
      Value<String?> color,
      Value<String?> fotoPath,
      Value<String?> vin,
      Value<String?> notas,
      Value<DateTime> creadoEn,
      Value<bool> archivado,
    });

final class $$VehiclesTableReferences
    extends BaseReferences<_$AppDatabase, $VehiclesTable, Vehicle> {
  $$VehiclesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MileageReadingsTable, List<MileageReading>>
  _mileageReadingsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.mileageReadings,
    aliasName: 'vehicles__id__mileage_readings__vehicle_id',
  );

  $$MileageReadingsTableProcessedTableManager get mileageReadingsRefs {
    final manager = $$MileageReadingsTableTableManager(
      $_db,
      $_db.mileageReadings,
    ).filter((f) => f.vehicleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _mileageReadingsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$VehiclesTableFilterComposer
    extends Composer<_$AppDatabase, $VehiclesTable> {
  $$VehiclesTableFilterComposer({
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

  ColumnFilters<String> get marca => $composableBuilder(
    column: $table.marca,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelo => $composableBuilder(
    column: $table.modelo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get anio => $composableBuilder(
    column: $table.anio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get matricula => $composableBuilder(
    column: $table.matricula,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<FuelType, FuelType, String> get combustible =>
      $composableBuilder(
        column: $table.combustible,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get fechaMatriculacion => $composableBuilder(
    column: $table.fechaMatriculacion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fotoPath => $composableBuilder(
    column: $table.fotoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vin => $composableBuilder(
    column: $table.vin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notas => $composableBuilder(
    column: $table.notas,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get creadoEn => $composableBuilder(
    column: $table.creadoEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get archivado => $composableBuilder(
    column: $table.archivado,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> mileageReadingsRefs(
    Expression<bool> Function($$MileageReadingsTableFilterComposer f) f,
  ) {
    final $$MileageReadingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mileageReadings,
      getReferencedColumn: (t) => t.vehicleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MileageReadingsTableFilterComposer(
            $db: $db,
            $table: $db.mileageReadings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VehiclesTableOrderingComposer
    extends Composer<_$AppDatabase, $VehiclesTable> {
  $$VehiclesTableOrderingComposer({
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

  ColumnOrderings<String> get marca => $composableBuilder(
    column: $table.marca,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelo => $composableBuilder(
    column: $table.modelo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get anio => $composableBuilder(
    column: $table.anio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get matricula => $composableBuilder(
    column: $table.matricula,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get combustible => $composableBuilder(
    column: $table.combustible,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fechaMatriculacion => $composableBuilder(
    column: $table.fechaMatriculacion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fotoPath => $composableBuilder(
    column: $table.fotoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vin => $composableBuilder(
    column: $table.vin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notas => $composableBuilder(
    column: $table.notas,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get creadoEn => $composableBuilder(
    column: $table.creadoEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get archivado => $composableBuilder(
    column: $table.archivado,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VehiclesTableAnnotationComposer
    extends Composer<_$AppDatabase, $VehiclesTable> {
  $$VehiclesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get marca =>
      $composableBuilder(column: $table.marca, builder: (column) => column);

  GeneratedColumn<String> get modelo =>
      $composableBuilder(column: $table.modelo, builder: (column) => column);

  GeneratedColumn<String> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<int> get anio =>
      $composableBuilder(column: $table.anio, builder: (column) => column);

  GeneratedColumn<String> get matricula =>
      $composableBuilder(column: $table.matricula, builder: (column) => column);

  GeneratedColumnWithTypeConverter<FuelType, String> get combustible =>
      $composableBuilder(
        column: $table.combustible,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get fechaMatriculacion => $composableBuilder(
    column: $table.fechaMatriculacion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get fotoPath =>
      $composableBuilder(column: $table.fotoPath, builder: (column) => column);

  GeneratedColumn<String> get vin =>
      $composableBuilder(column: $table.vin, builder: (column) => column);

  GeneratedColumn<String> get notas =>
      $composableBuilder(column: $table.notas, builder: (column) => column);

  GeneratedColumn<DateTime> get creadoEn =>
      $composableBuilder(column: $table.creadoEn, builder: (column) => column);

  GeneratedColumn<bool> get archivado =>
      $composableBuilder(column: $table.archivado, builder: (column) => column);

  Expression<T> mileageReadingsRefs<T extends Object>(
    Expression<T> Function($$MileageReadingsTableAnnotationComposer a) f,
  ) {
    final $$MileageReadingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mileageReadings,
      getReferencedColumn: (t) => t.vehicleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MileageReadingsTableAnnotationComposer(
            $db: $db,
            $table: $db.mileageReadings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VehiclesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VehiclesTable,
          Vehicle,
          $$VehiclesTableFilterComposer,
          $$VehiclesTableOrderingComposer,
          $$VehiclesTableAnnotationComposer,
          $$VehiclesTableCreateCompanionBuilder,
          $$VehiclesTableUpdateCompanionBuilder,
          (Vehicle, $$VehiclesTableReferences),
          Vehicle,
          PrefetchHooks Function({bool mileageReadingsRefs})
        > {
  $$VehiclesTableTableManager(_$AppDatabase db, $VehiclesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VehiclesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VehiclesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VehiclesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> marca = const Value.absent(),
                Value<String> modelo = const Value.absent(),
                Value<String?> version = const Value.absent(),
                Value<int?> anio = const Value.absent(),
                Value<String?> matricula = const Value.absent(),
                Value<FuelType> combustible = const Value.absent(),
                Value<DateTime?> fechaMatriculacion = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<String?> fotoPath = const Value.absent(),
                Value<String?> vin = const Value.absent(),
                Value<String?> notas = const Value.absent(),
                Value<DateTime> creadoEn = const Value.absent(),
                Value<bool> archivado = const Value.absent(),
              }) => VehiclesCompanion(
                id: id,
                marca: marca,
                modelo: modelo,
                version: version,
                anio: anio,
                matricula: matricula,
                combustible: combustible,
                fechaMatriculacion: fechaMatriculacion,
                color: color,
                fotoPath: fotoPath,
                vin: vin,
                notas: notas,
                creadoEn: creadoEn,
                archivado: archivado,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String marca,
                required String modelo,
                Value<String?> version = const Value.absent(),
                Value<int?> anio = const Value.absent(),
                Value<String?> matricula = const Value.absent(),
                required FuelType combustible,
                Value<DateTime?> fechaMatriculacion = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<String?> fotoPath = const Value.absent(),
                Value<String?> vin = const Value.absent(),
                Value<String?> notas = const Value.absent(),
                Value<DateTime> creadoEn = const Value.absent(),
                Value<bool> archivado = const Value.absent(),
              }) => VehiclesCompanion.insert(
                id: id,
                marca: marca,
                modelo: modelo,
                version: version,
                anio: anio,
                matricula: matricula,
                combustible: combustible,
                fechaMatriculacion: fechaMatriculacion,
                color: color,
                fotoPath: fotoPath,
                vin: vin,
                notas: notas,
                creadoEn: creadoEn,
                archivado: archivado,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$VehiclesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({mileageReadingsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (mileageReadingsRefs) db.mileageReadings,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (mileageReadingsRefs)
                    await $_getPrefetchedData<
                      Vehicle,
                      $VehiclesTable,
                      MileageReading
                    >(
                      currentTable: table,
                      referencedTable: $$VehiclesTableReferences
                          ._mileageReadingsRefsTable(db),
                      managerFromTypedResult: (p0) => $$VehiclesTableReferences(
                        db,
                        table,
                        p0,
                      ).mileageReadingsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.vehicleId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$VehiclesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VehiclesTable,
      Vehicle,
      $$VehiclesTableFilterComposer,
      $$VehiclesTableOrderingComposer,
      $$VehiclesTableAnnotationComposer,
      $$VehiclesTableCreateCompanionBuilder,
      $$VehiclesTableUpdateCompanionBuilder,
      (Vehicle, $$VehiclesTableReferences),
      Vehicle,
      PrefetchHooks Function({bool mileageReadingsRefs})
    >;
typedef $$MileageReadingsTableCreateCompanionBuilder =
    MileageReadingsCompanion Function({
      Value<int> id,
      required int vehicleId,
      required DateTime fecha,
      required int km,
      required MileageOrigin origen,
    });
typedef $$MileageReadingsTableUpdateCompanionBuilder =
    MileageReadingsCompanion Function({
      Value<int> id,
      Value<int> vehicleId,
      Value<DateTime> fecha,
      Value<int> km,
      Value<MileageOrigin> origen,
    });

final class $$MileageReadingsTableReferences
    extends
        BaseReferences<_$AppDatabase, $MileageReadingsTable, MileageReading> {
  $$MileageReadingsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $VehiclesTable _vehicleIdTable(_$AppDatabase db) =>
      db.vehicles.createAlias('mileage_readings__vehicle_id__vehicles__id');

  $$VehiclesTableProcessedTableManager get vehicleId {
    final $_column = $_itemColumn<int>('vehicle_id')!;

    final manager = $$VehiclesTableTableManager(
      $_db,
      $_db.vehicles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vehicleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MileageReadingsTableFilterComposer
    extends Composer<_$AppDatabase, $MileageReadingsTable> {
  $$MileageReadingsTableFilterComposer({
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

  ColumnFilters<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get km => $composableBuilder(
    column: $table.km,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<MileageOrigin, MileageOrigin, String>
  get origen => $composableBuilder(
    column: $table.origen,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  $$VehiclesTableFilterComposer get vehicleId {
    final $$VehiclesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableFilterComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MileageReadingsTableOrderingComposer
    extends Composer<_$AppDatabase, $MileageReadingsTable> {
  $$MileageReadingsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get km => $composableBuilder(
    column: $table.km,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get origen => $composableBuilder(
    column: $table.origen,
    builder: (column) => ColumnOrderings(column),
  );

  $$VehiclesTableOrderingComposer get vehicleId {
    final $$VehiclesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableOrderingComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MileageReadingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MileageReadingsTable> {
  $$MileageReadingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  GeneratedColumn<int> get km =>
      $composableBuilder(column: $table.km, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MileageOrigin, String> get origen =>
      $composableBuilder(column: $table.origen, builder: (column) => column);

  $$VehiclesTableAnnotationComposer get vehicleId {
    final $$VehiclesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableAnnotationComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MileageReadingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MileageReadingsTable,
          MileageReading,
          $$MileageReadingsTableFilterComposer,
          $$MileageReadingsTableOrderingComposer,
          $$MileageReadingsTableAnnotationComposer,
          $$MileageReadingsTableCreateCompanionBuilder,
          $$MileageReadingsTableUpdateCompanionBuilder,
          (MileageReading, $$MileageReadingsTableReferences),
          MileageReading,
          PrefetchHooks Function({bool vehicleId})
        > {
  $$MileageReadingsTableTableManager(
    _$AppDatabase db,
    $MileageReadingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MileageReadingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MileageReadingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MileageReadingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> vehicleId = const Value.absent(),
                Value<DateTime> fecha = const Value.absent(),
                Value<int> km = const Value.absent(),
                Value<MileageOrigin> origen = const Value.absent(),
              }) => MileageReadingsCompanion(
                id: id,
                vehicleId: vehicleId,
                fecha: fecha,
                km: km,
                origen: origen,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int vehicleId,
                required DateTime fecha,
                required int km,
                required MileageOrigin origen,
              }) => MileageReadingsCompanion.insert(
                id: id,
                vehicleId: vehicleId,
                fecha: fecha,
                km: km,
                origen: origen,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MileageReadingsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({vehicleId = false}) {
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
                    if (vehicleId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.vehicleId,
                                referencedTable:
                                    $$MileageReadingsTableReferences
                                        ._vehicleIdTable(db),
                                referencedColumn:
                                    $$MileageReadingsTableReferences
                                        ._vehicleIdTable(db)
                                        .id,
                              )
                              as T;
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

typedef $$MileageReadingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MileageReadingsTable,
      MileageReading,
      $$MileageReadingsTableFilterComposer,
      $$MileageReadingsTableOrderingComposer,
      $$MileageReadingsTableAnnotationComposer,
      $$MileageReadingsTableCreateCompanionBuilder,
      $$MileageReadingsTableUpdateCompanionBuilder,
      (MileageReading, $$MileageReadingsTableReferences),
      MileageReading,
      PrefetchHooks Function({bool vehicleId})
    >;
typedef $$SettingsTableCreateCompanionBuilder =
    SettingsCompanion Function({
      Value<int> id,
      Value<int> avisoKmPorDefecto,
      Value<int> avisoDiasPorDefecto,
      Value<int> diasRecordatorioLectura,
      Value<String> tema,
      Value<DateTime?> fechaUltimaCopia,
    });
typedef $$SettingsTableUpdateCompanionBuilder =
    SettingsCompanion Function({
      Value<int> id,
      Value<int> avisoKmPorDefecto,
      Value<int> avisoDiasPorDefecto,
      Value<int> diasRecordatorioLectura,
      Value<String> tema,
      Value<DateTime?> fechaUltimaCopia,
    });

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
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

  ColumnFilters<int> get avisoKmPorDefecto => $composableBuilder(
    column: $table.avisoKmPorDefecto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get avisoDiasPorDefecto => $composableBuilder(
    column: $table.avisoDiasPorDefecto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get diasRecordatorioLectura => $composableBuilder(
    column: $table.diasRecordatorioLectura,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tema => $composableBuilder(
    column: $table.tema,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fechaUltimaCopia => $composableBuilder(
    column: $table.fechaUltimaCopia,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
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

  ColumnOrderings<int> get avisoKmPorDefecto => $composableBuilder(
    column: $table.avisoKmPorDefecto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get avisoDiasPorDefecto => $composableBuilder(
    column: $table.avisoDiasPorDefecto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get diasRecordatorioLectura => $composableBuilder(
    column: $table.diasRecordatorioLectura,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tema => $composableBuilder(
    column: $table.tema,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fechaUltimaCopia => $composableBuilder(
    column: $table.fechaUltimaCopia,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get avisoKmPorDefecto => $composableBuilder(
    column: $table.avisoKmPorDefecto,
    builder: (column) => column,
  );

  GeneratedColumn<int> get avisoDiasPorDefecto => $composableBuilder(
    column: $table.avisoDiasPorDefecto,
    builder: (column) => column,
  );

  GeneratedColumn<int> get diasRecordatorioLectura => $composableBuilder(
    column: $table.diasRecordatorioLectura,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tema =>
      $composableBuilder(column: $table.tema, builder: (column) => column);

  GeneratedColumn<DateTime> get fechaUltimaCopia => $composableBuilder(
    column: $table.fechaUltimaCopia,
    builder: (column) => column,
  );
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          Setting,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
          Setting,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> avisoKmPorDefecto = const Value.absent(),
                Value<int> avisoDiasPorDefecto = const Value.absent(),
                Value<int> diasRecordatorioLectura = const Value.absent(),
                Value<String> tema = const Value.absent(),
                Value<DateTime?> fechaUltimaCopia = const Value.absent(),
              }) => SettingsCompanion(
                id: id,
                avisoKmPorDefecto: avisoKmPorDefecto,
                avisoDiasPorDefecto: avisoDiasPorDefecto,
                diasRecordatorioLectura: diasRecordatorioLectura,
                tema: tema,
                fechaUltimaCopia: fechaUltimaCopia,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> avisoKmPorDefecto = const Value.absent(),
                Value<int> avisoDiasPorDefecto = const Value.absent(),
                Value<int> diasRecordatorioLectura = const Value.absent(),
                Value<String> tema = const Value.absent(),
                Value<DateTime?> fechaUltimaCopia = const Value.absent(),
              }) => SettingsCompanion.insert(
                id: id,
                avisoKmPorDefecto: avisoKmPorDefecto,
                avisoDiasPorDefecto: avisoDiasPorDefecto,
                diasRecordatorioLectura: diasRecordatorioLectura,
                tema: tema,
                fechaUltimaCopia: fechaUltimaCopia,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      Setting,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
      Setting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$VehiclesTableTableManager get vehicles =>
      $$VehiclesTableTableManager(_db, _db.vehicles);
  $$MileageReadingsTableTableManager get mileageReadings =>
      $$MileageReadingsTableTableManager(_db, _db.mileageReadings);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
}
