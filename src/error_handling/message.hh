/*
  Copyright 2010-202x held jointly by participating institutions.
  Amanzi is released under the three-clause BSD License.
  The terms of use and "as is" disclaimer for this license are
  provided in the top-level COPYRIGHT file.

  Authors:
*/

#ifndef AMANZI_UTILS_MESSAGE_HH_
#define AMANZI_UTILS_MESSAGE_HH_

#include <algorithm>
#include <string>
#include <vector>

namespace Errors {

#define CHAR_MAX_VALUE 127;

inline void
encode_string(std::string& s, int n, int m, std::vector<int>& out)
{
  int mc = m * CHAR_MAX_VALUE;
  for (int i = 0; i < n; ++i) out[i] = mc + (int)s[i];
  out[n] = mc;
}

inline void
decode_string(const std::vector<int>& in, int n, std::string& s)
{
  int m = in[n];
  for (int i = 0; i < n; ++i) s[i] = in[i] - m;
}

} // namespace Errors
#endif
