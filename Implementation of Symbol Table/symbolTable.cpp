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

    bool deleteAnEntry(string symbol)
    {
        int location = hashing(symbol);
        cout << "Hash function in delete returned " << location << endl;
        SymbolInfo *cur = this->syfo;
        for(int i=0; i<location; i++)
        {
            cur++;
        }
        //if the location is empty, then the symbol is not present in the symbol table
        if(cur->getName()=="")
        {
            cout << "Empty string!" << endl;
            return false;
        }

        else
        {
            bool flag = false;
            SymbolInfo *prev=cur;
            while(cur!= NULL)
            {
                cout << "Entered while loop in delete\n";
                if(cur->getName()==symbol)
                {
                    flag = true;
                    cout << "flag is true in while loop\n";
                    break;
                }
                prev = cur;
                cur = cur->getNext();
            }
            if(flag)
            {
                if(cur->getNext() != NULL)
                {
                    //if the symbol is in the first pointer of collision linked list, then deleting the pointer causes
                    //to break down the array of pointers chain. therefore, the next pointer's data is kept here and the next
                    //pointer is deleted!
                    cur->setName(cur->getNext()->getName());
                    cur->setType(cur->getNext()->getType());
                    cur->setNext(cur->getNext()->getNext());
                    delete cur->getNext();

                }else
                {
                    cout << "Current's next pointer is null...so deleting current will do" << endl;
                    prev ->setNext(NULL);
                    //if previous's next pointer is not set to null, then deleting the current pointer causes run time error
                    delete cur;
                }

                cout << "Setting next pointer\n";
            }
            return flag;
        }
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

    s.deleteAnEntry("5");
    cout <<"\n\nAfter deleting\n\n";
    s.print();
    return 0;
}
