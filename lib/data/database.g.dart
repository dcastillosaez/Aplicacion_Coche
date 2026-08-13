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
  static const VerificationMeta _colorValorMeta = const VerificationMeta(
    'colorValor',
  );
  @override
  late final GeneratedColumn<int> colorValor = GeneratedColumn<int>(
    'color_valor',
    aliasedName,
    true,
    type: DriftSqlType.int,
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
    colorValor,
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
    if (data.containsKey('color_valor')) {
      context.handle(
        _colorValorMeta,
        colorValor.isAcceptableOrUnknown(data['color_valor']!, _colorValorMeta),
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
      colorValor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color_valor'],
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
  final int? colorValor;
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
    this.colorValor,
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
    if (!nullToAbsent || colorValor != null) {
      map['color_valor'] = Variable<int>(colorValor);
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
      colorValor: colorValor == null && nullToAbsent
          ? const Value.absent()
          : Value(colorValor),
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
      colorValor: serializer.fromJson<int?>(json['colorValor']),
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
      'colorValor': serializer.toJson<int?>(colorValor),
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
    Value<int?> colorValor = const Value.absent(),
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
    colorValor: colorValor.present ? colorValor.value : this.colorValor,
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
      colorValor: data.colorValor.present
          ? data.colorValor.value
          : this.colorValor,
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
          ..write('colorValor: $colorValor, ')
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
    colorValor,
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
          other.colorValor == this.colorValor &&
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
  final Value<int?> colorValor;
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
    this.colorValor = const Value.absent(),
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
    this.colorValor = const Value.absent(),
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
    Expression<int>? colorValor,
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
      if (colorValor != null) 'color_valor': colorValor,
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
    Value<int?>? colorValor,
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
      colorValor: colorValor ?? this.colorValor,
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
    if (colorValor.present) {
      map['color_valor'] = Variable<int>(colorValor.value);
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
          ..write('colorValor: $colorValor, ')
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

class $MaintenanceSchedulesTable extends MaintenanceSchedules
    with TableInfo<$MaintenanceSchedulesTable, MaintenanceSchedule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MaintenanceSchedulesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 80,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<MaintenanceCategory, String>
  categoria =
      GeneratedColumn<String>(
        'categoria',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<MaintenanceCategory>(
        $MaintenanceSchedulesTable.$convertercategoria,
      );
  static const VerificationMeta _intervalKmMeta = const VerificationMeta(
    'intervalKm',
  );
  @override
  late final GeneratedColumn<int> intervalKm = GeneratedColumn<int>(
    'interval_km',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _intervalMesesMeta = const VerificationMeta(
    'intervalMeses',
  );
  @override
  late final GeneratedColumn<int> intervalMeses = GeneratedColumn<int>(
    'interval_meses',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _avisoKmMeta = const VerificationMeta(
    'avisoKm',
  );
  @override
  late final GeneratedColumn<int> avisoKm = GeneratedColumn<int>(
    'aviso_km',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _avisoDiasMeta = const VerificationMeta(
    'avisoDias',
  );
  @override
  late final GeneratedColumn<int> avisoDias = GeneratedColumn<int>(
    'aviso_dias',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _activoMeta = const VerificationMeta('activo');
  @override
  late final GeneratedColumn<bool> activo = GeneratedColumn<bool>(
    'activo',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("activo" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _silenciadoMeta = const VerificationMeta(
    'silenciado',
  );
  @override
  late final GeneratedColumn<bool> silenciado = GeneratedColumn<bool>(
    'silenciado',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("silenciado" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _ordenMeta = const VerificationMeta('orden');
  @override
  late final GeneratedColumn<int> orden = GeneratedColumn<int>(
    'orden',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  late final GeneratedColumnWithTypeConverter<FuenteIntervalo, String>
  fuenteIntervalo =
      GeneratedColumn<String>(
        'fuente_intervalo',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('orientativo'),
      ).withConverter<FuenteIntervalo>(
        $MaintenanceSchedulesTable.$converterfuenteIntervalo,
      );
  @override
  late final GeneratedColumnWithTypeConverter<MaintenanceType?, String> tipo =
      GeneratedColumn<String>(
        'tipo',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<MaintenanceType?>(
        $MaintenanceSchedulesTable.$convertertipon,
      );
  @override
  late final GeneratedColumnWithTypeConverter<Posicion?, String> posicion =
      GeneratedColumn<String>(
        'posicion',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Posicion?>(
        $MaintenanceSchedulesTable.$converterposicionn,
      );
  static const VerificationMeta _nombreAutogeneradoMeta =
      const VerificationMeta('nombreAutogenerado');
  @override
  late final GeneratedColumn<bool> nombreAutogenerado = GeneratedColumn<bool>(
    'nombre_autogenerado',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("nombre_autogenerado" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    vehicleId,
    nombre,
    categoria,
    intervalKm,
    intervalMeses,
    avisoKm,
    avisoDias,
    activo,
    silenciado,
    orden,
    fuenteIntervalo,
    tipo,
    posicion,
    nombreAutogenerado,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'maintenance_schedules';
  @override
  VerificationContext validateIntegrity(
    Insertable<MaintenanceSchedule> instance, {
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
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('interval_km')) {
      context.handle(
        _intervalKmMeta,
        intervalKm.isAcceptableOrUnknown(data['interval_km']!, _intervalKmMeta),
      );
    }
    if (data.containsKey('interval_meses')) {
      context.handle(
        _intervalMesesMeta,
        intervalMeses.isAcceptableOrUnknown(
          data['interval_meses']!,
          _intervalMesesMeta,
        ),
      );
    }
    if (data.containsKey('aviso_km')) {
      context.handle(
        _avisoKmMeta,
        avisoKm.isAcceptableOrUnknown(data['aviso_km']!, _avisoKmMeta),
      );
    }
    if (data.containsKey('aviso_dias')) {
      context.handle(
        _avisoDiasMeta,
        avisoDias.isAcceptableOrUnknown(data['aviso_dias']!, _avisoDiasMeta),
      );
    }
    if (data.containsKey('activo')) {
      context.handle(
        _activoMeta,
        activo.isAcceptableOrUnknown(data['activo']!, _activoMeta),
      );
    }
    if (data.containsKey('silenciado')) {
      context.handle(
        _silenciadoMeta,
        silenciado.isAcceptableOrUnknown(data['silenciado']!, _silenciadoMeta),
      );
    }
    if (data.containsKey('orden')) {
      context.handle(
        _ordenMeta,
        orden.isAcceptableOrUnknown(data['orden']!, _ordenMeta),
      );
    }
    if (data.containsKey('nombre_autogenerado')) {
      context.handle(
        _nombreAutogeneradoMeta,
        nombreAutogenerado.isAcceptableOrUnknown(
          data['nombre_autogenerado']!,
          _nombreAutogeneradoMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MaintenanceSchedule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MaintenanceSchedule(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      vehicleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}vehicle_id'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      categoria: $MaintenanceSchedulesTable.$convertercategoria.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}categoria'],
        )!,
      ),
      intervalKm: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interval_km'],
      ),
      intervalMeses: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interval_meses'],
      ),
      avisoKm: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}aviso_km'],
      ),
      avisoDias: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}aviso_dias'],
      ),
      activo: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}activo'],
      )!,
      silenciado: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}silenciado'],
      )!,
      orden: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}orden'],
      )!,
      fuenteIntervalo: $MaintenanceSchedulesTable.$converterfuenteIntervalo
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.string,
              data['${effectivePrefix}fuente_intervalo'],
            )!,
          ),
      tipo: $MaintenanceSchedulesTable.$convertertipon.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}tipo'],
        ),
      ),
      posicion: $MaintenanceSchedulesTable.$converterposicionn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}posicion'],
        ),
      ),
      nombreAutogenerado: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}nombre_autogenerado'],
      )!,
    );
  }

  @override
  $MaintenanceSchedulesTable createAlias(String alias) {
    return $MaintenanceSchedulesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<MaintenanceCategory, String, String>
  $convertercategoria = const EnumNameConverter<MaintenanceCategory>(
    MaintenanceCategory.values,
  );
  static JsonTypeConverter2<FuenteIntervalo, String, String>
  $converterfuenteIntervalo = const EnumNameConverter<FuenteIntervalo>(
    FuenteIntervalo.values,
  );
  static JsonTypeConverter2<MaintenanceType, String, String> $convertertipo =
      const EnumNameConverter<MaintenanceType>(MaintenanceType.values);
  static JsonTypeConverter2<MaintenanceType?, String?, String?>
  $convertertipon = JsonTypeConverter2.asNullable($convertertipo);
  static JsonTypeConverter2<Posicion, String, String> $converterposicion =
      const EnumNameConverter<Posicion>(Posicion.values);
  static JsonTypeConverter2<Posicion?, String?, String?> $converterposicionn =
      JsonTypeConverter2.asNullable($converterposicion);
}

