using DentalClinic.Api.Filters;

namespace DentalClinic.Core.Domain.Repositories;

/// <summary>
/// Interface para recuperação de logs de auditoria (Requisito LGPD).
/// </summary>
public interface ILogAuditoriaRepository
{
    Task<IEnumerable<LogAuditoria>> GetLogsAsync(int page, int pageSize, string? userId = null);
    Task<int> CountAsync(string? userId = null);
}
