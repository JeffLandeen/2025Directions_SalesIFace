namespace Directions_SalesIFace.Directions_SalesIFace;

using Microsoft.Pricing.Calculation;
using Microsoft.Foundation.Company;
using Microsoft.Sales.Pricing;
using Microsoft.Purchases.Pricing;
using Microsoft.Pricing.Source;
using Microsoft.Pricing.Asset;
using Microsoft.Sales.Document;
using Microsoft.Pricing.PriceList;

codeunit 51500 "Sales IFace Contract Handler" implements "Price Calculation"
{
    //Step 2 - Write Interface Handler
    //Copied from original Base BC Codeunit 70002

    var
        CurrPriceCalculationSetup: Record "Price Calculation Setup";
        CurrLineWithPrice: Interface "Line With Price";
        OrigPriceEngine: Codeunit "Price Calculation - V16";
        TempTableErr: Label 'The table passed as a parameter must be temporary.';
        PickedWrongMinQtyErr: Label 'The quantity in the line is below the minimum quantity of the picked price list line.';

        testObject: Record "Sales Line";
        anotherTestObject: Codeunit "Price Calculation - V16";

    #region Price Calculation Interface procedures
    procedure Init(LineWithPrice: Interface "Line With Price"; PriceCalculationSetup: Record "Price Calculation Setup")
    begin
        CurrLineWithPrice := LineWithPrice;
        CurrPriceCalculationSetup := PriceCalculationSetup;
        OrigPriceEngine.Init(LineWithPrice, PriceCalculationSetup);
    end;

    procedure GetLine(var Line: Variant)
    begin
        OrigPriceEngine.GetLine(Line);
    end;

    procedure ApplyDiscount()
    begin
        OrigPriceEngine.ApplyDiscount();
    end;

    local procedure DoesCurrLineUseContractPrice() _result: Boolean
    begin
        _result := false;
        if (CurrLineWithPrice.GetTableNo() = Database::"Sales Line")
            and (CurrLineWithPrice.GetAssetType() = Enum::"Price Asset Type"::Item)
        then
            _result := true;
        exit(_result);
    end;

    procedure ApplyPrice(CalledByFieldNo: Integer)
    var
        TempPriceListLine: Record "Price List Line" temporary;
        PriceListLine: Record "Price List Line";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesHeaderVariant, SalesLineVariant : Variant;
        SalesHeaderRef, SalesLineRef : RecordRef;
        SalesHeaderSysIDField, SalesLineSysIDField : FieldRef;
        PriceCalculationBufferMgt: Codeunit "Price Calculation Buffer Mgt.";
        SalesIFaceBuffer: Codeunit "Sales IFace Price Calc. Buffer";
        AmountType: Enum "Price Amount Type";
        FoundLines: Boolean;
        FoundPrice: Boolean;
    begin
        if not HasAccess(CurrLineWithPrice.GetPriceType(), AmountType::Price) then
            exit;

        if DoesCurrLineUseContractPrice() then begin
            //Find price line with shipment method and customer
            CurrLineWithPrice.GetLine(SalesHeaderVariant, SalesLineVariant);
            SalesHeaderRef.GetTable(SalesHeaderVariant);
            SalesLineRef.GetTable(SalesLineVariant);
            if (SalesHeaderRef.Number = Database::"Sales Header") and (SalesLineRef.Number = Database::"Sales Line") then begin
                SalesHeaderSysIDField := SalesHeaderRef.Field(SalesHeaderRef.SystemIdNo());
                SalesLineSysIDField := SalesLineRef.Field(SalesLineRef.SystemIdNo());
                SalesHeader.GetBySystemId(SalesHeaderSysIDField.Value);
                SalesLine.GetBySystemId(SalesLineSysIDField.Value);


                //Step 6 - Implement some custom logic for sales Price
                //PriceListLine.SetRange(Status, PriceListLine.Status::Active);  //cannot make price active due to duplicate check
                PriceListLine.SetRange("Price Type", PriceListLine."Price Type"::Sale);
                PriceListLine.SetFilter("Amount Type", '%1|%2', AmountType, PriceListLine."Amount Type"::Any);

                PriceListLine.SetFilter("Ending Date", '%1|>=%2', 0D, SalesHeader."Document Date");
                PriceListLine.SetFilter("Currency Code", '%1|%2', SalesHeader."Currency Code", '');
                if SalesLine."Unit of Measure Code" <> '' then
                    PriceListLine.SetFilter("Unit of Measure Code", '%1|%2', SalesLine."Unit of Measure Code", '');
                PriceListLine.SetRange("Starting Date", 0D, SalesHeader."Document Date");

                PriceListLine.SetRange("Asset Type", PriceListLine."Asset Type"::Item);
                PriceListLine.SetRange("Asset No.", SalesLine."No.");
                PriceListLine.SetRange("Ship-To Code", SalesHeader."Ship-to Code");


                if not Confirm('Price List Filters: %1\Count: %2', false, PriceListLine.GetFilters(), PriceListLine.Count()) then
                    Error('Stopping');


                // CurrLineWithPrice.Verify();
                // if not CurrLineWithPrice.CopyToBuffer(PriceCalculationBufferMgt) then
                //     exit;
                // FoundLines := FindshipToLines(AmountType::Price, TempPriceListLine, SalesIFaceBuffer, false, SalesHeader, SalesLine);
                // if not Confirm('Number of price Lines: %1', false, TempPriceListLine.Count()) then
                //     Error('Halting for input 3');
                // if FoundLines then
                //     FoundPrice := CalcBestAmount(AmountType::Price, PriceCalculationBufferMgt, TempPriceListLine);
                // if not FoundPrice then
                //     PriceCalculationBufferMgt.FillBestLine(AmountType::Price, TempPriceListLine);
                // if CurrLineWithPrice.IsPriceUpdateNeeded(AmountType::Price, FoundLines, CalledByFieldNo) then
                //     CurrLineWithPrice.SetPrice(AmountType::Price, TempPriceListLine);
                // CurrLineWithPrice.Update(AmountType::Price);
            end;
        end else begin
            OrigPriceEngine.ApplyPrice(CalledByFieldNo);
        end;
    end;

    procedure CountDiscount(ShowAll: Boolean): Integer
    begin
        exit(OrigPriceEngine.CountDiscount(ShowAll));
    end;

    procedure CountPrice(ShowAll: Boolean): Integer
    begin
        exit(OrigPriceEngine.CountPrice(ShowAll));
    end;

    procedure FindDiscount(var TempPriceListLine: Record "Price List Line"; ShowAll: Boolean): Boolean
    begin
        exit(OrigPriceEngine.FindDiscount(TempPriceListLine, ShowAll));
    end;

    procedure FindPrice(var TempPriceListLine: Record "Price List Line"; ShowAll: Boolean): Boolean
    begin
        if not confirm('in FindPrice Function - keep going?', false) then
            Error('Halting');
        exit(OrigPriceEngine.FindPrice(TempPriceListLine, ShowAll));
    end;

    procedure IsDiscountExists(ShowAll: Boolean): Boolean
    begin
        exit(OrigPriceEngine.IsDiscountExists(ShowAll));
    end;

    procedure IsPriceExists(ShowAll: Boolean): Boolean
    begin
        exit(OrigPriceEngine.IsPriceExists(ShowAll));
    end;

    procedure PickDiscount()
    var
        AmountType: enum "Price Amount Type";
    begin
        Pick(AmountType::Discount, true);
    end;

    procedure PickPrice()
    var
        AmountType: enum "Price Amount Type";
    begin
        Pick(AmountType::Price, true);
    end;

    procedure ShowPrices(var TempPriceListLine: Record "Price List Line")
    begin
        OrigPriceEngine.ShowPrices(TempPriceListLine);
    end;
    #endregion

    #region Additional externally accessible procedures
    procedure FindLines(
        AmountType: Enum "Price Amount Type";
        var TempPriceListLine: Record "Price List Line" temporary;
        var PriceCalculationBufferMgt: Codeunit "Price Calculation Buffer Mgt.";
        ShowAll: Boolean) FoundLines: Boolean;
    begin
        FoundLines := OrigPriceEngine.FindLines(AmountType, TempPriceListLine, PriceCalculationBufferMgt, ShowAll);
    end;

    procedure CopyLinesBySource(
        var PriceListLine: Record "Price List Line";
        PriceSource: Record "Price Source";
        PriceAsset: Record "Price Asset";
        var TempPriceListLine: Record "Price List Line" temporary): Boolean;
    begin
        OrigPriceEngine.CopyLinesBySource(PriceListLine, PriceSource, PriceAsset, TempPriceListLine);
    end;

    procedure CopyLinesBySource(
        var PriceListLine: Record "Price List Line";
        PriceSource: Record "Price Source";
        var PriceAssetList: Codeunit "Price Asset List";
        var TempPriceListLine: Record "Price List Line" temporary) FoundLines: Boolean;
    begin
        FoundLines := OrigPriceEngine.CopyLinesBySource(PriceListLine, PriceSource, PriceAssetList, TempPriceListLine);
    end;

    procedure CalcBestAmount(AmountType: Enum "Price Amount Type"; var PriceCalculationBufferMgt: Codeunit "Price Calculation Buffer Mgt."; var PriceListLine: Record "Price List Line") FoundBestPrice: Boolean;
    begin
        FoundBestPrice := OrigPriceEngine.CalcBestAmount(AmountType, PriceCalculationBufferMgt, PriceListLine);
    end;
    #endregion

    #region local only procedures
    //Step 5 - This will show it in the price method list
    local procedure AddSupportedSetup(var TempPriceCalculationSetup: Record "Price Calculation Setup" temporary)
    begin
        TempPriceCalculationSetup.Init();
        TempPriceCalculationSetup.Validate(Implementation, TempPriceCalculationSetup.Implementation::"Sales Contract");
        TempPriceCalculationSetup.Method := TempPriceCalculationSetup.Method::"Sales Contract";
        TempPriceCalculationSetup.Enabled := not IsDisabled();
        TempPriceCalculationSetup.Default := true;
        //Disable for purchases - enabled for items only
        // TempPriceCalculationSetup.Type := TempPriceCalculationSetup.Type::Purchase;
        // TempPriceCalculationSetup.Insert(true);
        TempPriceCalculationSetup.Type := TempPriceCalculationSetup.Type::Sale;
        TempPriceCalculationSetup.Insert(true);
    end;

    local procedure IsDisabled() Result: Boolean;
    begin
        OnIsDisabled(Result);
    end;

    local procedure HasAccess(PriceType: Enum "Price Type"; AmountType: Enum "Price Amount Type"): Boolean;
    var
        PurchaseDiscountAccess: Record "Purchase Discount Access";
        PurchasePriceAccess: Record "Purchase Price Access";
        SalesDiscountAccess: Record "Sales Discount Access";
        SalesPriceAccess: Record "Sales Price Access";
    begin
        case PriceType of
            "Price Type"::Purchase:
                case AmountType of
                    "Price Amount Type"::Discount:
                        exit(PurchaseDiscountAccess.ReadPermission());
                    "Price Amount Type"::Price:
                        exit(PurchasePriceAccess.ReadPermission());
                end;
            "Price Type"::Sale:
                case AmountType of
                    "Price Amount Type"::Discount:
                        exit(SalesDiscountAccess.ReadPermission());
                    "Price Amount Type"::Price:
                        exit(SalesPriceAccess.ReadPermission());
                end;
        end;
        exit(true);
    end;

    local procedure PickBestLine(AmountType: Enum "Price Amount Type"; PriceListLine: Record "Price List Line"; var BestPriceListLine: Record "Price List Line"; var FoundBestLine: Boolean)
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforePickBestLine(AmountType, PriceListLine, BestPriceListLine, FoundBestLine, IsHandled);
        if IsHandled then
            exit;

        if IsImprovedLine(PriceListLine, BestPriceListLine) or not IsDegradedLine(PriceListLine, BestPriceListLine) then begin
            if IsImprovedLine(PriceListLine, BestPriceListLine) and not IsDegradedLine(PriceListLine, BestPriceListLine) then
                Clear(BestPriceListLine);
            if IsBetterLine(PriceListLine, AmountType, BestPriceListLine) then begin
                BestPriceListLine := PriceListLine;
                FoundBestLine := true;
            end;
        end;
        OnAfterPickBestLine(AmountType, PriceListLine, BestPriceListLine, FoundBestLine);
    end;

    local procedure FindPriceLines(AmountType: Enum "Price Amount Type"; ShowAll: Boolean; var TempPriceListLine: Record "Price List Line" temporary): Boolean;
    var
        PriceCalculationBufferMgt: Codeunit "Price Calculation Buffer Mgt.";
    begin
        if CurrLineWithPrice.CopyToBuffer(PriceCalculationBufferMgt) then
            exit(FindLines(AmountType, TempPriceListLine, PriceCalculationBufferMgt, ShowAll));
    end;

    local procedure Pick(AmountType: enum "Price Amount Type"; ShowAll: Boolean)
    var
        TempPriceListLine: Record "Price List Line" temporary;
        PriceCalculationBufferMgt: Codeunit "Price Calculation Buffer Mgt.";
        PriceAssetList: Codeunit "Price Asset List";
        GetPriceLine: Page "Get Price Line";
    begin
        if not HasAccess(CurrLineWithPrice.GetPriceType(), AmountType) then
            exit;
        CurrLineWithPrice.Verify();
        if not CurrLineWithPrice.CopyToBuffer(PriceCalculationBufferMgt) then
            exit;
        if FindLines(AmountType, TempPriceListLine, PriceCalculationBufferMgt, ShowAll) then begin
            PriceCalculationBufferMgt.GetAssets(PriceAssetList);
            GetPriceLine.SetDataCaptionExpr(PriceAssetList);
            GetPriceLine.SetForLookup(CurrLineWithPrice, AmountType, TempPriceListLine);
            if GetPriceLine.RunModal() = ACTION::LookupOK then begin
                GetPriceLine.GetRecord(TempPriceListLine);
                if not PriceCalculationBufferMgt.IsInMinQty(TempPriceListLine) then
                    Error(PickedWrongMinQtyErr);
                PriceCalculationBufferMgt.VerifySelectedLine(TempPriceListLine);
                PriceCalculationBufferMgt.ConvertAmount(AmountType, TempPriceListLine);
                CurrLineWithPrice.SetPrice(AmountType, TempPriceListLine);
                CurrLineWithPrice.Update(AmountType);
                CurrLineWithPrice.ValidatePrice(AmountType);
            end;
        end;
    end;

    #endregion

    #region Ship To related Logic
    local procedure FindshipToLines(
        AmountType: Enum "Price Amount Type";
        var TempPriceListLine: Record "Price List Line" temporary;
        var PriceCalculationBufferMgt: Codeunit "Sales IFace Price Calc. Buffer";
        ShowAll: Boolean;
        var SHeader: Record "Sales Header";
        var SLine: Record "Sales Line") FoundLines: Boolean;
    var
        PriceListLine: Record "Price List Line";
        PriceSource: Record "Price Source";
        PriceAssetList: Codeunit "Price Asset List";
        PriceSourceList: Codeunit "Price Source List";
        Level: array[2] of Integer;
        CurrLevel: Integer;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        if IsHandled then
            exit(FoundLines);


        if not TempPriceListLine.IsTemporary() then
            Error(TempTableErr);

        TempPriceListLine.Reset();
        TempPriceListLine.DeleteAll();

        PriceCalculationBufferMgt.SetShipToFiltersOnPriceListLine(PriceListLine, AmountType, ShowAll, SHeader, SLine);
        if PriceListLine.FindSet() then begin
            repeat
                clear(TempPriceListLine);
                TempPriceListLine.TransferFields(PriceListLine);
                if not TempPriceListLine.Insert() then
                    TempPriceListLine.Modify();
            until (PriceListLine.Next() = 0);
        end;

        TempPriceListLine.Reset();
        if not Confirm('Temp Price List Set Count: %1', false, TempPriceListLine.Count()) then
            Error('Stopping');

        PriceCalculationBufferMgt.GetAssets(PriceAssetList);
        PriceCalculationBufferMgt.GetSources(PriceSourceList);
        PriceSourceList.GetMinMaxLevel(Level);
        for CurrLevel := Level[2] downto Level[1] do
            if not FoundLines then
                if PriceSourceList.First(PriceSource, CurrLevel) then
                    repeat
                        if PriceSource.IsForAmountType(AmountType) then begin
                            FoundLines :=
                                FoundLines or CopyLinesBySource(PriceListLine, PriceSource, PriceAssetList, TempPriceListLine);
                            PriceCalculationBufferMgt.RestoreFilters(PriceListLine);
                        end;
                    until not PriceSourceList.Next(PriceSource);

        FoundLines := not TempPriceListLine.IsEmpty();
        if not FoundLines then begin
            Message('PRICE WARNING: No Price Found based on Ship To Code.');
            PriceCalculationBufferMgt.FillBestLine(AmountType, TempPriceListLine);
        end;
    end;
    #endregion

    #region Used by PickBestLine - need to review if these are needed
    local procedure IsDegradedLine(PriceListLine: Record "Price List Line"; BestPriceListLine: Record "Price List Line") Result: Boolean
    begin
        Result :=
            IsBlankedValue(PriceListLine."Currency Code", BestPriceListLine."Currency Code") or
            IsBlankedValue(PriceListLine."Variant Code", BestPriceListLine."Variant Code");

        OnAfterIsDegradedLine(PriceListLine, BestPriceListLine, Result);
    end;

    local procedure IsBlankedValue(LineValue: Text; BestLineValue: Text): Boolean
    begin
        exit((BestLineValue <> '') and (LineValue = ''));
    end;

    local procedure IsImprovedLine(PriceListLine: Record "Price List Line"; BestPriceListLine: Record "Price List Line") Result: Boolean
    begin
        Result :=
            IsSetValue(PriceListLine."Currency Code", BestPriceListLine."Currency Code") or
            IsSetValue(PriceListLine."Variant Code", BestPriceListLine."Variant Code");

        OnAfterIsImprovedLine(PriceListLine, BestPriceListLine, Result);
    end;

    local procedure IsSetValue(LineValue: Text; BestLineValue: Text): Boolean
    begin
        exit((BestLineValue = '') and (LineValue <> ''));
    end;

    procedure IsBetterLine(var PriceListLine: Record "Price List Line"; AmountType: Enum "Price Amount Type"; BestPriceListLine: Record "Price List Line") Result: Boolean;
    begin
        OrigPriceEngine.IsBetterLine(PriceListLine, AmountType, BestPriceListLine);
    end;

    local procedure IsBetterPrice(var PriceListLine: Record "Price List Line"; Price: Decimal; BestPriceListLine: Record "Price List Line"): Boolean;
    begin
        PriceListLine."Line Amount" := Price * (1 - PriceListLine."Line Discount %" / 100);
        if not BestPriceListLine.IsRealLine() then
            exit(true);
        exit(PriceListLine."Line Amount" < BestPriceListLine."Line Amount");
    end;
    #endregion


    #region Event Publishers
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Price Calculation Mgt.", 'OnFindSupportedSetup', '', false, false)]
    local procedure OnFindImplementationHandler(var TempPriceCalculationSetup: Record "Price Calculation Setup" temporary)
    begin
        AddSupportedSetup(TempPriceCalculationSetup);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company-Initialize", 'OnCompanyInitialize', '', false, false)]
    local procedure OnCompanyInitializeHandler()
    var
        PriceCalculationMgt: Codeunit "Price Calculation Mgt.";
    begin
        PriceCalculationMgt.Run();
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterIsBetterLine(PriceListLine: Record "Price List Line"; AmountType: Enum "Price Amount Type"; BestPriceListLine: Record "Price List Line"; var Result: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterIsDegradedLine(PriceListLine: Record "Price List Line"; BestPriceListLine: Record "Price List Line"; var Result: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterIsImprovedLine(PriceListLine: Record "Price List Line"; BestPriceListLine: Record "Price List Line"; var Result: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPickBestLine(AmountType: Enum "Price Amount Type"; PriceListLine: Record "Price List Line"; var BestPriceListLine: Record "Price List Line"; var FoundBestLine: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePickBestLine(AmountType: Enum "Price Amount Type"; PriceListLine: Record "Price List Line"; var BestPriceListLine: Record "Price List Line"; var FoundBestLine: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCalcBestAmount(AmountType: Enum "Price Amount Type"; var PriceCalculationBufferMgt: Codeunit "Price Calculation Buffer Mgt."; var PriceListLine: Record "Price List Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnIsDisabled(var Disabled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnFindLinesOnBefoerPriceSourceListGetMinMaxLevel(var PriceAssetList: Codeunit "Price Asset List"; var PriceSourceList: Codeunit "Price Source List"; AmountType: Enum "Price Amount Type"; var PriceCalculationBufferMgt: Codeunit "Price Calculation Buffer Mgt.")
    begin
    end;
    #endregion
}
