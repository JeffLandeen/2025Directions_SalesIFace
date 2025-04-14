# 2025Directions_SalesIFace
Sales Interface for 2025 Directions Summit in Las Vegas

Sales Contract Example Steps
------------
Note: This is based on a copy of the Base Microsoft Codeunit 7002.

Background:
==========
This starts with a copy of the existing Microsoft Codeunit that supports Best Price (i.e. lowest price wins)
Some additional functions are added to implement the custom code and the rest of the functionality re-uses original code or it just calls the original base BC codeunit 7002.

Key Steps and their BC AL Objects:
=================================================
1. Extend the Price Calculation Method Enum. (Enum Ext. 50500)
2. Write Interface Handler  (CDU 50500)
3. Hook calculation option up to handler (Enum Ext. 50501)
4. Add this pricing option to the price method list (in CDU 50500)
5. Implement/Update Price Calc. Buffer as needed (in CDU 50502)
6. Implement Custom Logic in ApplyPrice (in CDU 50500)

References
==========
Github Repositories
-------------------
1. Custom Process Interface: [Silviu Process Example Github Link](https://github.com/SilviuVirlan/Directions2025)
2. Retention Policies Interfaces (Base App): [Silviu Policy Github Link](https://github.com/SilviuVirlan/Directions2025InterfacesRetentionPoliciesCustomization)

Blogs & Articles
----------------
1. Directions 2025 Interface Presentation: [Link to Github Upload of Deck](https://github.com/JeffLandeen/2025Directions_SalesIFace/blob/main/presentation/Directions%202025%20Las%20Vegas%20-%20Harnessing%20Interfaces%20-%20build%20your%20own%20sales%20price%20engine.pptx)
2. Extending Best Price calculations (MS Learn): [Ext. Price Calculations Link](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-extending-best-price-calculations)
3. Extending Sales Price Engine (Flemming Bakkensen): [Blog Link](https://www.linkedin.com/pulse/how-extend-price-calculation-flemming-bakkensen-6tkgf/)
4. Interfaces (MS Learn): [Interface Help](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-interfaces-in-al)
5. Kyle Hardens Days of Knowledge Examples: [DOK Examples](https://github.com/kylehardin7/daysofknowledge)
