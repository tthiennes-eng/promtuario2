using DentalClinic.Core.Application.DTOs;
using DentalClinic.Core.Application.Interfaces;
using DentalClinic.Core.Domain.Entities;
using DentalClinic.Core.Domain.Repositories;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace DentalClinic.Api.Controllers;

/// <summary>
/// Controller para gestão de usuários (Colaboradores, Professores, Alunos).
/// Acesso restrito a Administradores e Coordenadores.
/// </summary>
[Authorize(Roles = "Admin,Coordinator")]
[ApiController]
[Route("api/[controller]")]
public class UsersController : ControllerBase
{
    private readonly IUserRepository _userRepository;
    private readonly IPasswordHasher _passwordHasher;
    private readonly ILogger<UsersController> _logger;

    public UsersController(
        IUserRepository userRepository,
        IPasswordHasher passwordHasher,
        ILogger<UsersController> logger)
    {
        _userRepository = userRepository;
        _passwordHasher = passwordHasher;
        _logger = logger;
    }

    private static bool TryParseUserRole(string? raw, out UserRole role)
    {
        role = UserRole.Student;
        if (string.IsNullOrWhiteSpace(raw)) return false;

        if (Enum.TryParse<UserRole>(raw.Trim(), true, out role))
            return true;

        switch (raw.Trim().ToLowerInvariant())
        {
            case "administrador":
            case "administrator":
                role = UserRole.Admin;
                return true;
            case "coordenador":
                role = UserRole.Coordinator;
                return true;
            case "professor":
                role = UserRole.Professor;
                return true;
            case "aluno":
            case "estudante":
                role = UserRole.Student;
                return true;
            case "recepcionista":
                role = UserRole.Receptionist;
                return true;
            case "secretaria":
            case "secretária":
                role = UserRole.Secretary;
                return true;
            default:
                return false;
        }
    }

    /// <summary>
    /// Lista usuários com filtros reais de papel e busca textual.
    /// </summary>
    [HttpGet]
    public async Task<IActionResult> Get([FromQuery] string? role = null, [FromQuery] string? search = null)
    {
        UserRole? userRole = null;
        if (!string.IsNullOrEmpty(role) && TryParseUserRole(role, out var parsedRole))
        {
            userRole = parsedRole;
        }

        var users = await _userRepository.GetAllAsync(userRole, search);

        var userDtos = users.Select(u => new UserDto(
            u.Id,
            u.Name,
            u.EmailAddress.Value,
            (u.Roles.FirstOrDefault() != default ? u.Roles.First() : u.Role).ToString(),
            u.IsActive
        ));

        return Ok(userDtos);
    }

    /// <summary>
    /// Cadastra um novo usuário.
    /// </summary>
    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateUserRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Name) || string.IsNullOrWhiteSpace(request.Email) || string.IsNullOrWhiteSpace(request.Password))
        {
            return BadRequest("Nome, e-mail e senha são obrigatórios.");
        }

        if (!TryParseUserRole(request.Role, out var role))
        {
            return BadRequest("Papel de usuário inválido.");
        }

        DentalClinic.Core.Domain.ValueObjects.Address? address = null;
        if (!string.IsNullOrWhiteSpace(request.Street) && !string.IsNullOrWhiteSpace(request.City))
        {
            address = DentalClinic.Core.Domain.ValueObjects.Address.Create(
                request.Street,
                request.Number ?? "S/N",
                request.Complement,
                request.Neighborhood ?? "Centro",
                request.City,
                request.State ?? "MA",
                request.ZipCode ?? "00000-000");
        }

        var user = DentalClinic.Core.Domain.Entities.User.Create(
            request.Name.Trim(),
            request.Email.Trim(),
            request.CPF ?? string.Empty,
            request.DateOfBirth,
            request.Phone,
            address,
            role
        );

        user.SetPasswordHash(_passwordHasher.HashPassword(request.Password));
        user.ConfirmEmail();
        user.Activate();

        await _userRepository.AddAsync(user);

        return CreatedAtAction(
            nameof(Get),
            new { id = user.Id },
            new UserDto(user.Id, user.Name, user.EmailAddress.Value, user.Role.ToString(), user.IsActive));
    }

    /// <summary>
    /// Altera o status de ativação de um usuário.
    /// </summary>
    [HttpPatch("{id}/status")]
    public async Task<IActionResult> ToggleStatus(Guid id, [FromBody] ToggleStatusRequest request)
    {
        var user = await _userRepository.GetByIdAsync(id);
        if (user == null) return NotFound();

        if (request.Active) user.Activate();
        else user.Deactivate();

        await _userRepository.UpdateAsync(user);
        return NoContent();
    }

    /// <summary>
    /// Altera o papel (perfil de acesso) de um usuário.
    /// </summary>
    [HttpPatch("{id}/role")]
    public async Task<IActionResult> UpdateRole(Guid id, [FromBody] UpdateRoleRequest request)
    {
        if (!TryParseUserRole(request.Role, out var newRole))
            return BadRequest("Papel de usuário inválido.");

        var user = await _userRepository.GetByIdAsync(id);
        if (user == null) return NotFound();

        user.UpdateRole(newRole);
        await _userRepository.UpdateAsync(user);
        return NoContent();
    }
}

public record CreateUserRequest(
    string Name,
    string Email,
    string Password,
    string Role,
    string? CPF = null,
    DateTime? DateOfBirth = null,
    string? Phone = null,
    string? Street = null,
    string? Number = null,
    string? Complement = null,
    string? Neighborhood = null,
    string? City = null,
    string? State = null,
    string? ZipCode = null
);

public record ToggleStatusRequest(bool Active);
public record UpdateRoleRequest(string Role);
