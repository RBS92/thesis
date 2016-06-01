# Code for master thesis (GR1052, WCS, AAU, 2016)
In this GIT repository you may find three MatLab-based simulators:
a LoRaWAN simulator
a LTE-MTC/LTE-A simulator
a "combined" simulator (Capilarry networks simulator)

NB!! To run the combined simulator a folder named "cc_coords" must be created and filled with ASCII files containing the coordinates of optimal solutions to the circle packing in a circle problem. Such ASCII files may be found at: 
http://hydra.nat.uni-magdeburg.de/packing/cci/txt/cci_coords.tar.gz

Thanks to Germán Madueño Correales for creating and letting me use the LTE-MTC simulator core (base functionality, scheduler, message exchange) which I have I have optimized, added features to (RLC, AMC, packet bundling) and spent countless hours debugging.

