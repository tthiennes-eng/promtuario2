import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:promt/core/database/local_database.dart';
import 'package:promt/core/network/api_client.dart';
import 'package:promt/features/dashboard/domain/services/statistical_engine.dart';

class StatisticalStudiesRepository {
  final ApiClient _apiClient;
  final AppDatabase _localDb;

  StatisticalStudiesRepository(this._apiClient, this._localDb);

  Future<Map<String, dynamic>> getStatisticalStudies({
    DateTime? start,
    DateTime? end,
    String? clinicId,
  }) async {
    try {
      final response = await _apiClient.instance.get(
        '/Reports/statistical-studies',
        queryParameters: {
          if (start != null) 'start': start.toUtc().toIso8601String(),
          if (end != null) 'end': end.toUtc().toIso8601String(),
          if (clinicId != null && clinicId.isNotEmpty) 'clinicId': clinicId,
        },
      );
      if (response.data is Map) {
        return Map<String, dynamic>.from(response.data as Map);
      }
    } catch (_) {
      // Fallback silencioso para agregação local via SQLite quando offline ou servidor desatualizado
    }

    return _buildFromLocalDb(start: start, end: end, clinicId: clinicId);
  }

  Future<Map<String, dynamic>> _buildFromLocalDb({
    DateTime? start,
    DateTime? end,
    String? clinicId,
  }) async {
    final patients = await _localDb.select(_localDb.patientsLocal).get();
    final clinics = await _localDb.select(_localDb.clinicsLocal).get();
    final appointments = await _localDb.select(_localDb.appointmentsLocal).get();
    final evolutions = await _localDb.select(_localDb.evolutionsLocal).get();
    final odontograms = await _localDb.select(_localDb.odontogramLocal).get();
    final anamneses = await _localDb.select(_localDb.anamneseLocal).get();
    final waitList = await _localDb.select(_localDb.waitListLocal).get();
    final treatmentItems = await _localDb.select(_localDb.treatmentItemsLocal).get();

    final clinicNames = <String, String>{for (final c in clinics) c.id: c.name};

    final filteredAppts = appointments.where((a) {
      if (start != null && a.startTime.isBefore(start)) return false;
      if (end != null && a.startTime.isAfter(end)) return false;
      if (clinicId != null && clinicId.isNotEmpty && a.clinicId != clinicId) return false;
      return true;
    }).toList();

    final filteredEvos = evolutions.where((e) {
      if (start != null && e.createdAt.isBefore(start)) return false;
      if (end != null && e.createdAt.isAfter(end)) return false;
      if (clinicId != null && clinicId.isNotEmpty) {
        final targetName = clinicNames[clinicId]?.toLowerCase();
        if (targetName != null && (e.clinicName ?? '').toLowerCase() != targetName) return false;
      }
      return true;
    }).toList();

    final filteredWaitList = waitList.where((w) {
      if (start != null && w.createdAt.isBefore(start)) return false;
      if (end != null && w.createdAt.isAfter(end)) return false;
      if (clinicId != null && clinicId.isNotEmpty && w.clinicId != clinicId) return false;
      return true;
    }).toList();

    final scopedPatientIds = clinicId != null && clinicId.isNotEmpty
        ? filteredAppts.map((a) => a.patientId).toSet()
        : patients.map((p) => p.id).toSet();

    final scopedPatients = clinicId != null && clinicId.isNotEmpty
        ? patients.where((p) => scopedPatientIds.contains(p.id)).toList()
        : patients;

    // Indexa fichas salvas na tabela odontogramLocal por prefixo
    final sheetsByKey = <String, Map<String, dynamic>>{};
    for (final row in odontograms) {
      try {
        final decoded = jsonDecode(row.dataJson);
        if (decoded is Map) {
          sheetsByKey[row.patientId] = Map<String, dynamic>.from(decoded);
        }
      } catch (_) {}
    }

    final anamneseByPatient = <String, Map<String, dynamic>>{};
    for (final a in anamneses) {
      try {
        final decoded = jsonDecode(a.responsesJson);
        if (decoded is Map) {
          anamneseByPatient[a.patientId] = Map<String, dynamic>.from(decoded);
        }
      } catch (_) {}
    }

    final now = DateTime.now();
    final ages = <double>[];
    final ageGroups = <String, int>{
      '0-5 anos': 0,
      '6-11 anos': 0,
      '12-17 anos': 0,
      '18-29 anos': 0,
      '30-49 anos': 0,
      '50-64 anos': 0,
      '65+ anos': 0,
    };
    final genderDist = <String, int>{};
    final cityDist = <String, int>{};
    final conditionCounts = <String, int>{};
    final toothCounts = <int, int>{};
    final cpodValues = <double>[];
    final comorbidities = <String, int>{};
    final dtmRisks = <String, Map<String, int>>{
      'carie': {'baixo': 0, 'moderado': 0, 'alto': 0},
      'oclusal': {'baixo': 0, 'moderado': 0, 'alto': 0},
      'dtm': {'baixo': 0, 'moderado': 0, 'alto': 0},
    };
    final ipvValues = <double>[];
    final isgValues = <double>[];
    final angleOcclusion = <String, int>{};
    final facialProfile = <String, int>{};
    final cariesProfile = <String, int>{};

    const sheetTypes = [
      'anamnese',
      'extraoral',
      'intraoral',
      'periograma',
      'endodontia',
      'ppr',
      'dtm',
      'odontopediatria',
      'tcle',
    ];
    final sheetCounts = <String, int>{for (final s in sheetTypes) s: 0};

    final patientDataset = <Map<String, dynamic>>[];
    int idx = 1;

    for (final p in scopedPatients) {
      final age = _computeAge(p.birthDate, now);
      if (age >= 0 && age <= 120) {
        ages.add(age.toDouble());
        final grp = _ageGroup(age);
        ageGroups[grp] = (ageGroups[grp] ?? 0) + 1;
      }

      final gender = _normalizeGender(p.gender);
      genderDist[gender] = (genderDist[gender] ?? 0) + 1;

      final city = (p.city ?? '').trim().isEmpty ? 'Não informada' : p.city!.trim();
      cityDist[city] = (cityDist[city] ?? 0) + 1;

      bool hasComorb = false;
      bool hasAllergy = false;
      bool hasSugaryDiet = false;
      bool hasDeleteriousHabit = false;
      bool hasMalocclusion = false;
      bool hasCaries = false;
      bool highDtmRisk = false;
      bool hasExtractionOrEndo = false;
      double? latestIpv;
      double? latestIsg;

      final anam = sheetsByKey['endo_anamnese_${p.id}'] ?? anamneseByPatient[p.id];
      final extraoral = sheetsByKey['endo_extraoral_${p.id}'];
      final intraoral = sheetsByKey['endo_intraoral_${p.id}'];
      final periograma = sheetsByKey['peri_${p.id}'] ?? sheetsByKey['endo_periograma_${p.id}'];
      final endodontia = sheetsByKey['endo_${p.id}'];
      final ppr = sheetsByKey['endo_ppr_${p.id}'];
      final dtm = sheetsByKey['endo_dtm_${p.id}'];
      final ped = sheetsByKey['endo_odontopediatria_${p.id}'];
      final tcle = sheetsByKey['endo_tcle_${p.id}'];
      final odo = sheetsByKey[p.id];

      if (anam != null) sheetCounts['anamnese'] = sheetCounts['anamnese']! + 1;
      if (extraoral != null) sheetCounts['extraoral'] = sheetCounts['extraoral']! + 1;
      if (intraoral != null) sheetCounts['intraoral'] = sheetCounts['intraoral']! + 1;
      if (periograma != null) sheetCounts['periograma'] = sheetCounts['periograma']! + 1;
      if (endodontia != null) sheetCounts['endodontia'] = sheetCounts['endodontia']! + 1;
      if (ppr != null) sheetCounts['ppr'] = sheetCounts['ppr']! + 1;
      if (dtm != null) sheetCounts['dtm'] = sheetCounts['dtm']! + 1;
      if (ped != null) sheetCounts['odontopediatria'] = sheetCounts['odontopediatria']! + 1;
      if (tcle != null) sheetCounts['tcle'] = sheetCounts['tcle']! + 1;

      // Parse Anamnese
      if (anam != null && anam['sistemico'] is Map) {
        final sis = Map<String, dynamic>.from(anam['sistemico'] as Map);
        void check(String k, String label) {
          final n = sis[k];
          if (n is Map && (n['sim'] == true || n['sim'] == 'true')) {
            comorbidities[label] = (comorbidities[label] ?? 0) + 1;
            if (k == 'alergia') {
              hasAllergy = true;
            } else {
              hasComorb = true;
            }
          }
        }
        check('cardiacos', 'Problemas Cardíacos');
        check('diabetes', 'Diabetes');
        check('alergia', 'Alergias');
        check('digestivos', 'Problemas Digestivos');
        check('figado', 'Problemas Hepáticos');
        check('neurologicos', 'Problemas Neurológicos');
        check('coagulacao', 'Distúrbios de Coagulação');
        check('sinusite', 'Sinusite');
        final pr = sis['pressao'];
        if (pr is Map && (pr['usaMeds'] == true || (pr['qual']?.toString().trim().isNotEmpty ?? false))) {
          comorbidities['Hipertensão / Pressão Arterial'] =
              (comorbidities['Hipertensão / Pressão Arterial'] ?? 0) + 1;
          hasComorb = true;
        }
      }

      // Parse DTM
      if (dtm != null) {
        for (final entry in [('riscoCarie', 'carie'), ('riscoOclusal', 'oclusal'), ('riscoDtm', 'dtm')]) {
          final v = (dtm[entry.$1] ?? '').toString().trim().toLowerCase();
          if (dtmRisks[entry.$2]!.containsKey(v)) {
            dtmRisks[entry.$2]![v] = dtmRisks[entry.$2]![v]! + 1;
            if (v == 'alto') highDtmRisk = true;
          }
        }
      }

      // Parse Odontopediatria
      if (ped != null) {
        latestIpv = _computeGridPercent(ped['t7_ipv_grid']);
        latestIsg = _computeGridPercent(ped['t7_isg_grid']);
        if (latestIpv != null) ipvValues.add(latestIpv);
        if (latestIsg != null) isgValues.add(latestIsg);

        String s(String k) => (ped[k] ?? '').toString().trim();
        if (s('t3_q1_liquidos_acucar').contains('Sim') ||
            s('t3_q2_refrigerantes').contains('Sim') ||
            s('t3_q5_doces').contains('Sim') ||
            s('t6_2m_bebidas_adocadas') == 'Sim' ||
            s('t6_2m_doces_guloseimas') == 'Sim') {
          hasSugaryDiet = true;
        }
        if (s('t5_hd_chupeta').contains('Sim') ||
            s('t5_hd_dedo').contains('Sim') ||
            s('t5_hd_outros').contains('Sim') ||
            s('t5_hd_bruxismo').contains('Sim') ||
            s('t5_hmat_respiracao').contains('Bucal')) {
          hasDeleteriousHabit = true;
        }
        if (s('t5_hmat_respiracao').contains('Bucal')) {
          comorbidities['Respiração Bucal'] = (comorbidities['Respiração Bucal'] ?? 0) + 1;
        }
        if (s('t5_hma_alergia').contains('Sim')) {
          hasAllergy = true;
          comorbidities['Alergias'] = (comorbidities['Alergias'] ?? 0) + 1;
        }
        final ocl = s('t9_mp_oclusao');
        if (ocl.isNotEmpty) {
          angleOcclusion[ocl] = (angleOcclusion[ocl] ?? 0) + 1;
          if (ocl != 'Normal') hasMalocclusion = true;
        }
        final pf = s('t9_facial_perfil');
        if (pf.isNotEmpty) facialProfile[pf] = (facialProfile[pf] ?? 0) + 1;
        final pc = ped['t8_perfil_carie'];
        if (pc is List) {
          for (final item in pc) {
            final label = item.toString().trim();
            if (label.isEmpty) continue;
            cariesProfile[label] = (cariesProfile[label] ?? 0) + 1;
            if (label.toLowerCase().contains('com experiência')) hasCaries = true;
          }
        }
      }

      // Parse Odontograma
      int pCpod = 0;
      if (odo != null && odo['teeth'] is List) {
        final teeth = odo['teeth'] as List;
        for (final t in teeth) {
          if (t is! Map) continue;
          final cond = (t['condition'] ?? t['Condition'] ?? 'healthy').toString();
          final tn = int.tryParse((t['toothNumber'] ?? t['ToothNumber'] ?? '0').toString()) ?? 0;
          conditionCounts[cond] = (conditionCounts[cond] ?? 0) + 1;
          final lc = cond.toLowerCase();
          if (lc != 'healthy' && tn > 0) toothCounts[tn] = (toothCounts[tn] ?? 0) + 1;
          if (lc == 'decayed' || lc == 'missing' || lc == 'restored') pCpod++;
          if (lc == 'decayed') hasCaries = true;
          if (lc == 'missing' || lc == 'endodontic') hasExtractionOrEndo = true;
        }
        if (teeth.isNotEmpty) cpodValues.add(pCpod.toDouble());
      }

      final pAppts = filteredAppts.where((a) => a.patientId == p.id).toList();
      final hasMissed = pAppts.any((a) {
        final st = a.status.toLowerCase();
        return st == 'noshow' || st == 'missed';
      });
      final pEvos = filteredEvos.where((e) => e.patientId == p.id).toList();
      final pItems = treatmentItems.where((ti) => ti.planId == p.id || ti.planId.contains(p.id)).toList();
      final completedProcs = pItems.where((ti) => ti.status.toLowerCase() == 'completed').length;
      if (pItems.any((ti) {
        final n = ti.procedureName.toLowerCase();
        return n.contains('exodontia') || n.contains('canal') || n.contains('endod');
      })) {
        hasExtractionOrEndo = true;
      }

      final hasLgpd = p.lgpdConsent || (tcle != null && tcle['accepted'] == true);

      patientDataset.add({
        'code': 'P${idx.toString().padLeft(3, '0')}',
        'age': age,
        'ageGroup': _ageGroup(age),
        'gender': gender,
        'city': city,
        'cpod': pCpod,
        'hasCaries': hasCaries,
        'hasExtractionOrEndo': hasExtractionOrEndo,
        'hasComorbidity': hasComorb,
        'hasAllergy': hasAllergy,
        'hasSugaryDiet': hasSugaryDiet,
        'hasDeleteriousHabit': hasDeleteriousHabit,
        'hasMalocclusion': hasMalocclusion,
        'ipvPercent': latestIpv != null ? double.parse(latestIpv.toStringAsFixed(1)) : null,
        'isgPercent': latestIsg != null ? double.parse(latestIsg.toStringAsFixed(1)) : null,
        'highIpv': latestIpv != null && latestIpv >= 20.0,
        'highDtmRisk': highDtmRisk,
        'hasMissedAppointment': hasMissed,
        'totalAppointments': pAppts.length,
        'completedProcedures': completedProcs,
        'hasAnamnese': anam != null,
        'hasOdontogram': odo != null,
        'hasTreatmentPlan': pItems.isNotEmpty,
        'hasEvolution': pEvos.isNotEmpty,
        'hasLgpdConsent': hasLgpd,
        'hasOdontopediatria': ped != null,
        'hasDtm': dtm != null,
        'hasPpr': ppr != null,
        'hasEndodontia': endodontia != null,
        'hasPeriograma': periograma != null,
      });
      idx++;
    }

    // Agenda / Gestão
    final statusBreakdown = <String, int>{};
    int missedAppts = 0;
    int cancelledAppts = 0;
    int completedAppts = 0;
    final byClinicMap = <String, List<AppointmentsLocalData>>{};

    for (final a in filteredAppts) {
      statusBreakdown[a.status] = (statusBreakdown[a.status] ?? 0) + 1;
      final st = a.status.toLowerCase();
      if (st == 'noshow' || st == 'missed') missedAppts++;
      if (st == 'cancelled') cancelledAppts++;
      if (st == 'completed') completedAppts++;
      final cname = clinicNames[a.clinicId] ?? 'Clínica Geral';
      byClinicMap.putIfAbsent(cname, () => []).add(a);
    }

    final absenteeismByClinic = byClinicMap.entries.map((e) {
      final total = e.value.length;
      final missed = e.value.where((a) => a.status.toLowerCase() == 'noshow' || a.status.toLowerCase() == 'missed').length;
      final cancelled = e.value.where((a) => a.status.toLowerCase() == 'cancelled').length;
      final completed = e.value.where((a) => a.status.toLowerCase() == 'completed').length;
      return {
        'clinic': e.key,
        'total': total,
        'completed': completed,
        'missed': missed,
        'cancelled': cancelled,
        'absenteeismRate': _pct(missed, total),
      };
    }).toList()
      ..sort((a, b) => (b['total'] as int).compareTo(a['total'] as int));

    const weekdays = [(1, 'Seg'), (2, 'Ter'), (3, 'Qua'), (4, 'Qui'), (5, 'Sex'), (6, 'Sáb')];
    final absenteeismByWeekday = weekdays.map((w) {
      final list = filteredAppts.where((a) => a.startTime.weekday == w.$1).toList();
      final missed = list.where((a) => a.status.toLowerCase() == 'noshow' || a.status.toLowerCase() == 'missed').length;
      return {'day': w.$2, 'total': list.length, 'missed': missed, 'rate': _pct(missed, list.length)};
    }).toList();

    const periods = [('Manhã (07h–12h)', 0, 12), ('Tarde (12h–18h)', 12, 18), ('Noite (18h+)', 18, 24)];
    final absenteeismByPeriod = periods.map((per) {
      final list = filteredAppts.where((a) => a.startTime.hour >= per.$2 && a.startTime.hour < per.$3).toList();
      final missed = list.where((a) => a.status.toLowerCase() == 'noshow' || a.status.toLowerCase() == 'missed').length;
      return {'period': per.$1, 'total': list.length, 'missed': missed, 'rate': _pct(missed, list.length)};
    }).toList();

    // Série mensal (6 meses)
    final monthlyTrend = <Map<String, dynamic>>[];
    for (int i = 5; i >= 0; i--) {
      final mStart = DateTime(now.year, now.month - i, 1);
      final mEnd = DateTime(mStart.year, mStart.month + 1, 1);
      final mAppts = filteredAppts.where((a) => !a.startTime.isBefore(mStart) && a.startTime.isBefore(mEnd)).toList();
      final mEvos = filteredEvos.where((e) => !e.createdAt.isBefore(mStart) && e.createdAt.isBefore(mEnd)).length;
      monthlyTrend.add({
        'month': DateFormat('MM/yyyy').format(mStart),
        'appointments': mAppts.length,
        'completed': mAppts.where((a) => a.status.toLowerCase() == 'completed').length,
        'missed': mAppts.where((a) => a.status.toLowerCase() == 'noshow' || a.status.toLowerCase() == 'missed').length,
        'evolutions': mEvos,
        'proceduresCompleted': 0,
      });
    }

    // Produtividade
    final byStudent = <String, List<EvolutionsLocalData>>{};
    final byProf = <String, List<EvolutionsLocalData>>{};
    for (final e in filteredEvos) {
      final sn = (e.studentName ?? '').trim().isEmpty ? 'Não informado' : e.studentName!.trim();
      final pn = (e.professorName ?? '').trim().isEmpty ? 'Não informado' : e.professorName!.trim();
      byStudent.putIfAbsent(sn, () => []).add(e);
      byProf.putIfAbsent(pn, () => []).add(e);
    }

    final signedEvos = filteredEvos.where((e) => e.isSignedByProfessor).length;
    final signHours = filteredEvos
        .where((e) => e.isSignedByProfessor && e.signedAt != null)
        .map((e) => e.signedAt!.difference(e.createdAt).inMinutes / 60.0)
        .where((h) => h >= 0)
        .toList();

    final scopedCount = scopedPatients.length;
    final lgpdCount = patientDataset.where((r) => r['hasLgpdConsent'] == true).length;

    // Procedimentos locais
    final procMap = <String, List<TreatmentItemsLocalData>>{};
    for (final ti in treatmentItems) {
      procMap.putIfAbsent(ti.procedureName, () => []).add(ti);
    }
    final procBreakdown = procMap.entries.map((e) => {
      'procedure': e.key,
      'total': e.value.length,
      'completed': e.value.where((i) => i.status.toLowerCase() == 'completed').length,
      'inProgress': e.value.where((i) => i.status.toLowerCase() == 'inprogress').length,
      'pending': e.value.where((i) => i.status.toLowerCase() == 'pending').length,
      'cancelled': e.value.where((i) => i.status.toLowerCase() == 'canceled' || i.status.toLowerCase() == 'cancelled').length,
    }).toList()
      ..sort((a, b) => (b['total'] as int).compareTo(a['total'] as int));

    final topTeeth = toothCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return {
      'generatedAt': DateTime.now().toIso8601String(),
      'source': 'local_sqlite',
      'epidemiological': {
        'totalPatients': scopedCount,
        'averageAge': _round1(StatisticalEngine.mean(ages)),
        'medianAge': _round1(StatisticalEngine.median(ages)),
        'stdDevAge': _round1(StatisticalEngine.stdDev(ages)),
        'ageGroups': ageGroups,
        'genderDistribution': genderDist,
        'cityDistribution': cityDist,
        'odontogram': {
          'evaluatedPatients': patientDataset.where((r) => r['hasOdontogram'] == true).length,
          'cpodMean': _round1(StatisticalEngine.mean(cpodValues)),
          'cpodMedian': _round1(StatisticalEngine.median(cpodValues)),
          'conditions': conditionCounts,
          'topAffectedTeeth': topTeeth.take(10).map((e) => {'tooth': e.key, 'count': e.value}).toList(),
        },
        'comorbidities': comorbidities,
        'dtmRisks': dtmRisks,
        'pediatric': {
          'evaluatedSheets': sheetCounts['odontopediatria'],
          'ipvMean': _round1(StatisticalEngine.mean(ipvValues)),
          'ipvMedian': _round1(StatisticalEngine.median(ipvValues)),
          'isgMean': _round1(StatisticalEngine.mean(isgValues)),
          'isgMedian': _round1(StatisticalEngine.median(isgValues)),
          'angleOcclusion': angleOcclusion,
          'facialProfile': facialProfile,
          'cariesProfile': cariesProfile,
        },
        'sheetCounts': sheetCounts,
      },
      'longitudinal': {
        'ipvEvolution': {'pairedPatients': 0, 'meanV1': 0.0, 'meanLatest': 0.0, 'delta': 0.0},
        'isgEvolution': {'pairedPatients': 0, 'meanV1': 0.0, 'meanLatest': 0.0, 'delta': 0.0},
        'treatmentPlans': {
          'totalPlans': patientDataset.where((r) => r['hasTreatmentPlan'] == true).length,
          'approvedPlans': patientDataset.where((r) => r['hasTreatmentPlan'] == true).length,
          'completedPlans': 0,
          'completionRate': 0.0,
          'avgDaysToComplete': 0.0,
          'procedures': procBreakdown.take(15).toList(),
        },
        'prescriptionsAndCertificates': {
          'totalPrescriptions': 0,
          'topMedications': const <Map<String, dynamic>>[],
          'totalCertificates': 0,
          'avgRestDays': 0.0,
          'topCids': const <Map<String, dynamic>>[],
        },
        'monthlyTrend': monthlyTrend,
      },
      'management': {
        'totalAppointments': filteredAppts.length,
        'completedAppointments': completedAppts,
        'missedAppointments': missedAppts,
        'cancelledAppointments': cancelledAppts,
        'absenteeismRate': _pct(missedAppts, filteredAppts.length),
        'completionRate': _pct(completedAppts, filteredAppts.length),
        'statusBreakdown': statusBreakdown,
        'absenteeismByClinic': absenteeismByClinic,
        'absenteeismByWeekday': absenteeismByWeekday,
        'absenteeismByPeriod': absenteeismByPeriod,
        'timing': {'avgWaitMinutes': 0.0, 'avgDelayMinutes': 0.0, 'avgDurationMinutes': 0.0, 'samples': 0},
        'productivityByStudent': byStudent.entries
            .map((e) => {
                  'name': e.key,
                  'evolutions': e.value.length,
                  'signed': e.value.where((x) => x.isSignedByProfessor).length,
                })
            .toList()
          ..sort((a, b) => (b['evolutions'] as int).compareTo(a['evolutions'] as int)),
        'productivityByProfessor': byProf.entries
            .map((e) => {
                  'name': e.key,
                  'evolutions': e.value.length,
                  'signed': e.value.where((x) => x.isSignedByProfessor).length,
                })
            .toList()
          ..sort((a, b) => (b['evolutions'] as int).compareTo(a['evolutions'] as int)),
        'waitList': {
          'total': filteredWaitList.length,
          'pending': filteredWaitList.length,
          'resolved': 0,
          'avgWaitDays': filteredWaitList.isEmpty
              ? 0.0
              : _round1(StatisticalEngine.mean(
                  filteredWaitList.map((w) => now.difference(w.createdAt).inHours / 24.0).toList(),
                )),
        },
      },
      'quality': {
        'completeness': {
          'anamnese': {'count': sheetCounts['anamnese'], 'percent': _pct(sheetCounts['anamnese']!, scopedCount)},
          'odontograma': {
            'count': patientDataset.where((r) => r['hasOdontogram'] == true).length,
            'percent': _pct(patientDataset.where((r) => r['hasOdontogram'] == true).length, scopedCount),
          },
          'planoTratamento': {
            'count': patientDataset.where((r) => r['hasTreatmentPlan'] == true).length,
            'percent': _pct(patientDataset.where((r) => r['hasTreatmentPlan'] == true).length, scopedCount),
          },
          'evolucao': {
            'count': patientDataset.where((r) => r['hasEvolution'] == true).length,
            'percent': _pct(patientDataset.where((r) => r['hasEvolution'] == true).length, scopedCount),
          },
          'tcleLgpd': {'count': lgpdCount, 'percent': _pct(lgpdCount, scopedCount)},
          'extraoral': {'count': sheetCounts['extraoral'], 'percent': _pct(sheetCounts['extraoral']!, scopedCount)},
          'intraoral': {'count': sheetCounts['intraoral'], 'percent': _pct(sheetCounts['intraoral']!, scopedCount)},
          'periograma': {'count': sheetCounts['periograma'], 'percent': _pct(sheetCounts['periograma']!, scopedCount)},
          'endodontia': {'count': sheetCounts['endodontia'], 'percent': _pct(sheetCounts['endodontia']!, scopedCount)},
          'ppr': {'count': sheetCounts['ppr'], 'percent': _pct(sheetCounts['ppr']!, scopedCount)},
          'dtm': {'count': sheetCounts['dtm'], 'percent': _pct(sheetCounts['dtm']!, scopedCount)},
          'odontopediatria': {
            'count': sheetCounts['odontopediatria'],
            'percent': _pct(sheetCounts['odontopediatria']!, scopedCount),
          },
        },
        'governance': {
          'totalEvolutions': filteredEvos.length,
          'signedEvolutions': signedEvos,
          'pendingSignatures': filteredEvos.length - signedEvos,
          'signedRate': _pct(signedEvos, filteredEvos.length),
          'avgHoursToSign': _round1(StatisticalEngine.mean(signHours)),
        },
        'lgpd': {
          'adherentPatients': lgpdCount,
          'totalPatients': scopedCount,
          'adherenceRate': _pct(lgpdCount, scopedCount),
        },
      },
      'patientDataset': patientDataset,
    };
  }

