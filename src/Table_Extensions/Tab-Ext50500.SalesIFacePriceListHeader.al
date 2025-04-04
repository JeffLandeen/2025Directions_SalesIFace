namespace Directions_SalesIFace.Directions_SalesIFace;

using Microsoft.Pricing.PriceList;
using Microsoft.Sales.Customer;
using Microsoft.Pricing.Source;

tableextension 51500 "Sales IFace Price List Header" extends "Price List Header"
{
    fields
    {
        field(51500; "Ship-To Code"; Code[10])
        {
            Caption = 'Ship-To Code';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                ShipToAddress: Record "Ship-to Address";
                ShipToListPage: Page "Ship-to Address List";
            begin
                if (Rec."Source Type" = Rec."Source Type"::Customer) then begin
                    if (Rec."Source No." <> '') then begin
                        ShipToAddress.SetRange("Customer No.", Rec."Source No.");
                        ShipToListPage.LookupMode(true);
                        ShipToListPage.SetTableView(ShipToAddress);
                        if (ShipToListPage.RunModal() = Action::LookupOK) then begin
                            ShipToListPage.GetRecord(ShipToAddress);
                            Rec.Validate("Ship-To Code", ShipToAddress.Code);
                        end;
                    end else begin
                        Error(CustNoMissingErr);
                    end;
                end else begin
                    Error(CustTypeOnlyErr);
                end;
            end;


            trigger OnValidate()
            var
                ShipToAddress: Record "Ship-to Address";
            begin
                if ("Ship-To Code" <> '') then begin
                    if (Rec."Source Type" = Rec."Source Type"::Customer) then begin
                        if not ShipToAddress.Get(Rec."Source No.", Rec."Ship-To Code") then
                            Error(CustShipInvalidErr);
                    end else begin
                        Error(CustTypeOnlyErr);
                    end;
                end;
            end;
        }
    }


    var
        CustTypeOnlyErr: Label 'Only Source Types of Customer are allowed.';
        CustNoMissingErr: Label 'You must Define a Customer No. in the Source No. field.';
        CustShipInvalidErr: Label 'Customer No. and Ship To Code combination are invalid.  Cannot find a matching Ship To Address.';
}