class MaintenanceSchedule extends DataClass
    implements Insertable<MaintenanceSchedule> {
  final int id;
  final int vehicleId;
  final String nombre;
  final MaintenanceCategory categoria;

  /// Al menos uno de los dos intervalos debe tener valor. La comprobación
  /// vive en el formulario: SQLite no puede expresarla sin un CHECK que
  /// complicaría las migraciones.
  final int? intervalKm;
  final int? intervalMeses;

  /// Márgenes de aviso propios. A nulo, se heredan los de Settings.
  final int? avisoKm;
  final int? avisoDias;
  final bool activo;

  /// Sigue calculando su estado, pero no genera notificación.
  final bool silenciado;
  final int orden;

  /// Ver `FuenteIntervalo`. Todo mantenimiento tiene una fuente, incluso
  /// los que no la eligieron explícitamente: por defecto es orientativo.
  final FuenteIntervalo fuenteIntervalo;

  /// Qué es, del catálogo. Nulo en los mantenimientos ya configurados
  /// antes de que existiera este campo, y en cualquiera nuevo que no use
  /// el catálogo: siguen funcionando igual, solo con nombre libre.
  final MaintenanceType? tipo;

  /// Dónde, cuando el tipo lo admite (`MaintenanceType.admitePosicion`).
  final Posicion? posicion;

  /// Si `nombre` se generó solo a partir de tipo+posición (y por tanto se
  /// regenera si cambian) o si el usuario lo editó a mano (y por tanto se
  /// queda quieto para siempre, aunque cambie el tipo o la posición).
  final bool nombreAutogenerado;
  const MaintenanceSchedule({
    required this.id,
    required this.vehicleId,
    required this.nombre,
    required this.categoria,
    this.intervalKm,
    this.intervalMeses,
    this.avisoKm,
    this.avisoDias,
    required this.activo,
    required this.silenciado,
    required this.orden,
    required this.fuenteIntervalo,
    this.tipo,
    this.posicion,
    required this.nombreAutogenerado,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['vehicle_id'] = Variable<int>(vehicleId);
    map['nombre'] = Variable<String>(nombre);
    {
      map['categoria'] = Variable<String>(
        $MaintenanceSchedulesTable.$convertercategoria.toSql(categoria),
      );
    }
    if (!nullToAbsent || intervalKm != null) {
      map['interval_km'] = Variable<int>(intervalKm);
    }
    if (!nullToAbsent || intervalMeses != null) {
      map['interval_meses'] = Variable<int>(intervalMeses);
    }
    if (!nullToAbsent || avisoKm != null) {
      map['aviso_km'] = Variable<int>(avisoKm);
    }
    if (!nullToAbsent || avisoDias != null) {
      map['aviso_dias'] = Variable<int>(avisoDias);
    }
    map['activo'] = Variable<bool>(activo);
    map['silenciado'] = Variable<bool>(silenciado);
    map['orden'] = Variable<int>(orden);
    {
      map['fuente_intervalo'] = Variable<String>(
        $MaintenanceSchedulesTable.$converterfuenteIntervalo.toSql(
          fuenteIntervalo,
        ),
      );
    }
    if (!nullToAbsent || tipo != null) {
      map['tipo'] = Variable<String>(
        $MaintenanceSchedulesTable.$convertertipon.toSql(tipo),
      );
    }
    if (!nullToAbsent || posicion != null) {
      map['posicion'] = Variable<String>(
        $MaintenanceSchedulesTable.$converterposicionn.toSql(posicion),
      );
    }
    map['nombre_autogenerado'] = Variable<bool>(nombreAutogenerado);
    return map;
  }

  MaintenanceSchedulesCompanion toCompanion(bool nullToAbsent) {
    return MaintenanceSchedulesCompanion(
      id: Value(id),
      vehicleId: Value(vehicleId),
      nombre: Value(nombre),
      categoria: Value(categoria),
      intervalKm: intervalKm == null && nullToAbsent
          ? const Value.absent()
          : Value(intervalKm),
      intervalMeses: intervalMeses == null && nullToAbsent
          ? const Value.absent()
          : Value(intervalMeses),
      avisoKm: avisoKm == null && nullToAbsent
          ? const Value.absent()
          : Value(avisoKm),
      avisoDias: avisoDias == null && nullToAbsent
          ? const Value.absent()
          : Value(avisoDias),
      activo: Value(activo),
      silenciado: Value(silenciado),
      orden: Value(orden),
      fuenteIntervalo: Value(fuenteIntervalo),
      tipo: tipo == null && nullToAbsent ? const Value.absent() : Value(tipo),
      posicion: posicion == null && nullToAbsent
          ? const Value.absent()
          : Value(posicion),
      nombreAutogenerado: Value(nombreAutogenerado),
    );
  }

  factory MaintenanceSchedule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MaintenanceSchedule(
      id: serializer.fromJson<int>(json['id']),
      vehicleId: serializer.fromJson<int>(json['vehicleId']),
      nombre: serializer.fromJson<String>(json['nombre']),
      categoria: $MaintenanceSchedulesTable.$convertercategoria.fromJson(
        serializer.fromJson<String>(json['categoria']),
      ),
      intervalKm: serializer.fromJson<int?>(json['intervalKm']),
      intervalMeses: serializer.fromJson<int?>(json['intervalMeses']),
      avisoKm: serializer.fromJson<int?>(json['avisoKm']),
      avisoDias: serializer.fromJson<int?>(json['avisoDias']),
      activo: serializer.fromJson<bool>(json['activo']),
      silenciado: serializer.fromJson<bool>(json['silenciado']),
      orden: serializer.fromJson<int>(json['orden']),
      fuenteIntervalo: $MaintenanceSchedulesTable.$converterfuenteIntervalo
          .fromJson(serializer.fromJson<String>(json['fuenteIntervalo'])),
      tipo: $MaintenanceSchedulesTable.$convertertipon.fromJson(
        serializer.fromJson<String?>(json['tipo']),
      ),
      posicion: $MaintenanceSchedulesTable.$converterposicionn.fromJson(
        serializer.fromJson<String?>(json['posicion']),
      ),
      nombreAutogenerado: serializer.fromJson<bool>(json['nombreAutogenerado']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'vehicleId': serializer.toJson<int>(vehicleId),
      'nombre': serializer.toJson<String>(nombre),
      'categoria': serializer.toJson<String>(
        $MaintenanceSchedulesTable.$convertercategoria.toJson(categoria),
      ),
      'intervalKm': serializer.toJson<int?>(intervalKm),
      'intervalMeses': serializer.toJson<int?>(intervalMeses),
      'avisoKm': serializer.toJson<int?>(avisoKm),
      'avisoDias': serializer.toJson<int?>(avisoDias),
      'activo': serializer.toJson<bool>(activo),
      'silenciado': serializer.toJson<bool>(silenciado),
      'orden': serializer.toJson<int>(orden),
      'fuenteIntervalo': serializer.toJson<String>(
        $MaintenanceSchedulesTable.$converterfuenteIntervalo.toJson(
          fuenteIntervalo,
        ),
      ),
      'tipo': serializer.toJson<String?>(
        $MaintenanceSchedulesTable.$convertertipon.toJson(tipo),
      ),
      'posicion': serializer.toJson<String?>(
        $MaintenanceSchedulesTable.$converterposicionn.toJson(posicion),
      ),
      'nombreAutogenerado': serializer.toJson<bool>(nombreAutogenerado),
    };
  }

  MaintenanceSchedule copyWith({
    int? id,
    int? vehicleId,
    String? nombre,
    MaintenanceCategory? categoria,
    Value<int?> intervalKm = const Value.absent(),
    Value<int?> intervalMeses = const Value.absent(),
    Value<int?> avisoKm = const Value.absent(),
    Value<int?> avisoDias = const Value.absent(),
    bool? activo,
    bool? silenciado,
    int? orden,
    FuenteIntervalo? fuenteIntervalo,
    Value<MaintenanceType?> tipo = const Value.absent(),
    Value<Posicion?> posicion = const Value.absent(),
    bool? nombreAutogenerado,
  }) => MaintenanceSchedule(
    id: id ?? this.id,
    vehicleId: vehicleId ?? this.vehicleId,
    nombre: nombre ?? this.nombre,
    categoria: categoria ?? this.categoria,
    intervalKm: intervalKm.present ? intervalKm.value : this.intervalKm,
    intervalMeses: intervalMeses.present
        ? intervalMeses.value
        : this.intervalMeses,
    avisoKm: avisoKm.present ? avisoKm.value : this.avisoKm,
    avisoDias: avisoDias.present ? avisoDias.value : this.avisoDias,
    activo: activo ?? this.activo,
    silenciado: silenciado ?? this.silenciado,
    orden: orden ?? this.orden,
    fuenteIntervalo: fuenteIntervalo ?? this.fuenteIntervalo,
    tipo: tipo.present ? tipo.value : this.tipo,
    posicion: posicion.present ? posicion.value : this.posicion,
    nombreAutogenerado: nombreAutogenerado ?? this.nombreAutogenerado,
  );
  MaintenanceSchedule copyWithCompanion(MaintenanceSchedulesCompanion data) {
    return MaintenanceSchedule(
      id: data.id.present ? data.id.value : this.id,
      vehicleId: data.vehicleId.present ? data.vehicleId.value : this.vehicleId,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      categoria: data.categoria.present ? data.categoria.value : this.categoria,
      intervalKm: data.intervalKm.present
          ? data.intervalKm.value
          : this.intervalKm,
      intervalMeses: data.intervalMeses.present
          ? data.intervalMeses.value
          : this.intervalMeses,
      avisoKm: data.avisoKm.present ? data.avisoKm.value : this.avisoKm,
      avisoDias: data.avisoDias.present ? data.avisoDias.value : this.avisoDias,
      activo: data.activo.present ? data.activo.value : this.activo,
      silenciado: data.silenciado.present
          ? data.silenciado.value
          : this.silenciado,
      orden: data.orden.present ? data.orden.value : this.orden,
      fuenteIntervalo: data.fuenteIntervalo.present
          ? data.fuenteIntervalo.value
          : this.fuenteIntervalo,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      posicion: data.posicion.present ? data.posicion.value : this.posicion,
      nombreAutogenerado: data.nombreAutogenerado.present
          ? data.nombreAutogenerado.value
          : this.nombreAutogenerado,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MaintenanceSchedule(')
          ..write('id: $id, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('nombre: $nombre, ')
          ..write('categoria: $categoria, ')
          ..write('intervalKm: $intervalKm, ')
          ..write('intervalMeses: $intervalMeses, ')
          ..write('avisoKm: $avisoKm, ')
          ..write('avisoDias: $avisoDias, ')
          ..write('activo: $activo, ')
          ..write('silenciado: $silenciado, ')
          ..write('orden: $orden, ')
          ..write('fuenteIntervalo: $fuenteIntervalo, ')
          ..write('tipo: $tipo, ')
          ..write('posicion: $posicion, ')
          ..write('nombreAutogenerado: $nombreAutogenerado')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    vehicleId,
    nombre,
    categoria,
    intervalKm,
    intervalMeses,
    avisoKm,
    avisoDias,
    activo,
    silenciado,
    orden,
    fuenteIntervalo,
    tipo,
    posicion,
    nombreAutogenerado,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MaintenanceSchedule &&
          other.id == this.id &&
          other.vehicleId == this.vehicleId &&
          other.nombre == this.nombre &&
          other.categoria == this.categoria &&
          other.intervalKm == this.intervalKm &&
          other.intervalMeses == this.intervalMeses &&
          other.avisoKm == this.avisoKm &&
          other.avisoDias == this.avisoDias &&
          other.activo == this.activo &&
          other.silenciado == this.silenciado &&
          other.orden == this.orden &&
          other.fuenteIntervalo == this.fuenteIntervalo &&
          other.tipo == this.tipo &&
          other.posicion == this.posicion &&
          other.nombreAutogenerado == this.nombreAutogenerado);
}

class MaintenanceSchedulesCompanion
    extends UpdateCompanion<MaintenanceSchedule> {
  final Value<int> id;
  final Value<int> vehicleId;
  final Value<String> nombre;
  final Value<MaintenanceCategory> categoria;
  final Value<int?> intervalKm;
  final Value<int?> intervalMeses;
  final Value<int?> avisoKm;
  final Value<int?> avisoDias;
  final Value<bool> activo;
  final Value<bool> silenciado;
  final Value<int> orden;
  final Value<FuenteIntervalo> fuenteIntervalo;
  final Value<MaintenanceType?> tipo;
  final Value<Posicion?> posicion;
  final Value<bool> nombreAutogenerado;
  const MaintenanceSchedulesCompanion({
    this.id = const Value.absent(),
    this.vehicleId = const Value.absent(),
    this.nombre = const Value.absent(),
    this.categoria = const Value.absent(),
    this.intervalKm = const Value.absent(),
    this.intervalMeses = const Value.absent(),
    this.avisoKm = const Value.absent(),
    this.avisoDias = const Value.absent(),
    this.activo = const Value.absent(),
    this.silenciado = const Value.absent(),
    this.orden = const Value.absent(),
    this.fuenteIntervalo = const Value.absent(),
    this.tipo = const Value.absent(),
    this.posicion = const Value.absent(),
    this.nombreAutogenerado = const Value.absent(),
  });
  MaintenanceSchedulesCompanion.insert({
    this.id = const Value.absent(),
    required int vehicleId,
    required String nombre,
    required MaintenanceCategory categoria,
    this.intervalKm = const Value.absent(),
    this.intervalMeses = const Value.absent(),
    this.avisoKm = const Value.absent(),
    this.avisoDias = const Value.absent(),
    this.activo = const Value.absent(),
    this.silenciado = const Value.absent(),
    this.orden = const Value.absent(),
    this.fuenteIntervalo = const Value.absent(),
    this.tipo = const Value.absent(),
    this.posicion = const Value.absent(),
    this.nombreAutogenerado = const Value.absent(),
  }) : vehicleId = Value(vehicleId),
       nombre = Value(nombre),
       categoria = Value(categoria);
  static Insertable<MaintenanceSchedule> custom({
    Expression<int>? id,
    Expression<int>? vehicleId,
    Expression<String>? nombre,
    Expression<String>? categoria,
    Expression<int>? intervalKm,
    Expression<int>? intervalMeses,
    Expression<int>? avisoKm,
    Expression<int>? avisoDias,
    Expression<bool>? activo,
    Expression<bool>? silenciado,
    Expression<int>? orden,
    Expression<String>? fuenteIntervalo,
    Expression<String>? tipo,
    Expression<String>? posicion,
    Expression<bool>? nombreAutogenerado,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (nombre != null) 'nombre': nombre,
      if (categoria != null) 'categoria': categoria,
      if (intervalKm != null) 'interval_km': intervalKm,
      if (intervalMeses != null) 'interval_meses': intervalMeses,
      if (avisoKm != null) 'aviso_km': avisoKm,
      if (avisoDias != null) 'aviso_dias': avisoDias,
      if (activo != null) 'activo': activo,
      if (silenciado != null) 'silenciado': silenciado,
      if (orden != null) 'orden': orden,
      if (fuenteIntervalo != null) 'fuente_intervalo': fuenteIntervalo,
      if (tipo != null) 'tipo': tipo,
      if (posicion != null) 'posicion': posicion,
      if (nombreAutogenerado != null) 'nombre_autogenerado': nombreAutogenerado,
    });
  }

  MaintenanceSchedulesCompanion copyWith({
    Value<int>? id,
    Value<int>? vehicleId,
    Value<String>? nombre,
    Value<MaintenanceCategory>? categoria,
    Value<int?>? intervalKm,
    Value<int?>? intervalMeses,
    Value<int?>? avisoKm,
    Value<int?>? avisoDias,
    Value<bool>? activo,
    Value<bool>? silenciado,
    Value<int>? orden,
    Value<FuenteIntervalo>? fuenteIntervalo,
    Value<MaintenanceType?>? tipo,
    Value<Posicion?>? posicion,
    Value<bool>? nombreAutogenerado,
  }) {
    return MaintenanceSchedulesCompanion(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      nombre: nombre ?? this.nombre,
      categoria: categoria ?? this.categoria,
      intervalKm: intervalKm ?? this.intervalKm,
      intervalMeses: intervalMeses ?? this.intervalMeses,
      avisoKm: avisoKm ?? this.avisoKm,
      avisoDias: avisoDias ?? this.avisoDias,
      activo: activo ?? this.activo,
      silenciado: silenciado ?? this.silenciado,
      orden: orden ?? this.orden,
      fuenteIntervalo: fuenteIntervalo ?? this.fuenteIntervalo,
      tipo: tipo ?? this.tipo,
      posicion: posicion ?? this.posicion,
      nombreAutogenerado: nombreAutogenerado ?? this.nombreAutogenerado,
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
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (categoria.present) {
      map['categoria'] = Variable<String>(
        $MaintenanceSchedulesTable.$convertercategoria.toSql(categoria.value),
      );
    }
    if (intervalKm.present) {
      map['interval_km'] = Variable<int>(intervalKm.value);
    }
    if (intervalMeses.present) {
      map['interval_meses'] = Variable<int>(intervalMeses.value);
    }
    if (avisoKm.present) {
      map['aviso_km'] = Variable<int>(avisoKm.value);
    }
    if (avisoDias.present) {
      map['aviso_dias'] = Variable<int>(avisoDias.value);
    }
    if (activo.present) {
      map['activo'] = Variable<bool>(activo.value);
    }
    if (silenciado.present) {
      map['silenciado'] = Variable<bool>(silenciado.value);
    }
    if (orden.present) {
      map['orden'] = Variable<int>(orden.value);
    }
    if (fuenteIntervalo.present) {
      map['fuente_intervalo'] = Variable<String>(
        $MaintenanceSchedulesTable.$converterfuenteIntervalo.toSql(
          fuenteIntervalo.value,
        ),
      );
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(
        $MaintenanceSchedulesTable.$convertertipon.toSql(tipo.value),
      );
    }
    if (posicion.present) {
      map['posicion'] = Variable<String>(
        $MaintenanceSchedulesTable.$converterposicionn.toSql(posicion.value),
      );
    }
    if (nombreAutogenerado.present) {
      map['nombre_autogenerado'] = Variable<bool>(nombreAutogenerado.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MaintenanceSchedulesCompanion(')
          ..write('id: $id, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('nombre: $nombre, ')
          ..write('categoria: $categoria, ')
          ..write('intervalKm: $intervalKm, ')
          ..write('intervalMeses: $intervalMeses, ')
          ..write('avisoKm: $avisoKm, ')
          ..write('avisoDias: $avisoDias, ')
          ..write('activo: $activo, ')
          ..write('silenciado: $silenciado, ')
          ..write('orden: $orden, ')
          ..write('fuenteIntervalo: $fuenteIntervalo, ')
          ..write('tipo: $tipo, ')
          ..write('posicion: $posicion, ')
          ..write('nombreAutogenerado: $nombreAutogenerado')
          ..write(')'))
        .toString();
  }
}

class $MaintenanceRecordsTable extends MaintenanceRecords
    with TableInfo<$MaintenanceRecordsTable, MaintenanceRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MaintenanceRecordsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _scheduleIdMeta = const VerificationMeta(
    'scheduleId',
  );
  @override
  late final GeneratedColumn<int> scheduleId = GeneratedColumn<int>(
    'schedule_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES maintenance_schedules (id) ON DELETE SET NULL',
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
  static const VerificationMeta _costeMeta = const VerificationMeta('coste');
  @override
  late final GeneratedColumn<double> coste = GeneratedColumn<double>(
    'coste',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tallerMeta = const VerificationMeta('taller');
  @override
  late final GeneratedColumn<String> taller = GeneratedColumn<String>(
    'taller',
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
  static const VerificationMeta _esSembradoMeta = const VerificationMeta(
    'esSembrado',
  );
  @override
  late final GeneratedColumn<bool> esSembrado = GeneratedColumn<bool>(
    'es_sembrado',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("es_sembrado" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  late final GeneratedColumnWithTypeConverter<MaintenanceOperationKind?, String>
  kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<MaintenanceOperationKind?>(
        $MaintenanceRecordsTable.$converterkindn,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    vehicleId,
    scheduleId,
    fecha,
    km,
    coste,
    taller,
    notas,
    esSembrado,
    kind,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'maintenance_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<MaintenanceRecord> instance, {
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
    if (data.containsKey('schedule_id')) {
      context.handle(
        _scheduleIdMeta,
        scheduleId.isAcceptableOrUnknown(data['schedule_id']!, _scheduleIdMeta),
      );
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
    if (data.containsKey('coste')) {
      context.handle(
        _costeMeta,
        coste.isAcceptableOrUnknown(data['coste']!, _costeMeta),
      );
    }
    if (data.containsKey('taller')) {
      context.handle(
        _tallerMeta,
        taller.isAcceptableOrUnknown(data['taller']!, _tallerMeta),
      );
    }
    if (data.containsKey('notas')) {
      context.handle(
        _notasMeta,
        notas.isAcceptableOrUnknown(data['notas']!, _notasMeta),
      );
    }
    if (data.containsKey('es_sembrado')) {
      context.handle(
        _esSembradoMeta,
        esSembrado.isAcceptableOrUnknown(data['es_sembrado']!, _esSembradoMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MaintenanceRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MaintenanceRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      vehicleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}vehicle_id'],
      )!,
      scheduleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}schedule_id'],
      ),
      fecha: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha'],
      )!,
      km: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}km'],
      )!,
      coste: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}coste'],
      ),
      taller: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}taller'],
      ),
      notas: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notas'],
      ),
      esSembrado: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}es_sembrado'],
      )!,
      kind: $MaintenanceRecordsTable.$converterkindn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        ),
      ),
    );
  }

  @override
  $MaintenanceRecordsTable createAlias(String alias) {
    return $MaintenanceRecordsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<MaintenanceOperationKind, String, String>
  $converterkind = const EnumNameConverter<MaintenanceOperationKind>(
    MaintenanceOperationKind.values,
  );
  static JsonTypeConverter2<MaintenanceOperationKind?, String?, String?>
  $converterkindn = JsonTypeConverter2.asNullable($converterkind);
}

