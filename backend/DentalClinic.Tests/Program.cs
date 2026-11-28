using System.Security.Claims;
using System.Text.Json;
using DentalClinic.Api.Controllers;
using DentalClinic.Core.Application.DTOs;
using DentalClinic.Core.Application.Interfaces;
using DentalClinic.Core.Domain.Entities;
using DentalClinic.Core.Domain.Repositories;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging.Abstractions;

int passed = 0;
int failed = 0;

void Assert(bool condition, string message)
{
    if (!condition) throw new Exception($"Assertion failed: {message}");
}

async Task RunTest(string name, Func<Task> body)
{
    try
    {
        await body();
        passed++;
        Console.WriteLine($"[PASS] {name}");
    }
    catch (Exception ex)
    {
        failed++;
        Console.WriteLine($"[FAIL] {name}: {ex.Message}");
    }
}

await RunTest("Appointment.Create rejects endTime <= startTime", () =>
{
    var now = DateTime.UtcNow;
    bool threw = false;
    try
    {
        Appointment.Create(Guid.NewGuid(), Guid.NewGuid(), now, now, Guid.NewGuid());
    }
    catch (InvalidOperationException)
    {
        threw = true;
    }
    Assert(threw, "Expected InvalidOperationException when endTime <= startTime");
    return Task.CompletedTask;
});

await RunTest("Appointment lifecycle transitions (Arrival -> Start -> Finish -> UpdateStatus -> Reschedule)", () =>
{
    var start = new DateTime(2026, 12, 1, 9, 0, 0, DateTimeKind.Utc);
    var end = start.AddHours(1);
    var appt = Appointment.Create(Guid.NewGuid(), Guid.NewGuid(), start, end, Guid.NewGuid(), "Restauração");

    Assert(appt.Status == AppointmentStatus.Scheduled, "Initial status must be Scheduled");

    appt.RegisterArrival();
    Assert(appt.Status == AppointmentStatus.Arrived && appt.ArrivalTime.HasValue, "RegisterArrival must set Arrived and ArrivalTime");

    appt.RegisterStart();
    Assert(appt.Status == AppointmentStatus.InProgress && appt.ActualStartTime.HasValue, "RegisterStart must set InProgress and ActualStartTime");

    appt.RegisterFinish();
    Assert(appt.Status == AppointmentStatus.Completed && appt.ActualEndTime.HasValue, "RegisterFinish must set Completed and ActualEndTime");

    appt.UpdateStatus(AppointmentStatus.NoShow);
    Assert(appt.Status == AppointmentStatus.NoShow, "UpdateStatus must update to NoShow");

    var newStart = start.AddDays(2);
    var newEnd = newStart.AddHours(1);
    appt.Reschedule(newStart, newEnd);
    Assert(appt.StartTime == newStart && appt.EndTime == newEnd, "Reschedule must update start/end");
    return Task.CompletedTask;
});

await RunTest("TreatmentPlan transitions Draft -> Approved -> InProgress -> Completed as items finish", () =>
{
    var plan = TreatmentPlan.Create(Guid.NewGuid(), Guid.NewGuid(), "Plano Reabilitador");
    Assert(plan.Status == TreatmentPlanStatus.Draft, "New plan starts as Draft");

    plan.Approve();
    Assert(plan.Status == TreatmentPlanStatus.Approved, "Approve must set Approved");

    plan.AddItem(Guid.NewGuid(), "Restauração", 0m, 16, null);
    plan.AddItem(Guid.NewGuid(), "Profilaxia", 0m, null, null);
    var first = plan.Items[0];
    var second = plan.Items[1];

    Assert(plan.UpdateItemStatus(first.Id, TreatmentItemStatus.Completed), "First item update should succeed");
    Assert(plan.Status == TreatmentPlanStatus.InProgress, "Plan should move to InProgress when partially completed");

    Assert(plan.UpdateItemStatus(second.Id, TreatmentItemStatus.Completed), "Second item update should succeed");
    Assert(plan.Status == TreatmentPlanStatus.Completed, "Plan should move to Completed when all items completed");
    return Task.CompletedTask;
});

