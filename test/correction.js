
var chai = require("chai");
var chaiAsPromised = require("chai-as-promised");

chai.use(chaiAsPromised);
chai.should();

var moment = require("moment");
var db = require("../lib/db")();

describe("Corretion methods", function(){
  it("should return the number of pending corrections", function(){
    var DB = {Solutions:[
      {exercise: 1, group: 1},
      {exercise: 1, group: 2},
      {exercise: 2, group: 1},
      {exercise: 2, group: 2}
    ],Results: [
      {exercise: 1, group: 1}
    ]};
    db.Set(DB);

    return db.Corrections.getNumPending(1).then(function(pending){
      pending.should.equal(1);
    });
  });
});
