int    handleInd;
double High[], Low[], Color[];

void instanceZZ()
{    ResetLastError();
     handleInd = iCustom(_Symbol, _Period, "Examples\\ZigzagColor");
     if(handleInd==INVALID_HANDLE) Print("Error: ", __FUNCTION__, __LINE__, GetLastError());
}

void readZZ()
{    ResetLastError();
     if(CopyBuffer(handleInd, 2, 0, 5, Color) == WRONG_VALUE) Print("Error: ", __FUNCTION__, __LINE__, GetLastError());
     if(CopyBuffer(handleInd, 3, 0, 5, High ) == WRONG_VALUE) Print("Error: ", __FUNCTION__, __LINE__, GetLastError());
     if(CopyBuffer(handleInd, 4, 0, 5, Low  ) == WRONG_VALUE) Print("Error: ", __FUNCTION__, __LINE__, GetLastError());
}

bool evalZZ(double &checkData[])
{    if(checkData[ArraySize(checkData)-1] == 0) return false;
     for(int index=0;index<ArraySize(checkData)-1;index++)
     {   if(checkData[index]>0) return false;
     }   return true;
}

string writeZZ(double &checkData[])
{    string values = "";
     for(int index=0;index<=ArraySize(checkData)-1;index++)
     {   values = values + DoubleToString(checkData[index],3) + " " ;
     }   return values;
}

void printZZ()
{    printf("Color: %s  High: %s  Low: %s", writeZZ(Color), writeZZ(High), writeZZ(Low));
}