await RunTest("AppointmentsController.UpdateStatus accepts integer 7 (NoShow), string 'falta', and rejects invalid status", async () =>
{
    var appt = Appointment.Create(
        Guid.NewGuid(),
        Guid.NewGuid(),
        DateTime.UtcNow.AddHours(1),
        DateTime.UtcNow.AddHours(2),
        Guid.NewGuid());

    var repo = new InMemoryAppointmentRepo(appt);
    var controller = new AppointmentsController(
        repo,
        null!,
        null!,
        null!,
        NullLogger<AppointmentsController>.Instance,
        null!);

    // Numeric enum value 7 -> NoShow
    using (var doc = JsonDocument.Parse("7"))
    {
        var result = await controller.UpdateStatus(appt.Id, new UpdateStatusRequest(doc.RootElement.Clone()));
        Assert(result is NoContentResult, $"Expected 204 NoContent for numeric 7, got {result.GetType().Name}");
        Assert(appt.Status == AppointmentStatus.NoShow, "Status should be NoShow");
    }

    // String alias "falta" -> NoShow
    using (var doc = JsonDocument.Parse("\"falta\""))
    {
        var result = await controller.UpdateStatus(appt.Id, new UpdateStatusRequest(doc.RootElement.Clone()));
        Assert(result is NoContentResult, $"Expected 204 NoContent for 'falta', got {result.GetType().Name}");
        Assert(appt.Status == AppointmentStatus.NoShow, "Status should remain NoShow");
    }

    // String enum name "confirmed" -> Confirmed
    using (var doc = JsonDocument.Parse("\"confirmed\""))
    {
        var result = await controller.UpdateStatus(appt.Id, new UpdateStatusRequest(doc.RootElement.Clone()));
        Assert(result is NoContentResult, $"Expected 204 NoContent for 'confirmed', got {result.GetType().Name}");
        Assert(appt.Status == AppointmentStatus.Confirmed, "Status should be Confirmed");
    }

    // Invalid string -> 400 BadRequest
    using (var doc = JsonDocument.Parse("\"status_inexistente\""))
    {
        var result = await controller.UpdateStatus(appt.Id, new UpdateStatusRequest(doc.RootElement.Clone()));
        Assert(result is BadRequestObjectResult, $"Expected 400 BadRequest for invalid status, got {result.GetType().Name}");
    }
});

await RunTest("AppointmentsController.Reschedule rejects conflicting time slot with 409 Conflict", async () =>
{
    var clinicId = Guid.NewGuid();
    var t1 = new DateTime(2026, 12, 5, 9, 0, 0, DateTimeKind.Utc);
    var t2 = new DateTime(2026, 12, 5, 10, 0, 0, DateTimeKind.Utc);
    var a1 = Appointment.Create(Guid.NewGuid(), Guid.NewGuid(), t1, t1.AddHours(1), clinicId);
    var a2 = Appointment.Create(Guid.NewGuid(), Guid.NewGuid(), t2, t2.AddHours(1), clinicId);

    var repo = new InMemoryAppointmentRepo(a1, a2);
    var controller = new AppointmentsController(
        repo, null!, null!, null!, NullLogger<AppointmentsController>.Instance, null!);

    var conflict = await controller.Reschedule(a2.Id, new RescheduleRequest(t1, t1.AddHours(1)));
    Assert(conflict is ConflictObjectResult, $"Expected 409 Conflict, got {conflict.GetType().Name}");

    // Se a1 tiver status Falta (NoShow), o horário t1 deve ficar liberado para reagendamento
    a1.UpdateStatus(AppointmentStatus.NoShow);
    var freedSlot = await controller.Reschedule(a2.Id, new RescheduleRequest(t1, t1.AddHours(1)));
    Assert(freedSlot is NoContentResult, $"Expected 204 NoContent when conflicting slot is NoShow, got {freedSlot.GetType().Name}");

    var freeSlot = t2.AddHours(2);
    var ok = await controller.Reschedule(a2.Id, new RescheduleRequest(freeSlot, freeSlot.AddHours(1)));
    Assert(ok is NoContentResult, $"Expected 204 NoContent for free slot, got {ok.GetType().Name}");
    Assert(a2.StartTime == freeSlot, "Appointment should have moved to free slot");
});

