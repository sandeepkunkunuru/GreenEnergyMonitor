[*Green Energy Monitor*](http://gem.tingri.me)
by [V Prabhakar]() and [K Sandeep](http://www.linkedin.com/in/sandeepkunkunuru/).

Green Energy Monitor
====================
GreenEnergyMonitor is an application that
* Monitor past and current electric power usage of a residential household relative to its neighborhood using Green Button Data API.
* It displays the past and current electric power usage of an user.
* It shows the usage in the context of the average, min and max usage in the neighborhood so that the user can get a feel of his energy usage with respect to his neighbors.
* It predicts future energy consumption of the user based on the past usage of electric power. This prediction helps the user preview and budget future energy consumption and take proactive insightful decisions.
* Allows the user to signup, login and upload his Green Button data by specifying the url at which it is available or uploading a previously downloaded file directly from his system.
* Aid the residential customers to effectively manage their demand requests placed on the electric grid esp. during high demand period.
* Rserve - to execute prediction models. Rserve acts as a socket server (TCP/IP or local sockets) which allows binary requests to be sent to R.

Trinidad application server interfaces with Rserve to execute the prediction model and the model is used to predict future usage values.

Tech Stack
==========

* GreenButton Data Parser
* Apache
* JRuby
* Ruby on Rails
* Trinidad
* d3.js,rickshaw.js jQuery.js
* R, Rserve (Multi-variate linear regression model, ARIMA model in progress)
* SQlite3

Future Tasks
=============
We plan to enhance the application to:

* Incorporate Home Energy Score to provide context around the usage stats
* Provide smartphone interface on iPhone and Android devices
* Integrate with smart thermostats.