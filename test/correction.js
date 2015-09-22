
var chai = require("chai");
var chaiAsPromised = require("chai-as-promised");
var moment = require("moment");

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
  it("should be possible to store results for a locked solution", function(){
    var DB = {Solutions:[{id:1, lock:"tutor"}]}
    db.Set(DB);
    return db.Corrections.setResultForExercise("tutor",1,["res"]).then(function(){
      return db.Corrections.getResultForExercise(1).then(function(sol){
        (sol == null).should.be.false;
        sol.result.should.deep.equal(["res"]);
      })
    });
  });
  it("should not be possible to store results for a not locked solution", function(){
    var DB = {Solutions:[{id:1}]};
    db.Set(DB);
    return db.Corrections.setResultForExercise("tutor",1,["res"]).should.be.rejected;
  });
  it("should not be possible to store results for a solution locked by another tutor", function(){
    var DB = {Solutions:[{id:1, lock:"tutor2"}]};
    db.Set(DB);
    return db.Corrections.setResultForExercise("tutor",1,["res"]).should.be.rejected;
  });
  /*
  it("should lock a solution for a tutor", function(){
    var DB = {Solutions: [{exercise:1, group:1},{exercise:2,group:2}]};
    db.Set(DB);

    return db.Corrections.lockSolutionForTutor(1,1,"tutor").should.be.fulfilled;
  });
  it("locking a solution twice shoul have no effect", function(){
    var DB = {Solutions: [{exercise:1, group:1},{exercise:2,group:2}]};
    db.Set(DB);

    return db.Corrections.lockSolutionForTutor("tutor",1,1).then(function(){
      return db.Corrections.lockSolutionForTutor("tutor",1,1)
    }).should.be.fulfilled;
  });
  it("should not be able to lock a solution by two different tutors", function(){
    var DB = {Solutions: [{exercise:1, group:1},{exercise:2,group:2}]};
    db.Set(DB);

    return db.Corrections.lockSolutionForTutor("tutor",1,1).then(function(){
      return db.Corrections.lockSolutionForTutor("tutor2",1,1)
    }).should.be.rejected;
  });
  it("solutions with results cannot be locked", function(){
    var DB = {Solutions: [{exercise:1, group:1},{exercise:2,group:2}],
      Results: [{exercise:1, group: 1}]};
    db.Set(DB);

    return db.Corrections.lockSolutionForTutor("tutor",1,1).should.be.rejected;
  });
  it("should lock a random not corrected solution", function(){
    var DB = {Solutions: [{exercise:1, group:1},{exercise:1,group:2}],
      Results: [{exercise:1, group: 1}]};
    db.Set(DB);

    return db.Corrections.lockNextSolutionForTutor("tutor2",1).then(function(){
      DB.Solutions[1].lock.should.equal("tutor");
    });
  });*/

  it("should fail if no exercise could be locked", function(){
    var DB = {Solutions: [{exercise:1, group:1},{exercise:2,group:2}],
      Results: [{exercise:1, group: 1}]};
    db.Set(DB);

    return db.Corrections.lockNextSolutionForTutor("tutor",3).should.be.rejected;
  });
  it("has a method returning the correction status of all exercises", function(){
    var DB = {Solutions:[
      {exercise: 1, group: 1},
      {exercise: 1, group: 2},
      {exercise: 2, group: 1},
      {exercise: 2, group: 2}
    ],Results: [
      {exercise: 1, group: 1}
    ],Exercises:[
      {id: 1, activationDate: moment().subtract(1, "days")},
      {id: 2, activationDate: moment().subtract(1, "days")}
    ]};
    db.Set(DB);

    return db.Corrections.getStatus().then(function(status){
      status.should.have.length(2);
      status.should.deep.include.members([{exercise:1,solutions:2,corrected:1},
            {exercise:2,solutions:2,corrected:0}])
    })
  });
});
