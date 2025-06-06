/*
  Copyright 2010-202x held jointly by participating institutions.
  Amanzi is released under the three-clause BSD License.
  The terms of use and "as is" disclaimer for this license are
  provided in the top-level COPYRIGHT file.

  Authors: Ethan Coon (ecoon@lanl.gov)
           Konstantin Lipnikov (lipnikov@lanl.gov)
*/

/*
  Evaluators

  A collection of porosity models along with a mesh partition.
*/

#include "dbc.hh"

#include "Porosity_Constant.hh"
#include "Porosity_Compressible.hh"
#include "PorosityModelPartition.hh"

namespace Amanzi {
namespace Evaluators {

/* ******************************************************************
* Non-member factory.
****************************************************************** */
Teuchos::RCP<PorosityModelPartition>
CreatePorosityModelPartition(Teuchos::RCP<const AmanziMesh::Mesh>& mesh,
                             Teuchos::RCP<Teuchos::ParameterList> plist)
{
  std::vector<Teuchos::RCP<Porosity>> pom_list;
  std::vector<std::vector<std::string>> region_list;

  for (auto lcv = plist->begin(); lcv != plist->end(); ++lcv) {
    std::string name = lcv->first;
    if (plist->isSublist(name)) {
      Teuchos::ParameterList sublist = plist->sublist(name);
      region_list.push_back(sublist.get<Teuchos::Array<std::string>>("regions").toVector());

      std::string model = sublist.get<std::string>("porosity model");
      if (model == "constant") {
        pom_list.push_back(Teuchos::rcp(new Porosity_Constant(sublist)));
      } else {
        pom_list.push_back(Teuchos::rcp(new Porosity_Compressible(sublist)));
      }
    } else {
      AMANZI_ASSERT(0);
    }
  }

  auto partition = Teuchos::rcp(new Functions::MeshPartition());
  partition->Initialize(mesh, AmanziMesh::Entity_kind::CELL, region_list, -1);
  partition->Verify();

  return Teuchos::rcp(new PorosityModelPartition(partition, pom_list));
}

} // namespace Evaluators
} // namespace Amanzi
