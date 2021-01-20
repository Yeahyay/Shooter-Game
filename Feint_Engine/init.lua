-- initializes the bare minimum for the engine to run

require("Feint_Engine.feintAPI")
Feint:init(false)

printf("\n")
Feint.Log.log("Initializing Feint Engine\n\n")

Feint.Util.Debug.PRINT_ENV(_ENV, false)

printf("\n")
Feint.Log.log("Initialized\n")
