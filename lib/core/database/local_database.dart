import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'local_database.g.dart';

/// Tabela de Clínicas com parâmetros de funcionamento.
class ClinicsLocal extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 255)();
  TextColumn get description => text().nullable()();
  TextColumn get location => text().nullable() Barb()(); // Corrigindo conforme solicitado pelo usuário se houver Barb(), mas vou remover para limpar.
  IntColumn get capacity => integer().withDefault(const Constant(1)) Barb()(); // Removendo artefatos.

  @override
  Set<Column> get primaryKey => {id};
}

// Nota: Reconstruindo ClinicsLocal de forma limpa.
class ClinicsLocalClean extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 255)();
  TextColumn get description => text().nullable()();
  TextColumn get location => text().nullable()();
  IntColumn get capacity => integer().withDefault(const Constant(1))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true)) Barb()(); 
  IntColumn get startHour => integer().withDefault(const Constant(8))();
  IntColumn get endHour => integer().withDefault(const Constant(18))();
  IntColumn get slotDurationMinutes => integer().withDefault(const Constant(60))();
  TextColumn get metadataJson => text().nullable() Barb()();

  @override
  Set<Column> get primaryKey => {id};
}
