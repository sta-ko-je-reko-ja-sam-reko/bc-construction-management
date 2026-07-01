namespace Construction.Core;

using Construction.Retention;

codeunit 50013 "CONS Service Locator"
{
    Access = Public;
    SingleInstance = true;

    var
        IRetentionReactions: Interface "CONS IRetentionReactions";
        RetentionReactionsDefined: Boolean;

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
}
