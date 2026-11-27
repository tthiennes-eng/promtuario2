using System.Text.Json;
using DentalClinic.Core.Domain.Repositories;
using DentalClinic.Core.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Memory;

namespace DentalClinic.Infrastructure.Persistence.Repositories;

/// <summary>
/// Implementação do repositório de relatórios e indicadores utilizando dados reais do Banco de Dados.
/// </summary>
public class ReportRepository : IReportRepository
{
    private readonly ApplicationDbContext _context;
    private readonly IMemoryCache? _cache;

    public ReportRepository(ApplicationDbContext context, IMemoryCache? cache = null)
    {
        _context = context;
        _cache = cache;
    }

    public async Task<DashboardStats> GetDashboardStatsAsync()
    {
        var totalPatients = await _context.Patients.CountAsync();

        var today = DateTime.UtcNow.Date;
        var tomorrow = today.AddDays(1);
        var firstDayOfMonth = new DateTime(today.Year, today.Month, 1, 0, 0, 0, DateTimeKind.Utc);

        var appointmentsToday = await _context.Appointments
            .CountAsync(a => a.StartTime >= today && a.StartTime < tomorrow
                && a.Status != AppointmentStatus.Cancelled
                && a.Status != AppointmentStatus.NoShow
                && a.Status != AppointmentStatus.Missed);

        var proceduresThisMonth = await _context.Set<TreatmentItem>()
            .CountAsync(i => i.Status == TreatmentItemStatus.Completed && i.UpdatedAt >= firstDayOfMonth);

        var pendingAlerts = await _context.Evolutions
            .CountAsync(e => !e.IsSignedByProfessor);

        var growthData = new List<MonthlyGrowth>();
        for (int i = 5; i >= 0; i--)
        {
            var monthDate = today.AddMonths(-i);
            var start = new DateTime(monthDate.Year, monthDate.Month, 1, 0, 0, 0, DateTimeKind.Utc);
            var end = start.AddMonths(1);

            var count = await _context.Appointments
                .CountAsync(a => a.StartTime >= start && a.StartTime < end && a.Status == AppointmentStatus.Completed);

            growthData.Add(new MonthlyGrowth(monthDate.ToString("MMM"), count));
        }

        return new DashboardStats(
            totalPatients,
            appointmentsToday,
            proceduresThisMonth,
            pendingAlerts,
            growthData
        );
    }

    public async Task<IEnumerable<ProductionReport>> GetProductionByProfessionalAsync(DateTime start, DateTime end)
    {
        var startUtc = NormalizeUtc(start);
        var endUtc = NormalizeUtc(end);

        var report = await _context.Evolutions
            .Where(e => e.CreatedAt >= startUtc && e.CreatedAt <= endUtc && e.IsSignedByProfessor)
            .GroupBy(e => e.Professor.Name)
            .Select(g => new ProductionReport(
                g.Key,
                "Professor",
                g.Count(),
                0
            ))
            .ToListAsync();

        return report;
    }

