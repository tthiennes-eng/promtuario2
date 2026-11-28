using DentalClinic.Core.Domain.Entities;
using DentalClinic.Core.Domain.Repositories;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace DentalClinic.Api.Controllers;

/// <summary>
/// Controller para gestão de notificações e alertas do sistema.
/// </summary>
[Authorize]
[ApiController]
[Route("api/[controller]")]
public class NotificationsController : ControllerBase
{
    private readonly INotificationRepository _repository;
    private readonly ILogger<NotificationsController> _logger;

    public NotificationsController(INotificationRepository repository, ILogger<NotificationsController> logger)
    {
        _repository = repository;
        _logger = logger;
    }

    /// <summary>
    /// Recupera as notificações do usuário autenticado.
    /// </summary>
    [HttpGet]
    public async Task<IActionResult> Get()
    {
        var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(userId)) return Unauthorized();

        var notifications = await _repository.GetByUserIdAsync(Guid.Parse(userId));
        return Ok(notifications);
    }

    /// <summary>
    /// Marca uma notificação específica como lida (somente do usuário autenticado).
    /// </summary>
    [HttpPatch("{id}/read")]
    public async Task<IActionResult> MarkAsRead(Guid id)
    {
        var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(userIdClaim) || !Guid.TryParse(userIdClaim, out var userId))
            return Unauthorized();

        var notification = await _repository.GetByIdAsync(id);
        if (notification == null) return NotFound();
        if (notification.UserId != userId) return Forbid();

        notification.MarkAsRead();
        await _repository.UpdateAsync(notification);
        return NoContent();
    }

    /// <summary>
    /// Remove uma notificação do usuário autenticado.
    /// </summary>
    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(Guid id)
    {
        var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(userIdClaim) || !Guid.TryParse(userIdClaim, out var userId))
            return Unauthorized();

        var notification = await _repository.GetByIdAsync(id);
        if (notification == null) return NotFound();
        if (notification.UserId != userId) return Forbid();

        await _repository.DeleteAsync(notification);
        return NoContent();
    }

    /// <summary>
    /// Marca todas as notificações do usuário como lidas.
    /// </summary>
    [HttpPost("mark-all-read")]
    [HttpPost("read-all")]
    public async Task<IActionResult> MarkAllRead()
    {
        var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(userId) || !Guid.TryParse(userId, out var parsedId)) return Unauthorized();

        await _repository.MarkAllAsReadAsync(parsedId);
        return NoContent();
    }
}
