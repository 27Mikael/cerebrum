// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $EngramAttemptsTable extends EngramAttempts
    with TableInfo<$EngramAttemptsTable, EngramAttemptRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EngramAttemptsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _attemptIdMeta = const VerificationMeta(
    'attemptId',
  );
  @override
  late final GeneratedColumn<String> attemptId = GeneratedColumn<String>(
    'attempt_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _engramIdMeta = const VerificationMeta(
    'engramId',
  );
  @override
  late final GeneratedColumn<String> engramId = GeneratedColumn<String>(
    'engram_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetCognitiveLevelMeta =
      const VerificationMeta('targetCognitiveLevel');
  @override
  late final GeneratedColumn<int> targetCognitiveLevel = GeneratedColumn<int>(
    'target_cognitive_level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('queued'),
  );
  static const VerificationMeta _jobIdMeta = const VerificationMeta('jobId');
  @override
  late final GeneratedColumn<String> jobId = GeneratedColumn<String>(
    'job_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _resultJsonMeta = const VerificationMeta(
    'resultJson',
  );
  @override
  late final GeneratedColumn<String> resultJson = GeneratedColumn<String>(
    'result_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _errorMeta = const VerificationMeta('error');
  @override
  late final GeneratedColumn<String> error = GeneratedColumn<String>(
    'error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _seenMeta = const VerificationMeta('seen');
  @override
  late final GeneratedColumn<bool> seen = GeneratedColumn<bool>(
    'seen',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("seen" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    attemptId,
    engramId,
    type,
    userId,
    payloadJson,
    targetCognitiveLevel,
    status,
    jobId,
    resultJson,
    error,
    seen,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'engram_attempts';
  @override
  VerificationContext validateIntegrity(
    Insertable<EngramAttemptRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('attempt_id')) {
      context.handle(
        _attemptIdMeta,
        attemptId.isAcceptableOrUnknown(data['attempt_id']!, _attemptIdMeta),
      );
    } else if (isInserting) {
      context.missing(_attemptIdMeta);
    }
    if (data.containsKey('engram_id')) {
      context.handle(
        _engramIdMeta,
        engramId.isAcceptableOrUnknown(data['engram_id']!, _engramIdMeta),
      );
    } else if (isInserting) {
      context.missing(_engramIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('target_cognitive_level')) {
      context.handle(
        _targetCognitiveLevelMeta,
        targetCognitiveLevel.isAcceptableOrUnknown(
          data['target_cognitive_level']!,
          _targetCognitiveLevelMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('job_id')) {
      context.handle(
        _jobIdMeta,
        jobId.isAcceptableOrUnknown(data['job_id']!, _jobIdMeta),
      );
    }
    if (data.containsKey('result_json')) {
      context.handle(
        _resultJsonMeta,
        resultJson.isAcceptableOrUnknown(data['result_json']!, _resultJsonMeta),
      );
    }
    if (data.containsKey('error')) {
      context.handle(
        _errorMeta,
        error.isAcceptableOrUnknown(data['error']!, _errorMeta),
      );
    }
    if (data.containsKey('seen')) {
      context.handle(
        _seenMeta,
        seen.isAcceptableOrUnknown(data['seen']!, _seenMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {attemptId};
  @override
  EngramAttemptRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EngramAttemptRow(
      attemptId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}attempt_id'],
          )!,
      engramId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}engram_id'],
          )!,
      type:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}type'],
          )!,
      userId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}user_id'],
          )!,
      payloadJson:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}payload_json'],
          )!,
      targetCognitiveLevel:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}target_cognitive_level'],
          )!,
      status:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}status'],
          )!,
      jobId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}job_id'],
      ),
      resultJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}result_json'],
      ),
      error: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error'],
      ),
      seen:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}seen'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
    );
  }

  @override
  $EngramAttemptsTable createAlias(String alias) {
    return $EngramAttemptsTable(attachedDatabase, alias);
  }
}

