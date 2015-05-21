/* File: hash_table.cc
 * ----------------
 */

#include <string>
#include <iostream>
#include <ext/hash_map>
#include <cstring>
//#include <tr1/unordered_map>

using namespace std;
using namespace __gnu_cxx;

using __gnu_cxx::hash_map;

namespace __gnu_cxx {

    template<> struct hash<std::string>
    {
        size_t operator()(const std::string& s) const
        {
            return hash<char*>()(s.c_str());
        }
    };

} 

/*struct myhashstr{
  size_t operator()(const string& str) const{
        return __stl_hash_string(str.c_str());
    }
};

struct eqstr{
  bool operator()(const char* s1, const char* s2) const{
     return strcmp(s1, s2)==0;
  }
};*/

/*namespace zl
{
    struct equal_to
    {
        bool operator()(const char* s1, const char* s2) const
        {
            return strcmp(s1, s2) == 0;
        }
    };
 
    struct hash_string
        : public std::unary_function<std::string, std::size_t>
        {
            std::size_t
                operator()(const std::string& __s) const
#ifdef __linux__
                { return std::tr1::Fnv_hash<>::hash(__s.data(), __s.length()); }
#else
                { return std::tr1::_Fnv_hash<>::hash(__s.data(), __s.length()); }
#endif
        };

    
    struct hash_charptr
        : public std::unary_function<const char*, std::size_t>
        {
            std::size_t
                operator()(const char* __s) const
#ifdef __linux__
                { return std::tr1::Fnv_hash<>::hash(__s, strlen(__s)); }
#else
                { return std::tr1::_Fnv_hash<>::hash(__s, strlen(__s)); }
#endif
        };
}*/