class MaintenanceRecord extends DataClass
    implements Insertable<MaintenanceRecord> {
  final int id;
  final int vehicleId;

  /// Nulo en reparaciones puntuales que no responden a ningún mantenimiento
  /// configurado. Si se borra el mantenimiento, el registro sobrevive.
  final int? scheduleId;
  final DateTime fecha;
  final int km;
  final double? coste;
  final String? taller;
  final String? notas;

  /// Dato anterior a la instalación de la app, introducido a mano para
  /// poder calcular el primer vencimiento. Cuenta para los cálculos y se
  /// distingue en el historial.
  final bool esSembrado;

  /// Qué se hizo realmente esta vez: reparación, sustitución, inspección...
  /// Nulo en los registros ya guardados antes de que existiera este campo,
  /// y en cualquiera nuevo que no lo rellene. No se recalcula nunca a
  /// partir de `MaintenanceType.defaultKind`: es un valor fijado al
  /// guardar, no una vista sobre el catálogo.
  final MaintenanceOperationKind? kind;
  const MaintenanceRecord({
    required this.id,
    required this.vehicleId,
    this.scheduleId,
    required this.fecha,
    required this.km,
    this.coste,
    this.taller,
    this.notas,
    required this.esSembrado,
    this.kind,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['vehicle_id'] = Variable<int>(vehicleId);
    if (!nullToAbsent || scheduleId != null) {
      map['schedule_id'] = Variable<int>(scheduleId);
    }
    map['fecha'] = Variable<DateTime>(fecha);
    map['km'] = Variable<int>(km);
    if (!nullToAbsent || coste != null) {
      map['coste'] = Variable<double>(coste);
    }
    if (!nullToAbsent || taller != null) {
      map['taller'] = Variable<String>(taller);
    }
    if (!nullToAbsent || notas != null) {
      map['notas'] = Variable<String>(notas);
    }
    map['es_sembrado'] = Variable<bool>(esSembrado);
    if (!nullToAbsent || kind != null) {
      map['kind'] = Variable<String>(
        $MaintenanceRecordsTable.$converterkindn.toSql(kind),
      );
    }
    return map;
  }

  MaintenanceRecordsCompanion toCompanion(bool nullToAbsent) {
    return MaintenanceRecordsCompanion(
      id: Value(id),
      vehicleId: Value(vehicleId),
      scheduleId: scheduleId == null && nullToAbsent
          ? const Value.absent()
          : Value(scheduleId),
      fecha: Value(fecha),
      km: Value(km),
      coste: coste == null && nullToAbsent
          ? const Value.absent()
          : Value(coste),
      taller: taller == null && nullToAbsent
          ? const Value.absent()
          : Value(taller),
      notas: notas == null && nullToAbsent
          ? const Value.absent()
          : Value(notas),
      esSembrado: Value(esSembrado),
      kind: kind == null && nullToAbsent ? const Value.absent() : Value(kind),
    );
  }

  factory MaintenanceRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MaintenanceRecord(
      id: serializer.fromJson<int>(json['id']),
      vehicleId: serializer.fromJson<int>(json['vehicleId']),
      scheduleId: serializer.fromJson<int?>(json['scheduleId']),
      fecha: serializer.fromJson<DateTime>(json['fecha']),
      km: serializer.fromJson<int>(json['km']),
      coste: serializer.fromJson<double?>(json['coste']),
      taller: serializer.fromJson<String?>(json['taller']),
      notas: serializer.fromJson<String?>(json['notas']),
      esSembrado: serializer.fromJson<bool>(json['esSembrado']),
      kind: $MaintenanceRecordsTable.$converterkindn.fromJson(
        serializer.fromJson<String?>(json['kind']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'vehicleId': serializer.toJson<int>(vehicleId),
      'scheduleId': serializer.toJson<int?>(scheduleId),
      'fecha': serializer.toJson<DateTime>(fecha),
      'km': serializer.toJson<int>(km),
      'coste': serializer.toJson<double?>(coste),
      'taller': serializer.toJson<String?>(taller),
      'notas': serializer.toJson<String?>(notas),
      'esSembrado': serializer.toJson<bool>(esSembrado),
      'kind': serializer.toJson<String?>(
        $MaintenanceRecordsTable.$converterkindn.toJson(kind),
      ),
    };
  }

  MaintenanceRecord copyWith({
    int? id,
    int? vehicleId,
    Value<int?> scheduleId = const Value.absent(),
    DateTime? fecha,
    int? km,
    Value<double?> coste = const Value.absent(),
    Value<String?> taller = const Value.absent(),
    Value<String?> notas = const Value.absent(),
    bool? esSembrado,
    Value<MaintenanceOperationKind?> kind = const Value.absent(),
  }) => MaintenanceRecord(
    id: id ?? this.id,
    vehicleId: vehicleId ?? this.vehicleId,
    scheduleId: scheduleId.present ? scheduleId.value : this.scheduleId,
    fecha: fecha ?? this.fecha,
    km: km ?? this.km,
    coste: coste.present ? coste.value : this.coste,
    taller: taller.present ? taller.value : this.taller,
    notas: notas.present ? notas.value : this.notas,
    esSembrado: esSembrado ?? this.esSembrado,
    kind: kind.present ? kind.value : this.kind,
  );
  MaintenanceRecord copyWithCompanion(MaintenanceRecordsCompanion data) {
    return MaintenanceRecord(
      id: data.id.present ? data.id.value : this.id,
      vehicleId: data.vehicleId.present ? data.vehicleId.value : this.vehicleId,
      scheduleId: data.scheduleId.present
          ? data.scheduleId.value
          : this.scheduleId,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      km: data.km.present ? data.km.value : this.km,
      coste: data.coste.present ? data.coste.value : this.coste,
      taller: data.taller.present ? data.taller.value : this.taller,
      notas: data.notas.present ? data.notas.value : this.notas,
      esSembrado: data.esSembrado.present
          ? data.esSembrado.value
          : this.esSembrado,
      kind: data.kind.present ? data.kind.value : this.kind,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MaintenanceRecord(')
          ..write('id: $id, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('scheduleId: $scheduleId, ')
          ..write('fecha: $fecha, ')
          ..write('km: $km, ')
          ..write('coste: $coste, ')
          ..write('taller: $taller, ')
          ..write('notas: $notas, ')
          ..write('esSembrado: $esSembrado, ')
          ..write('kind: $kind')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    vehicleId,
    scheduleId,
    fecha,
    km,
    coste,
    taller,
    notas,
    esSembrado,
    kind,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MaintenanceRecord &&
          other.id == this.id &&
          other.vehicleId == this.vehicleId &&
          other.scheduleId == this.scheduleId &&
          other.fecha == this.fecha &&
          other.km == this.km &&
          other.coste == this.coste &&
          other.taller == this.taller &&
          other.notas == this.notas &&
          other.esSembrado == this.esSembrado &&
          other.kind == this.kind);
}

class MaintenanceRecordsCompanion extends UpdateCompanion<MaintenanceRecord> {
  final Value<int> id;
  final Value<int> vehicleId;
  final Value<int?> scheduleId;
  final Value<DateTime> fecha;
  final Value<int> km;
  final Value<double?> coste;
  final Value<String?> taller;
  final Value<String?> notas;
  final Value<bool> esSembrado;
  final Value<MaintenanceOperationKind?> kind;
  const MaintenanceRecordsCompanion({
    this.id = const Value.absent(),
    this.vehicleId = const Value.absent(),
    this.scheduleId = const Value.absent(),
    this.fecha = const Value.absent(),
    this.km = const Value.absent(),
    this.coste = const Value.absent(),
    this.taller = const Value.absent(),
    this.notas = const Value.absent(),
    this.esSembrado = const Value.absent(),
    this.kind = const Value.absent(),
  });
  MaintenanceRecordsCompanion.insert({
    this.id = const Value.absent(),
    required int vehicleId,
    this.scheduleId = const Value.absent(),
    required DateTime fecha,
    required int km,
    this.coste = const Value.absent(),
    this.taller = const Value.absent(),
    this.notas = const Value.absent(),
    this.esSembrado = const Value.absent(),
    this.kind = const Value.absent(),
  }) : vehicleId = Value(vehicleId),
       fecha = Value(fecha),
       km = Value(km);
  static Insertable<MaintenanceRecord> custom({
    Expression<int>? id,
    Expression<int>? vehicleId,
    Expression<int>? scheduleId,
    Expression<DateTime>? fecha,
    Expression<int>? km,
    Expression<double>? coste,
    Expression<String>? taller,
    Expression<String>? notas,
    Expression<bool>? esSembrado,
    Expression<String>? kind,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (scheduleId != null) 'schedule_id': scheduleId,
      if (fecha != null) 'fecha': fecha,
      if (km != null) 'km': km,
      if (coste != null) 'coste': coste,
      if (taller != null) 'taller': taller,
      if (notas != null) 'notas': notas,
      if (esSembrado != null) 'es_sembrado': esSembrado,
      if (kind != null) 'kind': kind,
    });
  }

  MaintenanceRecordsCompanion copyWith({
    Value<int>? id,
    Value<int>? vehicleId,
    Value<int?>? scheduleId,
    Value<DateTime>? fecha,
    Value<int>? km,
    Value<double?>? coste,
    Value<String?>? taller,
    Value<String?>? notas,
    Value<bool>? esSembrado,
    Value<MaintenanceOperationKind?>? kind,
  }) {
    return MaintenanceRecordsCompanion(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      scheduleId: scheduleId ?? this.scheduleId,
      fecha: fecha ?? this.fecha,
      km: km ?? this.km,
      coste: coste ?? this.coste,
      taller: taller ?? this.taller,
      notas: notas ?? this.notas,
      esSembrado: esSembrado ?? this.esSembrado,
      kind: kind ?? this.kind,
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
    if (scheduleId.present) {
      map['schedule_id'] = Variable<int>(scheduleId.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<DateTime>(fecha.value);
    }
    if (km.present) {
      map['km'] = Variable<int>(km.value);
    }
    if (coste.present) {
      map['coste'] = Variable<double>(coste.value);
    }
    if (taller.present) {
      map['taller'] = Variable<String>(taller.value);
    }
    if (notas.present) {
      map['notas'] = Variable<String>(notas.value);
    }
    if (esSembrado.present) {
      map['es_sembrado'] = Variable<bool>(esSembrado.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $MaintenanceRecordsTable.$converterkindn.toSql(kind.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MaintenanceRecordsCompanion(')
          ..write('id: $id, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('scheduleId: $scheduleId, ')
          ..write('fecha: $fecha, ')
          ..write('km: $km, ')
          ..write('coste: $coste, ')
          ..write('taller: $taller, ')
          ..write('notas: $notas, ')
          ..write('esSembrado: $esSembrado, ')
          ..write('kind: $kind')
          ..write(')'))
        .toString();
  }
}

class $VehicleSpecificationsTable extends VehicleSpecifications
    with TableInfo<$VehicleSpecificationsTable, VehicleSpecification> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VehicleSpecificationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _vehicleIdMeta = const VerificationMeta(
    'vehicleId',
  );
  @override
  late final GeneratedColumn<int> vehicleId = GeneratedColumn<int>(
    'vehicle_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES vehicles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _generacionMeta = const VerificationMeta(
    'generacion',
  );
  @override
  late final GeneratedColumn<String> generacion = GeneratedColumn<String>(
    'generacion',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _motorCodigoMeta = const VerificationMeta(
    'motorCodigo',
  );
  @override
  late final GeneratedColumn<String> motorCodigo = GeneratedColumn<String>(
    'motor_codigo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cilindradaCcMeta = const VerificationMeta(
    'cilindradaCc',
  );
  @override
  late final GeneratedColumn<int> cilindradaCc = GeneratedColumn<int>(
    'cilindrada_cc',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _potenciaKwMeta = const VerificationMeta(
    'potenciaKw',
  );
  @override
  late final GeneratedColumn<int> potenciaKw = GeneratedColumn<int>(
    'potencia_kw',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TipoCaja?, String> tipoCaja =
      GeneratedColumn<String>(
        'tipo_caja',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<TipoCaja?>(
        $VehicleSpecificationsTable.$convertertipoCajan,
      );
  static const VerificationMeta _numeroMarchasMeta = const VerificationMeta(
    'numeroMarchas',
  );
  @override
  late final GeneratedColumn<int> numeroMarchas = GeneratedColumn<int>(
    'numero_marchas',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Traccion?, String> traccion =
      GeneratedColumn<String>(
        'traccion',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Traccion?>(
        $VehicleSpecificationsTable.$convertertraccionn,
      );
  static const VerificationMeta _codigoTecnicoMeta = const VerificationMeta(
    'codigoTecnico',
  );
  @override
  late final GeneratedColumn<String> codigoTecnico = GeneratedColumn<String>(
    'codigo_tecnico',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notasTecnicasMeta = const VerificationMeta(
    'notasTecnicas',
  );
  @override
  late final GeneratedColumn<String> notasTecnicas = GeneratedColumn<String>(
    'notas_tecnicas',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    vehicleId,
    generacion,
    motorCodigo,
    cilindradaCc,
    potenciaKw,
    tipoCaja,
    numeroMarchas,
    traccion,
    codigoTecnico,
    notasTecnicas,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vehicle_specifications';
  @override
  VerificationContext validateIntegrity(
    Insertable<VehicleSpecification> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('vehicle_id')) {
      context.handle(
        _vehicleIdMeta,
        vehicleId.isAcceptableOrUnknown(data['vehicle_id']!, _vehicleIdMeta),
      );
    }
    if (data.containsKey('generacion')) {
      context.handle(
        _generacionMeta,
        generacion.isAcceptableOrUnknown(data['generacion']!, _generacionMeta),
      );
    }
    if (data.containsKey('motor_codigo')) {
      context.handle(
        _motorCodigoMeta,
        motorCodigo.isAcceptableOrUnknown(
          data['motor_codigo']!,
          _motorCodigoMeta,
        ),
      );
    }
    if (data.containsKey('cilindrada_cc')) {
      context.handle(
        _cilindradaCcMeta,
        cilindradaCc.isAcceptableOrUnknown(
          data['cilindrada_cc']!,
          _cilindradaCcMeta,
        ),
      );
    }
    if (data.containsKey('potencia_kw')) {
      context.handle(
        _potenciaKwMeta,
        potenciaKw.isAcceptableOrUnknown(data['potencia_kw']!, _potenciaKwMeta),
      );
    }
    if (data.containsKey('numero_marchas')) {
      context.handle(
        _numeroMarchasMeta,
        numeroMarchas.isAcceptableOrUnknown(
          data['numero_marchas']!,
          _numeroMarchasMeta,
        ),
      );
    }
    if (data.containsKey('codigo_tecnico')) {
      context.handle(
        _codigoTecnicoMeta,
        codigoTecnico.isAcceptableOrUnknown(
          data['codigo_tecnico']!,
          _codigoTecnicoMeta,
        ),
      );
    }
    if (data.containsKey('notas_tecnicas')) {
      context.handle(
        _notasTecnicasMeta,
        notasTecnicas.isAcceptableOrUnknown(
          data['notas_tecnicas']!,
          _notasTecnicasMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {vehicleId};
  @override
  VehicleSpecification map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VehicleSpecification(
      vehicleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}vehicle_id'],
      )!,
      generacion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}generacion'],
      ),
      motorCodigo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}motor_codigo'],
      ),
      cilindradaCc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cilindrada_cc'],
      ),
      potenciaKw: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}potencia_kw'],
      ),
      tipoCaja: $VehicleSpecificationsTable.$convertertipoCajan.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}tipo_caja'],
        ),
      ),
      numeroMarchas: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}numero_marchas'],
      ),
      traccion: $VehicleSpecificationsTable.$convertertraccionn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}traccion'],
        ),
      ),
      codigoTecnico: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}codigo_tecnico'],
      ),
      notasTecnicas: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notas_tecnicas'],
      ),
    );
  }

  @override
  $VehicleSpecificationsTable createAlias(String alias) {
    return $VehicleSpecificationsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TipoCaja, String, String> $convertertipoCaja =
      const EnumNameConverter<TipoCaja>(TipoCaja.values);
  static JsonTypeConverter2<TipoCaja?, String?, String?> $convertertipoCajan =
      JsonTypeConverter2.asNullable($convertertipoCaja);
  static JsonTypeConverter2<Traccion, String, String> $convertertraccion =
      const EnumNameConverter<Traccion>(Traccion.values);
  static JsonTypeConverter2<Traccion?, String?, String?> $convertertraccionn =
      JsonTypeConverter2.asNullable($convertertraccion);
}

