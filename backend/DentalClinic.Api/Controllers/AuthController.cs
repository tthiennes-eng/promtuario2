using System.Security.Claims;
using DentalClinic.Core.Application.DTOs;
using DentalClinic.Core.Application.Services;
using DentalClinic.Core.Domain.Repositories;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace DentalClinic.Api.Controllers;

/// <summary>
/// Controller responsável pela autenticação e gestão de tokens.
/// </summary>
[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly IAuthService _authService;
    private readonly IUserRepository _userRepository;
    private readonly ILogger<AuthController> _logger;

    public AuthController(
        IAuthService authService,
        IUserRepository userRepository,
        ILogger<AuthController> logger)
    {
        _authService = authService;
        _userRepository = userRepository;
        _logger = logger;
    }

    /// <summary>
    /// Retorna os dados do usuário autenticado pela sessão atual.
    /// </summary>
    [Authorize]
    [HttpGet("me")]
    [ProducesResponseType(typeof(UserDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> Me()
    {
        var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(userIdClaim) || !Guid.TryParse(userIdClaim, out var userId))
        {
            return Unauthorized();
        }

        var user = await _userRepository.GetByIdAsync(userId);
        if (user == null || !user.IsActive)
        {
            return Unauthorized();
        }

        var userDto = new UserDto(
            user.Id,
            user.Name,
            user.EmailAddress.Value,
            user.Role.ToString().ToLower());

        return Ok(userDto);
    }

    /// <summary>
    /// Realiza o login do usuário.
    /// </summary>
    [HttpPost("login")]
    [AllowAnonymous]
    [ProducesResponseType(typeof(TokenDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> Login([FromBody] LoginDto loginDto)
    {
        _logger.LogInformation("Tentativa de login para: {Email}", loginDto.Email);

        var result = await _authService.AuthenticateAsync(loginDto);

        if (!result.Success)
        {
            return Unauthorized(new { message = result.Message });
        }

        return Ok(result.Data);
    }

    /// <summary>
    /// Renova o access token utilizando um refresh token.
    /// </summary>
    [HttpPost("refresh")]
    [AllowAnonymous]
    public async Task<IActionResult> Refresh([FromBody] RefreshTokenRequest request)
    {
        var result = await _authService.RefreshTokenAsync(request);

        if (!result.Success)
        {
            return BadRequest(new { message = result.Message });
        }

        return Ok(result.Data);
    }

    /// <summary>
    /// Encerra a sessão do usuário.
    /// </summary>
    [Authorize]
    [HttpPost("logout")]
    public async Task<IActionResult> Logout()
    {
        var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (userId != null)
        {
            await _authService.RevokeTokenAsync(userId);
        }
        return NoContent();
    }

    /// <summary>
    /// Registra uma solicitação de recuperação de senha sem expor se o e-mail existe na base.
    /// </summary>
    [HttpPost("forgot-password")]
    [AllowAnonymous]
    public async Task<IActionResult> ForgotPassword([FromBody] ForgotPasswordRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Email) || !request.Email.Contains('@'))
        {
            return BadRequest(new { message = "Informe um e-mail institucional válido." });
        }

        var normalizedEmail = request.Email.Trim().ToLowerInvariant();
        var user = await _userRepository.GetByEmailAsync(normalizedEmail);
        _logger.LogInformation(
            "Solicitação de recuperação de senha registrada para {Email} (usuário encontrado: {Found}).",
            normalizedEmail,
            user != null);

        return Ok(new
        {
            message = "Se o e-mail estiver cadastrado, a solicitação de redefinição de senha foi registrada para atendimento pela coordenação/administrador."
        });
    }
}

public record ForgotPasswordRequest(string Email);
