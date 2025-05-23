/*
  Copyright 2010-202x held jointly by participating institutions.
  Amanzi is released under the three-clause BSD License.
  The terms of use and "as is" disclaimer for this license are
  provided in the top-level COPYRIGHT file.

  Authors: Ethan Coon (ecoon@lanl.gov)
*/

//! A region consisting of the entirety of space in any dimension.
/*!

No parameters are required.

`"region type`" = `"all`"

.. _region-all-spec:
.. admonition:: region-all-spec

   * `"empty`" ``[bool]`` **True** This is simply here to avoid issues with empty lists.

Example:

.. code-block:: xml

   <ParameterList name="domain">
     <Parameter name="region type" type="string" value="all"/>
   </ParameterList>

*/


#ifndef AMANZI_REGION_ALL_HH_
#define AMANZI_REGION_ALL_HH_

#include <vector>

#include "errors.hh"
#include "GeometryDefs.hh"

#include "Region.hh"

namespace Amanzi {
namespace AmanziGeometry {

class RegionAll : public Region {
 public:
  RegionAll(const std::string& name,
            const int id,
            const LifeCycleType lifecycle = LifeCycleType::PERMANENT);

  // Is the the specified point inside this region
  bool inside(const Point& p) const;
};

} // namespace AmanziGeometry
} // namespace Amanzi


#endif
