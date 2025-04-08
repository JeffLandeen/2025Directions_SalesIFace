# 2025Directions_SalesIFace
Sales Interface for 2025 Directions Summit in Las Vegas

Sales Contract Example Steps
------------
Note:
====
This is based on a copy of the Base Microsoft Codeunit 7002.

Background:
==========
-> This starts with a copy of the existing Microsoft Codeunit that supports Best Price (i.e. lowest price wins)
-> Some additional functions are added to implement the custom code and the rest of the functionality re-uses original code or it just calls the original base BC codeunit 7002.

Key Steps and their BC AL Objects:
=================================================
1. Extend the Price Calculation Method Enum. (Enum Ext. 50500)
2. Write Interface Handler  (CDU 50500)
3. Hook calculation option up to handler (Enum Ext. 50501)
4. Add this pricing option to the price method list (in CDU 50500)
5. Implement/Update Price Calc. Buffer as needed (in CDU 50502)
6. Implement Custom Logic in ApplyPrice (in CDU 50500)
