#include<iostream>
#include<string>

using namespace std;

int no_of_buckets;

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

class ScopeTable //hash table
{
public:

    SymbolInfo *syfo; //array of pointers of SymbolInfo type
    ScopeTable *parentScope;
    int id=1;

    ScopeTable(int n)
    {
        syfo = new SymbolInfo[n];
    }

    int hashing(string name)
    {
        unsigned long hashVal = 0;
        int c;
        for(int i=0; i<name.size(); i++)
        {
            c = name[i];
            hashVal = c + (hashVal << 6) + (hashVal << 16) - hashVal;
        }
        return (hashVal%no_of_buckets);
    }

    SymbolInfo* lookUp(string symbolName)
    {
        SymbolInfo *cur = this->syfo;
        int ind = hashing(symbolName);
        for(int i=0; i<ind; i++)
        {
            cur++;
        }
        int auxInd = 0;
        while(cur!= NULL)
        {
            if(cur->getName() == symbolName)
            {
                return cur;
            }
            cur = cur->getNext();
            auxInd++;
        }
        return cur;
    }

    bool insertIntoSymbolTable(string symbolName, string symbolType)
    {
        SymbolInfo *ptr = this->syfo;
        int ind = hashing(symbolName);
        for(int i=0; i<ind; i++)
        {
            ptr++;
        }
        while(ptr->getNext()!= NULL)
        {
            if(ptr->getName()== symbolName)
                return false;
            if(ptr->getName()=="")
                break;
            ptr = ptr->getNext();
        }
        if(ptr->getName()== symbolName)
        {
            return false;
        }else if(ptr->getName()=="")
        {
            cout << "Inserted " << symbolName << endl;
            ptr->setName(symbolName);
            ptr->setType(symbolType);
            return true;
        }
        else
        {
            ptr->setNext(symbolName, symbolType);
            cout << "Inserted " << symbolName << endl;
            return true;
        }
        cout <<"oppse!\n";
    }

    void print()
    {
        SymbolInfo *ptr = this->syfo;
        for(int i=0; i<no_of_buckets; i++)
        {
            if(ptr-> getName()=="")
            {
                cout << i << " -->" << endl;
            }else
            {
                SymbolInfo *auxPtr = ptr;
                cout << i << " --> ";
                while(auxPtr != NULL)
                {
                    cout << "<" << auxPtr->getName() <<" : " << auxPtr->getType() << ">\t";
                    auxPtr = auxPtr->getNext();
                }
                cout << endl;
            }
            ptr++;
        }
    }

    ~ScopeTable()
    {
        delete[] syfo;
    }
};

int main()
{
    no_of_buckets = 7;
    ScopeTable s(7);
    s.insertIntoSymbolTable("a", "a");
    s.insertIntoSymbolTable("h", "h");
    s.insertIntoSymbolTable("foo", "FUNCTION");
    s.insertIntoSymbolTable("5", "NUMBER");
    s.insertIntoSymbolTable("i", "VAR");

    s.print();
    return 0;
}
