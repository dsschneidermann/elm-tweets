var util    = require('util'),
    express = require('express'),
    twitter = require('mtwitter'),
    nconf   = require('nconf'),
    cache   = require('memory-cache');

var port = process.env.PORT || 5000

app = express();

nconf.argv().env().file({ file: 'config.json' });

var twit = new twitter({
  consumer_key: process.env.CONSUMER_KEY || nconf.get('CONSUMER_KEY'),
  consumer_secret: process.env.CONSUMER_SECRET || nconf.get('CONSUMER_SECRET'),
  application_only: true
});

app.use(function(req, res, next) {
    res.header("Access-Control-Allow-Origin", "*");
    res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
    next();
  });

app.get(/\/(.*)/, function(req, res) {
    console.log("express-twitterproxy: GET " + req.params[0].toString())
    console.log(req.query);
    twit.get(req.params[0], req.query, function(err, data) {
        if (err) {
            console.log(err);
            res.status(500).send('An error occurred. Please try again later.');
        }
        else {
            res.status(200).send(data);
        }
    });
});

app.listen(port);
console.log('Started express-twitterproxy on: ' + port);