/*
  Copyright 2010-202x held jointly by participating institutions.
  Amanzi is released under the three-clause BSD License.
  The terms of use and "as is" disclaimer for this license are
  provided in the top-level COPYRIGHT file.

  Authors: Rao Garimella
           Ethan Coon (ecoon@lanl.gov)
*/

//! An (infinite) plane region in space, defined by a point and a normal.
/*!

Note that the dimension of the point and normal must match that of the mesh on
which the region is resolved.

`"region type`" = `"plane`"

.. _region-plane-spec:
.. admonition:: region-plane-spec

   * `"normal`" ``[Array(double)]`` Normal to the plane.
   * `"point`" ``[Array(double)]`` Point in space.

Example:

.. code-block:: xml

   <ParameterList name="TOP_SECTION"> <!-- parent list -->
     <Parameter name="region type" type="string" value="plane"/>
     <Parameter name="point" type="Array(double)" value="{2, 3, 5}"/>
     <Parameter name="normal" type="Array(double)" value="{1, 1, 0}"/>
     <ParameterList name="expert parameters">
       <Parameter name="tolerance" type="double" value="1.0e-05"/>
     </ParameterList>
   </ParameterList>

*/


#ifndef AMANZI_REGION_PLANE_HH_
#define AMANZI_REGION_PLANE_HH_

#include "Region.hh"

namespace Amanzi {
namespace AmanziGeometry {

class RegionPlane : public Region {
 public:
  // Default constructor uses point and normal
  RegionPlane(const std::string& name,
              const int id,
              const Point& p,
              const Point& normal,
              const LifeCycleType lifecycle = LifeCycleType::PERMANENT);

  // Get the point defining the plane
  const Point& point() const { return p_; }

  // Get the normal point defining the plane
  const Point& normal() const { return n_; }

  // Is the specified point inside this region - in this case it
  // means on the plane
  bool inside(const Point& p) const;

 protected:
  const Point p_; /* point on the plane */
  const Point n_; /* normal to the plane */
};

} // namespace AmanziGeometry
} // namespace Amanzi


#endif
