var options = {
  "project": {
    "org": "Vocativ",
    "name": "Starter Project",
    "slug": "dataviz-starter"
  },
  "website": {
    "host": "localhost",
    "port": 8888
  },
  "gaCode": "UA-31006619-3",
  "aws": {
    "key": process.env.AWS_ACCESS_KEY_ID,
    "secret": process.env.AWS_SECRET_ACCESS_KEY,
    "bucket": "interactives",
    "path": "interactives"
  }
}

module.exports = options