    public async Task<Dictionary<string, object>> GetStatisticalStudiesAsync(DateTime? start, DateTime? end, Guid? clinicId)
    {
        DateTime? startUtc = start.HasValue ? NormalizeUtc(start.Value) : null;
        DateTime? endUtc = end.HasValue ? NormalizeUtc(end.Value) : null;

        var cacheKey = $"stats:{startUtc?.ToString("yyyyMMddHH") ?? "all"}:{endUtc?.ToString("yyyyMMddHH") ?? "all"}:{clinicId?.ToString() ?? "all"}";
        if (_cache != null && _cache.TryGetValue(cacheKey, out Dictionary<string, object>? cached) && cached != null)
        {
            return cached;
        }

        var clinics = await SafeLoadAsync(() => _context.Clinics.AsNoTracking().ToListAsync());

        // Aplica filtros de data e clínica diretamente no SQL antes de materializar
        var filteredAppointments = await SafeLoadAsync(() =>
        {
            var q = _context.Appointments.AsNoTracking().AsQueryable();
            if (startUtc.HasValue) q = q.Where(a => a.StartTime >= startUtc.Value);
            if (endUtc.HasValue) q = q.Where(a => a.StartTime <= endUtc.Value);
            if (clinicId.HasValue) q = q.Where(a => a.ClinicId == clinicId.Value);
            return q.ToListAsync();
        });

        var filteredEvolutions = await SafeLoadAsync(() =>
        {
            var q = _context.Evolutions.AsNoTracking()
                .Include(e => e.Student)
                .Include(e => e.Professor)
                .Include(e => e.Clinic)
                .AsQueryable();
            if (startUtc.HasValue) q = q.Where(e => e.CreatedAt >= startUtc.Value);
            if (endUtc.HasValue) q = q.Where(e => e.CreatedAt <= endUtc.Value);
            if (clinicId.HasValue) q = q.Where(e => e.ClinicId == clinicId.Value);
            return q.ToListAsync();
        });

        var filteredPlans = await SafeLoadAsync(() =>
        {
            var q = _context.TreatmentPlans.AsNoTracking().Include(p => p.Items).AsQueryable();
            if (startUtc.HasValue) q = q.Where(p => p.CreatedAt >= startUtc.Value);
            if (endUtc.HasValue) q = q.Where(p => p.CreatedAt <= endUtc.Value);
            return q.ToListAsync();
        });

        var filteredPrescriptions = await SafeLoadAsync(() =>
        {
            var q = _context.Prescriptions.AsNoTracking().AsQueryable();
            if (startUtc.HasValue) q = q.Where(p => p.CreatedAt >= startUtc.Value);
            if (endUtc.HasValue) q = q.Where(p => p.CreatedAt <= endUtc.Value);
            if (clinicId.HasValue) q = q.Where(p => p.ClinicId == clinicId.Value);
            return q.ToListAsync();
        });

        var filteredCertificates = await SafeLoadAsync(() =>
        {
            var q = _context.Certificates.AsNoTracking().AsQueryable();
            if (startUtc.HasValue) q = q.Where(c => c.CreatedAt >= startUtc.Value);
            if (endUtc.HasValue) q = q.Where(c => c.CreatedAt <= endUtc.Value);
            if (clinicId.HasValue) q = q.Where(c => c.ClinicId == clinicId.Value);
            return q.ToListAsync();
        });

        var filteredWaitList = await SafeLoadAsync(() =>
        {
            var q = _context.WaitListEntries.AsNoTracking().AsQueryable();
            if (startUtc.HasValue) q = q.Where(w => w.CreatedAt >= startUtc.Value);
            if (endUtc.HasValue) q = q.Where(w => w.CreatedAt <= endUtc.Value);
            if (clinicId.HasValue) q = q.Where(w => w.ClinicId == clinicId.Value);
            return q.ToListAsync();
        });

        var patients = await SafeLoadAsync(() =>
        {
            if (clinicId.HasValue)
            {
                var ids = filteredAppointments.Select(a => a.PatientId)
                    .Concat(filteredEvolutions.Select(e => e.PatientId))
                    .Distinct()
                    .ToList();
                return _context.Patients.AsNoTracking().Where(p => ids.Contains(p.Id)).ToListAsync();
            }
            return _context.Patients.AsNoTracking().ToListAsync();
        });

        var scopedPatientIds = patients.Select(p => p.Id).ToHashSet();
        var scopedPatients = patients;

        var odontograms = await SafeLoadAsync(() =>
            _context.Odontograms.AsNoTracking()
                .Where(o => scopedPatientIds.Contains(o.PatientId))
                .ToListAsync());
        var clinicalSheets = await SafeLoadAsync(() =>
            _context.ClinicalSheets.AsNoTracking()
                .Where(s => scopedPatientIds.Contains(s.PatientId))
                .OrderBy(s => s.Version)
                .ThenBy(s => s.CreatedAt)
                .ToListAsync());
        var legacyAnamneses = await SafeLoadAsync(() =>
            _context.Anamneses.AsNoTracking()
                .Where(a => scopedPatientIds.Contains(a.PatientId))
                .ToListAsync());

        var clinicNames = clinics.ToDictionary(c => c.Id, c => c.Name);

        // Agrupa fichas clínicas por paciente e tipo
        var sheetsByPatientAndType = clinicalSheets
            .Where(s => scopedPatientIds.Contains(s.PatientId))
            .GroupBy(s => (s.PatientId, Type: s.SheetType.Trim().ToLowerInvariant()))
            .ToDictionary(g => g.Key, g => g.OrderBy(x => x.Version).ThenBy(x => x.CreatedAt).ToList());

        var legacyAnamneseByPatient = legacyAnamneses
            .Where(a => scopedPatientIds.Contains(a.PatientId))
            .GroupBy(a => a.PatientId)
            .ToDictionary(g => g.Key, g => g.OrderByDescending(x => x.CreatedAt).First());

        var latestOdontogramByPatient = odontograms
            .Where(o => scopedPatientIds.Contains(o.PatientId))
            .GroupBy(o => o.PatientId)
            .ToDictionary(g => g.Key, g => g.OrderByDescending(x => x.UpdatedAt ?? x.CreatedAt).First());

        // =========================================================================
        // 1. ESTUDO EPIDEMIOLÓGICO DESCRITIVO
        // =========================================================================
        var now = DateTime.UtcNow;
        var ages = new List<double>();
        var ageGroups = new Dictionary<string, int>
        {
            ["0-5 anos"] = 0,
            ["6-11 anos"] = 0,
            ["12-17 anos"] = 0,
            ["18-29 anos"] = 0,
            ["30-49 anos"] = 0,
            ["50-64 anos"] = 0,
            ["65+ anos"] = 0,
        };
        var genderDistribution = new Dictionary<string, int>();
        var cityDistribution = new Dictionary<string, int>(StringComparer.OrdinalIgnoreCase);

        foreach (var p in scopedPatients)
        {
            var age = ComputeAge(p.BirthDate, now);
            if (age >= 0 && age <= 120)
            {
                ages.Add(age);
                var group = AgeGroupLabel(age);
                ageGroups[group] = ageGroups.GetValueOrDefault(group) + 1;
            }

            var gLabel = NormalizeGender(p.Gender);
            genderDistribution[gLabel] = genderDistribution.GetValueOrDefault(gLabel) + 1;

            var city = string.IsNullOrWhiteSpace(p.Address?.City) ? "Não informada" : p.Address!.City.Trim();
            cityDistribution[city] = cityDistribution.GetValueOrDefault(city) + 1;
        }

        // Odontograma / CPO-D
        var conditionCounts = new Dictionary<string, int>();
        var toothCounts = new Dictionary<int, int>();
        var cpodValues = new List<double>();

        foreach (var odo in latestOdontogramByPatient.Values)
        {
            int cpod = 0;
            foreach (var tooth in odo.Teeth)
            {
                var condKey = tooth.Condition.ToString();
                conditionCounts[condKey] = conditionCounts.GetValueOrDefault(condKey) + 1;
                if (tooth.Condition != ConditionType.Healthy)
                {
                    toothCounts[tooth.ToothNumber] = toothCounts.GetValueOrDefault(tooth.ToothNumber) + 1;
                }
                if (tooth.Condition is ConditionType.Decayed or ConditionType.Missing or ConditionType.Restored)
                {
                    cpod++;
                }
            }
            if (odo.Teeth.Count > 0)
            {
                cpodValues.Add(cpod);
            }
        }

        // Comorbidades, DTM, Odontopediatria, Fichas Clínicas
        var comorbiditiesCount = new Dictionary<string, int>();
        var dtmRisks = new Dictionary<string, Dictionary<string, int>>
        {
            ["carie"] = new() { ["baixo"] = 0, ["moderado"] = 0, ["alto"] = 0 },
            ["oclusal"] = new() { ["baixo"] = 0, ["moderado"] = 0, ["alto"] = 0 },
            ["dtm"] = new() { ["baixo"] = 0, ["moderado"] = 0, ["alto"] = 0 },
        };
        var ipvValues = new List<double>();
        var isgValues = new List<double>();
        var angleOcclusionCounts = new Dictionary<string, int>();
        var facialProfileCounts = new Dictionary<string, int>();
        var cariesProfileCounts = new Dictionary<string, int>();

        // Evolução longitudinal de IPV/ISG (v1 -> vN)
        var ipvV1List = new List<double>();
        var ipvVNList = new List<double>();
        var isgV1List = new List<double>();
        var isgVNList = new List<double>();

        var sheetTypes = new[] { "anamnese", "extraoral", "intraoral", "periograma", "endodontia", "ppr", "dtm", "odontopediatria", "tcle" };
        var sheetPatientCounts = sheetTypes.ToDictionary(t => t, _ => 0);

        // Dataset anonimizado para cruzamentos 2x2 e exportação CSV
        var patientDataset = new List<Dictionary<string, object?>>();
        var appointmentsByPatient = filteredAppointments.GroupBy(a => a.PatientId).ToDictionary(g => g.Key, g => g.ToList());
        var plansByPatient = filteredPlans.GroupBy(p => p.PatientId).ToDictionary(g => g.Key, g => g.ToList());
        var evolutionsByPatient = filteredEvolutions.GroupBy(e => e.PatientId).ToDictionary(g => g.Key, g => g.ToList());

        int pIndex = 1;
        foreach (var p in scopedPatients.OrderBy(x => x.CreatedAt))
        {
            var age = ComputeAge(p.BirthDate, now);
            var gLabel = NormalizeGender(p.Gender);
            var city = string.IsNullOrWhiteSpace(p.Address?.City) ? "Não informada" : p.Address!.City.Trim();

            bool hasComorbidity = false;
            bool hasAllergy = false;
            bool hasSugaryDiet = false;
            bool hasDeleteriousHabit = false;
            bool hasMalocclusion = false;
            bool hasCaries = false;
            bool highDtmRisk = false;
            double? latestIpv = null;
            double? latestIsg = null;

            foreach (var st in sheetTypes)
            {
                bool present = sheetsByPatientAndType.ContainsKey((p.Id, st)) ||
                    (st == "anamnese" && legacyAnamneseByPatient.ContainsKey(p.Id));
                if (present) sheetPatientCounts[st]++;
            }

            // Analisa Anamnese (prontuario_fichas ou legada)
            string? anamneseJson = sheetsByPatientAndType.TryGetValue((p.Id, "anamnese"), out var anamList)
                ? anamList.Last().DataJson
                : (legacyAnamneseByPatient.TryGetValue(p.Id, out var legAnam) ? legAnam.RespostasJson : null);

            if (!string.IsNullOrWhiteSpace(anamneseJson))
            {
                ParseAnamnese(anamneseJson, comorbiditiesCount, ref hasComorbidity, ref hasAllergy);
            }

            // Analisa DTM
            if (sheetsByPatientAndType.TryGetValue((p.Id, "dtm"), out var dtmList))
            {
                ParseDtm(dtmList.Last().DataJson, dtmRisks, ref highDtmRisk);
            }

            // Analisa Odontopediatria (versão inicial vs mais recente)
            if (sheetsByPatientAndType.TryGetValue((p.Id, "odontopediatria"), out var pedList))
            {
                var latestPed = pedList.Last().DataJson;
                ParseOdontopediatria(
                    latestPed,
                    comorbiditiesCount,
                    angleOcclusionCounts,
                    facialProfileCounts,
                    cariesProfileCounts,
                    ref hasComorbidity,
                    ref hasAllergy,
                    ref hasSugaryDiet,
                    ref hasDeleteriousHabit,
                    ref hasMalocclusion,
                    ref hasCaries,
                    out latestIpv,
                    out latestIsg);

                if (latestIpv.HasValue) ipvValues.Add(latestIpv.Value);
                if (latestIsg.HasValue) isgValues.Add(latestIsg.Value);

                if (pedList.Count >= 2)
                {
                    var firstIpv = ComputeBinaryGridPercent(pedList.First().DataJson, "t7_ipv_grid");
                    var lastIpv = ComputeBinaryGridPercent(pedList.Last().DataJson, "t7_ipv_grid");
                    if (firstIpv.HasValue && lastIpv.HasValue)
                    {
                        ipvV1List.Add(firstIpv.Value);
                        ipvVNList.Add(lastIpv.Value);
                    }

                    var firstIsg = ComputeBinaryGridPercent(pedList.First().DataJson, "t7_isg_grid");
                    var lastIsg = ComputeBinaryGridPercent(pedList.Last().DataJson, "t7_isg_grid");
                    if (firstIsg.HasValue && lastIsg.HasValue)
                    {
                        isgV1List.Add(firstIsg.Value);
                        isgVNList.Add(lastIsg.Value);
                    }
                }
            }

            // Odontograma do paciente
            int patientCpod = 0;
            bool hasExtractionOrEndo = false;
            if (latestOdontogramByPatient.TryGetValue(p.Id, out var pOdo))
            {
                foreach (var t in pOdo.Teeth)
                {
                    if (t.Condition is ConditionType.Decayed or ConditionType.Missing or ConditionType.Restored)
                        patientCpod++;
                    if (t.Condition == ConditionType.Decayed)
                        hasCaries = true;
                    if (t.Condition is ConditionType.Missing or ConditionType.Endodontic)
                        hasExtractionOrEndo = true;
                }
            }

            // Planos de tratamento do paciente
            int completedProcs = 0;
            bool hasTreatmentPlan = false;
            if (plansByPatient.TryGetValue(p.Id, out var pPlans))
            {
                hasTreatmentPlan = pPlans.Count > 0;
                foreach (var plan in pPlans)
                {
                    foreach (var item in plan.Items)
                    {
                        if (item.Status == TreatmentItemStatus.Completed) completedProcs++;
                        var pn = (item.ProcedureName ?? "").ToLowerInvariant();
                        if (pn.Contains("exodontia") || pn.Contains("canal") || pn.Contains("endod"))
                            hasExtractionOrEndo = true;
                    }
                }
            }

            // Agendamentos do paciente
            bool hasMissed = false;
            int totalApptsPatient = 0;
            if (appointmentsByPatient.TryGetValue(p.Id, out var pAppts))
            {
                totalApptsPatient = pAppts.Count;
                hasMissed = pAppts.Any(a => a.Status is AppointmentStatus.NoShow or AppointmentStatus.Missed);
            }

            bool hasTcleSigned = p.LgpdConsent ||
                (sheetsByPatientAndType.TryGetValue((p.Id, "tcle"), out var tcleList) && IsTcleAccepted(tcleList.Last().DataJson));

            patientDataset.Add(new Dictionary<string, object?>
            {
                ["code"] = $"P{pIndex:000}",
                ["age"] = age,
                ["ageGroup"] = AgeGroupLabel(age),
                ["gender"] = gLabel,
                ["city"] = city,
                ["cpod"] = patientCpod,
                ["hasCaries"] = hasCaries,
                ["hasExtractionOrEndo"] = hasExtractionOrEndo,
                ["hasComorbidity"] = hasComorbidity,
                ["hasAllergy"] = hasAllergy,
                ["hasSugaryDiet"] = hasSugaryDiet,
                ["hasDeleteriousHabit"] = hasDeleteriousHabit,
                ["hasMalocclusion"] = hasMalocclusion,
                ["ipvPercent"] = latestIpv.HasValue ? Math.Round(latestIpv.Value, 1) : null,
                ["isgPercent"] = latestIsg.HasValue ? Math.Round(latestIsg.Value, 1) : null,
                ["highIpv"] = latestIpv.HasValue && latestIpv.Value >= 20.0,
                ["highDtmRisk"] = highDtmRisk,
                ["hasMissedAppointment"] = hasMissed,
                ["totalAppointments"] = totalApptsPatient,
                ["completedProcedures"] = completedProcs,
                ["hasAnamnese"] = !string.IsNullOrWhiteSpace(anamneseJson),
                ["hasOdontogram"] = latestOdontogramByPatient.ContainsKey(p.Id),
                ["hasTreatmentPlan"] = hasTreatmentPlan,
                ["hasEvolution"] = evolutionsByPatient.ContainsKey(p.Id),
                ["hasLgpdConsent"] = hasTcleSigned,
                ["hasOdontopediatria"] = sheetsByPatientAndType.ContainsKey((p.Id, "odontopediatria")),
                ["hasDtm"] = sheetsByPatientAndType.ContainsKey((p.Id, "dtm")),
                ["hasPpr"] = sheetsByPatientAndType.ContainsKey((p.Id, "ppr")),
                ["hasEndodontia"] = sheetsByPatientAndType.ContainsKey((p.Id, "endodontia")),
                ["hasPeriograma"] = sheetsByPatientAndType.ContainsKey((p.Id, "periograma")),
            });
            pIndex++;
        }

        // =========================================================================
        // 3. ESTUDO LONGITUDINAL E EFETIVIDADE CLÍNICA
        // =========================================================================
        int totalPlans = filteredPlans.Count;
        int approvedPlans = filteredPlans.Count(p => p.Status is TreatmentPlanStatus.Approved or TreatmentPlanStatus.InProgress or TreatmentPlanStatus.Completed);
        int completedPlans = filteredPlans.Count(p => p.Status == TreatmentPlanStatus.Completed);
        var planCompletionDays = filteredPlans
            .Where(p => p.Status == TreatmentPlanStatus.Completed && p.UpdatedAt.HasValue)
            .Select(p => Math.Max(0, (p.UpdatedAt!.Value - p.CreatedAt).TotalDays))
            .ToList();

        var procedureBreakdown = filteredPlans
            .SelectMany(p => p.Items)
            .GroupBy(i => string.IsNullOrWhiteSpace(i.ProcedureName) ? "Não especificado" : i.ProcedureName.Trim())
            .Select(g => new Dictionary<string, object>
            {
                ["procedure"] = g.Key,
                ["total"] = g.Count(),
                ["completed"] = g.Count(i => i.Status == TreatmentItemStatus.Completed),
                ["inProgress"] = g.Count(i => i.Status == TreatmentItemStatus.InProgress),
                ["pending"] = g.Count(i => i.Status == TreatmentItemStatus.Pending),
                ["cancelled"] = g.Count(i => i.Status == TreatmentItemStatus.Cancelled),
            })
            .OrderByDescending(x => (int)x["total"])
            .Take(15)
            .ToList();

        var topMedications = filteredPrescriptions
            .SelectMany(p => p.Items)
            .Where(i => !string.IsNullOrWhiteSpace(i.MedicineName))
            .GroupBy(i => i.MedicineName.Trim(), StringComparer.OrdinalIgnoreCase)
            .Select(g => new Dictionary<string, object> { ["name"] = g.First().MedicineName.Trim(), ["count"] = g.Count() })
            .OrderByDescending(x => (int)x["count"])
            .Take(10)
            .ToList();

        var topCids = filteredCertificates
            .Where(c => !string.IsNullOrWhiteSpace(c.CID))
            .GroupBy(c => c.CID.Trim().ToUpperInvariant())
            .Select(g => new Dictionary<string, object> { ["cid"] = g.Key, ["count"] = g.Count() })
            .OrderByDescending(x => (int)x["count"])
            .Take(10)
            .ToList();

        var avgRestDays = filteredCertificates.Count > 0
            ? Math.Round(filteredCertificates.Average(c => c.DaysOfRest), 1)
            : 0.0;

        // Série mensal (últimos 6 meses)
        var monthlyTrend = new List<Dictionary<string, object>>();
        for (int i = 5; i >= 0; i--)
        {
            var mRef = now.AddMonths(-i);
            var mStart = new DateTime(mRef.Year, mRef.Month, 1, 0, 0, 0, DateTimeKind.Utc);
            var mEnd = mStart.AddMonths(1);

            var mAppts = filteredAppointments.Where(a => a.StartTime >= mStart && a.StartTime < mEnd).ToList();
            var mEvos = filteredEvolutions.Count(e => e.CreatedAt >= mStart && e.CreatedAt < mEnd);
            var mCompletedProcs = filteredPlans
                .SelectMany(p => p.Items)
                .Count(it => it.Status == TreatmentItemStatus.Completed && (it.UpdatedAt ?? it.CreatedAt) >= mStart && (it.UpdatedAt ?? it.CreatedAt) < mEnd);

            monthlyTrend.Add(new Dictionary<string, object>
            {
                ["month"] = mStart.ToString("MM/yyyy"),
                ["appointments"] = mAppts.Count,
                ["completed"] = mAppts.Count(a => a.Status == AppointmentStatus.Completed),
                ["missed"] = mAppts.Count(a => a.Status is AppointmentStatus.NoShow or AppointmentStatus.Missed),
                ["evolutions"] = mEvos,
                ["proceduresCompleted"] = mCompletedProcs,
            });
        }

        // =========================================================================
        // 4. ESTUDO DE GESTÃO, PRODUTIVIDADE E FLUXO ASSISTENCIAL
        // =========================================================================
        var statusBreakdown = filteredAppointments
            .GroupBy(a => a.Status.ToString())
            .ToDictionary(g => g.Key, g => g.Count());

        int totalAppts = filteredAppointments.Count;
        int missedAppts = filteredAppointments.Count(a => a.Status is AppointmentStatus.NoShow or AppointmentStatus.Missed);
        int cancelledAppts = filteredAppointments.Count(a => a.Status == AppointmentStatus.Cancelled);
        int completedAppts = filteredAppointments.Count(a => a.Status == AppointmentStatus.Completed);

        var absenteeismByClinic = filteredAppointments
            .GroupBy(a => clinicNames.TryGetValue(a.ClinicId, out var cn) ? cn : "Clínica Geral")
            .Select(g =>
            {
                int total = g.Count();
                int missed = g.Count(a => a.Status is AppointmentStatus.NoShow or AppointmentStatus.Missed);
                int cancelled = g.Count(a => a.Status == AppointmentStatus.Cancelled);
                int completed = g.Count(a => a.Status == AppointmentStatus.Completed);
                return new Dictionary<string, object>
                {
                    ["clinic"] = g.Key,
                    ["total"] = total,
                    ["completed"] = completed,
                    ["missed"] = missed,
                    ["cancelled"] = cancelled,
                    ["absenteeismRate"] = total > 0 ? Math.Round((double)missed / total * 100.0, 1) : 0.0,
                };
            })
            .OrderByDescending(x => (int)x["total"])
            .ToList();

        var weekdayOrder = new[]
        {
            (DayOfWeek.Monday, "Seg"),
            (DayOfWeek.Tuesday, "Ter"),
            (DayOfWeek.Wednesday, "Qua"),
            (DayOfWeek.Thursday, "Qui"),
            (DayOfWeek.Friday, "Sex"),
            (DayOfWeek.Saturday, "Sáb"),
        };

        var absenteeismByWeekday = weekdayOrder.Select(w =>
        {
            var list = filteredAppointments.Where(a => a.StartTime.ToLocalTime().DayOfWeek == w.Item1).ToList();
            int missed = list.Count(a => a.Status is AppointmentStatus.NoShow or AppointmentStatus.Missed);
            return new Dictionary<string, object>
            {
                ["day"] = w.Item2,
                ["total"] = list.Count,
                ["missed"] = missed,
                ["rate"] = list.Count > 0 ? Math.Round((double)missed / list.Count * 100.0, 1) : 0.0,
            };
        }).ToList();

        var periods = new[] { ("Manhã (07h–12h)", 0, 12), ("Tarde (12h–18h)", 12, 18), ("Noite (18h+)", 18, 24) };
        var absenteeismByPeriod = periods.Select(per =>
        {
            var list = filteredAppointments.Where(a =>
            {
                var h = a.StartTime.ToLocalTime().Hour;
                return h >= per.Item2 && h < per.Item3;
            }).ToList();
            int missed = list.Count(a => a.Status is AppointmentStatus.NoShow or AppointmentStatus.Missed);
            return new Dictionary<string, object>
            {
                ["period"] = per.Item1,
                ["total"] = list.Count,
                ["missed"] = missed,
                ["rate"] = list.Count > 0 ? Math.Round((double)missed / list.Count * 100.0, 1) : 0.0,
            };
        }).ToList();

        var waitMinutes = filteredAppointments
            .Where(a => a.ArrivalTime.HasValue && a.ActualStartTime.HasValue)
            .Select(a => Math.Max(0, (a.ActualStartTime!.Value - a.ArrivalTime!.Value).TotalMinutes))
            .ToList();
        var delayMinutes = filteredAppointments
            .Where(a => a.ActualStartTime.HasValue)
            .Select(a => (a.ActualStartTime!.Value - a.StartTime).TotalMinutes)
            .ToList();
        var durationMinutes = filteredAppointments
            .Where(a => a.ActualStartTime.HasValue && a.ActualEndTime.HasValue)
            .Select(a => Math.Max(0, (a.ActualEndTime!.Value - a.ActualStartTime!.Value).TotalMinutes))
            .ToList();

        var productivityByStudent = filteredEvolutions
            .GroupBy(e => string.IsNullOrWhiteSpace(e.Student?.Name) ? "Não informado" : e.Student!.Name.Trim())
            .Select(g => new Dictionary<string, object>
            {
                ["name"] = g.Key,
                ["evolutions"] = g.Count(),
                ["signed"] = g.Count(e => e.IsSignedByProfessor),
            })
            .OrderByDescending(x => (int)x["evolutions"])
            .Take(10)
            .ToList();

        var productivityByProfessor = filteredEvolutions
            .GroupBy(e => string.IsNullOrWhiteSpace(e.Professor?.Name) ? "Não informado" : e.Professor!.Name.Trim())
            .Select(g => new Dictionary<string, object>
            {
                ["name"] = g.Key,
                ["evolutions"] = g.Count(),
                ["signed"] = g.Count(e => e.IsSignedByProfessor),
            })
            .OrderByDescending(x => (int)x["evolutions"])
            .Take(10)
            .ToList();

        var waitDaysList = filteredWaitList
            .Select(w => Math.Max(0, ((w.IsResolved ? (w.UpdatedAt ?? now) : now) - w.CreatedAt).TotalDays))
            .ToList();

        // =========================================================================
        // 5. QUALIDADE DO PRONTUÁRIO, AUDITORIA E LGPD
        // =========================================================================
        int totalEvos = filteredEvolutions.Count;
        int signedEvos = filteredEvolutions.Count(e => e.IsSignedByProfessor);
        var signHours = filteredEvolutions
            .Where(e => e.IsSignedByProfessor && e.SignedAt.HasValue)
            .Select(e => Math.Max(0, (e.SignedAt!.Value - e.CreatedAt).TotalHours))
            .ToList();

        int lgpdAdherent = patientDataset.Count(r => r["hasLgpdConsent"] is true);
        int scopedCount = scopedPatients.Count;

        double Pct(int num, int den) => den > 0 ? Math.Round((double)num / den * 100.0, 1) : 0.0;

        var completeness = new Dictionary<string, object>
        {
            ["anamnese"] = new Dictionary<string, object> { ["count"] = sheetPatientCounts["anamnese"], ["percent"] = Pct(sheetPatientCounts["anamnese"], scopedCount) },
            ["odontograma"] = new Dictionary<string, object> { ["count"] = latestOdontogramByPatient.Count, ["percent"] = Pct(latestOdontogramByPatient.Count, scopedCount) },
            ["planoTratamento"] = new Dictionary<string, object> { ["count"] = patientDataset.Count(r => r["hasTreatmentPlan"] is true), ["percent"] = Pct(patientDataset.Count(r => r["hasTreatmentPlan"] is true), scopedCount) },
            ["evolucao"] = new Dictionary<string, object> { ["count"] = patientDataset.Count(r => r["hasEvolution"] is true), ["percent"] = Pct(patientDataset.Count(r => r["hasEvolution"] is true), scopedCount) },
            ["tcleLgpd"] = new Dictionary<string, object> { ["count"] = lgpdAdherent, ["percent"] = Pct(lgpdAdherent, scopedCount) },
            ["extraoral"] = new Dictionary<string, object> { ["count"] = sheetPatientCounts["extraoral"], ["percent"] = Pct(sheetPatientCounts["extraoral"], scopedCount) },
            ["intraoral"] = new Dictionary<string, object> { ["count"] = sheetPatientCounts["intraoral"], ["percent"] = Pct(sheetPatientCounts["intraoral"], scopedCount) },
            ["periograma"] = new Dictionary<string, object> { ["count"] = sheetPatientCounts["periograma"], ["percent"] = Pct(sheetPatientCounts["periograma"], scopedCount) },
            ["endodontia"] = new Dictionary<string, object> { ["count"] = sheetPatientCounts["endodontia"], ["percent"] = Pct(sheetPatientCounts["endodontia"], scopedCount) },
            ["ppr"] = new Dictionary<string, object> { ["count"] = sheetPatientCounts["ppr"], ["percent"] = Pct(sheetPatientCounts["ppr"], scopedCount) },
            ["dtm"] = new Dictionary<string, object> { ["count"] = sheetPatientCounts["dtm"], ["percent"] = Pct(sheetPatientCounts["dtm"], scopedCount) },
            ["odontopediatria"] = new Dictionary<string, object> { ["count"] = sheetPatientCounts["odontopediatria"], ["percent"] = Pct(sheetPatientCounts["odontopediatria"], scopedCount) },
        };

        var payload = new Dictionary<string, object>
        {
            ["generatedAt"] = DateTime.UtcNow,
            ["source"] = "postgresql",
            ["epidemiological"] = new Dictionary<string, object>
            {
                ["totalPatients"] = scopedCount,
                ["averageAge"] = Mean(ages),
                ["medianAge"] = Median(ages),
                ["stdDevAge"] = StdDev(ages),
                ["ageGroups"] = ageGroups,
                ["genderDistribution"] = genderDistribution,
                ["cityDistribution"] = cityDistribution
                    .OrderByDescending(kv => kv.Value)
                    .Take(10)
                    .ToDictionary(kv => kv.Key, kv => kv.Value),
                ["odontogram"] = new Dictionary<string, object>
                {
                    ["evaluatedPatients"] = latestOdontogramByPatient.Count,
                    ["cpodMean"] = Mean(cpodValues),
                    ["cpodMedian"] = Median(cpodValues),
                    ["conditions"] = conditionCounts,
                    ["topAffectedTeeth"] = toothCounts
                        .OrderByDescending(kv => kv.Value)
                        .Take(10)
                        .Select(kv => new Dictionary<string, object> { ["tooth"] = kv.Key, ["count"] = kv.Value })
                        .ToList(),
                },
                ["comorbidities"] = comorbiditiesCount
                    .OrderByDescending(kv => kv.Value)
                    .ToDictionary(kv => kv.Key, kv => kv.Value),
                ["dtmRisks"] = dtmRisks,
                ["pediatric"] = new Dictionary<string, object>
                {
                    ["evaluatedSheets"] = sheetPatientCounts["odontopediatria"],
                    ["ipvMean"] = Mean(ipvValues),
                    ["ipvMedian"] = Median(ipvValues),
                    ["isgMean"] = Mean(isgValues),
                    ["isgMedian"] = Median(isgValues),
                    ["angleOcclusion"] = angleOcclusionCounts,
                    ["facialProfile"] = facialProfileCounts,
                    ["cariesProfile"] = cariesProfileCounts,
                },
                ["sheetCounts"] = sheetPatientCounts,
            },
            ["longitudinal"] = new Dictionary<string, object>
            {
                ["ipvEvolution"] = new Dictionary<string, object>
                {
                    ["pairedPatients"] = ipvV1List.Count,
                    ["meanV1"] = Mean(ipvV1List),
                    ["meanLatest"] = Mean(ipvVNList),
                    ["delta"] = Math.Round(Mean(ipvVNList) - Mean(ipvV1List), 1),
                },
                ["isgEvolution"] = new Dictionary<string, object>
                {
                    ["pairedPatients"] = isgV1List.Count,
                    ["meanV1"] = Mean(isgV1List),
                    ["meanLatest"] = Mean(isgVNList),
                    ["delta"] = Math.Round(Mean(isgVNList) - Mean(isgV1List), 1),
                },
                ["treatmentPlans"] = new Dictionary<string, object>
                {
                    ["totalPlans"] = totalPlans,
                    ["approvedPlans"] = approvedPlans,
                    ["completedPlans"] = completedPlans,
                    ["completionRate"] = Pct(completedPlans, totalPlans),
                    ["avgDaysToComplete"] = Mean(planCompletionDays),
                    ["procedures"] = procedureBreakdown,
                },
                ["prescriptionsAndCertificates"] = new Dictionary<string, object>
                {
                    ["totalPrescriptions"] = filteredPrescriptions.Count,
                    ["topMedications"] = topMedications,
                    ["totalCertificates"] = filteredCertificates.Count,
                    ["avgRestDays"] = avgRestDays,
                    ["topCids"] = topCids,
                },
                ["monthlyTrend"] = monthlyTrend,
            },
            ["management"] = new Dictionary<string, object>
            {
                ["totalAppointments"] = totalAppts,
                ["completedAppointments"] = completedAppts,
                ["missedAppointments"] = missedAppts,
                ["cancelledAppointments"] = cancelledAppts,
                ["absenteeismRate"] = Pct(missedAppts, totalAppts),
                ["completionRate"] = Pct(completedAppts, totalAppts),
                ["statusBreakdown"] = statusBreakdown,
                ["absenteeismByClinic"] = absenteeismByClinic,
                ["absenteeismByWeekday"] = absenteeismByWeekday,
                ["absenteeismByPeriod"] = absenteeismByPeriod,
                ["timing"] = new Dictionary<string, object>
                {
                    ["avgWaitMinutes"] = Mean(waitMinutes),
                    ["avgDelayMinutes"] = Mean(delayMinutes),
                    ["avgDurationMinutes"] = Mean(durationMinutes),
                    ["samples"] = durationMinutes.Count,
                },
                ["productivityByStudent"] = productivityByStudent,
                ["productivityByProfessor"] = productivityByProfessor,
                ["waitList"] = new Dictionary<string, object>
                {
                    ["total"] = filteredWaitList.Count,
                    ["pending"] = filteredWaitList.Count(w => !w.IsResolved),
                    ["resolved"] = filteredWaitList.Count(w => w.IsResolved),
                    ["avgWaitDays"] = Mean(waitDaysList),
                },
            },
            ["quality"] = new Dictionary<string, object>
            {
                ["completeness"] = completeness,
                ["governance"] = new Dictionary<string, object>
                {
                    ["totalEvolutions"] = totalEvos,
                    ["signedEvolutions"] = signedEvos,
                    ["pendingSignatures"] = totalEvos - signedEvos,
                    ["signedRate"] = Pct(signedEvos, totalEvos),
                    ["avgHoursToSign"] = Mean(signHours),
                },
                ["lgpd"] = new Dictionary<string, object>
                {
                    ["adherentPatients"] = lgpdAdherent,
                    ["totalPatients"] = scopedCount,
                    ["adherenceRate"] = Pct(lgpdAdherent, scopedCount),
                },
            },
            ["patientDataset"] = patientDataset,
        };

        _cache?.Set(cacheKey, payload, TimeSpan.FromSeconds(30));
        return payload;
    }

