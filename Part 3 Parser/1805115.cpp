
#include<bits/stdc++.h>
using namespace std;

#pragma once


class AdditionalInfo
{
public:
    string returnType;
    bool isFunction = false;
    bool isFunctionDefined = false;
    bool isArray = false;
    int arraySize = 0;
    vector<string> typeSpecifiers;
    vector<string> argumentNames;
};


class SymbolInfo
{
    string name;
    string type;
    SymbolInfo *next;

public:

    AdditionalInfo *ai;
    
    SymbolInfo()
    {
        next= NULL;
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
        if(ai !=0)
            delete ai;
    }
};


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
        return (hashVal%7);
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
            cur = cur->getNext();
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
            ptr[location] = cur->getNext();
            delete cur;
            cout << "Found in ScopeTable# "<< scopeId << " at position "<< location << ", " <<ind <<endl;
            cout << "Deleted Entry " << location << ", " << ind << " from current ScopeTable" << endl;
            return true;
        }
        SymbolInfo *prev = cur;
        while(cur != NULL)
        {
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
        for(int i=0; i<7; i++)
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

    void printInLogFile(FILE *logout)
    {
        FILE *fptr = logout;
        SymbolInfo **ptr = this->syfo;
        bool flag = true;
        for(int i=0; i<7; i++)
        {
            if(*ptr != NULL)
            {
            	if(flag)
        	{
        		fprintf(fptr, "\nScopeTable # %s\n", this->scopeId.c_str());
        		flag = false;
        	}

                SymbolInfo *auxPtr = *ptr;
                fprintf(fptr, "%d--> ",i);
                while(auxPtr != NULL)
                {
                    fprintf(fptr, "<%s : %s> ", auxPtr->getName().c_str(), auxPtr->getType().c_str());
                    auxPtr = auxPtr->getNext();
                }
                fprintf(fptr, "\n");
            }
            ptr++;
        }
    }

    ~ScopeTable()
    {
        for(int i=0; i<7; i++)
        {
            delete syfo[i];
        }
        delete[] syfo;
    }
};


class SymbolTable
{
public:

    ScopeTable *currentScopeTable;

    SymbolTable(int n)
    {
        currentScopeTable = new ScopeTable(n);
        currentScopeTable->scopeId = "1";
    }

    void enterScope()
    {
        if(this->currentScopeTable == NULL)
        {
            currentScopeTable = new ScopeTable(7);
            currentScopeTable->scopeId = "1";
            return;
        }
        ScopeTable *st = new ScopeTable(7);
        st->parentScope = this->currentScopeTable;
        this->currentScopeTable = st;
        cout <<"New ScopeTable with id " << this->currentScopeTable->giveUniqueId() <<" created\n";
    }

    void exitScope()
    {
        if(this->currentScopeTable==NULL)
        {
            cout << "NO CURRENT SCOPE" << endl;
            return;
        }
        ScopeTable *temp = this->currentScopeTable;
        cout << "ScopeTable with id " << temp->scopeId << " removed" << endl;
        this->currentScopeTable = this->currentScopeTable->parentScope;
        if(this->currentScopeTable != NULL)
        {
            this->currentScopeTable->deletedId++;
        }
        delete temp;
    }

    bool insertInCurrentST(string name, string type)
    {
        if(this->currentScopeTable == NULL)
        {
            currentScopeTable = new ScopeTable(7);
            currentScopeTable->scopeId = "1";
        }
        bool flag = this->currentScopeTable->insertIntoSymbolTable(name, type);
        return flag;
    }

    bool removeFromCurrentST(string name)
    {
        if(this->currentScopeTable==NULL)
        {
            cout << "NO CURRENT SCOPE" << endl;
            return false;
        }
        bool flag = this->currentScopeTable->deleteAnEntry(name);
        return flag;
    }

    SymbolInfo* lookUp(string name)
    {
        if(this->currentScopeTable==NULL)
        {
            cout << "NO CURRENT SCOPE" << endl;
            return NULL;
        }
        ScopeTable *ptr = currentScopeTable;
        SymbolInfo *location = ptr->lookUp(name);
        if(location != NULL)
        {
            return location;
        }
        while(ptr->parentScope != NULL)
        {
            ptr = ptr->parentScope;
            location = ptr->lookUp(name);
            if(location != NULL)
            {
                cout << "Found!!!!!!!!!!" << endl;
                return location;
            }
        }
        cout << "Not found " << endl;
        return location;
    }

    void printCurrentScopeTable()
    {
        if(this->currentScopeTable==NULL)
        {
            cout << "NO CURRENT SCOPE" << endl;
            return;
        }
        cout << "ScopeTable # " << this->currentScopeTable->scopeId << endl;
        this->currentScopeTable->print();
    }

    void printAllScopeTable(FILE *logout)
    {
        if(this->currentScopeTable==NULL)
        {
            cout << "NO CURRENT SCOPE" << endl;
            return;
        }
        ScopeTable *ptr = this->currentScopeTable;
        while(ptr!= NULL)
        {
            cout << "\nScopeTable # " << ptr->scopeId << endl;
            ptr->print();
            ptr->printInLogFile(logout);
            ptr = ptr->parentScope;
        }
        delete ptr;
    }
    
    ~SymbolTable()
    {
        delete currentScopeTable;
    }
};

