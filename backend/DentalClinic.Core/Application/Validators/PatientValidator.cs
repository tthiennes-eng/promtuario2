using DentalClinic.Core.Domain.Entities;
using FluentValidation;

namespace DentalClinic.Core.Application.Validators;

public class PatientValidator : AbstractValidator<Patient>
{
    public PatientValidator()
    {
        // Regra para Nome: sincronizado com propriedade FullName
        RuleFor(x => x.FullName)
            .NotEmpty().WithMessage("O nome do paciente é obrigatório.")
            .MinimumLength(3).WithMessage("O nome deve ter pelo menos 3 caracteres.")
            .MaximumLength(255).WithMessage("O nome não pode exceder 255 caracteres.");

        RuleFor(x => x.CPF)
            .NotEmpty().WithMessage("O CPF é obrigatório.")
            .Matches(@"^\d{11}$|^\d{3}\.\d{3}\.\d{3}-\d{2}$")
            .WithMessage("O CPF deve conter 11 dígitos.");

        RuleFor(x => x.SusNumber)
            .Must(value => string.IsNullOrWhiteSpace(value) || value.Length == 15)
            .WithMessage("O número do SUS deve conter 15 dígitos.");

        // CORREÇÃO: Email passa a ser opcional (validar formato apenas quando preenchido).
        // A regra NotEmpty() anterior rejeitava cadastros vindos do app Flutter
        // que não informavam e-mail, impedindo a sincronização do paciente com o
        // servidor e causando o erro "paciente não existe" ao agendar.
        RuleFor(x => x.Email)
            .EmailAddress().WithMessage("O formato do email é inválido.")
            .When(x => !string.IsNullOrWhiteSpace(x.Email));

        // Regra para Data de Nascimento: Sincronizado com propriedade BirthDate
        RuleFor(x => x.BirthDate)
            .NotEmpty().WithMessage("A data de nascimento é obrigatória.")
            .LessThan(DateTime.Now).WithMessage("A data de nascimento deve ser no passado.");
    }
}