class VehicleSpecification extends DataClass
    implements Insertable<VehicleSpecification> {
  final int vehicleId;
  final String? generacion;
  final String? motorCodigo;
  final int? cilindradaCc;

  /// Siempre en kilovatios, como en la ficha técnica oficial. El CV se
  /// calcula al mostrarlo (ver `lib/domain/potencia.dart`) y nunca se
  /// guarda aquí.
  final int? potenciaKw;
  final TipoCaja? tipoCaja;
  final int? numeroMarchas;
  final Traccion? traccion;

  /// Identificador de variante de un catálogo externo (p. ej. el KType de
  /// TecDoc). Nunca se rellena a mano: solo lo resolverá un catálogo, si
  /// alguna vez existe. Sin UI en esta fase.
  final String? codigoTecnico;
  final String? notasTecnicas;
  const VehicleSpecification({
    required this.vehicleId,
    this.generacion,
    this.motorCodigo,
    this.cilindradaCc,
    this.potenciaKw,
    this.tipoCaja,
    this.numeroMarchas,
    this.traccion,
    this.codigoTecnico,
    this.notasTecnicas,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['vehicle_id'] = Variable<int>(vehicleId);
    if (!nullToAbsent || generacion != null) {
      map['generacion'] = Variable<String>(generacion);
    }
    if (!nullToAbsent || motorCodigo != null) {
      map['motor_codigo'] = Variable<String>(motorCodigo);
    }
    if (!nullToAbsent || cilindradaCc != null) {
      map['cilindrada_cc'] = Variable<int>(cilindradaCc);
    }
    if (!nullToAbsent || potenciaKw != null) {
      map['potencia_kw'] = Variable<int>(potenciaKw);
    }
    if (!nullToAbsent || tipoCaja != null) {
      map['tipo_caja'] = Variable<String>(
        $VehicleSpecificationsTable.$convertertipoCajan.toSql(tipoCaja),
      );
    }
    if (!nullToAbsent || numeroMarchas != null) {
      map['numero_marchas'] = Variable<int>(numeroMarchas);
    }
    if (!nullToAbsent || traccion != null) {
      map['traccion'] = Variable<String>(
        $VehicleSpecificationsTable.$convertertraccionn.toSql(traccion),
      );
    }
    if (!nullToAbsent || codigoTecnico != null) {
      map['codigo_tecnico'] = Variable<String>(codigoTecnico);
    }
    if (!nullToAbsent || notasTecnicas != null) {
      map['notas_tecnicas'] = Variable<String>(notasTecnicas);
    }
    return map;
  }

  VehicleSpecificationsCompanion toCompanion(bool nullToAbsent) {
    return VehicleSpecificationsCompanion(
      vehicleId: Value(vehicleId),
      generacion: generacion == null && nullToAbsent
          ? const Value.absent()
          : Value(generacion),
      motorCodigo: motorCodigo == null && nullToAbsent
          ? const Value.absent()
          : Value(motorCodigo),
      cilindradaCc: cilindradaCc == null && nullToAbsent
          ? const Value.absent()
          : Value(cilindradaCc),
      potenciaKw: potenciaKw == null && nullToAbsent
          ? const Value.absent()
          : Value(potenciaKw),
      tipoCaja: tipoCaja == null && nullToAbsent
          ? const Value.absent()
          : Value(tipoCaja),
      numeroMarchas: numeroMarchas == null && nullToAbsent
          ? const Value.absent()
          : Value(numeroMarchas),
      traccion: traccion == null && nullToAbsent
          ? const Value.absent()
          : Value(traccion),
      codigoTecnico: codigoTecnico == null && nullToAbsent
          ? const Value.absent()
          : Value(codigoTecnico),
      notasTecnicas: notasTecnicas == null && nullToAbsent
          ? const Value.absent()
          : Value(notasTecnicas),
    );
  }

  factory VehicleSpecification.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VehicleSpecification(
      vehicleId: serializer.fromJson<int>(json['vehicleId']),
      generacion: serializer.fromJson<String?>(json['generacion']),
      motorCodigo: serializer.fromJson<String?>(json['motorCodigo']),
      cilindradaCc: serializer.fromJson<int?>(json['cilindradaCc']),
      potenciaKw: serializer.fromJson<int?>(json['potenciaKw']),
      tipoCaja: $VehicleSpecificationsTable.$convertertipoCajan.fromJson(
        serializer.fromJson<String?>(json['tipoCaja']),
      ),
      numeroMarchas: serializer.fromJson<int?>(json['numeroMarchas']),
      traccion: $VehicleSpecificationsTable.$convertertraccionn.fromJson(
        serializer.fromJson<String?>(json['traccion']),
      ),
      codigoTecnico: serializer.fromJson<String?>(json['codigoTecnico']),
      notasTecnicas: serializer.fromJson<String?>(json['notasTecnicas']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'vehicleId': serializer.toJson<int>(vehicleId),
      'generacion': serializer.toJson<String?>(generacion),
      'motorCodigo': serializer.toJson<String?>(motorCodigo),
      'cilindradaCc': serializer.toJson<int?>(cilindradaCc),
      'potenciaKw': serializer.toJson<int?>(potenciaKw),
      'tipoCaja': serializer.toJson<String?>(
        $VehicleSpecificationsTable.$convertertipoCajan.toJson(tipoCaja),
      ),
      'numeroMarchas': serializer.toJson<int?>(numeroMarchas),
      'traccion': serializer.toJson<String?>(
        $VehicleSpecificationsTable.$convertertraccionn.toJson(traccion),
      ),
      'codigoTecnico': serializer.toJson<String?>(codigoTecnico),
      'notasTecnicas': serializer.toJson<String?>(notasTecnicas),
    };
  }

  VehicleSpecification copyWith({
    int? vehicleId,
    Value<String?> generacion = const Value.absent(),
    Value<String?> motorCodigo = const Value.absent(),
    Value<int?> cilindradaCc = const Value.absent(),
    Value<int?> potenciaKw = const Value.absent(),
    Value<TipoCaja?> tipoCaja = const Value.absent(),
    Value<int?> numeroMarchas = const Value.absent(),
    Value<Traccion?> traccion = const Value.absent(),
    Value<String?> codigoTecnico = const Value.absent(),
    Value<String?> notasTecnicas = const Value.absent(),
  }) => VehicleSpecification(
    vehicleId: vehicleId ?? this.vehicleId,
    generacion: generacion.present ? generacion.value : this.generacion,
    motorCodigo: motorCodigo.present ? motorCodigo.value : this.motorCodigo,
    cilindradaCc: cilindradaCc.present ? cilindradaCc.value : this.cilindradaCc,
    potenciaKw: potenciaKw.present ? potenciaKw.value : this.potenciaKw,
    tipoCaja: tipoCaja.present ? tipoCaja.value : this.tipoCaja,
    numeroMarchas: numeroMarchas.present
        ? numeroMarchas.value
        : this.numeroMarchas,
    traccion: traccion.present ? traccion.value : this.traccion,
    codigoTecnico: codigoTecnico.present
        ? codigoTecnico.value
        : this.codigoTecnico,
    notasTecnicas: notasTecnicas.present
        ? notasTecnicas.value
        : this.notasTecnicas,
  );
  VehicleSpecification copyWithCompanion(VehicleSpecificationsCompanion data) {
    return VehicleSpecification(
      vehicleId: data.vehicleId.present ? data.vehicleId.value : this.vehicleId,
      generacion: data.generacion.present
          ? data.generacion.value
          : this.generacion,
      motorCodigo: data.motorCodigo.present
          ? data.motorCodigo.value
          : this.motorCodigo,
      cilindradaCc: data.cilindradaCc.present
          ? data.cilindradaCc.value
          : this.cilindradaCc,
      potenciaKw: data.potenciaKw.present
          ? data.potenciaKw.value
          : this.potenciaKw,
      tipoCaja: data.tipoCaja.present ? data.tipoCaja.value : this.tipoCaja,
      numeroMarchas: data.numeroMarchas.present
          ? data.numeroMarchas.value
          : this.numeroMarchas,
      traccion: data.traccion.present ? data.traccion.value : this.traccion,
      codigoTecnico: data.codigoTecnico.present
          ? data.codigoTecnico.value
          : this.codigoTecnico,
      notasTecnicas: data.notasTecnicas.present
          ? data.notasTecnicas.value
          : this.notasTecnicas,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VehicleSpecification(')
          ..write('vehicleId: $vehicleId, ')
          ..write('generacion: $generacion, ')
          ..write('motorCodigo: $motorCodigo, ')
          ..write('cilindradaCc: $cilindradaCc, ')
          ..write('potenciaKw: $potenciaKw, ')
          ..write('tipoCaja: $tipoCaja, ')
          ..write('numeroMarchas: $numeroMarchas, ')
          ..write('traccion: $traccion, ')
          ..write('codigoTecnico: $codigoTecnico, ')
          ..write('notasTecnicas: $notasTecnicas')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    vehicleId,
    generacion,
    motorCodigo,
    cilindradaCc,
    potenciaKw,
    tipoCaja,
    numeroMarchas,
    traccion,
    codigoTecnico,
    notasTecnicas,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VehicleSpecification &&
          other.vehicleId == this.vehicleId &&
          other.generacion == this.generacion &&
          other.motorCodigo == this.motorCodigo &&
          other.cilindradaCc == this.cilindradaCc &&
          other.potenciaKw == this.potenciaKw &&
          other.tipoCaja == this.tipoCaja &&
          other.numeroMarchas == this.numeroMarchas &&
          other.traccion == this.traccion &&
          other.codigoTecnico == this.codigoTecnico &&
          other.notasTecnicas == this.notasTecnicas);
}

class VehicleSpecificationsCompanion
    extends UpdateCompanion<VehicleSpecification> {
  final Value<int> vehicleId;
  final Value<String?> generacion;
  final Value<String?> motorCodigo;
  final Value<int?> cilindradaCc;
  final Value<int?> potenciaKw;
  final Value<TipoCaja?> tipoCaja;
  final Value<int?> numeroMarchas;
  final Value<Traccion?> traccion;
  final Value<String?> codigoTecnico;
  final Value<String?> notasTecnicas;
  const VehicleSpecificationsCompanion({
    this.vehicleId = const Value.absent(),
    this.generacion = const Value.absent(),
    this.motorCodigo = const Value.absent(),
    this.cilindradaCc = const Value.absent(),
    this.potenciaKw = const Value.absent(),
    this.tipoCaja = const Value.absent(),
    this.numeroMarchas = const Value.absent(),
    this.traccion = const Value.absent(),
    this.codigoTecnico = const Value.absent(),
    this.notasTecnicas = const Value.absent(),
  });
  VehicleSpecificationsCompanion.insert({
    this.vehicleId = const Value.absent(),
    this.generacion = const Value.absent(),
    this.motorCodigo = const Value.absent(),
    this.cilindradaCc = const Value.absent(),
    this.potenciaKw = const Value.absent(),
    this.tipoCaja = const Value.absent(),
    this.numeroMarchas = const Value.absent(),
    this.traccion = const Value.absent(),
    this.codigoTecnico = const Value.absent(),
    this.notasTecnicas = const Value.absent(),
  });
  static Insertable<VehicleSpecification> custom({
    Expression<int>? vehicleId,
    Expression<String>? generacion,
    Expression<String>? motorCodigo,
    Expression<int>? cilindradaCc,
    Expression<int>? potenciaKw,
    Expression<String>? tipoCaja,
    Expression<int>? numeroMarchas,
    Expression<String>? traccion,
    Expression<String>? codigoTecnico,
    Expression<String>? notasTecnicas,
  }) {
    return RawValuesInsertable({
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (generacion != null) 'generacion': generacion,
      if (motorCodigo != null) 'motor_codigo': motorCodigo,
      if (cilindradaCc != null) 'cilindrada_cc': cilindradaCc,
      if (potenciaKw != null) 'potencia_kw': potenciaKw,
      if (tipoCaja != null) 'tipo_caja': tipoCaja,
      if (numeroMarchas != null) 'numero_marchas': numeroMarchas,
      if (traccion != null) 'traccion': traccion,
      if (codigoTecnico != null) 'codigo_tecnico': codigoTecnico,
      if (notasTecnicas != null) 'notas_tecnicas': notasTecnicas,
    });
  }

  VehicleSpecificationsCompanion copyWith({
    Value<int>? vehicleId,
    Value<String?>? generacion,
    Value<String?>? motorCodigo,
    Value<int?>? cilindradaCc,
    Value<int?>? potenciaKw,
    Value<TipoCaja?>? tipoCaja,
    Value<int?>? numeroMarchas,
    Value<Traccion?>? traccion,
    Value<String?>? codigoTecnico,
    Value<String?>? notasTecnicas,
  }) {
    return VehicleSpecificationsCompanion(
      vehicleId: vehicleId ?? this.vehicleId,
      generacion: generacion ?? this.generacion,
      motorCodigo: motorCodigo ?? this.motorCodigo,
      cilindradaCc: cilindradaCc ?? this.cilindradaCc,
      potenciaKw: potenciaKw ?? this.potenciaKw,
      tipoCaja: tipoCaja ?? this.tipoCaja,
      numeroMarchas: numeroMarchas ?? this.numeroMarchas,
      traccion: traccion ?? this.traccion,
      codigoTecnico: codigoTecnico ?? this.codigoTecnico,
      notasTecnicas: notasTecnicas ?? this.notasTecnicas,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (vehicleId.present) {
      map['vehicle_id'] = Variable<int>(vehicleId.value);
    }
    if (generacion.present) {
      map['generacion'] = Variable<String>(generacion.value);
    }
    if (motorCodigo.present) {
      map['motor_codigo'] = Variable<String>(motorCodigo.value);
    }
    if (cilindradaCc.present) {
      map['cilindrada_cc'] = Variable<int>(cilindradaCc.value);
    }
    if (potenciaKw.present) {
      map['potencia_kw'] = Variable<int>(potenciaKw.value);
    }
    if (tipoCaja.present) {
      map['tipo_caja'] = Variable<String>(
        $VehicleSpecificationsTable.$convertertipoCajan.toSql(tipoCaja.value),
      );
    }
    if (numeroMarchas.present) {
      map['numero_marchas'] = Variable<int>(numeroMarchas.value);
    }
    if (traccion.present) {
      map['traccion'] = Variable<String>(
        $VehicleSpecificationsTable.$convertertraccionn.toSql(traccion.value),
      );
    }
    if (codigoTecnico.present) {
      map['codigo_tecnico'] = Variable<String>(codigoTecnico.value);
    }
    if (notasTecnicas.present) {
      map['notas_tecnicas'] = Variable<String>(notasTecnicas.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VehicleSpecificationsCompanion(')
          ..write('vehicleId: $vehicleId, ')
          ..write('generacion: $generacion, ')
          ..write('motorCodigo: $motorCodigo, ')
          ..write('cilindradaCc: $cilindradaCc, ')
          ..write('potenciaKw: $potenciaKw, ')
          ..write('tipoCaja: $tipoCaja, ')
          ..write('numeroMarchas: $numeroMarchas, ')
          ..write('traccion: $traccion, ')
          ..write('codigoTecnico: $codigoTecnico, ')
          ..write('notasTecnicas: $notasTecnicas')
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
  late final $MaintenanceSchedulesTable maintenanceSchedules =
      $MaintenanceSchedulesTable(this);
  late final $MaintenanceRecordsTable maintenanceRecords =
      $MaintenanceRecordsTable(this);
  late final $VehicleSpecificationsTable vehicleSpecifications =
      $VehicleSpecificationsTable(this);
  late final VehicleDao vehicleDao = VehicleDao(this as AppDatabase);
  late final MileageDao mileageDao = MileageDao(this as AppDatabase);
  late final MaintenanceDao maintenanceDao = MaintenanceDao(
    this as AppDatabase,
  );
  late final VehicleSpecificationDao vehicleSpecificationDao =
      VehicleSpecificationDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    vehicles,
    mileageReadings,
    settings,
    maintenanceSchedules,
    maintenanceRecords,
    vehicleSpecifications,
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
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'vehicles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('maintenance_schedules', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'vehicles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('maintenance_records', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'maintenance_schedules',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('maintenance_records', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'vehicles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('vehicle_specifications', kind: UpdateKind.delete)],
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
      Value<int?> colorValor,
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
      Value<int?> colorValor,
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

  static MultiTypedResultKey<
    $MaintenanceSchedulesTable,
    List<MaintenanceSchedule>
  >
  _maintenanceSchedulesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.maintenanceSchedules,
        aliasName: 'vehicles__id__maintenance_schedules__vehicle_id',
      );

  $$MaintenanceSchedulesTableProcessedTableManager
  get maintenanceSchedulesRefs {
    final manager = $$MaintenanceSchedulesTableTableManager(
      $_db,
      $_db.maintenanceSchedules,
    ).filter((f) => f.vehicleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _maintenanceSchedulesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MaintenanceRecordsTable, List<MaintenanceRecord>>
  _maintenanceRecordsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.maintenanceRecords,
        aliasName: 'vehicles__id__maintenance_records__vehicle_id',
      );

  $$MaintenanceRecordsTableProcessedTableManager get maintenanceRecordsRefs {
    final manager = $$MaintenanceRecordsTableTableManager(
      $_db,
      $_db.maintenanceRecords,
    ).filter((f) => f.vehicleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _maintenanceRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $VehicleSpecificationsTable,
    List<VehicleSpecification>
  >
  _vehicleSpecificationsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.vehicleSpecifications,
        aliasName: 'vehicles__id__vehicle_specifications__vehicle_id',
      );

  $$VehicleSpecificationsTableProcessedTableManager
  get vehicleSpecificationsRefs {
    final manager = $$VehicleSpecificationsTableTableManager(
      $_db,
      $_db.vehicleSpecifications,
    ).filter((f) => f.vehicleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _vehicleSpecificationsRefsTable($_db),
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

  ColumnFilters<int> get colorValor => $composableBuilder(
    column: $table.colorValor,
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

  Expression<bool> maintenanceSchedulesRefs(
    Expression<bool> Function($$MaintenanceSchedulesTableFilterComposer f) f,
  ) {
    final $$MaintenanceSchedulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.maintenanceSchedules,
      getReferencedColumn: (t) => t.vehicleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MaintenanceSchedulesTableFilterComposer(
            $db: $db,
            $table: $db.maintenanceSchedules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> maintenanceRecordsRefs(
    Expression<bool> Function($$MaintenanceRecordsTableFilterComposer f) f,
  ) {
    final $$MaintenanceRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.maintenanceRecords,
      getReferencedColumn: (t) => t.vehicleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MaintenanceRecordsTableFilterComposer(
            $db: $db,
            $table: $db.maintenanceRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> vehicleSpecificationsRefs(
    Expression<bool> Function($$VehicleSpecificationsTableFilterComposer f) f,
  ) {
    final $$VehicleSpecificationsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.vehicleSpecifications,
          getReferencedColumn: (t) => t.vehicleId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$VehicleSpecificationsTableFilterComposer(
                $db: $db,
                $table: $db.vehicleSpecifications,
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

  ColumnOrderings<int> get colorValor => $composableBuilder(
    column: $table.colorValor,
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

  GeneratedColumn<int> get colorValor => $composableBuilder(
    column: $table.colorValor,
    builder: (column) => column,
  );

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

  Expression<T> maintenanceSchedulesRefs<T extends Object>(
    Expression<T> Function($$MaintenanceSchedulesTableAnnotationComposer a) f,
  ) {
    final $$MaintenanceSchedulesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.maintenanceSchedules,
          getReferencedColumn: (t) => t.vehicleId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MaintenanceSchedulesTableAnnotationComposer(
                $db: $db,
                $table: $db.maintenanceSchedules,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> maintenanceRecordsRefs<T extends Object>(
    Expression<T> Function($$MaintenanceRecordsTableAnnotationComposer a) f,
  ) {
    final $$MaintenanceRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.maintenanceRecords,
          getReferencedColumn: (t) => t.vehicleId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MaintenanceRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.maintenanceRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> vehicleSpecificationsRefs<T extends Object>(
    Expression<T> Function($$VehicleSpecificationsTableAnnotationComposer a) f,
  ) {
    final $$VehicleSpecificationsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.vehicleSpecifications,
          getReferencedColumn: (t) => t.vehicleId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$VehicleSpecificationsTableAnnotationComposer(
                $db: $db,
                $table: $db.vehicleSpecifications,
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
          PrefetchHooks Function({
            bool mileageReadingsRefs,
            bool maintenanceSchedulesRefs,
            bool maintenanceRecordsRefs,
            bool vehicleSpecificationsRefs,
          })
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
                Value<int?> colorValor = const Value.absent(),
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
                colorValor: colorValor,
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
                Value<int?> colorValor = const Value.absent(),
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
                colorValor: colorValor,
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
          prefetchHooksCallback:
              ({
                mileageReadingsRefs = false,
                maintenanceSchedulesRefs = false,
                maintenanceRecordsRefs = false,
                vehicleSpecificationsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (mileageReadingsRefs) db.mileageReadings,
                    if (maintenanceSchedulesRefs) db.maintenanceSchedules,
                    if (maintenanceRecordsRefs) db.maintenanceRecords,
                    if (vehicleSpecificationsRefs) db.vehicleSpecifications,
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
                          managerFromTypedResult: (p0) =>
                              $$VehiclesTableReferences(
                                db,
                                table,
                                p0,
                              ).mileageReadingsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.vehicleId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (maintenanceSchedulesRefs)
                        await $_getPrefetchedData<
                          Vehicle,
                          $VehiclesTable,
                          MaintenanceSchedule
                        >(
                          currentTable: table,
                          referencedTable: $$VehiclesTableReferences
                              ._maintenanceSchedulesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VehiclesTableReferences(
                                db,
                                table,
                                p0,
                              ).maintenanceSchedulesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.vehicleId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (maintenanceRecordsRefs)
                        await $_getPrefetchedData<
                          Vehicle,
                          $VehiclesTable,
                          MaintenanceRecord
                        >(
                          currentTable: table,
                          referencedTable: $$VehiclesTableReferences
                              ._maintenanceRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VehiclesTableReferences(
                                db,
                                table,
                                p0,
                              ).maintenanceRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.vehicleId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (vehicleSpecificationsRefs)
                        await $_getPrefetchedData<
                          Vehicle,
                          $VehiclesTable,
                          VehicleSpecification
                        >(
                          currentTable: table,
                          referencedTable: $$VehiclesTableReferences
                              ._vehicleSpecificationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VehiclesTableReferences(
                                db,
                                table,
                                p0,
                              ).vehicleSpecificationsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.vehicleId == item.id,
                              ),
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
      PrefetchHooks Function({
        bool mileageReadingsRefs,
        bool maintenanceSchedulesRefs,
        bool maintenanceRecordsRefs,
        bool vehicleSpecificationsRefs,
      })
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
typedef $$MaintenanceSchedulesTableCreateCompanionBuilder =
    MaintenanceSchedulesCompanion Function({
      Value<int> id,
      required int vehicleId,
      required String nombre,
      required MaintenanceCategory categoria,
      Value<int?> intervalKm,
      Value<int?> intervalMeses,
      Value<int?> avisoKm,
      Value<int?> avisoDias,
      Value<bool> activo,
      Value<bool> silenciado,
      Value<int> orden,
      Value<FuenteIntervalo> fuenteIntervalo,
      Value<MaintenanceType?> tipo,
      Value<Posicion?> posicion,
      Value<bool> nombreAutogenerado,
    });
typedef $$MaintenanceSchedulesTableUpdateCompanionBuilder =
    MaintenanceSchedulesCompanion Function({
      Value<int> id,
      Value<int> vehicleId,
      Value<String> nombre,
      Value<MaintenanceCategory> categoria,
      Value<int?> intervalKm,
      Value<int?> intervalMeses,
      Value<int?> avisoKm,
      Value<int?> avisoDias,
      Value<bool> activo,
      Value<bool> silenciado,
      Value<int> orden,
      Value<FuenteIntervalo> fuenteIntervalo,
      Value<MaintenanceType?> tipo,
      Value<Posicion?> posicion,
      Value<bool> nombreAutogenerado,
    });

final class $$MaintenanceSchedulesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $MaintenanceSchedulesTable,
          MaintenanceSchedule
        > {
  $$MaintenanceSchedulesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $VehiclesTable _vehicleIdTable(_$AppDatabase db) => db.vehicles
      .createAlias('maintenance_schedules__vehicle_id__vehicles__id');

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

  static MultiTypedResultKey<$MaintenanceRecordsTable, List<MaintenanceRecord>>
  _maintenanceRecordsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.maintenanceRecords,
        aliasName:
            'maintenance_schedules__id__maintenance_records__schedule_id',
      );

  $$MaintenanceRecordsTableProcessedTableManager get maintenanceRecordsRefs {
    final manager = $$MaintenanceRecordsTableTableManager(
      $_db,
      $_db.maintenanceRecords,
    ).filter((f) => f.scheduleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _maintenanceRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MaintenanceSchedulesTableFilterComposer
    extends Composer<_$AppDatabase, $MaintenanceSchedulesTable> {
  $$MaintenanceSchedulesTableFilterComposer({
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

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    MaintenanceCategory,
    MaintenanceCategory,
    String
  >
  get categoria => $composableBuilder(
    column: $table.categoria,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get intervalKm => $composableBuilder(
    column: $table.intervalKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intervalMeses => $composableBuilder(
    column: $table.intervalMeses,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get avisoKm => $composableBuilder(
    column: $table.avisoKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get avisoDias => $composableBuilder(
    column: $table.avisoDias,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get activo => $composableBuilder(
    column: $table.activo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get silenciado => $composableBuilder(
    column: $table.silenciado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orden => $composableBuilder(
    column: $table.orden,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<FuenteIntervalo, FuenteIntervalo, String>
  get fuenteIntervalo => $composableBuilder(
    column: $table.fuenteIntervalo,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<MaintenanceType?, MaintenanceType, String>
  get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<Posicion?, Posicion, String> get posicion =>
      $composableBuilder(
        column: $table.posicion,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<bool> get nombreAutogenerado => $composableBuilder(
    column: $table.nombreAutogenerado,
    builder: (column) => ColumnFilters(column),
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

  Expression<bool> maintenanceRecordsRefs(
    Expression<bool> Function($$MaintenanceRecordsTableFilterComposer f) f,
  ) {
    final $$MaintenanceRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.maintenanceRecords,
      getReferencedColumn: (t) => t.scheduleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MaintenanceRecordsTableFilterComposer(
            $db: $db,
            $table: $db.maintenanceRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MaintenanceSchedulesTableOrderingComposer
    extends Composer<_$AppDatabase, $MaintenanceSchedulesTable> {
  $$MaintenanceSchedulesTableOrderingComposer({
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

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoria => $composableBuilder(
    column: $table.categoria,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intervalKm => $composableBuilder(
    column: $table.intervalKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intervalMeses => $composableBuilder(
    column: $table.intervalMeses,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get avisoKm => $composableBuilder(
    column: $table.avisoKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get avisoDias => $composableBuilder(
    column: $table.avisoDias,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get activo => $composableBuilder(
    column: $table.activo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get silenciado => $composableBuilder(
    column: $table.silenciado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orden => $composableBuilder(
    column: $table.orden,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fuenteIntervalo => $composableBuilder(
    column: $table.fuenteIntervalo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get posicion => $composableBuilder(
    column: $table.posicion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get nombreAutogenerado => $composableBuilder(
    column: $table.nombreAutogenerado,
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

class $$MaintenanceSchedulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MaintenanceSchedulesTable> {
  $$MaintenanceSchedulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MaintenanceCategory, String> get categoria =>
      $composableBuilder(column: $table.categoria, builder: (column) => column);

  GeneratedColumn<int> get intervalKm => $composableBuilder(
    column: $table.intervalKm,
    builder: (column) => column,
  );

  GeneratedColumn<int> get intervalMeses => $composableBuilder(
    column: $table.intervalMeses,
    builder: (column) => column,
  );

  GeneratedColumn<int> get avisoKm =>
      $composableBuilder(column: $table.avisoKm, builder: (column) => column);

  GeneratedColumn<int> get avisoDias =>
      $composableBuilder(column: $table.avisoDias, builder: (column) => column);

  GeneratedColumn<bool> get activo =>
      $composableBuilder(column: $table.activo, builder: (column) => column);

  GeneratedColumn<bool> get silenciado => $composableBuilder(
    column: $table.silenciado,
    builder: (column) => column,
  );

  GeneratedColumn<int> get orden =>
      $composableBuilder(column: $table.orden, builder: (column) => column);

  GeneratedColumnWithTypeConverter<FuenteIntervalo, String>
  get fuenteIntervalo => $composableBuilder(
    column: $table.fuenteIntervalo,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<MaintenanceType?, String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Posicion?, String> get posicion =>
      $composableBuilder(column: $table.posicion, builder: (column) => column);

  GeneratedColumn<bool> get nombreAutogenerado => $composableBuilder(
    column: $table.nombreAutogenerado,
    builder: (column) => column,
  );

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

  Expression<T> maintenanceRecordsRefs<T extends Object>(
    Expression<T> Function($$MaintenanceRecordsTableAnnotationComposer a) f,
  ) {
    final $$MaintenanceRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.maintenanceRecords,
          getReferencedColumn: (t) => t.scheduleId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MaintenanceRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.maintenanceRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$MaintenanceSchedulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MaintenanceSchedulesTable,
          MaintenanceSchedule,
          $$MaintenanceSchedulesTableFilterComposer,
          $$MaintenanceSchedulesTableOrderingComposer,
          $$MaintenanceSchedulesTableAnnotationComposer,
          $$MaintenanceSchedulesTableCreateCompanionBuilder,
          $$MaintenanceSchedulesTableUpdateCompanionBuilder,
          (MaintenanceSchedule, $$MaintenanceSchedulesTableReferences),
          MaintenanceSchedule,
          PrefetchHooks Function({bool vehicleId, bool maintenanceRecordsRefs})
        > {
  $$MaintenanceSchedulesTableTableManager(
    _$AppDatabase db,
    $MaintenanceSchedulesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MaintenanceSchedulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MaintenanceSchedulesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$MaintenanceSchedulesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> vehicleId = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<MaintenanceCategory> categoria = const Value.absent(),
                Value<int?> intervalKm = const Value.absent(),
                Value<int?> intervalMeses = const Value.absent(),
                Value<int?> avisoKm = const Value.absent(),
                Value<int?> avisoDias = const Value.absent(),
                Value<bool> activo = const Value.absent(),
                Value<bool> silenciado = const Value.absent(),
                Value<int> orden = const Value.absent(),
                Value<FuenteIntervalo> fuenteIntervalo = const Value.absent(),
                Value<MaintenanceType?> tipo = const Value.absent(),
                Value<Posicion?> posicion = const Value.absent(),
                Value<bool> nombreAutogenerado = const Value.absent(),
              }) => MaintenanceSchedulesCompanion(
                id: id,
                vehicleId: vehicleId,
                nombre: nombre,
                categoria: categoria,
                intervalKm: intervalKm,
                intervalMeses: intervalMeses,
                avisoKm: avisoKm,
                avisoDias: avisoDias,
                activo: activo,
                silenciado: silenciado,
                orden: orden,
                fuenteIntervalo: fuenteIntervalo,
                tipo: tipo,
                posicion: posicion,
                nombreAutogenerado: nombreAutogenerado,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int vehicleId,
                required String nombre,
                required MaintenanceCategory categoria,
                Value<int?> intervalKm = const Value.absent(),
                Value<int?> intervalMeses = const Value.absent(),
                Value<int?> avisoKm = const Value.absent(),
                Value<int?> avisoDias = const Value.absent(),
                Value<bool> activo = const Value.absent(),
                Value<bool> silenciado = const Value.absent(),
                Value<int> orden = const Value.absent(),
                Value<FuenteIntervalo> fuenteIntervalo = const Value.absent(),
                Value<MaintenanceType?> tipo = const Value.absent(),
                Value<Posicion?> posicion = const Value.absent(),
                Value<bool> nombreAutogenerado = const Value.absent(),
              }) => MaintenanceSchedulesCompanion.insert(
                id: id,
                vehicleId: vehicleId,
                nombre: nombre,
                categoria: categoria,
                intervalKm: intervalKm,
                intervalMeses: intervalMeses,
                avisoKm: avisoKm,
                avisoDias: avisoDias,
                activo: activo,
                silenciado: silenciado,
                orden: orden,
                fuenteIntervalo: fuenteIntervalo,
                tipo: tipo,
                posicion: posicion,
                nombreAutogenerado: nombreAutogenerado,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MaintenanceSchedulesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({vehicleId = false, maintenanceRecordsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (maintenanceRecordsRefs) db.maintenanceRecords,
                  ],
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
                                        $$MaintenanceSchedulesTableReferences
                                            ._vehicleIdTable(db),
                                    referencedColumn:
                                        $$MaintenanceSchedulesTableReferences
                                            ._vehicleIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (maintenanceRecordsRefs)
                        await $_getPrefetchedData<
                          MaintenanceSchedule,
                          $MaintenanceSchedulesTable,
                          MaintenanceRecord
                        >(
                          currentTable: table,
                          referencedTable: $$MaintenanceSchedulesTableReferences
                              ._maintenanceRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MaintenanceSchedulesTableReferences(
                                db,
                                table,
                                p0,
                              ).maintenanceRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.scheduleId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$MaintenanceSchedulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MaintenanceSchedulesTable,
      MaintenanceSchedule,
      $$MaintenanceSchedulesTableFilterComposer,
      $$MaintenanceSchedulesTableOrderingComposer,
      $$MaintenanceSchedulesTableAnnotationComposer,
      $$MaintenanceSchedulesTableCreateCompanionBuilder,
      $$MaintenanceSchedulesTableUpdateCompanionBuilder,
      (MaintenanceSchedule, $$MaintenanceSchedulesTableReferences),
      MaintenanceSchedule,
      PrefetchHooks Function({bool vehicleId, bool maintenanceRecordsRefs})
    >;
typedef $$MaintenanceRecordsTableCreateCompanionBuilder =
    MaintenanceRecordsCompanion Function({
      Value<int> id,
      required int vehicleId,
      Value<int?> scheduleId,
      required DateTime fecha,
      required int km,
      Value<double?> coste,
      Value<String?> taller,
      Value<String?> notas,
      Value<bool> esSembrado,
      Value<MaintenanceOperationKind?> kind,
    });
typedef $$MaintenanceRecordsTableUpdateCompanionBuilder =
    MaintenanceRecordsCompanion Function({
      Value<int> id,
      Value<int> vehicleId,
      Value<int?> scheduleId,
      Value<DateTime> fecha,
      Value<int> km,
      Value<double?> coste,
      Value<String?> taller,
      Value<String?> notas,
      Value<bool> esSembrado,
      Value<MaintenanceOperationKind?> kind,
    });

final class $$MaintenanceRecordsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $MaintenanceRecordsTable,
          MaintenanceRecord
        > {
  $$MaintenanceRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $VehiclesTable _vehicleIdTable(_$AppDatabase db) =>
      db.vehicles.createAlias('maintenance_records__vehicle_id__vehicles__id');

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

  static $MaintenanceSchedulesTable _scheduleIdTable(_$AppDatabase db) =>
      db.maintenanceSchedules.createAlias(
        'maintenance_records__schedule_id__maintenance_schedules__id',
      );

  $$MaintenanceSchedulesTableProcessedTableManager? get scheduleId {
    final $_column = $_itemColumn<int>('schedule_id');
    if ($_column == null) return null;
    final manager = $$MaintenanceSchedulesTableTableManager(
      $_db,
      $_db.maintenanceSchedules,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_scheduleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MaintenanceRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $MaintenanceRecordsTable> {
  $$MaintenanceRecordsTableFilterComposer({
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

  ColumnFilters<double> get coste => $composableBuilder(
    column: $table.coste,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taller => $composableBuilder(
    column: $table.taller,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notas => $composableBuilder(
    column: $table.notas,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get esSembrado => $composableBuilder(
    column: $table.esSembrado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    MaintenanceOperationKind?,
    MaintenanceOperationKind,
    String
  >
  get kind => $composableBuilder(
    column: $table.kind,
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

  $$MaintenanceSchedulesTableFilterComposer get scheduleId {
    final $$MaintenanceSchedulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.scheduleId,
      referencedTable: $db.maintenanceSchedules,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MaintenanceSchedulesTableFilterComposer(
            $db: $db,
            $table: $db.maintenanceSchedules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MaintenanceRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $MaintenanceRecordsTable> {
  $$MaintenanceRecordsTableOrderingComposer({
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

  ColumnOrderings<double> get coste => $composableBuilder(
    column: $table.coste,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taller => $composableBuilder(
    column: $table.taller,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notas => $composableBuilder(
    column: $table.notas,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get esSembrado => $composableBuilder(
    column: $table.esSembrado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
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

  $$MaintenanceSchedulesTableOrderingComposer get scheduleId {
    final $$MaintenanceSchedulesTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.scheduleId,
          referencedTable: $db.maintenanceSchedules,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MaintenanceSchedulesTableOrderingComposer(
                $db: $db,
                $table: $db.maintenanceSchedules,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$MaintenanceRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MaintenanceRecordsTable> {
  $$MaintenanceRecordsTableAnnotationComposer({
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

  GeneratedColumn<double> get coste =>
      $composableBuilder(column: $table.coste, builder: (column) => column);

  GeneratedColumn<String> get taller =>
      $composableBuilder(column: $table.taller, builder: (column) => column);

  GeneratedColumn<String> get notas =>
      $composableBuilder(column: $table.notas, builder: (column) => column);

  GeneratedColumn<bool> get esSembrado => $composableBuilder(
    column: $table.esSembrado,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<MaintenanceOperationKind?, String>
  get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

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

  $$MaintenanceSchedulesTableAnnotationComposer get scheduleId {
    final $$MaintenanceSchedulesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.scheduleId,
          referencedTable: $db.maintenanceSchedules,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MaintenanceSchedulesTableAnnotationComposer(
                $db: $db,
                $table: $db.maintenanceSchedules,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$MaintenanceRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MaintenanceRecordsTable,
          MaintenanceRecord,
          $$MaintenanceRecordsTableFilterComposer,
          $$MaintenanceRecordsTableOrderingComposer,
          $$MaintenanceRecordsTableAnnotationComposer,
          $$MaintenanceRecordsTableCreateCompanionBuilder,
          $$MaintenanceRecordsTableUpdateCompanionBuilder,
          (MaintenanceRecord, $$MaintenanceRecordsTableReferences),
          MaintenanceRecord,
          PrefetchHooks Function({bool vehicleId, bool scheduleId})
        > {
  $$MaintenanceRecordsTableTableManager(
    _$AppDatabase db,
    $MaintenanceRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MaintenanceRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MaintenanceRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MaintenanceRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> vehicleId = const Value.absent(),
                Value<int?> scheduleId = const Value.absent(),
                Value<DateTime> fecha = const Value.absent(),
                Value<int> km = const Value.absent(),
                Value<double?> coste = const Value.absent(),
                Value<String?> taller = const Value.absent(),
                Value<String?> notas = const Value.absent(),
                Value<bool> esSembrado = const Value.absent(),
                Value<MaintenanceOperationKind?> kind = const Value.absent(),
              }) => MaintenanceRecordsCompanion(
                id: id,
                vehicleId: vehicleId,
                scheduleId: scheduleId,
                fecha: fecha,
                km: km,
                coste: coste,
                taller: taller,
                notas: notas,
                esSembrado: esSembrado,
                kind: kind,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int vehicleId,
                Value<int?> scheduleId = const Value.absent(),
                required DateTime fecha,
                required int km,
                Value<double?> coste = const Value.absent(),
                Value<String?> taller = const Value.absent(),
                Value<String?> notas = const Value.absent(),
                Value<bool> esSembrado = const Value.absent(),
                Value<MaintenanceOperationKind?> kind = const Value.absent(),
              }) => MaintenanceRecordsCompanion.insert(
                id: id,
                vehicleId: vehicleId,
                scheduleId: scheduleId,
                fecha: fecha,
                km: km,
                coste: coste,
                taller: taller,
                notas: notas,
                esSembrado: esSembrado,
                kind: kind,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MaintenanceRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({vehicleId = false, scheduleId = false}) {
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
                                    $$MaintenanceRecordsTableReferences
                                        ._vehicleIdTable(db),
                                referencedColumn:
                                    $$MaintenanceRecordsTableReferences
                                        ._vehicleIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (scheduleId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.scheduleId,
                                referencedTable:
                                    $$MaintenanceRecordsTableReferences
                                        ._scheduleIdTable(db),
                                referencedColumn:
                                    $$MaintenanceRecordsTableReferences
                                        ._scheduleIdTable(db)
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

typedef $$MaintenanceRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MaintenanceRecordsTable,
      MaintenanceRecord,
      $$MaintenanceRecordsTableFilterComposer,
      $$MaintenanceRecordsTableOrderingComposer,
      $$MaintenanceRecordsTableAnnotationComposer,
      $$MaintenanceRecordsTableCreateCompanionBuilder,
      $$MaintenanceRecordsTableUpdateCompanionBuilder,
      (MaintenanceRecord, $$MaintenanceRecordsTableReferences),
      MaintenanceRecord,
      PrefetchHooks Function({bool vehicleId, bool scheduleId})
    >;
typedef $$VehicleSpecificationsTableCreateCompanionBuilder =
    VehicleSpecificationsCompanion Function({
      Value<int> vehicleId,
      Value<String?> generacion,
      Value<String?> motorCodigo,
      Value<int?> cilindradaCc,
      Value<int?> potenciaKw,
      Value<TipoCaja?> tipoCaja,
      Value<int?> numeroMarchas,
      Value<Traccion?> traccion,
      Value<String?> codigoTecnico,
      Value<String?> notasTecnicas,
    });
typedef $$VehicleSpecificationsTableUpdateCompanionBuilder =
    VehicleSpecificationsCompanion Function({
      Value<int> vehicleId,
      Value<String?> generacion,
      Value<String?> motorCodigo,
      Value<int?> cilindradaCc,
      Value<int?> potenciaKw,
      Value<TipoCaja?> tipoCaja,
      Value<int?> numeroMarchas,
      Value<Traccion?> traccion,
      Value<String?> codigoTecnico,
      Value<String?> notasTecnicas,
    });

final class $$VehicleSpecificationsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $VehicleSpecificationsTable,
          VehicleSpecification
        > {
  $$VehicleSpecificationsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $VehiclesTable _vehicleIdTable(_$AppDatabase db) => db.vehicles
      .createAlias('vehicle_specifications__vehicle_id__vehicles__id');

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

class $$VehicleSpecificationsTableFilterComposer
    extends Composer<_$AppDatabase, $VehicleSpecificationsTable> {
  $$VehicleSpecificationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get generacion => $composableBuilder(
    column: $table.generacion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get motorCodigo => $composableBuilder(
    column: $table.motorCodigo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cilindradaCc => $composableBuilder(
    column: $table.cilindradaCc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get potenciaKw => $composableBuilder(
    column: $table.potenciaKw,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TipoCaja?, TipoCaja, String> get tipoCaja =>
      $composableBuilder(
        column: $table.tipoCaja,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get numeroMarchas => $composableBuilder(
    column: $table.numeroMarchas,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Traccion?, Traccion, String> get traccion =>
      $composableBuilder(
        column: $table.traccion,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get codigoTecnico => $composableBuilder(
    column: $table.codigoTecnico,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notasTecnicas => $composableBuilder(
    column: $table.notasTecnicas,
    builder: (column) => ColumnFilters(column),
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

class $$VehicleSpecificationsTableOrderingComposer
    extends Composer<_$AppDatabase, $VehicleSpecificationsTable> {
  $$VehicleSpecificationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get generacion => $composableBuilder(
    column: $table.generacion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get motorCodigo => $composableBuilder(
    column: $table.motorCodigo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cilindradaCc => $composableBuilder(
    column: $table.cilindradaCc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get potenciaKw => $composableBuilder(
    column: $table.potenciaKw,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipoCaja => $composableBuilder(
    column: $table.tipoCaja,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get numeroMarchas => $composableBuilder(
    column: $table.numeroMarchas,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get traccion => $composableBuilder(
    column: $table.traccion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get codigoTecnico => $composableBuilder(
    column: $table.codigoTecnico,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notasTecnicas => $composableBuilder(
    column: $table.notasTecnicas,
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

class $$VehicleSpecificationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $VehicleSpecificationsTable> {
  $$VehicleSpecificationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get generacion => $composableBuilder(
    column: $table.generacion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get motorCodigo => $composableBuilder(
    column: $table.motorCodigo,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cilindradaCc => $composableBuilder(
    column: $table.cilindradaCc,
    builder: (column) => column,
  );

  GeneratedColumn<int> get potenciaKw => $composableBuilder(
    column: $table.potenciaKw,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<TipoCaja?, String> get tipoCaja =>
      $composableBuilder(column: $table.tipoCaja, builder: (column) => column);

  GeneratedColumn<int> get numeroMarchas => $composableBuilder(
    column: $table.numeroMarchas,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Traccion?, String> get traccion =>
      $composableBuilder(column: $table.traccion, builder: (column) => column);

  GeneratedColumn<String> get codigoTecnico => $composableBuilder(
    column: $table.codigoTecnico,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notasTecnicas => $composableBuilder(
    column: $table.notasTecnicas,
    builder: (column) => column,
  );

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

class $$VehicleSpecificationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VehicleSpecificationsTable,
          VehicleSpecification,
          $$VehicleSpecificationsTableFilterComposer,
          $$VehicleSpecificationsTableOrderingComposer,
          $$VehicleSpecificationsTableAnnotationComposer,
          $$VehicleSpecificationsTableCreateCompanionBuilder,
          $$VehicleSpecificationsTableUpdateCompanionBuilder,
          (VehicleSpecification, $$VehicleSpecificationsTableReferences),
          VehicleSpecification,
          PrefetchHooks Function({bool vehicleId})
        > {
  $$VehicleSpecificationsTableTableManager(
    _$AppDatabase db,
    $VehicleSpecificationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VehicleSpecificationsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$VehicleSpecificationsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$VehicleSpecificationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> vehicleId = const Value.absent(),
                Value<String?> generacion = const Value.absent(),
                Value<String?> motorCodigo = const Value.absent(),
                Value<int?> cilindradaCc = const Value.absent(),
                Value<int?> potenciaKw = const Value.absent(),
                Value<TipoCaja?> tipoCaja = const Value.absent(),
                Value<int?> numeroMarchas = const Value.absent(),
                Value<Traccion?> traccion = const Value.absent(),
                Value<String?> codigoTecnico = const Value.absent(),
                Value<String?> notasTecnicas = const Value.absent(),
              }) => VehicleSpecificationsCompanion(
                vehicleId: vehicleId,
                generacion: generacion,
                motorCodigo: motorCodigo,
                cilindradaCc: cilindradaCc,
                potenciaKw: potenciaKw,
                tipoCaja: tipoCaja,
                numeroMarchas: numeroMarchas,
                traccion: traccion,
                codigoTecnico: codigoTecnico,
                notasTecnicas: notasTecnicas,
              ),
          createCompanionCallback:
              ({
                Value<int> vehicleId = const Value.absent(),
                Value<String?> generacion = const Value.absent(),
                Value<String?> motorCodigo = const Value.absent(),
                Value<int?> cilindradaCc = const Value.absent(),
                Value<int?> potenciaKw = const Value.absent(),
                Value<TipoCaja?> tipoCaja = const Value.absent(),
                Value<int?> numeroMarchas = const Value.absent(),
                Value<Traccion?> traccion = const Value.absent(),
                Value<String?> codigoTecnico = const Value.absent(),
                Value<String?> notasTecnicas = const Value.absent(),
              }) => VehicleSpecificationsCompanion.insert(
                vehicleId: vehicleId,
                generacion: generacion,
                motorCodigo: motorCodigo,
                cilindradaCc: cilindradaCc,
                potenciaKw: potenciaKw,
                tipoCaja: tipoCaja,
                numeroMarchas: numeroMarchas,
                traccion: traccion,
                codigoTecnico: codigoTecnico,
                notasTecnicas: notasTecnicas,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$VehicleSpecificationsTableReferences(db, table, e),
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
                                    $$VehicleSpecificationsTableReferences
                                        ._vehicleIdTable(db),
                                referencedColumn:
                                    $$VehicleSpecificationsTableReferences
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

typedef $$VehicleSpecificationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VehicleSpecificationsTable,
      VehicleSpecification,
      $$VehicleSpecificationsTableFilterComposer,
      $$VehicleSpecificationsTableOrderingComposer,
      $$VehicleSpecificationsTableAnnotationComposer,
      $$VehicleSpecificationsTableCreateCompanionBuilder,
      $$VehicleSpecificationsTableUpdateCompanionBuilder,
      (VehicleSpecification, $$VehicleSpecificationsTableReferences),
      VehicleSpecification,
      PrefetchHooks Function({bool vehicleId})
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
  $$MaintenanceSchedulesTableTableManager get maintenanceSchedules =>
      $$MaintenanceSchedulesTableTableManager(_db, _db.maintenanceSchedules);
  $$MaintenanceRecordsTableTableManager get maintenanceRecords =>
      $$MaintenanceRecordsTableTableManager(_db, _db.maintenanceRecords);
  $$VehicleSpecificationsTableTableManager get vehicleSpecifications =>
      $$VehicleSpecificationsTableTableManager(_db, _db.vehicleSpecifications);
}