class EngramAttemptRow extends DataClass
    implements Insertable<EngramAttemptRow> {
  final String attemptId;
  final String engramId;
  final String type;
  final String userId;
  final String payloadJson;
  final int targetCognitiveLevel;
  final String status;
  final String? jobId;
  final String? resultJson;
  final String? error;
  final bool seen;
  final DateTime createdAt;
  final DateTime updatedAt;
  const EngramAttemptRow({
    required this.attemptId,
    required this.engramId,
    required this.type,
    required this.userId,
    required this.payloadJson,
    required this.targetCognitiveLevel,
    required this.status,
    this.jobId,
    this.resultJson,
    this.error,
    required this.seen,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['attempt_id'] = Variable<String>(attemptId);
    map['engram_id'] = Variable<String>(engramId);
    map['type'] = Variable<String>(type);
    map['user_id'] = Variable<String>(userId);
    map['payload_json'] = Variable<String>(payloadJson);
    map['target_cognitive_level'] = Variable<int>(targetCognitiveLevel);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || jobId != null) {
      map['job_id'] = Variable<String>(jobId);
    }
    if (!nullToAbsent || resultJson != null) {
      map['result_json'] = Variable<String>(resultJson);
    }
    if (!nullToAbsent || error != null) {
      map['error'] = Variable<String>(error);
    }
    map['seen'] = Variable<bool>(seen);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  EngramAttemptsCompanion toCompanion(bool nullToAbsent) {
    return EngramAttemptsCompanion(
      attemptId: Value(attemptId),
      engramId: Value(engramId),
      type: Value(type),
      userId: Value(userId),
      payloadJson: Value(payloadJson),
      targetCognitiveLevel: Value(targetCognitiveLevel),
      status: Value(status),
      jobId:
          jobId == null && nullToAbsent ? const Value.absent() : Value(jobId),
      resultJson:
          resultJson == null && nullToAbsent
              ? const Value.absent()
              : Value(resultJson),
      error:
          error == null && nullToAbsent ? const Value.absent() : Value(error),
      seen: Value(seen),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory EngramAttemptRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EngramAttemptRow(
      attemptId: serializer.fromJson<String>(json['attemptId']),
      engramId: serializer.fromJson<String>(json['engramId']),
      type: serializer.fromJson<String>(json['type']),
      userId: serializer.fromJson<String>(json['userId']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      targetCognitiveLevel: serializer.fromJson<int>(
        json['targetCognitiveLevel'],
      ),
      status: serializer.fromJson<String>(json['status']),
      jobId: serializer.fromJson<String?>(json['jobId']),
      resultJson: serializer.fromJson<String?>(json['resultJson']),
      error: serializer.fromJson<String?>(json['error']),
      seen: serializer.fromJson<bool>(json['seen']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'attemptId': serializer.toJson<String>(attemptId),
      'engramId': serializer.toJson<String>(engramId),
      'type': serializer.toJson<String>(type),
      'userId': serializer.toJson<String>(userId),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'targetCognitiveLevel': serializer.toJson<int>(targetCognitiveLevel),
      'status': serializer.toJson<String>(status),
      'jobId': serializer.toJson<String?>(jobId),
      'resultJson': serializer.toJson<String?>(resultJson),
      'error': serializer.toJson<String?>(error),
      'seen': serializer.toJson<bool>(seen),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  EngramAttemptRow copyWith({
    String? attemptId,
    String? engramId,
    String? type,
    String? userId,
    String? payloadJson,
    int? targetCognitiveLevel,
    String? status,
    Value<String?> jobId = const Value.absent(),
    Value<String?> resultJson = const Value.absent(),
    Value<String?> error = const Value.absent(),
    bool? seen,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => EngramAttemptRow(
    attemptId: attemptId ?? this.attemptId,
    engramId: engramId ?? this.engramId,
    type: type ?? this.type,
    userId: userId ?? this.userId,
    payloadJson: payloadJson ?? this.payloadJson,
    targetCognitiveLevel: targetCognitiveLevel ?? this.targetCognitiveLevel,
    status: status ?? this.status,
    jobId: jobId.present ? jobId.value : this.jobId,
    resultJson: resultJson.present ? resultJson.value : this.resultJson,
    error: error.present ? error.value : this.error,
    seen: seen ?? this.seen,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  EngramAttemptRow copyWithCompanion(EngramAttemptsCompanion data) {
    return EngramAttemptRow(
      attemptId: data.attemptId.present ? data.attemptId.value : this.attemptId,
      engramId: data.engramId.present ? data.engramId.value : this.engramId,
      type: data.type.present ? data.type.value : this.type,
      userId: data.userId.present ? data.userId.value : this.userId,
      payloadJson:
          data.payloadJson.present ? data.payloadJson.value : this.payloadJson,
      targetCognitiveLevel:
          data.targetCognitiveLevel.present
              ? data.targetCognitiveLevel.value
              : this.targetCognitiveLevel,
      status: data.status.present ? data.status.value : this.status,
      jobId: data.jobId.present ? data.jobId.value : this.jobId,
      resultJson:
          data.resultJson.present ? data.resultJson.value : this.resultJson,
      error: data.error.present ? data.error.value : this.error,
      seen: data.seen.present ? data.seen.value : this.seen,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EngramAttemptRow(')
          ..write('attemptId: $attemptId, ')
          ..write('engramId: $engramId, ')
          ..write('type: $type, ')
          ..write('userId: $userId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('targetCognitiveLevel: $targetCognitiveLevel, ')
          ..write('status: $status, ')
          ..write('jobId: $jobId, ')
          ..write('resultJson: $resultJson, ')
          ..write('error: $error, ')
          ..write('seen: $seen, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    attemptId,
    engramId,
    type,
    userId,
    payloadJson,
    targetCognitiveLevel,
    status,
    jobId,
    resultJson,
    error,
    seen,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EngramAttemptRow &&
          other.attemptId == this.attemptId &&
          other.engramId == this.engramId &&
          other.type == this.type &&
          other.userId == this.userId &&
          other.payloadJson == this.payloadJson &&
          other.targetCognitiveLevel == this.targetCognitiveLevel &&
          other.status == this.status &&
          other.jobId == this.jobId &&
          other.resultJson == this.resultJson &&
          other.error == this.error &&
          other.seen == this.seen &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class EngramAttemptsCompanion extends UpdateCompanion<EngramAttemptRow> {
  final Value<String> attemptId;
  final Value<String> engramId;
  final Value<String> type;
  final Value<String> userId;
  final Value<String> payloadJson;
  final Value<int> targetCognitiveLevel;
  final Value<String> status;
  final Value<String?> jobId;
  final Value<String?> resultJson;
  final Value<String?> error;
  final Value<bool> seen;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const EngramAttemptsCompanion({
    this.attemptId = const Value.absent(),
    this.engramId = const Value.absent(),
    this.type = const Value.absent(),
    this.userId = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.targetCognitiveLevel = const Value.absent(),
    this.status = const Value.absent(),
    this.jobId = const Value.absent(),
    this.resultJson = const Value.absent(),
    this.error = const Value.absent(),
    this.seen = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EngramAttemptsCompanion.insert({
    required String attemptId,
    required String engramId,
    required String type,
    required String userId,
    required String payloadJson,
    this.targetCognitiveLevel = const Value.absent(),
    this.status = const Value.absent(),
    this.jobId = const Value.absent(),
    this.resultJson = const Value.absent(),
    this.error = const Value.absent(),
    this.seen = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : attemptId = Value(attemptId),
       engramId = Value(engramId),
       type = Value(type),
       userId = Value(userId),
       payloadJson = Value(payloadJson),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<EngramAttemptRow> custom({
    Expression<String>? attemptId,
    Expression<String>? engramId,
    Expression<String>? type,
    Expression<String>? userId,
    Expression<String>? payloadJson,
    Expression<int>? targetCognitiveLevel,
    Expression<String>? status,
    Expression<String>? jobId,
    Expression<String>? resultJson,
    Expression<String>? error,
    Expression<bool>? seen,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (attemptId != null) 'attempt_id': attemptId,
      if (engramId != null) 'engram_id': engramId,
      if (type != null) 'type': type,
      if (userId != null) 'user_id': userId,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (targetCognitiveLevel != null)
        'target_cognitive_level': targetCognitiveLevel,
      if (status != null) 'status': status,
      if (jobId != null) 'job_id': jobId,
      if (resultJson != null) 'result_json': resultJson,
      if (error != null) 'error': error,
      if (seen != null) 'seen': seen,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EngramAttemptsCompanion copyWith({
    Value<String>? attemptId,
    Value<String>? engramId,
    Value<String>? type,
    Value<String>? userId,
    Value<String>? payloadJson,
    Value<int>? targetCognitiveLevel,
    Value<String>? status,
    Value<String?>? jobId,
    Value<String?>? resultJson,
    Value<String?>? error,
    Value<bool>? seen,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return EngramAttemptsCompanion(
      attemptId: attemptId ?? this.attemptId,
      engramId: engramId ?? this.engramId,
      type: type ?? this.type,
      userId: userId ?? this.userId,
      payloadJson: payloadJson ?? this.payloadJson,
      targetCognitiveLevel: targetCognitiveLevel ?? this.targetCognitiveLevel,
      status: status ?? this.status,
      jobId: jobId ?? this.jobId,
      resultJson: resultJson ?? this.resultJson,
      error: error ?? this.error,
      seen: seen ?? this.seen,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (attemptId.present) {
      map['attempt_id'] = Variable<String>(attemptId.value);
    }
    if (engramId.present) {
      map['engram_id'] = Variable<String>(engramId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (targetCognitiveLevel.present) {
      map['target_cognitive_level'] = Variable<int>(targetCognitiveLevel.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (jobId.present) {
      map['job_id'] = Variable<String>(jobId.value);
    }
    if (resultJson.present) {
      map['result_json'] = Variable<String>(resultJson.value);
    }
    if (error.present) {
      map['error'] = Variable<String>(error.value);
    }
    if (seen.present) {
      map['seen'] = Variable<bool>(seen.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
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
    return (StringBuffer('EngramAttemptsCompanion(')
          ..write('attemptId: $attemptId, ')
          ..write('engramId: $engramId, ')
          ..write('type: $type, ')
          ..write('userId: $userId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('targetCognitiveLevel: $targetCognitiveLevel, ')
          ..write('status: $status, ')
          ..write('jobId: $jobId, ')
          ..write('resultJson: $resultJson, ')
          ..write('error: $error, ')
          ..write('seen: $seen, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EngramMasteryRowsTable extends EngramMasteryRows
    with TableInfo<$EngramMasteryRowsTable, EngramMasteryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EngramMasteryRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _engramIdMeta = const VerificationMeta(
    'engramId',
  );
  @override
  late final GeneratedColumn<String> engramId = GeneratedColumn<String>(
    'engram_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _easeFactorMeta = const VerificationMeta(
    'easeFactor',
  );
  @override
  late final GeneratedColumn<double> easeFactor = GeneratedColumn<double>(
    'ease_factor',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(2.5),
  );
  static const VerificationMeta _intervalDaysMeta = const VerificationMeta(
    'intervalDays',
  );
  @override
  late final GeneratedColumn<int> intervalDays = GeneratedColumn<int>(
    'interval_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _repetitionsMeta = const VerificationMeta(
    'repetitions',
  );
  @override
  late final GeneratedColumn<int> repetitions = GeneratedColumn<int>(
    'repetitions',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lapsesMeta = const VerificationMeta('lapses');
  @override
  late final GeneratedColumn<int> lapses = GeneratedColumn<int>(
    'lapses',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _dueAtMeta = const VerificationMeta('dueAt');
  @override
  late final GeneratedColumn<DateTime> dueAt = GeneratedColumn<DateTime>(
    'due_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastGradeMeta = const VerificationMeta(
    'lastGrade',
  );
  @override
  late final GeneratedColumn<String> lastGrade = GeneratedColumn<String>(
    'last_grade',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _masteryStateMeta = const VerificationMeta(
    'masteryState',
  );
  @override
  late final GeneratedColumn<String> masteryState = GeneratedColumn<String>(
    'mastery_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('learning'),
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    engramId,
    easeFactor,
    intervalDays,
    repetitions,
    lapses,
    dueAt,
    lastGrade,
    masteryState,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'engram_mastery_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<EngramMasteryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('engram_id')) {
      context.handle(
        _engramIdMeta,
        engramId.isAcceptableOrUnknown(data['engram_id']!, _engramIdMeta),
      );
    } else if (isInserting) {
      context.missing(_engramIdMeta);
    }
    if (data.containsKey('ease_factor')) {
      context.handle(
        _easeFactorMeta,
        easeFactor.isAcceptableOrUnknown(data['ease_factor']!, _easeFactorMeta),
      );
    }
    if (data.containsKey('interval_days')) {
      context.handle(
        _intervalDaysMeta,
        intervalDays.isAcceptableOrUnknown(
          data['interval_days']!,
          _intervalDaysMeta,
        ),
      );
    }
    if (data.containsKey('repetitions')) {
      context.handle(
        _repetitionsMeta,
        repetitions.isAcceptableOrUnknown(
          data['repetitions']!,
          _repetitionsMeta,
        ),
      );
    }
    if (data.containsKey('lapses')) {
      context.handle(
        _lapsesMeta,
        lapses.isAcceptableOrUnknown(data['lapses']!, _lapsesMeta),
      );
    }
    if (data.containsKey('due_at')) {
      context.handle(
        _dueAtMeta,
        dueAt.isAcceptableOrUnknown(data['due_at']!, _dueAtMeta),
      );
    }
    if (data.containsKey('last_grade')) {
      context.handle(
        _lastGradeMeta,
        lastGrade.isAcceptableOrUnknown(data['last_grade']!, _lastGradeMeta),
      );
    }
    if (data.containsKey('mastery_state')) {
      context.handle(
        _masteryStateMeta,
        masteryState.isAcceptableOrUnknown(
          data['mastery_state']!,
          _masteryStateMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {engramId};
  @override
  EngramMasteryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EngramMasteryRow(
      engramId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}engram_id'],
          )!,
      easeFactor:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}ease_factor'],
          )!,
      intervalDays:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}interval_days'],
          )!,
      repetitions:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}repetitions'],
          )!,
      lapses:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}lapses'],
          )!,
      dueAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_at'],
      ),
      lastGrade: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_grade'],
      ),
      masteryState:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}mastery_state'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
    );
  }

  @override
  $EngramMasteryRowsTable createAlias(String alias) {
    return $EngramMasteryRowsTable(attachedDatabase, alias);
  }
}

class EngramMasteryRow extends DataClass
    implements Insertable<EngramMasteryRow> {
  final String engramId;
  final double easeFactor;
  final int intervalDays;
  final int repetitions;
  final int lapses;
  final DateTime? dueAt;
  final String? lastGrade;
  final String masteryState;
  final DateTime updatedAt;
  const EngramMasteryRow({
    required this.engramId,
    required this.easeFactor,
    required this.intervalDays,
    required this.repetitions,
    required this.lapses,
    this.dueAt,
    this.lastGrade,
    required this.masteryState,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['engram_id'] = Variable<String>(engramId);
    map['ease_factor'] = Variable<double>(easeFactor);
    map['interval_days'] = Variable<int>(intervalDays);
    map['repetitions'] = Variable<int>(repetitions);
    map['lapses'] = Variable<int>(lapses);
    if (!nullToAbsent || dueAt != null) {
      map['due_at'] = Variable<DateTime>(dueAt);
    }
    if (!nullToAbsent || lastGrade != null) {
      map['last_grade'] = Variable<String>(lastGrade);
    }
    map['mastery_state'] = Variable<String>(masteryState);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  EngramMasteryRowsCompanion toCompanion(bool nullToAbsent) {
    return EngramMasteryRowsCompanion(
      engramId: Value(engramId),
      easeFactor: Value(easeFactor),
      intervalDays: Value(intervalDays),
      repetitions: Value(repetitions),
      lapses: Value(lapses),
      dueAt:
          dueAt == null && nullToAbsent ? const Value.absent() : Value(dueAt),
      lastGrade:
          lastGrade == null && nullToAbsent
              ? const Value.absent()
              : Value(lastGrade),
      masteryState: Value(masteryState),
      updatedAt: Value(updatedAt),
    );
  }

  factory EngramMasteryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EngramMasteryRow(
      engramId: serializer.fromJson<String>(json['engramId']),
      easeFactor: serializer.fromJson<double>(json['easeFactor']),
      intervalDays: serializer.fromJson<int>(json['intervalDays']),
      repetitions: serializer.fromJson<int>(json['repetitions']),
      lapses: serializer.fromJson<int>(json['lapses']),
      dueAt: serializer.fromJson<DateTime?>(json['dueAt']),
      lastGrade: serializer.fromJson<String?>(json['lastGrade']),
      masteryState: serializer.fromJson<String>(json['masteryState']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'engramId': serializer.toJson<String>(engramId),
      'easeFactor': serializer.toJson<double>(easeFactor),
      'intervalDays': serializer.toJson<int>(intervalDays),
      'repetitions': serializer.toJson<int>(repetitions),
      'lapses': serializer.toJson<int>(lapses),
      'dueAt': serializer.toJson<DateTime?>(dueAt),
      'lastGrade': serializer.toJson<String?>(lastGrade),
      'masteryState': serializer.toJson<String>(masteryState),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  EngramMasteryRow copyWith({
    String? engramId,
    double? easeFactor,
    int? intervalDays,
    int? repetitions,
    int? lapses,
    Value<DateTime?> dueAt = const Value.absent(),
    Value<String?> lastGrade = const Value.absent(),
    String? masteryState,
    DateTime? updatedAt,
  }) => EngramMasteryRow(
    engramId: engramId ?? this.engramId,
    easeFactor: easeFactor ?? this.easeFactor,
    intervalDays: intervalDays ?? this.intervalDays,
    repetitions: repetitions ?? this.repetitions,
    lapses: lapses ?? this.lapses,
    dueAt: dueAt.present ? dueAt.value : this.dueAt,
    lastGrade: lastGrade.present ? lastGrade.value : this.lastGrade,
    masteryState: masteryState ?? this.masteryState,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  EngramMasteryRow copyWithCompanion(EngramMasteryRowsCompanion data) {
    return EngramMasteryRow(
      engramId: data.engramId.present ? data.engramId.value : this.engramId,
      easeFactor:
          data.easeFactor.present ? data.easeFactor.value : this.easeFactor,
      intervalDays:
          data.intervalDays.present
              ? data.intervalDays.value
              : this.intervalDays,
      repetitions:
          data.repetitions.present ? data.repetitions.value : this.repetitions,
      lapses: data.lapses.present ? data.lapses.value : this.lapses,
      dueAt: data.dueAt.present ? data.dueAt.value : this.dueAt,
      lastGrade: data.lastGrade.present ? data.lastGrade.value : this.lastGrade,
      masteryState:
          data.masteryState.present
              ? data.masteryState.value
              : this.masteryState,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EngramMasteryRow(')
          ..write('engramId: $engramId, ')
          ..write('easeFactor: $easeFactor, ')
          ..write('intervalDays: $intervalDays, ')
          ..write('repetitions: $repetitions, ')
          ..write('lapses: $lapses, ')
          ..write('dueAt: $dueAt, ')
          ..write('lastGrade: $lastGrade, ')
          ..write('masteryState: $masteryState, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    engramId,
    easeFactor,
    intervalDays,
    repetitions,
    lapses,
    dueAt,
    lastGrade,
    masteryState,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EngramMasteryRow &&
          other.engramId == this.engramId &&
          other.easeFactor == this.easeFactor &&
          other.intervalDays == this.intervalDays &&
          other.repetitions == this.repetitions &&
          other.lapses == this.lapses &&
          other.dueAt == this.dueAt &&
          other.lastGrade == this.lastGrade &&
          other.masteryState == this.masteryState &&
          other.updatedAt == this.updatedAt);
}

class EngramMasteryRowsCompanion extends UpdateCompanion<EngramMasteryRow> {
  final Value<String> engramId;
  final Value<double> easeFactor;
  final Value<int> intervalDays;
  final Value<int> repetitions;
  final Value<int> lapses;
  final Value<DateTime?> dueAt;
  final Value<String?> lastGrade;
  final Value<String> masteryState;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const EngramMasteryRowsCompanion({
    this.engramId = const Value.absent(),
    this.easeFactor = const Value.absent(),
    this.intervalDays = const Value.absent(),
    this.repetitions = const Value.absent(),
    this.lapses = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.lastGrade = const Value.absent(),
    this.masteryState = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EngramMasteryRowsCompanion.insert({
    required String engramId,
    this.easeFactor = const Value.absent(),
    this.intervalDays = const Value.absent(),
    this.repetitions = const Value.absent(),
    this.lapses = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.lastGrade = const Value.absent(),
    this.masteryState = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : engramId = Value(engramId),
       updatedAt = Value(updatedAt);
  static Insertable<EngramMasteryRow> custom({
    Expression<String>? engramId,
    Expression<double>? easeFactor,
    Expression<int>? intervalDays,
    Expression<int>? repetitions,
    Expression<int>? lapses,
    Expression<DateTime>? dueAt,
    Expression<String>? lastGrade,
    Expression<String>? masteryState,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (engramId != null) 'engram_id': engramId,
      if (easeFactor != null) 'ease_factor': easeFactor,
      if (intervalDays != null) 'interval_days': intervalDays,
      if (repetitions != null) 'repetitions': repetitions,
      if (lapses != null) 'lapses': lapses,
      if (dueAt != null) 'due_at': dueAt,
      if (lastGrade != null) 'last_grade': lastGrade,
      if (masteryState != null) 'mastery_state': masteryState,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EngramMasteryRowsCompanion copyWith({
    Value<String>? engramId,
    Value<double>? easeFactor,
    Value<int>? intervalDays,
    Value<int>? repetitions,
    Value<int>? lapses,
    Value<DateTime?>? dueAt,
    Value<String?>? lastGrade,
    Value<String>? masteryState,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return EngramMasteryRowsCompanion(
      engramId: engramId ?? this.engramId,
      easeFactor: easeFactor ?? this.easeFactor,
      intervalDays: intervalDays ?? this.intervalDays,
      repetitions: repetitions ?? this.repetitions,
      lapses: lapses ?? this.lapses,
      dueAt: dueAt ?? this.dueAt,
      lastGrade: lastGrade ?? this.lastGrade,
      masteryState: masteryState ?? this.masteryState,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (engramId.present) {
      map['engram_id'] = Variable<String>(engramId.value);
    }
    if (easeFactor.present) {
      map['ease_factor'] = Variable<double>(easeFactor.value);
    }
    if (intervalDays.present) {
      map['interval_days'] = Variable<int>(intervalDays.value);
    }
    if (repetitions.present) {
      map['repetitions'] = Variable<int>(repetitions.value);
    }
    if (lapses.present) {
      map['lapses'] = Variable<int>(lapses.value);
    }
    if (dueAt.present) {
      map['due_at'] = Variable<DateTime>(dueAt.value);
    }
    if (lastGrade.present) {
      map['last_grade'] = Variable<String>(lastGrade.value);
    }
    if (masteryState.present) {
      map['mastery_state'] = Variable<String>(masteryState.value);
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
    return (StringBuffer('EngramMasteryRowsCompanion(')
          ..write('engramId: $engramId, ')
          ..write('easeFactor: $easeFactor, ')
          ..write('intervalDays: $intervalDays, ')
          ..write('repetitions: $repetitions, ')
          ..write('lapses: $lapses, ')
          ..write('dueAt: $dueAt, ')
          ..write('lastGrade: $lastGrade, ')
          ..write('masteryState: $masteryState, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedEngramsTable extends CachedEngrams
    with TableInfo<$CachedEngramsTable, CachedEngram> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedEngramsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bubbleIdMeta = const VerificationMeta(
    'bubbleId',
  );
  @override
  late final GeneratedColumn<String> bubbleId = GeneratedColumn<String>(
    'bubble_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteIdMeta = const VerificationMeta('noteId');
  @override
  late final GeneratedColumn<String> noteId = GeneratedColumn<String>(
    'note_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetCognitiveLevelMeta =
      const VerificationMeta('targetCognitiveLevel');
  @override
  late final GeneratedColumn<int> targetCognitiveLevel = GeneratedColumn<int>(
    'target_cognitive_level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _tagsJsonMeta = const VerificationMeta(
    'tagsJson',
  );
  @override
  late final GeneratedColumn<String> tagsJson = GeneratedColumn<String>(
    'tags_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _contentJsonMeta = const VerificationMeta(
    'contentJson',
  );
  @override
  late final GeneratedColumn<String> contentJson = GeneratedColumn<String>(
    'content_json',
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    bubbleId,
    noteId,
    type,
    targetCognitiveLevel,
    tagsJson,
    contentJson,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_engrams';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedEngram> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('bubble_id')) {
      context.handle(
        _bubbleIdMeta,
        bubbleId.isAcceptableOrUnknown(data['bubble_id']!, _bubbleIdMeta),
      );
    }
    if (data.containsKey('note_id')) {
      context.handle(
        _noteIdMeta,
        noteId.isAcceptableOrUnknown(data['note_id']!, _noteIdMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('target_cognitive_level')) {
      context.handle(
        _targetCognitiveLevelMeta,
        targetCognitiveLevel.isAcceptableOrUnknown(
          data['target_cognitive_level']!,
          _targetCognitiveLevelMeta,
        ),
      );
    }
    if (data.containsKey('tags_json')) {
      context.handle(
        _tagsJsonMeta,
        tagsJson.isAcceptableOrUnknown(data['tags_json']!, _tagsJsonMeta),
      );
    }
    if (data.containsKey('content_json')) {
      context.handle(
        _contentJsonMeta,
        contentJson.isAcceptableOrUnknown(
          data['content_json']!,
          _contentJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contentJsonMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedEngram map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedEngram(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      userId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}user_id'],
          )!,
      bubbleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bubble_id'],
      ),
      noteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note_id'],
      ),
      type:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}type'],
          )!,
      targetCognitiveLevel:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}target_cognitive_level'],
          )!,
      tagsJson:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}tags_json'],
          )!,
      contentJson:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}content_json'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
    );
  }

  @override
  $CachedEngramsTable createAlias(String alias) {
    return $CachedEngramsTable(attachedDatabase, alias);
  }
}

class CachedEngram extends DataClass implements Insertable<CachedEngram> {
  final String id;
  final String userId;
  final String? bubbleId;
  final String? noteId;
  final String type;
  final int targetCognitiveLevel;
  final String tagsJson;
  final String contentJson;
  final DateTime updatedAt;
  const CachedEngram({
    required this.id,
    required this.userId,
    this.bubbleId,
    this.noteId,
    required this.type,
    required this.targetCognitiveLevel,
    required this.tagsJson,
    required this.contentJson,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || bubbleId != null) {
      map['bubble_id'] = Variable<String>(bubbleId);
    }
    if (!nullToAbsent || noteId != null) {
      map['note_id'] = Variable<String>(noteId);
    }
    map['type'] = Variable<String>(type);
    map['target_cognitive_level'] = Variable<int>(targetCognitiveLevel);
    map['tags_json'] = Variable<String>(tagsJson);
    map['content_json'] = Variable<String>(contentJson);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CachedEngramsCompanion toCompanion(bool nullToAbsent) {
    return CachedEngramsCompanion(
      id: Value(id),
      userId: Value(userId),
      bubbleId:
          bubbleId == null && nullToAbsent
              ? const Value.absent()
              : Value(bubbleId),
      noteId:
          noteId == null && nullToAbsent ? const Value.absent() : Value(noteId),
      type: Value(type),
      targetCognitiveLevel: Value(targetCognitiveLevel),
      tagsJson: Value(tagsJson),
      contentJson: Value(contentJson),
      updatedAt: Value(updatedAt),
    );
  }

  factory CachedEngram.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedEngram(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      bubbleId: serializer.fromJson<String?>(json['bubbleId']),
      noteId: serializer.fromJson<String?>(json['noteId']),
      type: serializer.fromJson<String>(json['type']),
      targetCognitiveLevel: serializer.fromJson<int>(
        json['targetCognitiveLevel'],
      ),
      tagsJson: serializer.fromJson<String>(json['tagsJson']),
      contentJson: serializer.fromJson<String>(json['contentJson']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'bubbleId': serializer.toJson<String?>(bubbleId),
      'noteId': serializer.toJson<String?>(noteId),
      'type': serializer.toJson<String>(type),
      'targetCognitiveLevel': serializer.toJson<int>(targetCognitiveLevel),
      'tagsJson': serializer.toJson<String>(tagsJson),
      'contentJson': serializer.toJson<String>(contentJson),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CachedEngram copyWith({
    String? id,
    String? userId,
    Value<String?> bubbleId = const Value.absent(),
    Value<String?> noteId = const Value.absent(),
    String? type,
    int? targetCognitiveLevel,
    String? tagsJson,
    String? contentJson,
    DateTime? updatedAt,
  }) => CachedEngram(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    bubbleId: bubbleId.present ? bubbleId.value : this.bubbleId,
    noteId: noteId.present ? noteId.value : this.noteId,
    type: type ?? this.type,
    targetCognitiveLevel: targetCognitiveLevel ?? this.targetCognitiveLevel,
    tagsJson: tagsJson ?? this.tagsJson,
    contentJson: contentJson ?? this.contentJson,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CachedEngram copyWithCompanion(CachedEngramsCompanion data) {
    return CachedEngram(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      bubbleId: data.bubbleId.present ? data.bubbleId.value : this.bubbleId,
      noteId: data.noteId.present ? data.noteId.value : this.noteId,
      type: data.type.present ? data.type.value : this.type,
      targetCognitiveLevel:
          data.targetCognitiveLevel.present
              ? data.targetCognitiveLevel.value
              : this.targetCognitiveLevel,
      tagsJson: data.tagsJson.present ? data.tagsJson.value : this.tagsJson,
      contentJson:
          data.contentJson.present ? data.contentJson.value : this.contentJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedEngram(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('bubbleId: $bubbleId, ')
          ..write('noteId: $noteId, ')
          ..write('type: $type, ')
          ..write('targetCognitiveLevel: $targetCognitiveLevel, ')
          ..write('tagsJson: $tagsJson, ')
          ..write('contentJson: $contentJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    bubbleId,
    noteId,
    type,
    targetCognitiveLevel,
    tagsJson,
    contentJson,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedEngram &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.bubbleId == this.bubbleId &&
          other.noteId == this.noteId &&
          other.type == this.type &&
          other.targetCognitiveLevel == this.targetCognitiveLevel &&
          other.tagsJson == this.tagsJson &&
          other.contentJson == this.contentJson &&
          other.updatedAt == this.updatedAt);
}

class CachedEngramsCompanion extends UpdateCompanion<CachedEngram> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String?> bubbleId;
  final Value<String?> noteId;
  final Value<String> type;
  final Value<int> targetCognitiveLevel;
  final Value<String> tagsJson;
  final Value<String> contentJson;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CachedEngramsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.bubbleId = const Value.absent(),
    this.noteId = const Value.absent(),
    this.type = const Value.absent(),
    this.targetCognitiveLevel = const Value.absent(),
    this.tagsJson = const Value.absent(),
    this.contentJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedEngramsCompanion.insert({
    required String id,
    required String userId,
    this.bubbleId = const Value.absent(),
    this.noteId = const Value.absent(),
    required String type,
    this.targetCognitiveLevel = const Value.absent(),
    this.tagsJson = const Value.absent(),
    required String contentJson,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       type = Value(type),
       contentJson = Value(contentJson),
       updatedAt = Value(updatedAt);
  static Insertable<CachedEngram> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? bubbleId,
    Expression<String>? noteId,
    Expression<String>? type,
    Expression<int>? targetCognitiveLevel,
    Expression<String>? tagsJson,
    Expression<String>? contentJson,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (bubbleId != null) 'bubble_id': bubbleId,
      if (noteId != null) 'note_id': noteId,
      if (type != null) 'type': type,
      if (targetCognitiveLevel != null)
        'target_cognitive_level': targetCognitiveLevel,
      if (tagsJson != null) 'tags_json': tagsJson,
      if (contentJson != null) 'content_json': contentJson,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedEngramsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String?>? bubbleId,
    Value<String?>? noteId,
    Value<String>? type,
    Value<int>? targetCognitiveLevel,
    Value<String>? tagsJson,
    Value<String>? contentJson,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return CachedEngramsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      bubbleId: bubbleId ?? this.bubbleId,
      noteId: noteId ?? this.noteId,
      type: type ?? this.type,
      targetCognitiveLevel: targetCognitiveLevel ?? this.targetCognitiveLevel,
      tagsJson: tagsJson ?? this.tagsJson,
      contentJson: contentJson ?? this.contentJson,
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
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (bubbleId.present) {
      map['bubble_id'] = Variable<String>(bubbleId.value);
    }
    if (noteId.present) {
      map['note_id'] = Variable<String>(noteId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (targetCognitiveLevel.present) {
      map['target_cognitive_level'] = Variable<int>(targetCognitiveLevel.value);
    }
    if (tagsJson.present) {
      map['tags_json'] = Variable<String>(tagsJson.value);
    }
    if (contentJson.present) {
      map['content_json'] = Variable<String>(contentJson.value);
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
    return (StringBuffer('CachedEngramsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('bubbleId: $bubbleId, ')
          ..write('noteId: $noteId, ')
          ..write('type: $type, ')
          ..write('targetCognitiveLevel: $targetCognitiveLevel, ')
          ..write('tagsJson: $tagsJson, ')
          ..write('contentJson: $contentJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $EngramAttemptsTable engramAttempts = $EngramAttemptsTable(this);
  late final $EngramMasteryRowsTable engramMasteryRows =
      $EngramMasteryRowsTable(this);
  late final $CachedEngramsTable cachedEngrams = $CachedEngramsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    engramAttempts,
    engramMasteryRows,
    cachedEngrams,
  ];
}

typedef $$EngramAttemptsTableCreateCompanionBuilder =
    EngramAttemptsCompanion Function({
      required String attemptId,
      required String engramId,
      required String type,
      required String userId,
      required String payloadJson,
      Value<int> targetCognitiveLevel,
      Value<String> status,
      Value<String?> jobId,
      Value<String?> resultJson,
      Value<String?> error,
      Value<bool> seen,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$EngramAttemptsTableUpdateCompanionBuilder =
    EngramAttemptsCompanion Function({
      Value<String> attemptId,
      Value<String> engramId,
      Value<String> type,
      Value<String> userId,
      Value<String> payloadJson,
      Value<int> targetCognitiveLevel,
      Value<String> status,
      Value<String?> jobId,
      Value<String?> resultJson,
      Value<String?> error,
      Value<bool> seen,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$EngramAttemptsTableFilterComposer
    extends Composer<_$AppDatabase, $EngramAttemptsTable> {
  $$EngramAttemptsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get attemptId => $composableBuilder(
    column: $table.attemptId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get engramId => $composableBuilder(
    column: $table.engramId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetCognitiveLevel => $composableBuilder(
    column: $table.targetCognitiveLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jobId => $composableBuilder(
    column: $table.jobId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resultJson => $composableBuilder(
    column: $table.resultJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get seen => $composableBuilder(
    column: $table.seen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EngramAttemptsTableOrderingComposer
    extends Composer<_$AppDatabase, $EngramAttemptsTable> {
  $$EngramAttemptsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get attemptId => $composableBuilder(
    column: $table.attemptId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get engramId => $composableBuilder(
    column: $table.engramId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetCognitiveLevel => $composableBuilder(
    column: $table.targetCognitiveLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jobId => $composableBuilder(
    column: $table.jobId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resultJson => $composableBuilder(
    column: $table.resultJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get seen => $composableBuilder(
    column: $table.seen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EngramAttemptsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EngramAttemptsTable> {
  $$EngramAttemptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get attemptId =>
      $composableBuilder(column: $table.attemptId, builder: (column) => column);

  GeneratedColumn<String> get engramId =>
      $composableBuilder(column: $table.engramId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetCognitiveLevel => $composableBuilder(
    column: $table.targetCognitiveLevel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get jobId =>
      $composableBuilder(column: $table.jobId, builder: (column) => column);

  GeneratedColumn<String> get resultJson => $composableBuilder(
    column: $table.resultJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get error =>
      $composableBuilder(column: $table.error, builder: (column) => column);

  GeneratedColumn<bool> get seen =>
      $composableBuilder(column: $table.seen, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$EngramAttemptsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EngramAttemptsTable,
          EngramAttemptRow,
          $$EngramAttemptsTableFilterComposer,
          $$EngramAttemptsTableOrderingComposer,
          $$EngramAttemptsTableAnnotationComposer,
          $$EngramAttemptsTableCreateCompanionBuilder,
          $$EngramAttemptsTableUpdateCompanionBuilder,
          (
            EngramAttemptRow,
            BaseReferences<
              _$AppDatabase,
              $EngramAttemptsTable,
              EngramAttemptRow
            >,
          ),
          EngramAttemptRow,
          PrefetchHooks Function()
        > {
  $$EngramAttemptsTableTableManager(
    _$AppDatabase db,
    $EngramAttemptsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$EngramAttemptsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$EngramAttemptsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$EngramAttemptsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> attemptId = const Value.absent(),
                Value<String> engramId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<int> targetCognitiveLevel = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> jobId = const Value.absent(),
                Value<String?> resultJson = const Value.absent(),
                Value<String?> error = const Value.absent(),
                Value<bool> seen = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EngramAttemptsCompanion(
                attemptId: attemptId,
                engramId: engramId,
                type: type,
                userId: userId,
                payloadJson: payloadJson,
                targetCognitiveLevel: targetCognitiveLevel,
                status: status,
                jobId: jobId,
                resultJson: resultJson,
                error: error,
                seen: seen,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String attemptId,
                required String engramId,
                required String type,
                required String userId,
                required String payloadJson,
                Value<int> targetCognitiveLevel = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> jobId = const Value.absent(),
                Value<String?> resultJson = const Value.absent(),
                Value<String?> error = const Value.absent(),
                Value<bool> seen = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => EngramAttemptsCompanion.insert(
                attemptId: attemptId,
                engramId: engramId,
                type: type,
                userId: userId,
                payloadJson: payloadJson,
                targetCognitiveLevel: targetCognitiveLevel,
                status: status,
                jobId: jobId,
                resultJson: resultJson,
                error: error,
                seen: seen,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EngramAttemptsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EngramAttemptsTable,
      EngramAttemptRow,
      $$EngramAttemptsTableFilterComposer,
      $$EngramAttemptsTableOrderingComposer,
      $$EngramAttemptsTableAnnotationComposer,
      $$EngramAttemptsTableCreateCompanionBuilder,
      $$EngramAttemptsTableUpdateCompanionBuilder,
      (
        EngramAttemptRow,
        BaseReferences<_$AppDatabase, $EngramAttemptsTable, EngramAttemptRow>,
      ),
      EngramAttemptRow,
      PrefetchHooks Function()
    >;
typedef $$EngramMasteryRowsTableCreateCompanionBuilder =
    EngramMasteryRowsCompanion Function({
      required String engramId,
      Value<double> easeFactor,
      Value<int> intervalDays,
      Value<int> repetitions,
      Value<int> lapses,
      Value<DateTime?> dueAt,
      Value<String?> lastGrade,
      Value<String> masteryState,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$EngramMasteryRowsTableUpdateCompanionBuilder =
    EngramMasteryRowsCompanion Function({
      Value<String> engramId,
      Value<double> easeFactor,
      Value<int> intervalDays,
      Value<int> repetitions,
      Value<int> lapses,
      Value<DateTime?> dueAt,
      Value<String?> lastGrade,
      Value<String> masteryState,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$EngramMasteryRowsTableFilterComposer
    extends Composer<_$AppDatabase, $EngramMasteryRowsTable> {
  $$EngramMasteryRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get engramId => $composableBuilder(
    column: $table.engramId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get easeFactor => $composableBuilder(
    column: $table.easeFactor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get repetitions => $composableBuilder(
    column: $table.repetitions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lapses => $composableBuilder(
    column: $table.lapses,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastGrade => $composableBuilder(
    column: $table.lastGrade,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get masteryState => $composableBuilder(
    column: $table.masteryState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EngramMasteryRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $EngramMasteryRowsTable> {
  $$EngramMasteryRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get engramId => $composableBuilder(
    column: $table.engramId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get easeFactor => $composableBuilder(
    column: $table.easeFactor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get repetitions => $composableBuilder(
    column: $table.repetitions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lapses => $composableBuilder(
    column: $table.lapses,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastGrade => $composableBuilder(
    column: $table.lastGrade,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get masteryState => $composableBuilder(
    column: $table.masteryState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EngramMasteryRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EngramMasteryRowsTable> {
  $$EngramMasteryRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get engramId =>
      $composableBuilder(column: $table.engramId, builder: (column) => column);

  GeneratedColumn<double> get easeFactor => $composableBuilder(
    column: $table.easeFactor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get repetitions => $composableBuilder(
    column: $table.repetitions,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lapses =>
      $composableBuilder(column: $table.lapses, builder: (column) => column);

  GeneratedColumn<DateTime> get dueAt =>
      $composableBuilder(column: $table.dueAt, builder: (column) => column);

  GeneratedColumn<String> get lastGrade =>
      $composableBuilder(column: $table.lastGrade, builder: (column) => column);

  GeneratedColumn<String> get masteryState => $composableBuilder(
    column: $table.masteryState,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$EngramMasteryRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EngramMasteryRowsTable,
          EngramMasteryRow,
          $$EngramMasteryRowsTableFilterComposer,
          $$EngramMasteryRowsTableOrderingComposer,
          $$EngramMasteryRowsTableAnnotationComposer,
          $$EngramMasteryRowsTableCreateCompanionBuilder,
          $$EngramMasteryRowsTableUpdateCompanionBuilder,
          (
            EngramMasteryRow,
            BaseReferences<
              _$AppDatabase,
              $EngramMasteryRowsTable,
              EngramMasteryRow
            >,
          ),
          EngramMasteryRow,
          PrefetchHooks Function()
        > {
  $$EngramMasteryRowsTableTableManager(
    _$AppDatabase db,
    $EngramMasteryRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$EngramMasteryRowsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer:
              () => $$EngramMasteryRowsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$EngramMasteryRowsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> engramId = const Value.absent(),
                Value<double> easeFactor = const Value.absent(),
                Value<int> intervalDays = const Value.absent(),
                Value<int> repetitions = const Value.absent(),
                Value<int> lapses = const Value.absent(),
                Value<DateTime?> dueAt = const Value.absent(),
                Value<String?> lastGrade = const Value.absent(),
                Value<String> masteryState = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EngramMasteryRowsCompanion(
                engramId: engramId,
                easeFactor: easeFactor,
                intervalDays: intervalDays,
                repetitions: repetitions,
                lapses: lapses,
                dueAt: dueAt,
                lastGrade: lastGrade,
                masteryState: masteryState,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String engramId,
                Value<double> easeFactor = const Value.absent(),
                Value<int> intervalDays = const Value.absent(),
                Value<int> repetitions = const Value.absent(),
                Value<int> lapses = const Value.absent(),
                Value<DateTime?> dueAt = const Value.absent(),
                Value<String?> lastGrade = const Value.absent(),
                Value<String> masteryState = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => EngramMasteryRowsCompanion.insert(
                engramId: engramId,
                easeFactor: easeFactor,
                intervalDays: intervalDays,
                repetitions: repetitions,
                lapses: lapses,
                dueAt: dueAt,
                lastGrade: lastGrade,
                masteryState: masteryState,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EngramMasteryRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EngramMasteryRowsTable,
      EngramMasteryRow,
      $$EngramMasteryRowsTableFilterComposer,
      $$EngramMasteryRowsTableOrderingComposer,
      $$EngramMasteryRowsTableAnnotationComposer,
      $$EngramMasteryRowsTableCreateCompanionBuilder,
      $$EngramMasteryRowsTableUpdateCompanionBuilder,
      (
        EngramMasteryRow,
        BaseReferences<
          _$AppDatabase,
          $EngramMasteryRowsTable,
          EngramMasteryRow
        >,
      ),
      EngramMasteryRow,
      PrefetchHooks Function()
    >;
typedef $$CachedEngramsTableCreateCompanionBuilder =
    CachedEngramsCompanion Function({
      required String id,
      required String userId,
      Value<String?> bubbleId,
      Value<String?> noteId,
      required String type,
      Value<int> targetCognitiveLevel,
      Value<String> tagsJson,
      required String contentJson,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$CachedEngramsTableUpdateCompanionBuilder =
    CachedEngramsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String?> bubbleId,
      Value<String?> noteId,
      Value<String> type,
      Value<int> targetCognitiveLevel,
      Value<String> tagsJson,
      Value<String> contentJson,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$CachedEngramsTableFilterComposer
    extends Composer<_$AppDatabase, $CachedEngramsTable> {
  $$CachedEngramsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bubbleId => $composableBuilder(
    column: $table.bubbleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get noteId => $composableBuilder(
    column: $table.noteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetCognitiveLevel => $composableBuilder(
    column: $table.targetCognitiveLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tagsJson => $composableBuilder(
    column: $table.tagsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentJson => $composableBuilder(
    column: $table.contentJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedEngramsTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedEngramsTable> {
  $$CachedEngramsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bubbleId => $composableBuilder(
    column: $table.bubbleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get noteId => $composableBuilder(
    column: $table.noteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetCognitiveLevel => $composableBuilder(
    column: $table.targetCognitiveLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tagsJson => $composableBuilder(
    column: $table.tagsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentJson => $composableBuilder(
    column: $table.contentJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedEngramsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedEngramsTable> {
  $$CachedEngramsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get bubbleId =>
      $composableBuilder(column: $table.bubbleId, builder: (column) => column);

  GeneratedColumn<String> get noteId =>
      $composableBuilder(column: $table.noteId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get targetCognitiveLevel => $composableBuilder(
    column: $table.targetCognitiveLevel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tagsJson =>
      $composableBuilder(column: $table.tagsJson, builder: (column) => column);

  GeneratedColumn<String> get contentJson => $composableBuilder(
    column: $table.contentJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CachedEngramsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedEngramsTable,
          CachedEngram,
          $$CachedEngramsTableFilterComposer,
          $$CachedEngramsTableOrderingComposer,
          $$CachedEngramsTableAnnotationComposer,
          $$CachedEngramsTableCreateCompanionBuilder,
          $$CachedEngramsTableUpdateCompanionBuilder,
          (
            CachedEngram,
            BaseReferences<_$AppDatabase, $CachedEngramsTable, CachedEngram>,
          ),
          CachedEngram,
          PrefetchHooks Function()
        > {
  $$CachedEngramsTableTableManager(_$AppDatabase db, $CachedEngramsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$CachedEngramsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$CachedEngramsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$CachedEngramsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String?> bubbleId = const Value.absent(),
                Value<String?> noteId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> targetCognitiveLevel = const Value.absent(),
                Value<String> tagsJson = const Value.absent(),
                Value<String> contentJson = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedEngramsCompanion(
                id: id,
                userId: userId,
                bubbleId: bubbleId,
                noteId: noteId,
                type: type,
                targetCognitiveLevel: targetCognitiveLevel,
                tagsJson: tagsJson,
                contentJson: contentJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                Value<String?> bubbleId = const Value.absent(),
                Value<String?> noteId = const Value.absent(),
                required String type,
                Value<int> targetCognitiveLevel = const Value.absent(),
                Value<String> tagsJson = const Value.absent(),
                required String contentJson,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CachedEngramsCompanion.insert(
                id: id,
                userId: userId,
                bubbleId: bubbleId,
                noteId: noteId,
                type: type,
                targetCognitiveLevel: targetCognitiveLevel,
                tagsJson: tagsJson,
                contentJson: contentJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedEngramsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedEngramsTable,
      CachedEngram,
      $$CachedEngramsTableFilterComposer,
      $$CachedEngramsTableOrderingComposer,
      $$CachedEngramsTableAnnotationComposer,
      $$CachedEngramsTableCreateCompanionBuilder,
      $$CachedEngramsTableUpdateCompanionBuilder,
      (
        CachedEngram,
        BaseReferences<_$AppDatabase, $CachedEngramsTable, CachedEngram>,
      ),
      CachedEngram,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$EngramAttemptsTableTableManager get engramAttempts =>
      $$EngramAttemptsTableTableManager(_db, _db.engramAttempts);
  $$EngramMasteryRowsTableTableManager get engramMasteryRows =>
      $$EngramMasteryRowsTableTableManager(_db, _db.engramMasteryRows);
  $$CachedEngramsTableTableManager get cachedEngrams =>
      $$CachedEngramsTableTableManager(_db, _db.cachedEngrams);
}
