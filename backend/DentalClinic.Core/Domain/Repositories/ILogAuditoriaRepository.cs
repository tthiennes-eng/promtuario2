using DentalClinic.Core.Domain.Entities;
using System.Linq.Expressions;

namespace DentalClinic.Core.Domain.Repositories
{
    public interface ILogAuditoriaRepository
    {
        Task<LogAuditoria> CreateAsync(LogAuditoria log);
        Task<IEnumerable<LogAuditoria>> GetAllAsync();
        Task<IEnumerable<LogAuditoria>> FindAsync(Expression<Func<LogAuditoria, bool>> predicate);
        Task<LogAuditoria?> GetByIdAsync(Guid id);
        Task<int> SaveChangesAsync();
    }
}