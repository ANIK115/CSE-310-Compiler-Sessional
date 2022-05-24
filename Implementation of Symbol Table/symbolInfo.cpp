#include<bits/stdc++.h>
using namespace std;

class SymbolInfo
{
    string name;
    string type;
    SymbolInfo *next;

public:

    SymbolInfo()
    {

    }

    SymbolInfo(string name, string type)
    {
        this->name = name;
        this->type = type;
        next = NULL;
    }

    string getName()
    {
        return this->name;
    }
    string getType()
    {
        return this->type;
    }
    SymbolInfo* getNext()
    {
        return next;
    }
    void setNext(string symName, string symType)
    {
        next = new SymbolInfo(symName, symType);
    }
    void setNext(SymbolInfo* s)
    {
        next = s;
    }
    void setName(string name)
    {
        this->name = name;
    }
    void setType(string type)
    {
        this->type = type;
    }
    ~SymbolInfo()
    {
        delete next;
    }
};
