//##########################################################################################################
//# Variable ZigZag Indicator                                                                              #
//##########################################################################################################
       double HighBuffer[];
       double LowBuffer[];
       double ColorBuffer[];
       int    handleInd;
#define ERROR_ZZ(error)    Print("Error: ", __FUNCTION__, __LINE__, error)

//##########################################################################################################
//# ZigZag Indicator                                                                                       #
//##########################################################################################################
void instanceZizZagIndicator()
{    ResetLastError();
     handleInd = iCustom(_Symbol, _Period, "Examples\\ZigzagColor");
     if(handleInd==INVALID_HANDLE)
     {  ERROR_ZZ(GetLastError());
     }
}

void readZigZagIndicator()
{    ResetLastError();
     if(CopyBuffer(handleInd, 2, 0, 5, ColorBuffer) == WRONG_VALUE) ERROR_ZZ(GetLastError());
     if(CopyBuffer(handleInd, 3, 0, 5, HighBuffer ) == WRONG_VALUE) ERROR_ZZ(GetLastError());
     if(CopyBuffer(handleInd, 4, 0, 5, LowBuffer  ) == WRONG_VALUE) ERROR_ZZ(GetLastError());
}

bool evalZigZagIndicator(double &checkData[])
{    if(checkData[ArraySize(checkData)-1] == 0)
     {   return false;
     }
     for(int index=0;index<ArraySize(checkData)-1;index++)
     {   if(checkData[index]>0)
         { return false;
         }
     }
     return true;
}

bool evalZigZagColor(double &checkColor[])
{    for(int index=0;index<ArraySize(checkColor);index++)
     {   if(checkColor[index]>0)
         { return false;
         }
     }
     return true;
}

void printZigZagIndicator()
{    Print("Color Buffer: ", writeZigZagIndicator(ColorBuffer) + "-" + 
           "High Buffer: " , writeZigZagIndicator(HighBuffer ) + "-" + 
           "Low Buffer: "  , writeZigZagIndicator(LowBuffer  ));
}

string writeZigZagIndicator(double &checkData[])
{    string values = "";
     for(int index=0;index<=ArraySize(checkData)-1;index++)
     {   values = values + DoubleToString(checkData[index],3) + " " ;
     }
     return StringSubstr(values,0,StringLen(values)-1);
}
//##########################################################################################################
//# End ZigZag Indicator                                                                                   #
//##########################################################################################################