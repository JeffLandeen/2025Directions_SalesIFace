namespace Directions_SalesIFace.Directions_SalesIFace;
using Microsoft.Pricing.Calculation;

codeunit 51501 "Sales IFace Management"
{
    //Step 4 - This will show it in the price method list

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Price Calculation Mgt.", 'OnFindSupportedSetup', '', false, false)]
    local procedure OnFindSupportedSetup(var TempPriceCalculationSetup: Record "Price Calculation Setup");
    begin
        TempPriceCalculationSetup.Init();
        TempPriceCalculationSetup.Method := TempPriceCalculationSetup.Method::"Sales Contract";
        TempPriceCalculationSetup.Enabled := true;
        TempPriceCalculationSetup.Type := TempPriceCalculationSetup.Type::Sale;
        TempPriceCalculationSetup."Asset Type" := TempPriceCalculationSetup."Asset Type"::Item;
        TempPriceCalculationSetup.Validate(Implementation, TempPriceCalculationSetup.Implementation::"Sales Contract");
        TempPriceCalculationSetup.Default := true;
        TempPriceCalculationSetup.Insert(true);
    end;
}