await RunTest("AuthController.ForgotPassword validates email and never leaks account existence", async () =>
{
    var controller = new AuthController(null!, new EmptyUserRepo(), NullLogger<AuthController>.Instance);
    var bad = await controller.ForgotPassword(new ForgotPasswordRequest("invalido"));
    Assert(bad is BadRequestObjectResult, "Invalid email should return 400");

    var ok = await controller.ForgotPassword(new ForgotPasswordRequest("aluno@ufma.br"));
    Assert(ok is OkObjectResult, "Valid email should return 200 without leaking existence");
});

await RunTest("UsersController supports PT roles, minimal payload, IsActive in GET, and PATCH role", async () =>
{
    var repo = new InMemoryUserRepo();
    var controller = new UsersController(repo, new StubHasher(), NullLogger<UsersController>.Instance);

    var created = await controller.Create(new CreateUserRequest("Aluno Teste", "aluno@ufma.br", "senha123", "aluno"));
    Assert(created is CreatedAtActionResult, $"Expected 201 Created, got {created.GetType().Name}");

    var listRes = await controller.Get(role: "aluno") as OkObjectResult;
    var dtos = (listRes?.Value as IEnumerable<UserDto>)?.ToList() ?? new List<UserDto>();
    Assert(dtos.Count == 1 && dtos[0].Role == "Student" && dtos[0].IsActive, "Should return created Student with IsActive=true");

    var toggleRes = await controller.ToggleStatus(dtos[0].Id, new ToggleStatusRequest(false));
    Assert(toggleRes is NoContentResult, "ToggleStatus should return 204");

    var roleRes = await controller.UpdateRole(dtos[0].Id, new UpdateRoleRequest("coordenador"));
    Assert(roleRes is NoContentResult, "UpdateRole should accept Portuguese role 'coordenador'");

    var afterRes = await controller.Get(role: "coordenador") as OkObjectResult;
    var afterDtos = (afterRes?.Value as IEnumerable<UserDto>)?.ToList() ?? new List<UserDto>();
    Assert(afterDtos.Count == 1 && !afterDtos[0].IsActive && afterDtos[0].Role == "Coordinator", "Updated role and IsActive=false should be reflected");
});

await RunTest("NotificationsController enforces ownership on MarkAsRead and Delete", async () =>
{
    var ownerId = Guid.NewGuid();
    var otherId = Guid.NewGuid();
    var notif = Notification.Create(ownerId, "Aviso", "Teste", NotificationType.SystemAlert);
    var repo = new InMemoryNotificationRepo(notif);

    var controller = new NotificationsController(repo, NullLogger<NotificationsController>.Instance)
    {
        ControllerContext = new ControllerContext
        {
            HttpContext = new DefaultHttpContext
            {
                User = new ClaimsPrincipal(new ClaimsIdentity(new[] { new Claim(ClaimTypes.NameIdentifier, otherId.ToString()) }))
            }
        }
    };

    var forbidRead = await controller.MarkAsRead(notif.Id);
    Assert(forbidRead is ForbidResult, $"Expected ForbidResult for other user MarkAsRead, got {forbidRead.GetType().Name}");

    var forbidDel = await controller.Delete(notif.Id);
    Assert(forbidDel is ForbidResult, $"Expected ForbidResult for other user Delete, got {forbidDel.GetType().Name}");

    controller.ControllerContext.HttpContext.User = new ClaimsPrincipal(
        new ClaimsIdentity(new[] { new Claim(ClaimTypes.NameIdentifier, ownerId.ToString()) }));

    var okRead = await controller.MarkAsRead(notif.Id);
    Assert(okRead is NoContentResult && notif.IsRead, "Owner should be able to mark notification as read");

    var okDel = await controller.Delete(notif.Id);
    Assert(okDel is NoContentResult && await repo.GetByIdAsync(notif.Id) == null, "Owner should be able to delete notification");
});

