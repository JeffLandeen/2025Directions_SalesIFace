namespace Directions_SalesIFace.Directions_SalesIFace;

using Microsoft.Sales.Pricing;

pageextension 51500 "Sales IFace Sales Price List" extends "Sales Price List"
{
    layout
    {
        addafter(AssignToNo)
        {
            field("Ship-To Code"; Rec."Ship-To Code")
            {
                ApplicationArea = all;
                Caption = 'Ship-To Code';
                ToolTip = 'This is the Customer Ship To ID realted to the Source No.  Only allowed for Customer Price Lists';
            }
        }
    }
}
