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
Custom Process Interface: [Silviu Process Example Github Link](https://github.com/SilviuVirlan/Directions2025)
Retention Policies Interfaces (Base App): [Silviu Policy Github Link](https://github.com/SilviuVirlan/Directions2025InterfacesRetentionPoliciesCustomization)

Blogs & Articles
----------------
Extending Best Price calculations (MS Learn): [Ext. Price Calculations Link](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-extending-best-price-calculations)
Extending Sales Price Engine (Flemming Bakkensen): [Blog Link](https://www.linkedin.com/pulse/how-extend-price-calculation-flemming-bakkensen-6tkgf/)
Interfaces (MS Learn): [Interface Help](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-interfaces-in-al)
Kyle Hardens Days of Knowledge Examples: [DOK Examples](https://github.com/user-attachments/assets/c5187aed-6fea-4d6f-8b6f-607dd9574c3e)
