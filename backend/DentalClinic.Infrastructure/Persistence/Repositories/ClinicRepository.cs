using System.Globalization;
using System.Text;
using System.Text.RegularExpressions;
using DentalClinic.Core.Domain.Entities;
using DentalClinic.Core.Domain.Repositories;
using Microsoft.EntityFrameworkCore;

namespace DentalClinic.Infrastructure.Persistence.Repositories;

/// <summary>
/// Implementação do repositório de clínicas.
/// </summary>
public class ClinicRepository : IClinicRepository
{
    private readonly ApplicationDbContext _context;

    private static readonly Dictionary<string, int> RomanOrder = new(StringComparer.OrdinalIgnoreCase)
    {
        ["i"] = 1,
        ["ii"] = 2,
        ["iii"] = 3,
        ["iv"] = 4,
        ["v"] = 5,
        ["vi"] = 6,
        ["vii"] = 7,
        ["viii"] = 8,
        ["ix"] = 9,
        ["x"] = 10
    };

    private static readonly Regex NumberedClinicPattern = new(
        @"^clinica\s+(i|ii|iii|iv|v|vi|vii|viii|ix|x|\d+)$",
        RegexOptions.Compiled | RegexOptions.IgnoreCase);

    public ClinicRepository(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<IEnumerable<Clinic>> GetAllAsync(bool includeInactive = false)
    {
        var query = _context.Set<Clinic>().AsQueryable();
        if (!includeInactive)
        {
            query = query.Where(c => c.IsActive);
        }

        var clinics = await query.ToListAsync();

        return clinics
            .OrderBy(c => GetSequenceNumber(c.Name).HasValue ? 0 : 1)
            .ThenBy(c => GetSequenceNumber(c.Name) ?? int.MaxValue)
            .ThenBy(c => NormalizeName(c.Name), StringComparer.Ordinal)
            .ThenBy(c => c.CreatedAt)
            .GroupBy(c => NormalizeName(c.Name), StringComparer.Ordinal)
            .Select(g => g.First())
            .ToList();
    }

    private static int? GetSequenceNumber(string? name)
    {
        if (string.IsNullOrWhiteSpace(name)) return null;
        var match = NumberedClinicPattern.Match(NormalizeName(name));
        if (!match.Success) return null;
        var token = match.Groups[1].Value;
        if (RomanOrder.TryGetValue(token, out var roman)) return roman;
        return int.TryParse(token, out var numeric) ? numeric : null;
    }

    private static string NormalizeName(string? name)
    {
        if (string.IsNullOrWhiteSpace(name)) return string.Empty;
        var decomposed = name.Trim().Normalize(NormalizationForm.FormD);
        var sb = new StringBuilder(decomposed.Length);
        foreach (var ch in decomposed)
        {
            if (CharUnicodeInfo.GetUnicodeCategory(ch) != UnicodeCategory.NonSpacingMark)
            {
                sb.Append(char.ToLowerInvariant(ch));
            }
        }
        return Regex.Replace(sb.ToString(), @"\s+", " ");
    }

    public async Task<Clinic?> GetByIdAsync(Guid id)
    {
        return await _context.Set<Clinic>().FindAsync(id);
    }

    public async Task AddAsync(Clinic clinic)
    {
        await _context.Set<Clinic>().AddAsync(clinic);
        await _context.SaveChangesAsync();
    }

    public async Task UpdateAsync(Clinic clinic)
    {
        _context.Set<Clinic>().Update(clinic);
        await _context.SaveChangesAsync();
    }
}
