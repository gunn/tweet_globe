# Tweet Globe

An interactive 3D globe showing tweets live.
![Tweet Globe](https://raw.github.com/gunn/tweet_globe/master/animation.gif)


## How it Works

#### Server
`app.coffee` defines a node server that makes a direct connection to twitter to stream tweets with geographic information. It the repackages the tweet data to contain only the information needed and pushes that data to each connected client via websockets (falling back to other methods if needed.)

#### Client
`assets/js/application.coffee` includes the tree of files that make up the client. The client is an ember app that uses D3.js to plot the tweet data from the server onto a globe.
