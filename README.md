# Tweet Globe

A 3D interactive globe of live tweets. See it running at https://tweet-globe.herokuapp.com

![Tweet Globe](https://raw.github.com/gunn/tweet_globe/master/animation.gif)


## How it Works

#### Server
`app.coffee` defines a node server that makes a direct connection to twitter to stream tweets with geographic information. It the repackages the tweet data to contain only the information needed and pushes that data to each connected client via websockets (falling back to other methods if needed.)

#### Client
`assets/js/application.coffee` includes the tree of files that make up the client. The client is an ember app that uses D3.js to plot the tweet data from the server onto a globe.

## To run

You must have a `.env` file to contain your twitter api credentials:
```
ACCESS_TOKEN_KEY=XXXXXXXX-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
ACCESS_TOKEN_SECRET=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
CONSUMER_KEY=XXXXXXXXXXXXXXXXXXXXX
CONSUMER_SECRET=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
PORT=1337
```

Install dependencies and launch the server:
```
npm install
npm start
```
