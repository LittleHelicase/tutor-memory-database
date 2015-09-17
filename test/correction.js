
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
  it("has can list all solutions for an exercise", function(){
    var DB = {Solutions:[
      {exercise: 1, group: 1},
      {exercise: 1, group: 2},
      {exercise: 2, group: 1},
      {exercise: 2, group: 2}
    ]};
    db.Set(DB);

    return db.Corrections.getSolutionsForExercise(1).then(function(sols){
      sols.should.have.length(2);
      sols.should.deep.include.members([{exercise: 1, group: 1},{exercise: 1, group: 2}]);
    });
  });
  it("should lock a solution for a tutor", function(){
    var DB = {Solutions: [{exercise:1, group:1},{exercise:2,group:2}]};
    db.Set(DB);

    return db.Corrections.lockSolutionForTutor(1,1,"tutor").should.be.fulfilled;
  });
  it("locking a solution twice shoul have no effect", function(){
    var DB = {Solutions: [{exercise:1, group:1},{exercise:2,group:2}]};
    db.Set(DB);

    return db.Corrections.lockSolutionForTutor(1,1,"tutor").then(function(){
      return db.Corrections.lockSolutionForTutor(1,1,"tutor")
    }).should.be.fulfilled;
  });
  it("should not be able to lock a solution by two different tutors", function(){
    var DB = {Solutions: [{exercise:1, group:1},{exercise:2,group:2}]};
    db.Set(DB);

    return db.Corrections.lockSolutionForTutor(1,1,"tutor").then(function(){
      return db.Corrections.lockSolutionForTutor(1,1,"tutor2")
    }).should.be.rejected;
  });
  it("solutions with results cannot be locked", function(){
    var DB = {Solutions: [{exercise:1, group:1},{exercise:2,group:2}],
      Results: [{exercise:1, group: 1}]};
    db.Set(DB);

    return db.Corrections.lockSolutionForTutor(1,1,"tutor").should.be.rejected;
  });
  it("should lock a random not corrected solution", function(){
    var DB = {Solutions: [{exercise:1, group:1},{exercise:1,group:2}],
      Results: [{exercise:1, group: 1}],
      Exercises: [{number:1,id:1}]};
    db.Set(DB);

    return db.Corrections.lockNextSolutionForTutor(1,"tutor").then(function(){
      DB.Solutions[1].lock.should.equal("tutor");
    });
  });

  it("should fail if no exercise could be locked", function(){
    var DB = {Solutions: [{exercise:1, group:1},{exercise:2,group:2}],
      Results: [{exercise:1, group: 1}],
      Exercises: [{number:1,id:1}]};
    db.Set(DB);

    return db.Corrections.lockNextSolutionForTutor(3,"tutor").should.be.rejected;
  });
});