    private static DateTime NormalizeUtc(DateTime dt) =>
        dt.Kind == DateTimeKind.Utc ? dt : DateTime.SpecifyKind(dt, DateTimeKind.Utc);

    private static async Task<List<T>> SafeLoadAsync<T>(Func<Task<List<T>>> loader)
    {
        try
        {
            return await loader();
        }
        catch
        {
            return new List<T>();
        }
    }

    private static int ComputeAge(DateTime birthDate, DateTime now)
    {
        var age = now.Year - birthDate.Year;
        if (birthDate.Date > now.Date.AddYears(-age)) age--;
        return Math.Max(0, age);
    }

    private static string AgeGroupLabel(int age) => age switch
    {
        <= 5 => "0-5 anos",
        <= 11 => "6-11 anos",
        <= 17 => "12-17 anos",
        <= 29 => "18-29 anos",
        <= 49 => "30-49 anos",
        <= 64 => "50-64 anos",
        _ => "65+ anos",
    };

    private static string NormalizeGender(string? g)
    {
        var s = (g ?? "").Trim().ToUpperInvariant();
        if (s.StartsWith("M")) return "Masculino";
        if (s.StartsWith("F")) return "Feminino";
        return "Não informado / Outro";
    }

    private static double Mean(List<double> values) =>
        values.Count == 0 ? 0.0 : Math.Round(values.Average(), 1);

