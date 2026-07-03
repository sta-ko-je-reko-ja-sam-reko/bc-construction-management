namespace Construction.Core;

using Construction.Retention;
using Construction.Subcontracts;

codeunit 50013 "CONS Service Locator"
{
    Access = Public;
    SingleInstance = true;

    var
        IAccessPolicy: Interface "CONS IAccessPolicy";
        IRetentionReactions: Interface "CONS IRetentionReactions";
        ISubcWfReactions: Interface "CONS ISubc Wf Reactions";
        AccessPolicyDefined: Boolean;
        RetentionReactionsDefined: Boolean;
        SubcWfReactionsDefined: Boolean;

    /// <summary>Resolves the access-policy implementation (defaults to the built-in effective-permission check). In the Unlicensed base permission set — every user resolves it.</summary>
    /// <returns>The active access-policy implementation.</returns>
    procedure AccessPolicy(): Interface "CONS IAccessPolicy"
    var
        Default: Codeunit "CONS Access Policy";
    begin
        if not AccessPolicyDefined then
            ImplementAccessPolicy(Default);
        exit(IAccessPolicy);
    end;

    /// <summary>Overrides the access-policy implementation (tests / dependent apps).</summary>
    /// <param name="Implementation">The access-policy implementation to use.</param>
    procedure ImplementAccessPolicy(Implementation: Interface "CONS IAccessPolicy")
    begin
        IAccessPolicy := Implementation;
        AccessPolicyDefined := true;
    end;

    /// <summary>Resolves the retention-reaction implementation (defaults to the built-in logic).</summary>
    /// <returns>The active retention-reaction implementation.</returns>
    internal procedure RetentionReactions(): Interface "CONS IRetentionReactions"
    var
        Default: Codeunit "CONS Retention Logic";
    begin
        if not RetentionReactionsDefined then
            ImplementRetentionReactions(Default);
        exit(IRetentionReactions);
    end;

    /// <summary>Overrides the retention-reaction implementation (tests / dependent apps).</summary>
    /// <param name="Implementation">The retention-reaction implementation to use.</param>
    internal procedure ImplementRetentionReactions(Implementation: Interface "CONS IRetentionReactions")
    begin
        IRetentionReactions := Implementation;
        RetentionReactionsDefined := true;
    end;

    /// <summary>Resolves the change-order approval/workflow reaction implementation (defaults to the built-in logic).</summary>
    /// <returns>The active subcontracts workflow-reaction implementation.</returns>
    internal procedure SubcWfReactions(): Interface "CONS ISubc Wf Reactions"
    var
        Default: Codeunit "CONS Subc Wf Reactions";
    begin
        if not SubcWfReactionsDefined then
            ImplementSubcWfReactions(Default);
        exit(ISubcWfReactions);
    end;

    /// <summary>Overrides the subcontracts workflow-reaction implementation (tests / dependent apps).</summary>
    /// <param name="Implementation">The subcontracts workflow-reaction implementation to use.</param>
    internal procedure ImplementSubcWfReactions(Implementation: Interface "CONS ISubc Wf Reactions")
    begin
        ISubcWfReactions := Implementation;
        SubcWfReactionsDefined := true;
    end;
}
