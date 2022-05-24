#include<bits/stdc++.h>
#include "symbolInfo.cpp"
using namespace std;


int no_of_buckets;

class ScopeTable //hash table
{
public:

    SymbolInfo *syfo; //array of pointers of SymbolInfo type
    ScopeTable *parentScope;
    int deletedId = 0;
    string scopeId= "";

    ScopeTable(int n)
    {
        syfo = new SymbolInfo[n];
        parentScope = NULL;
    }

    string giveUniqueId()
    {
        ScopeTable *ptr = parentScope;
        if(ptr != NULL)
        {
            scopeId += ptr->scopeId+".";
        }
        scopeId += to_string((parentScope->deletedId+1));
        return scopeId;
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
                cout << "Found in ScopeTable# " << scopeId << " at position " << ind << ", " << auxInd << endl;
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
        int pos = 0;
        while(ptr->getNext()!= NULL)
        {
            if(ptr->getName()== symbolName)
            {
                cout << "<" << symbolName << "," << symbolType << "> already exists in current ScopeTable" << endl;
                return false;
            }

            if(ptr->getName()=="")
                break;
            ptr = ptr->getNext();
            pos++;
        }
        if(ptr->getName()== symbolName)
        {
            cout << "<" << symbolName << "," << symbolType << "> already exists in current ScopeTable" << endl;
            return false;
        }else if(ptr->getName()=="")
        {
            cout << "Inserted in ScopeTable# " << scopeId << " at position " << ind << ", " << pos << endl;
            ptr->setName(symbolName);
            ptr->setType(symbolType);
            return true;
        }
        else
        {
            pos++;
            ptr->setNext(symbolName, symbolType);
            cout << "Inserted in ScopeTable# " << scopeId << " at position " << ind << ", " << pos << endl;
            return true;
        }
        cout << __LINE__ << endl;
    }

    bool deleteAnEntry(string symbol)
    {
        int location = hashing(symbol);
        SymbolInfo *cur = this->syfo;
        int ind = 0;
        for(int i=0; i<location; i++)
        {
            cur++;
        }
        //if the location is empty, then the symbol is not present in the symbol table
        if(cur->getName()=="")
        {
            cout <<  "Not found"<< endl;
            return false;
        }

        else
        {
            bool flag = false;
            SymbolInfo *prev=cur;
            while(cur!= NULL)
            {
//                cout << "In while loop of deleteAnEntry" << endl;
                if(cur->getName()==symbol)
                {
                    flag = true;
                    break;
                }
                ind++;
                prev = cur;
                cur = cur->getNext();
            }
            if(flag)
            {
                if(cur->getNext() != NULL)
                {
//                    cout << "next is not null case" << endl;
                    //if the symbol is in the first pointer of collision linked list, then deleting the pointer causes
                    //to break down the array of pointers chain. therefore, the next pointer's data is kept here and the next
                    //pointer is deleted!
                    cur->setName(cur->getNext()->getName());
                    cur->setType(cur->getNext()->getType());
                    cur->setNext(cur->getNext()->getNext());
                    delete cur->getNext();

                }else
                {
//                    cout << "next is null case" << endl;
                    prev ->setNext(cur->getNext());
                    //if previous's next pointer is not set to null, then deleting the current pointer causes run time error
//                    delete cur;
                }
                cout << "Found in ScopeTable# "<< scopeId << " at position "<< location << ", " <<ind <<endl;
                cout << "Deleted Entry " << location << ", " << ind << " from current ScopeTable" << endl;
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

