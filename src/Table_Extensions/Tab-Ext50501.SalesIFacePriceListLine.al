namespace Directions_SalesIFace.Directions_SalesIFace;
using Microsoft.Pricing.PriceList;
using Microsoft.Pricing.Source;

tableextension 51501 "Sales IFace Price List Line" extends "Price List Line"
{
    fields
    {
        field(51500; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(51501; "Ship-To Code"; Code[10])
        {
            Caption = 'Ship-To Code';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    trigger OnBeforeInsert()
    begin
        CheckUpdateSalesIFaceFields();
    end;

    trigger OnBeforeModify()
    begin
        CheckUpdateSalesIFaceFields();
    end;

    local procedure CheckUpdateSalesIFaceFields();
    var
        PriceHeader: Record "Price List Header";
    begin
        if PriceHeader.Get(Rec."Price List Code") then begin
            if (PriceHeader."Source Type" = PriceHeader."Source Type"::Customer) then begin
                if Rec."Ship-To Code" <> PriceHeader."Ship-To Code" then
                    Rec."Ship-To Code" := PriceHeader."Ship-To Code";
                if Rec."Customer No." <> PriceHeader."Source No." then
                    Rec."Customer No." := PriceHeader."Source No.";
            end;
        end;
    end;
}
