using DentalClinic.Core.Domain.Entities;
using DentalClinic.Core.Domain.Repositories;
using Microsoft.EntityFrameworkCore;

namespace DentalClinic.Infrastructure.Persistence.Repositories;

public class TreatmentPlanRepository : ITreatmentPlanRepository
{
    private readonly ApplicationDbContext _context;

    public TreatmentPlanRepository(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<TreatmentPlan?> GetActivePlanByPatientIdAsync(Guid patientId)
    {
        return await _context.Set<TreatmentPlan>()
            .Include(p => p.Items)
            .FirstOrDefaultAsync(p => p.PatientId == patientId &&
                                     (p.Status == TreatmentPlanStatus.Draft ||
                                      p.Status == TreatmentPlanStatus.Approved ||
                                      p.Status == TreatmentPlanStatus.InProgress));
    }

    public async Task<TreatmentPlan?> GetByIdAsync(Guid id)
    {
        return await _context.Set<TreatmentPlan>()
            .Include(p => p.Items)
            .FirstOrDefaultAsync(p => p.Id == id);
    }

    public async Task AddAsync(TreatmentPlan plan)
    {
        await _context.Set<TreatmentPlan>().AddAsync(plan);
        await _context.SaveChangesAsync();
    }

    public async Task UpdateAsync(TreatmentPlan plan)
    {
        var existingItemIds = await _context.TreatmentItems
            .AsNoTracking()
            .Where(i => i.TreatmentPlanId == plan.Id)
            .Select(i => i.Id)
            .ToListAsync();
        var existingSet = existingItemIds.ToHashSet();

        var planEntry = _context.Entry(plan);
        if (planEntry.State == EntityState.Detached)
        {
            _context.Set<TreatmentPlan>().Attach(plan);
            planEntry.State = EntityState.Modified;
        }

        foreach (var item in plan.Items)
        {
            var itemEntry = _context.Entry(item);
            if (!existingSet.Contains(item.Id))
            {
                itemEntry.State = EntityState.Added;
            }
            else if (itemEntry.State == EntityState.Detached)
            {
                itemEntry.State = EntityState.Modified;
            }
        }

        await _context.SaveChangesAsync();
    }
}
