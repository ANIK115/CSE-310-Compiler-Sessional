#include<iostream>
#include<string>
#include <fstream>
#include <vector>
#include <algorithm>
#include <sstream>
#include <iterator>
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
        if(this->currentScopeTable == NULL)
        {
            currentScopeTable = new ScopeTable(no_of_buckets);
            currentScopeTable->scopeId = "1";
            cout <<"New ScopeTable with id " << this->currentScopeTable->scopeId <<" created\n";

            return;
        }
        ScopeTable *st = new ScopeTable(n);
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
    }

    bool insertInCurrentST(string name, string type)
    {
        if(this->currentScopeTable == NULL)
        {
            currentScopeTable = new ScopeTable(no_of_buckets);
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
        while(ptr->parentScope != NULL)
        {
            if(location != NULL)
            {
                return location;
            }
            ptr = ptr->parentScope;
            location = ptr->lookUp(name);
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

    void printAllScopeTable()
    {
        if(this->currentScopeTable==NULL)
        {
            cout << "NO CURRENT SCOPE" << endl;
            return;
        }
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
    fstream myfile ("input.txt");
    string line;
    if (myfile.is_open())
    {
        getline(myfile,line);
        stringstream s(line);
        s >> no_of_buckets;
        SymbolTable st(no_of_buckets);
        while ( getline (myfile,line) )
        {
            cout << line << "\n\n";
            vector<std::string> tokens;
            string token;
            stringstream ss(line);
            while (getline(ss, token, ' '))
            {
                tokens.push_back(token);
            }

            if(tokens[0]=="I")
            {
                st.insertInCurrentST(tokens[1], tokens[2]);
            }
            else if(tokens[0]=="L")
            {
                st.lookUp(tokens[1]);
            }
            else if(tokens[0]=="D")
            {
                st.removeFromCurrentST(tokens[1]);
            }
            else if(tokens[0]=="P")
            {
                if(tokens[1]=="A")
                {
                    st.printAllScopeTable();
                }
                if(tokens[1]=="C")
                {
                    st.printCurrentScopeTable();
                }
            }
            else if(tokens[0]=="S")
            {
                st.enterScope(no_of_buckets);
            }
            else if(tokens[0]=="E")
            {
                st.exitScope();
            }
            else
            {
                cout << "Invalid command from input file!" << endl;
                break;
            }
            cout <<"\n\n";

        }
        myfile.close();
    }

    else cout << "Unable to open file";
    return 0;
}
