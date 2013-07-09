int objIndName = 0;

void paintOrder(MqlTradeRequest &req)
{    if(req.comment == "OPEN ")
     {  paintOrderGraphicType(OBJ_TREND, req);
        paintOrderGraphicType(OBJ_ARROW_LEFT_PRICE, req);
     } 
     if(req.comment == "CLOSE ORDER ")
     {  objIndName = objIndName - 4;
        paintOrderGraphicType(OBJ_TREND, req);
        objIndName = objIndName + 4;
        paintOrderGraphicType(OBJ_ARROW_RIGHT_PRICE, req);
        
     }
     paintOrderGraphicType(OBJ_VLINE, req);
     paintOrderGraphicText(req);
     ChartRedraw(0);
}

void paintOrderGraphicType(ENUM_OBJECT type, MqlTradeRequest &req)
{    objIndName++;
     ObjectCreate    (0, IntegerToString(objIndName), type, 0, TimeCurrent(), req.price);
     ObjectSetInteger(0, IntegerToString(objIndName), OBJPROP_COLOR, clrYellow);
     ObjectSetInteger(0, IntegerToString(objIndName), OBJPROP_BGCOLOR, clrBlack);
     ObjectSetInteger(0, IntegerToString(objIndName), OBJPROP_STYLE, STYLE_DASH);
     ObjectSetInteger(0, IntegerToString(objIndName), OBJPROP_WIDTH, 1);
}

void paintOrderGraphicText(MqlTradeRequest &req)
{    objIndName++;
     ObjectCreate    (0, IntegerToString(objIndName), OBJ_TEXT, 0, TimeCurrent(), req.price);
     ObjectSetInteger(0, IntegerToString(objIndName), OBJPROP_COLOR, clrYellow);
     ObjectSetInteger(0, IntegerToString(objIndName), OBJPROP_BGCOLOR, clrBlack);
     ObjectSetString (0, IntegerToString(objIndName), OBJPROP_TEXT, req.comment + EnumToString(req.type));
     ObjectSetString (0, IntegerToString(objIndName), OBJPROP_FONT, "Arial");
     ObjectSetInteger(0, IntegerToString(objIndName), OBJPROP_FONTSIZE, 8);
     ObjectSetInteger(0, IntegerToString(objIndName), OBJPROP_ANCHOR, ANCHOR_RIGHT_LOWER);
     ObjectSetDouble (0, IntegerToString(objIndName), OBJPROP_ANGLE, 90);
}

string getInfoOnTick()
{    return StringFormat("ASK=%.6f  \nBID=%.6f  \nSPREAD=%G", SymbolInfoDouble( Symbol(),SYMBOL_ASK), 
            SymbolInfoDouble( Symbol(),SYMBOL_BID), SymbolInfoInteger(Symbol(),SYMBOL_SPREAD));
}