namespace Directions_SalesIFace.Directions_SalesIFace;

using Microsoft.Sales.Pricing;

pageextension 51502 "Sales IFace Sales Price Lists" extends "Sales Price Lists"
{
    layout
    {
        addafter(SourceNo)
        {
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
