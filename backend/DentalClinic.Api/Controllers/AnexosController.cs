using DentalClinic.Core.Application.Interfaces;
using DentalClinic.Core.Domain.Entities;
using DentalClinic.Core.Domain.Repositories;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace DentalClinic.Api.Controllers;

[Authorize]
[ApiController]
[Route("api/[controller]")]
public class AnexosController : ControllerBase
{
    private readonly IStorageService _storageService;
    private readonly IAnexoRepository _anexoRepository;
    private readonly IConfiguration _configuration;
    private readonly ILogger<AnexosController> _logger;

    public AnexosController(
        IStorageService storageService,
        IAnexoRepository anexoRepository,
        IConfiguration configuration,
        ILogger<AnexosController> logger)
    {
        _storageService = storageService;
        _anexoRepository = anexoRepository;
        _configuration = configuration;
        _logger = logger;
    }

    private static readonly HashSet<string> AllowedExtensions = new(StringComparer.OrdinalIgnoreCase)
    {
        ".jpg", ".jpeg", ".png", ".gif", ".webp", ".bmp", ".heic",
        ".txt", ".md", ".csv", ".json", ".xml", ".log", ".rtf",
        ".pdf", ".doc", ".docx"
    };

    private static string ResolveContentType(string fileName)
    {
        return Path.GetExtension(fileName).ToLowerInvariant() switch
        {
            ".jpg" or ".jpeg" => "image/jpeg",
            ".png" => "image/png",
            ".gif" => "image/gif",
            ".webp" => "image/webp",
            ".bmp" => "image/bmp",
            ".heic" => "image/heic",
            ".txt" or ".log" => "text/plain; charset=utf-8",
            ".md" => "text/markdown; charset=utf-8",
            ".csv" => "text/csv; charset=utf-8",
            ".json" => "application/json; charset=utf-8",
            ".xml" => "application/xml; charset=utf-8",
            ".rtf" => "application/rtf",
            ".pdf" => "application/pdf",
            ".doc" => "application/msword",
            ".docx" => "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
            _ => "application/octet-stream",
        };
    }

    [HttpPost("upload/{pacienteId}")]
    public async Task<IActionResult> Upload(Guid pacienteId, IFormFile file, [FromQuery] string? tipo)
    {
        if (file == null || file.Length == 0)
            return BadRequest("Arquivo inválido ou vazio.");

        var extension = Path.GetExtension(file.FileName);
        if (string.IsNullOrWhiteSpace(extension) || !AllowedExtensions.Contains(extension))
        {
            return BadRequest("Formato de arquivo não suportado. Envie imagens (JPG, PNG, WEBP, BMP, GIF) ou arquivos de texto/documentos (TXT, MD, CSV, PDF, DOC, DOCX).");
        }

        var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(userId)) return Unauthorized();

        var normalizedExt = extension.ToLowerInvariant();
        var resolvedTipo = string.IsNullOrWhiteSpace(tipo)
            ? (normalizedExt is ".txt" or ".md" or ".csv" or ".json" or ".xml" or ".log" or ".rtf" or ".pdf" or ".doc" or ".docx"
                ? "Documento"
                : "Foto")
            : tipo.Trim();

        string? uploadedUrl = null;
        try
        {
            _logger.LogInformation("Iniciando upload de {Tipo} ({FileName}) para o paciente {PacienteId}", resolvedTipo, file.FileName, pacienteId);

            using var stream = file.OpenReadStream();
            uploadedUrl = await _storageService.UploadFileAsync(stream, file.FileName, file.ContentType);

            var anexo = Anexo.Create(
                pacienteId,
                file.FileName,
                resolvedTipo,
                uploadedUrl,
                file.Length,
                Guid.Parse(userId)
            );

            await _anexoRepository.AddAsync(anexo);

            return CreatedAtAction(nameof(GetByPaciente), new { pacienteId = anexo.PacienteId }, anexo);
        }
        catch (Exception ex)
        {
            if (!string.IsNullOrWhiteSpace(uploadedUrl))
            {
                try { await _storageService.DeleteFileAsync(uploadedUrl); } catch { }
            }
            _logger.LogError(ex, "Falha crítica no processamento de anexo.");
            return StatusCode(500, "Erro interno ao processar o arquivo clínico.");
        }
    }

    [HttpGet("paciente/{pacienteId}")]
    public async Task<IActionResult> GetByPaciente(Guid pacienteId)
    {
        var anexos = await _anexoRepository.GetByPacienteIdAsync(pacienteId);
        return Ok(anexos);
    }

    /// <summary>
    /// Retorna o arquivo físico de um anexo clínico mediante autenticação JWT (LGPD).
    /// </summary>
    [HttpGet("{id}/file")]
    public async Task<IActionResult> GetFile(Guid id)
    {
        var anexo = await _anexoRepository.GetByIdAsync(id);
        if (anexo == null) return NotFound();

        var safeFileName = Path.GetFileName(anexo.Url);
        if (string.IsNullOrWhiteSpace(safeFileName)) return NotFound();

        var uploadsDir = _configuration["Storage:LocalPath"]
            ?? Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "uploads");
        var fullPath = Path.GetFullPath(Path.Combine(uploadsDir, safeFileName));
        var normalizedRoot = Path.GetFullPath(uploadsDir);

        if (!fullPath.StartsWith(normalizedRoot, StringComparison.OrdinalIgnoreCase) || !System.IO.File.Exists(fullPath))
        {
            return NotFound("Arquivo físico não encontrado.");
        }

        return PhysicalFile(fullPath, ResolveContentType(anexo.Nome), enableRangeProcessing: true);
    }

    [HttpDelete("{id}")]
    [Authorize(Roles = "Admin,Professor")]
    public async Task<IActionResult> Delete(Guid id)
    {
        var anexo = await _anexoRepository.GetByIdAsync(id);
        if (anexo == null) return NotFound();

        try
        {
            await _storageService.DeleteFileAsync(anexo.Url);
            await _anexoRepository.DeleteAsync(id);
            return NoContent();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao excluir arquivo físico ou registro.");
            return StatusCode(500, "Erro ao remover anexo.");
        }
    }
}
