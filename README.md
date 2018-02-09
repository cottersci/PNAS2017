# Code for Cotter C. R. Schutter H-B. Igoshin O. A. Shimkets L. J. (2017) PNAS 114(23) E4592-E4601

http://www.pnas.org/content/114/23/E4592.abstract

While I suspect the data is compatible with many versions of MATLAB, I did
most of the work in MATLAB_R2016b, in which I am sure the data loads.

Please include the following citation with the use of this code or derivatives:

```
Cotter, C.R., Schüttler, H.-B., Igoshin, O.A., and Shimkets, L.J. (2017). Data-driven
    modeling reveals cell behaviors controlling self-organization during Myxococcus
    xanthus development. Proc. Natl. Acad. Sci. U.S.A. 114, E4592–E4601.
```

## Data Structures

### NOTICE
Cell density measurements in the data structures for this paper were calculated assuming a mean cell density greater than was actually used in experiments. Cell density values should be rescaled by 0.42 to convert to true experimental densities.

For example: AllDataTable.rho1 * 0.42 = [True cell density in experiments]

## AllDataTable
Found in the AllDataWStopsum.mat data file (Not included in repository due to size)

AllDataTable: A table combining all the run data from AllData into one structure. This was used to run the simulations and generate all figures. The resulting table of runs is temporally aligned according to the values of AllData{i}.AlignedStart and AllData{i}.AlignedStop

Each row represents one cell run, with columns (variables) representing the quantified data relating to that run. Most variables are followed by a number (i.e. Rd1, Rd0). The number 1 indicates the value for that run. Variables that end in a 0 (i.e. Rd0) contain the value for the run from the same cell, performed prior to the current run. In the same way, variables that end in a 2 indicate values for the run from the same cell, performed after the current run. See figure below for visual explanation:

![Variable Naming Figure](/VariableNamingFigure.png?raw=true "AllDataTable Naming Scheme")

Unnumbered variables relate to the run represented by that row (the current run).

The table consists of the variables:

See Figure S1 of paper for a drawing of some of these variables.

```Rd (float):``` Run distance (um)

```Rt (float):``` Run duration (min)

```Rs (float):``` Run speed (um/min)

```rho (float):``` Local Cell density at start of the run (cells/um^2)

```drho (float):``` Change in cell density from the start to the end of the run (cells/um^2)

```TSS (float):``` Time since the beginning of the movie (Frames [1 frame = 30 seconds])

```Dn (float):``` Distance to the nearest aggregate boundary (um). A value of NaN indicates there are no aggregates.

```phi (float):``` Angle between the ending point of the run and a vector pointing to the center of the neareast aggregate (radians 0 <= beta < pi/2). A value of NaN indicates there are no aggregates

```beta (float):``` Angle between the starting point of the run and a vector pointing to the center of the neareast aggregate (radians 0 <= beta < pi/2). A value of NaN indicates there are no aggregates

```startInside (bool):``` Run start inside of an aggregate

```theta (float):``` Angle enclosed between the previous run of a cell and the current run

```xstart (float):``` x coordinate of the start of the run (um)

```ystart (float):``` y coordinate of the start of the run (um)

```xstop (float):``` x coordinate of the end of the run (um)

```ystop (float):``` y coordinate of the end of the run (um)

```orientation (float):``` Angle enclosed between the run vector and the x axis (radians 0 <= beta < pi/2)

```state (int):``` State of the cell during the run (1: Persistent forward, 2: Persistent forward [opposite direction], 3: Nonpersistent )

```movie (string):``` The name of the fluorescent movie the run came from

```set (int):``` An id unique to the movie the run came from

```ksi (float):``` Mean Nematic alignment orientation at cell location (radians 0 <= beta < pi/2)

```ksiN (float):``` Number of runs that started without the alignment window of the current run, 0 indicates no other runs were close enough to calculate alignment. The size of the window is set by:
- TIME: the surroudning runs must occur within +/- TIME frames (Set to 10)
- RADIUS: the surrounding runs must occur within +/- RADIUS um   (Set to 14)

```chi (float):``` ksi1 - orientation1

```neighbor_alignment (float):```  mean(cos(2 * (orientation1 - surrounding))) where surrounding is the cells within the alignment calculation window.

```mean_alignment (float):``` cos(2 * (orientation1 - T.ksi1))
