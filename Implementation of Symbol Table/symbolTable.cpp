#include<iostream>
#include<string>
#include "scopeTable.cpp"

using namespace std;

class SymbolTable
{
public:

    ScopeTable *currentScopeTable;

    SymbolTable(int n)
    {
        currentScopeTable = new ScopeTable(n);
        currentScopeTable->scopeId = "1";
    }

    void enterScope(int n)
    {
        ScopeTable *st = new ScopeTable(n);
        st->parentScope = this->currentScopeTable;
        this->currentScopeTable = st;
        cout <<"New ScopeTable with id " << this->currentScopeTable->giveUniqueId() <<" created\n";
    }

    void exitScope()
    {
        ScopeTable *temp = this->currentScopeTable;
        this->currentScopeTable = this->currentScopeTable->parentScope;
        this->currentScopeTable->deletedId++;
        delete temp;
    }

    bool insertInCurrentST(string name, string type)
    {
        bool flag = this->currentScopeTable->insertIntoSymbolTable(name, type);
        return flag;
    }

    bool removeFromCurrentST(string name)
    {
        bool flag = this->currentScopeTable->deleteAnEntry(name);
        return flag;
    }

    SymbolInfo* lookUp(string name)
    {
        ScopeTable *ptr = currentScopeTable;
        SymbolInfo *location = ptr->lookUp(name);
        while(ptr->parentScope != NULL)
        {
            if(location != NULL)
            {
                return location;
            }
            ptr = ptr->parentScope;
            location = ptr->lookUp(name);
        }
        return location;
    }

    void printCurrentScopeTable()
    {
        cout << "ScopeTable # " << this->currentScopeTable->scopeId << endl;
        this->currentScopeTable->print();
    }

    void printAllScopeTable()
    {
        ScopeTable *ptr = this->currentScopeTable;
        while(ptr!= NULL)
        {
            cout << "ScopeTable # " << ptr->scopeId << endl;
            ptr->print();
            ptr = ptr->parentScope;
        }
    }
};

int main()
{

    no_of_buckets = 7;
    SymbolTable st(no_of_buckets);
    st.insertInCurrentST("a", "a");
    st.enterScope(no_of_buckets);
    st.insertInCurrentST("h","h");
    st.enterScope(no_of_buckets);
    st.insertInCurrentST("o","o");
    st.printAllScopeTable();

    return 0;
}
