#include <iostream>
#include "stdlib.h"
#include "math.h"

#include <Epetra_Comm.h>
#include <Epetra_MpiComm.h>
#include "Epetra_SerialComm.h"
#include "Teuchos_ParameterList.hpp"
#include "Teuchos_ParameterXMLFileReader.hpp"
#include "UnitTest++.h"

#include "CycleDriver.hh"
#include "energy_thermal_conductivity_registration.hh"
#include "energy_internal_energy_registration.hh"
#include "Mesh.hh"
#include "MeshFactory.hh"
#include "mpc_pks_registration.hh"
#include "PK_Factory.hh"
#include "PK.hh"
#include "energy_twophase_registration.hh"
#include "pks_flow_registration.hh"
#include "pks_transport_registration.hh"
#include "State.hh"


TEST(MPC_DRIVER_THERMAL_RICHARDS) {

using namespace Amanzi;
using namespace Amanzi::AmanziMesh;
using namespace Amanzi::AmanziGeometry;

  Epetra_MpiComm comm(MPI_COMM_WORLD);
  
  std::string xmlInFileName = "test/mpc_driver_thermal_richards.xml";

  // read the main parameter list
  Teuchos::ParameterXMLFileReader xmlreader(xmlInFileName);
  Teuchos::ParameterList plist = xmlreader.getParameters();
  
  // For now create one geometric model from all the regions in the spec
  Teuchos::ParameterList region_list = plist.get<Teuchos::ParameterList>("Regions");
  GeometricModelPtr gm = new GeometricModel(2, region_list, &comm);

  // create mesh
  FrameworkPreference pref;
  pref.clear();
  pref.push_back(MSTK);
  pref.push_back(STKMESH);

  MeshFactory meshfactory(&comm);
  meshfactory.preference(pref);
  Teuchos::RCP<Mesh> mesh = meshfactory(0.0, 0.0, 216.0, 120.0, 54, 60, gm);
  ASSERT(!mesh.is_null());

  bool mpc_new = true;
  
  // create dummy observation data object
  Amanzi::ObservationData obs_data;    

  if (mpc_new) {
    if (plist.isSublist("State")) {
      // Create the state.    
      Teuchos::ParameterList state_plist = plist.sublist("State");
      Teuchos::RCP<Amanzi::State> S = Teuchos::rcp(new Amanzi::State(state_plist));
      S->RegisterMesh("domain", mesh);

      Amanzi::CycleDriver cycle_driver(plist, S, &comm, obs_data);
      cycle_driver.go();
    }
  }
}

