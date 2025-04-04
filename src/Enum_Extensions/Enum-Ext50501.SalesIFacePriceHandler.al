namespace Directions_SalesIFace.Directions_SalesIFace;

using Microsoft.Pricing.Calculation;

enumextension 51501 "Sales IFace Price Handler" extends "Price Calculation Handler"
{
    //Step 3 - hook calculation option up to handler
    value(51500; "Sales Contract")
    {
        Implementation = "Price Calculation" = "Sales IFace Contract Handler";
    }
}
