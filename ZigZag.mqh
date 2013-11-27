//+-------------------------------------------------------------------------------------------------------------------+
//|                                                                                                       ZigZag.mqh  |
//+-------------------------------------------------------------------------------------------------------------------+
class ZigZag
{   private:
		double            Low[];
		double            High[];
		int               handle;
		ENUM_ORDER_TYPE   resEvalToOpenPosition;
		void              read(void);
		void              print();
		bool              eval(double &vector[]);
		string            write(double &vector[]);
    public:
		void              instance(void);
		ENUM_ORDER_TYPE   evalToOpenPosition();
		ENUM_ORDER_TYPE   getResEvalToOpenPosition();
};
//+-------------------------------------------------------------------------------------------------------------------+
//| instance()                                                                                                        |
//+-------------------------------------------------------------------------------------------------------------------+
void ZigZag::instance() {
    handle = iCustom(_Symbol, _Period, "Examples\\ZigzagColor");
    if (handle == INVALID_HANDLE) {
		Print("Error: ", __FUNCTION__, __LINE__, GetLastError());
    }
}
//+-------------------------------------------------------------------------------------------------------------------+
//| read()                                                                                                            |
//+-------------------------------------------------------------------------------------------------------------------+
void ZigZag::read() {
    if ((CopyBuffer(handle, 3, 0, 6, High) == WRONG_VALUE) || (CopyBuffer(handle, 4, 0, 6, Low) == WRONG_VALUE)) {
        Print("Error: ", __FUNCTION__, __LINE__, GetLastError());
    }
}
//+-------------------------------------------------------------------------------------------------------------------+
//| eval()                                                                                                            |
//+-------------------------------------------------------------------------------------------------------------------+
bool ZigZag::eval(double &vector[]) {
    if (vector[ArraySize(vector) - 1] == 0) {
        return false;
    }
    for (int index=0; index < ArraySize(vector) - 1; index++) {
        if (vector[index] > 0) {
            return false;
        }
    }
    return true;
}
//+-------------------------------------------------------------------------------------------------------------------+
//| evalToOpenPosition()                                                                                              |
//+-------------------------------------------------------------------------------------------------------------------+
ENUM_ORDER_TYPE ZigZag::evalToOpenPosition() {
    read();
    if (eval(High)) {
        resEvalToOpenPosition = ORDER_TYPE_SELL;
    } else if (eval(Low)) {
        resEvalToOpenPosition = ORDER_TYPE_BUY;
    } else {
        resEvalToOpenPosition = NULL;
    }
    return getResEvalToOpenPosition();
}
//+-------------------------------------------------------------------------------------------------------------------+
//| write()                                                                                                           |
//+-------------------------------------------------------------------------------------------------------------------+
string ZigZag::write(double &vector[]) {
    string values = "";
    for (int index=0; index <= ArraySize(vector) - 1; index++) {
        values = values + DoubleToString(vector[index], 2) + " ";
    }
    return values;
}
//+-------------------------------------------------------------------------------------------------------------------+
//| print()                                                                                                           |
//+-------------------------------------------------------------------------------------------------------------------+
void ZigZag::print() {
    printf("High: %s  Low: %s", write(High), write(Low));
}
//+-------------------------------------------------------------------------------------------------------------------+
//| getResEvalToOpenPosition()                                                                                        |
//+-------------------------------------------------------------------------------------------------------------------+
ENUM_ORDER_TYPE ZigZag::getResEvalToOpenPosition() {
    return resEvalToOpenPosition;
}
//+-------------------------------------------------------------------------------------------------------------------+
//| end                                                                                                               |
//+-------------------------------------------------------------------------------------------------------------------+