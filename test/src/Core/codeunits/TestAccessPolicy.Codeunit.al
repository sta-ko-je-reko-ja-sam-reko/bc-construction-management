namespace Construction.Test;

using Construction.Core;

/// <summary>Configurable access policy injected through the Service Locator, so the tests control the licensing gate instead of depending on the permissions of the user running them.</summary>
codeunit 64017 "CONS Test Access Policy" implements "CONS IAccessPolicy"
{
    SingleInstance = true;

    var
        Deny: Boolean;

    /// <summary>Grants (true) or denies (false) every permission check.</summary>
    /// <param name="Allow">Whether the policy grants access.</param>
    procedure SetAllow(Allow: Boolean)
    begin
        Deny := not Allow;
    end;

    procedure HasEffectiveExecute(CodeunitId: Integer): Boolean
    begin
        exit(not Deny);
    end;

    procedure HasEffectiveRead(TableId: Integer): Boolean
    begin
        exit(not Deny);
    end;
}
