#include<bits/stdc++.h>
#include "symbolInfo.cpp"
using namespace std;


int no_of_buckets;

class ScopeTable //hash table
{
public:

    SymbolInfo **syfo; //pointer for the hash table
    ScopeTable *parentScope;
    int deletedId = 0;
    string scopeId= "";

    ScopeTable(int n)
    {
        syfo = new SymbolInfo*[n];
        for(int i=0; i<n; i++)
        {
            syfo[i] = NULL;
        }
        parentScope = NULL;
    }

    string giveUniqueId()
    {
        //if the parent scope exist, then concatenate parent scope's id
        if(parentScope != NULL)
        {
            scopeId += parentScope->scopeId+".";
        }
        scopeId += to_string((parentScope->deletedId+1));
        return scopeId;
    }

    uint32_t hashing(string name)
    {
        uint32_t hashVal = 0;
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
        SymbolInfo **ptr = this->syfo;
        int ind = hashing(symbolName);
        int auxInd = 0;
        SymbolInfo *cur = ptr[ind];
        while(cur!= NULL)
        {
            if(cur->getName() == symbolName)
            {
                cout << "Found in ScopeTable# " << scopeId << " at position " << ind << ", " << auxInd << endl;
                return cur;
            }
            cur = cur->getNext(); //traversing the particular row of the hash table
            auxInd++;
        }
        return cur;
    }

    bool insertIntoSymbolTable(string symbolName, string symbolType)
    {
        SymbolInfo **ptr = this->syfo;
        int ind = hashing(symbolName);
        int pos = 0;

        SymbolInfo *cur = ptr[ind];
        while(true)
        {
            if(cur == NULL)
            {
                //if the hash table index is empty, simply insert the symbol in that hash table
                ptr[ind] = new SymbolInfo(symbolName, symbolType);
                cout << "Inserted in ScopeTable# " << scopeId << " at position " << ind << ", " << pos << endl;
                return true;
            }
            if(cur->getName()== symbolName)
            {
                cout << "<" << symbolName << "," << symbolType << "> already exists in current ScopeTable" << endl;
                return false;
            }
            if(cur->getNext() == NULL)
            {
                //inserting at the end
                pos++;
                cur->setNext(symbolName, symbolType);
                cout << "Inserted in ScopeTable# " << scopeId << " at position " << ind << ", " << pos << endl;
                return true;
            }
            cur = cur->getNext();
            pos++;
        }
    }

    bool deleteAnEntry(string symbol)
    {
        int location = hashing(symbol);
        SymbolInfo **ptr = this->syfo;
        SymbolInfo *cur = ptr[location];
        int ind = 0;
        if(cur == NULL)
        {
            cout << "Not found\n";
            return false;
        }
        if(cur->getName()==symbol)
        {
            //if the desired symbol is at the beginning of a row
            ptr[location] = cur->getNext();
            delete cur;
            cout << "Found in ScopeTable# "<< scopeId << " at position "<< location << ", " <<ind <<endl;
            cout << "Deleted Entry " << location << ", " << ind << " from current ScopeTable" << endl;
            return true;
        }
        SymbolInfo *prev = cur;
        while(cur != NULL)
        {
            //if the desired value is at anywhere but beginning
            if(cur->getName()==symbol)
            {
                prev->setNext(cur->getNext());
                delete cur;
                cout << "Found in ScopeTable# "<< scopeId << " at position "<< location << ", " <<ind <<endl;
                cout << "Deleted Entry " << location << ", " << ind << " from current ScopeTable" << endl;
                return true;
            }
            prev = cur;
            cur = cur->getNext();
            ind++;
        }
        cout << "Not found!" << endl;
        return false;
    }

    void print()
    {
        SymbolInfo **ptr = this->syfo;
        for(int i=0; i<no_of_buckets; i++)
        {
            if(ptr == NULL)
            {
                cout << i << " -->" << endl;
            }
            else
            {
                SymbolInfo *auxPtr = *ptr;
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
        for(int i=0; i<no_of_buckets; i++)
        {
            delete syfo[i];
        }
        delete[] syfo;
    }
};

