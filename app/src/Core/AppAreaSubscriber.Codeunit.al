namespace Construction.Core;

using System.Environment.Configuration;

codeunit 50323 "CONS App Area Subscriber"
{
    Access = Internal;
    SingleInstance = true;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Application Area Mgmt. Facade", OnGetEssentialExperienceAppAreas, '', false, false)]
    local procedure SetConstructionAppAreasOnGetEssentialExperienceAppAreas(var TempApplicationAreaSetup: Record "Application Area Setup" temporary)
    var
        FeatureMgt: Codeunit "CONS Feature Mgt.";
    begin
        FeatureMgt.SetEssentialAppAreas(TempApplicationAreaSetup);
    end;
}
