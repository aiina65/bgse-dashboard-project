# BGSE Dashboard Project: Historical football match data and betting odds

### Overview

This project implements a recommendation engine for making safe bettings and also a football match predictor. 

The objectives of the project are:

- Develop a set of betting odds recommendation rules, based on the push-relabel algorithm
- Predict the outcome of a match given data from past matches. 

### Structure

The core of the analysis is contained in these three files:

- `data_and_analysis.php`
- `analysis.R`

Note that some of the key `SQL` queries, to generate the data for the analysis, are contained in the `R` file. The latter is called by the setup script after the database is populated.

### Implementation

To develop the betting odd recommendation engine we have used the push-relabel algorithm.  

The 'Data' tab includes a network graph of the links between product categories. Note that the graph is generated dynamically each time the `./setup.sh run` command is given. 

### Required packages

The `R` analysis relies on the following package. 

- `igraph`
- `betareg`
- `rjags`
- `coda`
- `dplyr`
- `ggplot2`
- `RMySQL`


## Acknowledgments

This project is based on code by: Guglielmo Bartolozzi, Gaston Besanson, Christian Brownlees, Stefano Costantini, Laura Cozma, Jordi Zamora Munt