await RunTest("User.Role reflects persisted Roles list (never defaults Admin to Student)", async () =>
{
    var u = User.Create("Admin", "admin@odontoclinica.edu.br", "", null, null, null, UserRole.Admin);
    // Simula materialização EF Core onde apenas Roles (perfis_json) é populado
    u.Roles = new List<UserRole> { UserRole.Admin };
    Assert(u.Role == UserRole.Admin, $"Expected Admin, got {u.Role}");
    u.Roles = new List<UserRole> { UserRole.Coordinator };
    Assert(u.Role == UserRole.Coordinator, $"Expected Coordinator, got {u.Role}");
});

await RunTest("UsersController blocks Coordinator->Admin privilege escalation and duplicate email (409)", async () =>
{
    var repo = new InMemoryUserRepo();
    var controller = new UsersController(repo, new StubHasher(), NullLogger<UsersController>.Instance)
    {
        ControllerContext = new ControllerContext
        {
            HttpContext = new DefaultHttpContext
            {
                User = new ClaimsPrincipal(new ClaimsIdentity(new[]
                {
                    new Claim(ClaimTypes.NameIdentifier, Guid.NewGuid().ToString()),
                    new Claim(ClaimTypes.Role, "Coordinator")
                }))
            }
        }
    };

    var forbidCreate = await controller.Create(new CreateUserRequest("Hack Admin", "hack@ufma.br", "senha123", "Admin"));
    Assert(forbidCreate is ForbidResult, $"Expected ForbidResult for Coordinator creating Admin, got {forbidCreate.GetType().Name}");

    var okCreate = await controller.Create(new CreateUserRequest("Aluno 1", "aluno1@ufma.br", "senha123", "Student"));
    Assert(okCreate is CreatedAtActionResult, "Coordinator should be able to create Student");

    var dup = await controller.Create(new CreateUserRequest("Aluno Dup", "aluno1@ufma.br", "senha123", "Student"));
    Assert(dup is ConflictObjectResult, $"Expected 409 Conflict for duplicate email, got {dup.GetType().Name}");

    var createdDto = ((CreatedAtActionResult)okCreate).Value as UserDto;
    var forbidPromote = await controller.UpdateRole(createdDto!.Id, new UpdateRoleRequest("Admin"));
    Assert(forbidPromote is ForbidResult, $"Expected ForbidResult for Coordinator promoting to Admin, got {forbidPromote.GetType().Name}");
});

await RunTest("Evolution.Sign enforces responsible professor and records actual signer on override", () =>
{
    var profA = Guid.NewGuid();
    var profB = Guid.NewGuid();
    var adminId = Guid.NewGuid();
    var evo = Evolution.Create(Guid.NewGuid(), Guid.NewGuid(), profA, Guid.NewGuid(), "Restauração dente 16");

    bool blocked = false;
    try
    {
        evo.Sign(profB, allowOverride: false);
    }
    catch (InvalidOperationException)
    {
        blocked = true;
    }
    Assert(blocked, "Another professor without override must be rejected");
    Assert(!evo.IsSignedByProfessor, "Evolution must remain unsigned after rejection");

    evo.Sign(adminId, allowOverride: true);
    Assert(evo.IsSignedByProfessor && evo.ProfessorId == adminId, "Override sign must record actual signer ID");
    return Task.CompletedTask;
});

Console.WriteLine($"\nBackend test summary: {passed} passed, {failed} failed.");
return failed == 0 ? 0 : 1;

sealed class InMemoryAppointmentRepo : IAppointmentRepository
{
    private readonly List<Appointment> _items;
    public InMemoryAppointmentRepo(params Appointment[] items) => _items = items.ToList();