    private static double Median(List<double> values)
    {
        if (values.Count == 0) return 0.0;
        var sorted = values.OrderBy(v => v).ToList();
        int mid = sorted.Count / 2;
        double med = sorted.Count % 2 == 0 ? (sorted[mid - 1] + sorted[mid]) / 2.0 : sorted[mid];
        return Math.Round(med, 1);
    }

    private static double StdDev(List<double> values)
    {
        if (values.Count <= 1) return 0.0;
        double avg = values.Average();
        double sumSq = values.Sum(v => Math.Pow(v - avg, 2));
        return Math.Round(Math.Sqrt(sumSq / (values.Count - 1)), 1);
    }

    private static void ParseAnamnese(
        string json,
        Dictionary<string, int> comorbiditiesCount,
        ref bool hasComorbidity,
        ref bool hasAllergy)
    {
        bool localComorb = hasComorbidity;
        bool localAllergy = hasAllergy;
        try
        {
            using var doc = JsonDocument.Parse(json);
            if (!doc.RootElement.TryGetProperty("sistemico", out var sis) || sis.ValueKind != JsonValueKind.Object)
                return;

            void CheckFlag(string prop, string label)
            {
                if (sis.TryGetProperty(prop, out var node) && node.ValueKind == JsonValueKind.Object &&
                    node.TryGetProperty("sim", out var simVal) &&
                    (simVal.ValueKind == JsonValueKind.True || (simVal.ValueKind == JsonValueKind.String && simVal.GetString()?.Equals("true", StringComparison.OrdinalIgnoreCase) == true)))
                {
                    comorbiditiesCount[label] = comorbiditiesCount.GetValueOrDefault(label) + 1;
                    if (prop == "alergia") localAllergy = true;
                    else localComorb = true;
                }
            }

            CheckFlag("cardiacos", "Problemas Cardíacos");
            CheckFlag("diabetes", "Diabetes");
            CheckFlag("alergia", "Alergias");
            CheckFlag("digestivos", "Problemas Digestivos");
            CheckFlag("figado", "Problemas Hepáticos");
            CheckFlag("neurologicos", "Problemas Neurológicos");
            CheckFlag("coagulacao", "Distúrbios de Coagulação");
            CheckFlag("sinusite", "Sinusite");

            if (sis.TryGetProperty("pressao", out var pr) && pr.ValueKind == JsonValueKind.Object)
            {
                bool usaMeds = pr.TryGetProperty("usaMeds", out var um) && um.ValueKind == JsonValueKind.True;
                bool hasQual = pr.TryGetProperty("qual", out var q) && !string.IsNullOrWhiteSpace(q.GetString());
                if (usaMeds || hasQual)
                {
                    comorbiditiesCount["Hipertensão / Pressão Arterial"] =
                        comorbiditiesCount.GetValueOrDefault("Hipertensão / Pressão Arterial") + 1;
                    localComorb = true;
                }
            }
        }
        catch { }
        hasComorbidity = localComorb;
        hasAllergy = localAllergy;
    }