  static double? _computeGridPercent(dynamic grid) {
    if (grid is! Map) return null;
    int total = 0;
    int pos = 0;
    for (final tooth in grid.values) {
      if (tooth is Map) {
        for (final v in tooth.values) {
          final s = v.toString().trim();
          if (s == '0' || s == '1') {
            total++;
            if (s == '1') pos++;
          }
        }
      }
    }
    return total == 0 ? null : (pos / total) * 100.0;
  }

  static int _computeAge(DateTime birthDate, DateTime now) {
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age < 0 ? 0 : age;
  }

  static String _ageGroup(int age) {
    if (age <= 5) return '0-5 anos';
    if (age <= 11) return '6-11 anos';
    if (age <= 17) return '12-17 anos';
    if (age <= 29) return '18-29 anos';
    if (age <= 49) return '30-49 anos';
    if (age <= 64) return '50-64 anos';
    return '65+ anos';
  }

  static String _normalizeGender(String? g) {
    final s = (g ?? '').trim().toUpperCase();
    if (s.startsWith('M')) return 'Masculino';
    if (s.startsWith('F')) return 'Feminino';
    return 'Não informado / Outro';
  }

  static double _pct(int n, int d) => d == 0 ? 0.0 : double.parse(((n / d) * 100.0).toStringAsFixed(1));

  static double _round1(double v) => double.parse(v.toStringAsFixed(1));
}
