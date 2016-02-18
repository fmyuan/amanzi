/* -*-  mode: c++; c-default-style: "google"; indent-tabs-mode: nil -*- */
/*
  A region consisting of all entities on a mesh.

  Copyright 2010-2013 held jointly by LANS/LANL, LBNL, and PNNL. 
  Amanzi is released under the three-clause BSD License. 
  The terms of use and "as is" disclaimer for this license are 
  provided in the top-level COPYRIGHT file.

  Authors: Ethan Coon (ecoon@lanl.gov)
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
	    const Set_ID id,
	    const LifeCycleType lifecycle=PERMANENT);

  // Is the the specified point inside this region
  bool inside(const Point& p) const;
  
protected:
  const std::string entity_str_; // what kind of entities make up this set
  const std::vector<Entity_ID> entities_; // list of those included
};


} // namespace AmanziGeometry
} // namespace Amanzi


#endif