    private static void ParseDtm(
        string json,
        Dictionary<string, Dictionary<string, int>> dtmRisks,
        ref bool highDtmRisk)
    {
        bool localHigh = highDtmRisk;
        try
        {
            using var doc = JsonDocument.Parse(json);
            var root = doc.RootElement;

            void RecordRisk(string prop, string bucket)
            {
                if (!root.TryGetProperty(prop, out var el)) return;
                var val = (el.GetString() ?? "").Trim().ToLowerInvariant();
                if (dtmRisks[bucket].ContainsKey(val))
                {
                    dtmRisks[bucket][val]++;
                    if (val == "alto") localHigh = true;
                }
            }

            RecordRisk("riscoCarie", "carie");
            RecordRisk("riscoOclusal", "oclusal");
            RecordRisk("riscoDtm", "dtm");
        }
        catch { }
        highDtmRisk = localHigh;
    }

    private static double? ComputeBinaryGridPercent(string json, string gridKey)
    {
        try
        {
            using var doc = JsonDocument.Parse(json);
            if (!doc.RootElement.TryGetProperty(gridKey, out var grid) || grid.ValueKind != JsonValueKind.Object)
                return null;
            int total = 0;
            int positive = 0;
            foreach (var tooth in grid.EnumerateObject())
            {
                if (tooth.Value.ValueKind != JsonValueKind.Object) continue;
                foreach (var surf in tooth.Value.EnumerateObject())
                {
                    var v = (surf.Value.GetString() ?? "").Trim();
                    if (v == "0" || v == "1")
                    {
                        total++;
                        if (v == "1") positive++;
                    }
                }
            }
            return total == 0 ? null : (double)positive / total * 100.0;
        }
        catch
        {
            return null;
        }
    }

