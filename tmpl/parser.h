
#ifndef IMBECILE_PARSER_HEADER
#define IMBECILE_PARSER_HEADER

#include <pcre.h>

#include <iostream>
#include <map>
#include <vector>

#ifdef I_NAMESPACE
namespace I_NAMESPACE {
#endif

#ifndef REFPTR_H
#define REFPTR_H REFPTR_H

/* Author: Josh Holtrop
 * Purpose: Provide a reference-counting pointer-like first order
 *   C++ object that will free the object it is pointing to when
 *   all references to it have been destroyed.
 * This implementation does not solve the circular reference problem.
 * I was not concerned with that when developing this class.
 */
#include <stdlib.h>             /* NULL */

template <typename T>
class refptr
{
    public:
        refptr<T>();
        refptr<T>(T * ptr);
        refptr<T>(const refptr<T> & orig);
        refptr<T> & operator=(const refptr<T> & orig);
        refptr<T> & operator=(T * ptr);
        ~refptr<T>();
        T & operator*() const { return *m_ptr; }
        T * operator->() const { return m_ptr; }
        bool isNull() const { return m_ptr == NULL; }

    private:
        void cloneFrom(const refptr<T> & orig);
        void destroy();

        T * m_ptr;
        int * m_refCount;
};

template <typename T> refptr<T>::refptr()
{
    m_ptr = NULL;
    m_refCount = NULL;
}

template <typename T> refptr<T>::refptr(T * ptr)
{
    m_ptr = ptr;
    m_refCount = new int;
    *m_refCount = 1;
}

template <typename T> refptr<T>::refptr(const refptr<T> & orig)
{
    cloneFrom(orig);
}

template <typename T> refptr<T> & refptr<T>::operator=(const refptr<T> & orig)
{
    destroy();
    cloneFrom(orig);
    return *this;
}

template <typename T> refptr<T> & refptr<T>::operator=(T * ptr)
{
    destroy();
    m_ptr = ptr;
    m_refCount = new int;
    *m_refCount = 1;
    return *this;
}

template <typename T> void refptr<T>::cloneFrom(const refptr<T> & orig)
{
    this->m_ptr = orig.m_ptr;
    this->m_refCount = orig.m_refCount;
    if (m_refCount != NULL)
        (*m_refCount)++;
}

template <typename T> refptr<T>::~refptr()
{
    destroy();
}

template <typename T> void refptr<T>::destroy()
{
    if (m_refCount != NULL)
    {
        if (*m_refCount <= 1)
        {
            delete m_ptr;
            delete m_refCount;
        }
        else
        {
            (*m_refCount)--;
        }
    }
}

#endif


class I_CLASSNAME
{
    public:
        I_CLASSNAME();
        bool parse(std::istream & in);
        const char * getError() { return m_errstr; }

    protected:
        const char * m_errstr;
};

class Matches
{
    public:
        Matches(pcre * re, const char * data, int * ovector, int ovec_size);
        std::string operator[](int index);
        std::string operator[](const std::string & index);

    protected:
        pcre * m_re;
        const char * m_data;
        int * m_ovector;
        int m_ovec_size;
};
typedef refptr<Matches> MatchesRef;

class Node
{
    public:
        refptr<Node> operator[](int index);
        refptr<Node> operator[](const std::string & index);

    protected:
        std::map< std::string, refptr<Node> > m_named_children;
        std::vector< refptr<Node> > m_indexed_children;
};
typedef refptr<Node> NodeRef;

class Token : public Node
{
    public:
        virtual void process(MatchesRef matches);

    protected:
        {%token_data%}
};
typedef refptr<Token> TokenRef;

{%token_classes%}

#ifdef I_NAMESPACE
};
#endif

#endif /* IMBECILE_PARSER_HEADER */
