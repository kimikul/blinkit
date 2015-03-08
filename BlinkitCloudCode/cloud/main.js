
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:

Parse.Cloud.define("hello", function(request, response) {
  response.success("hi kim!");
});

// var _ = require("underscore");
// Parse.Cloud.beforeSave("Blink", function(request, response) {
//     var blink = request.object;

//     var toLowerCase = function(w) { return w.toLowerCase(); };

//     var words = blink.get("content").split(/\b/);
//     words = _.map(words, toLowerCase);
//     var stopWords = ["the", "in", "and", "a", "to", "of", "at", "or", "i", "you", "he", "she", "on", "it", "is"]
//     words = _.filter(words, function(w) { return w.match(/^\w+$/) && ! _.contains(stopWords, w); });
//     words = _.uniq(words);

//     var hashtags = blink.get("content").match(/#.+?\b/g);
//     hashtags = _.map(hashtags, toLowerCase);
//     hashtags = _.uniq(hashtags);

//     blink.set("words", words);
//     blink.set("hashtags", hashtags);
//     response.success();
// });


Parse.Cloud.define("parseSearchTermsForBlinks", function(request, response) {
    skip = request.params.skip;

    var query = new Parse.Query("Blink");
    query.ascending("createdAt");
    query.skip(skip);
    query.limit(9);
    query.find({
      success: function(results) {
        for (var i = 0; i < results.length; i++) {
          var blink = results[i];
          blink.save();
        }

        response.success();
      },
      error: function(error) {
        console.error("Got an error " + error.code + " : " + error.message);
      }
    });
});

Parse.Cloud.define("parseSearchTermsForNonParsedBlinks", function(request, response) {
    var query = new Parse.Query("Blink");
    query.ascending("createdAt");
    query.doesNotExist("words");
    query.limit(9);
    query.find({
      success: function(results) {
        for (var i = 0; i < results.length; i++) {
          var blink = results[i];
          blink.save();
        }

        response.success();
      },
      error: function(error) {
        console.error("Got an error " + error.code + " : " + error.message);
      }
    });
});
