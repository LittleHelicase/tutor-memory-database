
var chai = require("chai");
var chaiAsPromised = require("chai-as-promised");

chai.use(chaiAsPromised);
chai.should();

var moment = require("moment");
var db = require("../lib/db")();

describe("Student Exercise Queries", function(){
  it("should filter not activated exercises", function(){
    var DB = {Exercises:[
      {activationDate: moment().subtract(2, 'days').toJSON()},
      {activationDate: moment().add(2, 'days').toJSON()}
    ]};
    db.Set(DB);

    return db.Exercises.get().then(function(ex){
      ex.length.should.equal(1);
    });
  });

  it("should return an exercise by id", function(){
    var DB = {Exercises:[
      {activationDate: moment().subtract(2, 'days').toJSON(),id:1},
      {activationDate: moment().add(2, 'days').toJSON(),id:2}
    ]};
    db.Set(DB);

    return db.Exercises.getById(1).then(function(ex){
      ex.id.should.equal(1);
    });
  });

  it("should not return an unactive exercise by id", function(){
    var DB = {Exercises:[
      {activationDate: moment().subtract(2, 'days').toJSON(),id:1},
      {activationDate: moment().add(2, 'days').toJSON(),id:2}
    ]};
    db.Set(DB);

    return db.Exercises.getById(2).then(function(ex){
      (ex == null).should.be.true;
    });
  });

  it("should be able to query all active exercises", function(){
    var DB = {Exercises:[
      {activationDate: moment().subtract(2, 'days').toJSON(),dueDate: moment().add(2, 'days').toJSON()},
      {activationDate: moment().subtract(2, 'days').toJSON(),dueDate: moment().subtract(1, 'days').toJSON()},
      {activationDate: moment().add(2, 'days').toJSON(),dueDate: moment().subtract(2, 'days').toJSON()}
    ]};
    db.Set(DB);

    return db.Exercises.getAllActive().then(function(ex){
      ex.length.should.equal(1);
    });
  });

  it("should be able to get detailed information for an exercise", function(){
    var DB = {Exercises:[
      {id:"abc",activationDate: moment().subtract(2, 'days').toJSON()},
      {id:"cde",activationDate: moment().subtract(2, 'days').toJSON()},
      {id:"efg",activationDate: moment().subtract(2, 'days').toJSON()}
    ]};
    db.Set(DB);

    return db.Exercises.getDetailed("abc").then(function(ex){
      (Array.isArray(ex)).should.be.false;
      ex.id.should.equal("abc");
    });
  });

  it("should be able to get the solution for an exercise", function(){
    var DB = {Solutions:[
      {group:"A",exercise: 1,solutions:["text","textA"]},
      {group:2,exercise: 1,solutions:["text2","textA2"]},
      {group:1,exercise: 2,solutions:["text3","textA3"]},
      {group:"A",exercise: 2,solutions:["text3","textA3"]}
    ], Groups: [
      {id: "A", users: [ 1 ]}
    ]};
    db.Set(DB);

    return db.Exercises.getExerciseSolutions(1,1).then(function(sol){
      (Array.isArray(sol)).should.be.false;
      sol.solutions.should.deep.include.members(["text","textA"])
    });
  });

  it("a non existing solution should return an empty object", function(){
    var DB = {Solutions:[
      {group:"B",exercise: 1,solutions:["text","textA"]},
      {group:2,exercise: 1,solutions:["text2","textA2"]},
      {group:1,exercise: 2,solutions:["text3","textA3"]},
      {group:"A",exercise: 2,solutions:["text3","textA3"]}
    ], Groups: [
      {id: "A", users: [ 1 ]}
    ]};
    db.Set(DB);

    return db.Exercises.getExerciseSolutions(1,1).then(function(sol){
      (sol == null).should.be.false;
      sol.solutions.should.have.length(0);
    });
  });
});