    private static void ParseOdontopediatria(
        string json,
        Dictionary<string, int> comorbiditiesCount,
        Dictionary<string, int> angleOcclusionCounts,
        Dictionary<string, int> facialProfileCounts,
        Dictionary<string, int> cariesProfileCounts,
        ref bool hasComorbidity,
        ref bool hasAllergy,
        ref bool hasSugaryDiet,
        ref bool hasDeleteriousHabit,
        ref bool hasMalocclusion,
        ref bool hasCaries,
        out double? ipvPercent,
        out double? isgPercent)
    {
        ipvPercent = ComputeBinaryGridPercent(json, "t7_ipv_grid");
        isgPercent = ComputeBinaryGridPercent(json, "t7_isg_grid");
        try
        {
            using var doc = JsonDocument.Parse(json);
            var root = doc.RootElement;

            string GetStr(string key) =>
                root.TryGetProperty(key, out var v) && v.ValueKind == JsonValueKind.String
                    ? (v.GetString() ?? "").Trim()
                    : "";

            // Dieta açucarada (Parte 2 ou Marcadores de Consumo Alimentar)
            if (GetStr("t3_q1_liquidos_acucar").Contains("Sim") ||
                GetStr("t3_q2_refrigerantes").Contains("Sim") ||
                GetStr("t3_q5_doces").Contains("Sim") ||
                GetStr("t6_2m_bebidas_adocadas") == "Sim" ||
                GetStr("t6_2m_doces_guloseimas") == "Sim" ||
                GetStr("t6_6a23_bebidas_adocadas") == "Sim" ||
                GetStr("t6_6a23_doces_guloseimas") == "Sim")
            {
                hasSugaryDiet = true;
            }

            // Hábitos deletérios e respiração bucal
            if (GetStr("t5_hd_chupeta").Contains("Sim") ||
                GetStr("t5_hd_dedo").Contains("Sim") ||
                GetStr("t5_hd_outros").Contains("Sim") ||
                GetStr("t5_hd_bruxismo").Contains("Sim") ||
                GetStr("t5_hmat_respiracao").Contains("Bucal"))
            {
                hasDeleteriousHabit = true;
            }

            if (GetStr("t5_hmat_respiracao").Contains("Bucal"))
            {
                comorbiditiesCount["Respiração Bucal"] = comorbiditiesCount.GetValueOrDefault("Respiração Bucal") + 1;
            }

            if (GetStr("t5_hma_alergia").Contains("Sim"))
            {
                hasAllergy = true;
                comorbiditiesCount["Alergias"] = comorbiditiesCount.GetValueOrDefault("Alergias") + 1;
            }

            // Oclusão e Perfil Facial
            var oclusao = GetStr("t9_mp_oclusao");
            if (!string.IsNullOrEmpty(oclusao))
            {
                angleOcclusionCounts[oclusao] = angleOcclusionCounts.GetValueOrDefault(oclusao) + 1;
                if (oclusao != "Normal") hasMalocclusion = true;
            }

            var transv = GetStr("t9_orto_q7_transversal");
            var vert = GetStr("t9_orto_q8_vertical");
            if ((!string.IsNullOrEmpty(transv) && !transv.Contains("Normal")) ||
                (!string.IsNullOrEmpty(vert) && (vert.Contains("aberta") || vert.Contains("Topo"))))
            {
                hasMalocclusion = true;
            }

            var perfil = GetStr("t9_facial_perfil");
            if (!string.IsNullOrEmpty(perfil))
            {
                facialProfileCounts[perfil] = facialProfileCounts.GetValueOrDefault(perfil) + 1;
            }

            // Perfil de cárie
            if (root.TryGetProperty("t8_perfil_carie", out var pc) && pc.ValueKind == JsonValueKind.Array)
            {
                foreach (var item in pc.EnumerateArray())
                {
                    var label = (item.GetString() ?? "").Trim();
                    if (string.IsNullOrEmpty(label)) continue;
                    cariesProfileCounts[label] = cariesProfileCounts.GetValueOrDefault(label) + 1;
                    if (label.Contains("Com experiência de Cárie", StringComparison.OrdinalIgnoreCase))
                        hasCaries = true;
                }
            }

            // Verifica códigos clínicos 1, 3, 8, 9 (cárie ativa / cavidade / recidiva / destruição)
            if (root.TryGetProperty("t8_clinico_grid", out var cg) && cg.ValueKind == JsonValueKind.Object)
            {
                foreach (var tooth in cg.EnumerateObject())
                {
                    if (tooth.Value.ValueKind != JsonValueKind.Object) continue;
                    foreach (var surf in tooth.Value.EnumerateObject())
                    {
                        var code = (surf.Value.GetString() ?? "").Trim();
                        if (code is "1" or "3" or "8" or "9" or "10") hasCaries = true;
                    }
                }
            }
        }
        catch { }
    }

    private static bool IsTcleAccepted(string json)
    {
        try
        {
            using var doc = JsonDocument.Parse(json);
            return doc.RootElement.TryGetProperty("accepted", out var acc) && acc.ValueKind == JsonValueKind.True;
        }
        catch
        {
            return false;
        }
    }
}