    public Task<Appointment?> GetByIdAsync(Guid id) =>
        Task.FromResult(_items.FirstOrDefault(x => x.Id == id));

    public Task<IEnumerable<Appointment>> GetByRangeAsync(DateTime start, DateTime end, Guid? clinicId) =>
        Task.FromResult<IEnumerable<Appointment>>(_items.Where(a =>
            (!clinicId.HasValue || a.ClinicId == clinicId.Value) &&
            a.StartTime < end && a.EndTime > start).ToList());

    public Task<IEnumerable<Appointment>> GetByPatientIdAsync(Guid patientId) =>
        Task.FromResult<IEnumerable<Appointment>>(_items.Where(a => a.PatientId == patientId).ToList());

    public Task AddAsync(Appointment appointment)
    {
        _items.Add(appointment);
        return Task.CompletedTask;
    }

    public Task UpdateAsync(Appointment appointment) => Task.CompletedTask;
}

sealed class EmptyUserRepo : IUserRepository
{
    public Task<User?> GetByIdAsync(Guid id) => Task.FromResult<User?>(null);
    public Task<User?> GetByEmailAsync(string email) => Task.FromResult<User?>(null);
    public Task<User?> GetByCpfAsync(string cpf) => Task.FromResult<User?>(null);
    public Task<IEnumerable<User>> GetAllAsync(UserRole? role = null, string? query = null) =>
        Task.FromResult<IEnumerable<User>>(Array.Empty<User>());
    public Task AddAsync(User user) => Task.CompletedTask;
    public Task UpdateAsync(User user) => Task.CompletedTask;
    public Task DeleteAsync(Guid id) => Task.CompletedTask;
}

sealed class InMemoryUserRepo : IUserRepository
{
    private readonly List<User> _users = new();
    public Task<User?> GetByIdAsync(Guid id) => Task.FromResult(_users.FirstOrDefault(u => u.Id == id));
    public Task<User?> GetByEmailAsync(string email) => Task.FromResult(_users.FirstOrDefault(u => u.EmailAddress.Value == email));
    public Task<User?> GetByCpfAsync(string cpf) => Task.FromResult<User?>(null);
    public Task<IEnumerable<User>> GetAllAsync(UserRole? role = null, string? query = null) =>
        Task.FromResult<IEnumerable<User>>(_users.Where(u => !role.HasValue || u.Roles.Contains(role.Value)).ToList());
    public Task AddAsync(User user) { _users.Add(user); return Task.CompletedTask; }
    public Task UpdateAsync(User user) => Task.CompletedTask;
    public Task DeleteAsync(Guid id) { _users.RemoveAll(u => u.Id == id); return Task.CompletedTask; }
}

sealed class StubHasher : IPasswordHasher
{
    public string HashPassword(string password) => $"hashed:{password}";
    public bool VerifyPassword(string password, string hash) => hash == $"hashed:{password}";
}

sealed class InMemoryNotificationRepo : INotificationRepository
{
    private readonly List<Notification> _items;
    public InMemoryNotificationRepo(params Notification[] items) => _items = items.ToList();
    public Task<IEnumerable<Notification>> GetByUserIdAsync(Guid userId) =>
        Task.FromResult<IEnumerable<Notification>>(_items.Where(n => n.UserId == userId).ToList());
    public Task<Notification?> GetByIdAsync(Guid id) => Task.FromResult(_items.FirstOrDefault(n => n.Id == id));
    public Task AddAsync(Notification notification) { _items.Add(notification); return Task.CompletedTask; }
    public Task UpdateAsync(Notification notification) => Task.CompletedTask;
    public Task DeleteAsync(Notification notification) { _items.Remove(notification); return Task.CompletedTask; }
    public Task MarkAllAsReadAsync(Guid userId)
    {
        foreach (var n in _items.Where(x => x.UserId == userId)) n.MarkAsRead();
        return Task.CompletedTask;
    }
}
