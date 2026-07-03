namespace Construction.Core;

using System.Security.AccessControl;

/// <summary>
/// Default <c>CONS IAccessPolicy</c> — the effective-permission check, in ONE place. Asks the platform for the
/// user's effective permission BY OBJECT ID via the Microsoft <c>Effective Permissions Mgt.</c> codeunit filling
/// a temporary <c>Permission Buffer</c>; it only ever touches Microsoft objects (every user is licensed for
/// them), so it never re-introduces the licensing crash it exists to prevent. Must be in the Unlicensed base
/// permission set (every user resolves it from the base-app subscriber proxies). <c>SingleInstance</c> +
/// per-id caching: effective permissions are constant within a session.
/// </summary>
codeunit 50028 "CONS Access Policy" implements "CONS IAccessPolicy"
{
    Access = Public;
    SingleInstance = true;

    var
        ExecuteCache: Dictionary of [Integer, Boolean];
        ReadCache: Dictionary of [Integer, Boolean];

    procedure HasEffectiveExecute(CodeunitId: Integer): Boolean
    var
        ExpandedPermission: Record "Expanded Permission";
        HasAccess: Boolean;
    begin
        if ExecuteCache.ContainsKey(CodeunitId) then
            exit(ExecuteCache.Get(CodeunitId));
        HasAccess := HasEffective(ExpandedPermission."Object Type"::Codeunit, CodeunitId, true);
        ExecuteCache.Set(CodeunitId, HasAccess);
        exit(HasAccess);
    end;

    procedure HasEffectiveRead(TableId: Integer): Boolean
    var
        ExpandedPermission: Record "Expanded Permission";
        HasAccess: Boolean;
    begin
        if ReadCache.ContainsKey(TableId) then
            exit(ReadCache.Get(TableId));
        HasAccess := HasEffective(ExpandedPermission."Object Type"::"Table Data", TableId, false);
        ReadCache.Set(TableId, HasAccess);
        exit(HasAccess);
    end;

    /// <summary>Effective-permission check by object id — touches only Microsoft objects, never a product object.</summary>
    local procedure HasEffective(ObjectType: Integer; ObjectId: Integer; CheckExecute: Boolean): Boolean
    var
        TempPermissionBuffer: Record "Permission Buffer" temporary;
        EffectivePermissionsMgt: Codeunit "Effective Permissions Mgt.";
    begin
        EffectivePermissionsMgt.PopulatePermissionBuffer(
            TempPermissionBuffer, UserSecurityId(), CopyStr(CompanyName(), 1, 50), ObjectType, ObjectId);
        if CheckExecute then
            TempPermissionBuffer.SetFilter("Execute Permission", '<>%1', TempPermissionBuffer."Execute Permission"::" ")
        else
            TempPermissionBuffer.SetFilter("Read Permission", '<>%1', TempPermissionBuffer."Read Permission"::" ");
        exit(not TempPermissionBuffer.IsEmpty());
    end;
}
