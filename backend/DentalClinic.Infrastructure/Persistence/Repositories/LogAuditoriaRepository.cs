using DentalClinic.Core.Domain.Entities;
using DentalClinic.Core.Domain.Repositories;
using Microsoft.EntityFrameworkCore;
using System.Linq.Expressions;

namespace DentalClinic.Infrastructure.Persistence.Repositories;

/// <summary>
/// Implementação do repositório de auditoria para conformidade com a LGPD.
/// </summary>
public class LogAuditoriaRepository : ILogAuditoriaRepository
{
    private readonly ApplicationDbContext _context;

    public LogAuditoriaRepository(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<LogAuditoria> CreateAsync(LogAuditoria log)
    {
        await _context.Set<LogAuditoria>().AddAsync(log);
        return log;
    }

    public async Task<IEnumerable<LogAuditoria>> GetAllAsync()
    {
        return await _context.Set<LogAuditoria>()
            .OrderByDescending(l => l.DataHora)
            .ToListAsync();
    }

    public async Task<IEnumerable<LogAuditoria>> FindAsync(Expression<Func<LogAuditoria, bool>> predicate)
    {
        return await _context.Set<LogAuditoria>()
            .Where(predicate)
            .OrderByDescending(l => l.DataHora)
            .ToListAsync();
    }

    public async Task<LogAuditoria?> GetByIdAsync(Guid id)
    {
        return await _context.Set<LogAuditoria>()
            .FirstOrDefaultAsync(l => l.Id == id);
    }

    public async Task<(IReadOnlyList<LogAuditoria> Items, int Total)> GetPagedAsync(
        int page,
        int pageSize,
        Guid? userId = null,
        string? action = null,
        string? resourceId = null)
    {
        var safePage = Math.Max(1, page);
        var safePageSize = Math.Clamp(pageSize, 1, 200);

        var query = _context.Set<LogAuditoria>().AsNoTracking().AsQueryable();
        if (userId.HasValue)
        {
            query = query.Where(x => x.UsuarioId == userId.Value);
        }
        if (!string.IsNullOrWhiteSpace(action))
        {
            var term = action.Trim().ToLower();
            query = query.Where(x => x.Acao.ToLower().Contains(term));
        }
        if (!string.IsNullOrWhiteSpace(resourceId))
        {
            var resTerm = resourceId.Trim().ToLower();
            query = query.Where(x =>
                (x.Recurso != null && x.Recurso.ToLower().Contains(resTerm)) ||
                (x.Detalhes != null && x.Detalhes.ToLower().Contains(resTerm)));
        }

        var total = await query.CountAsync();
        var items = await query
            .OrderByDescending(x => x.DataHora)
            .Skip((safePage - 1) * safePageSize)
            .Take(safePageSize)
            .ToListAsync();

        return (items, total);
    }

    public async Task<int> SaveChangesAsync()
    {
        return await _context.SaveChangesAsync();
    }
}
