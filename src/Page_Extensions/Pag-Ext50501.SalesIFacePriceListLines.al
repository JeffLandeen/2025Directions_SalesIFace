namespace Directions_SalesIFace.Directions_SalesIFace;

using Microsoft.Pricing.PriceList;

pageextension 51501 "Sales IFace Price List Lines" extends "Price List Lines"
{
    layout
    {
        addbefore("Asset Type")
        {
            field("Customer No."; Rec."Customer No.")
            {
                ApplicationArea = all;
                Caption = 'Customer No.';
                ToolTip = 'This is the Customer No. inherited from the header of the list';
                Editable = false;
            }
            field("Ship-To Code"; Rec."Ship-To Code")
            {
                ApplicationArea = all;
                Caption = 'Ship-To Code';
                ToolTip = 'This is the Customer Ship To ID inherited from the header of the list';
                Editable = false;
            }
        }

    }
}
