MCMC-Simulation
===============

This is a Markov Chain Monte Carlo simulation program, 
written in MATLAB, which prompts users to input appropriate data 
(time-series functions, markov chain order, etc.) and outputs a 
simulated version of that data. It is a useful tool for generating
potential future data (for wind power, wind speed, electricity 
prices, etc.) which can be used to determine what kind of wind 
farms, retrofits, etc. should be implemented.

Running the application
-----------------------
To start the application, run main.m. This will call Pre_MCMC.m, which will display a GUI that takes user inputs to perform the simulation. Sample training data can be found in the data folder.

Editing the GUI
----------------
To modify the elements of the 2nd GUI, call tabpanel('main_GUI.fig','tabs'). This will make the tabs and its contents editable.
