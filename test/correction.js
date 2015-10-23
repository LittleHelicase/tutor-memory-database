
var chai = require("chai");
var chaiAsPromised = require("chai-as-promised");
var moment = require("moment");

chai.use(chaiAsPromised);
chai.should();

var moment = require("moment");
var db = require("../lib/db")({});

describe("Correction methods", function(){
  it("should return the number of pending corrections", function(){
    var DB = {Solutions:[
      {exercise: 1, group: 1},
      {exercise: 1, group: 2, results:[]},
      {exercise: 2, group: 1},
      {exercise: 2, group: 2}
    ]};
    db.Set(DB);

    return db.Corrections.getNumPending(1).then(function(pending){
      pending.should.equal(1);
    });
  });
  it("can list all solutions for an exercise", function(){
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
  it("lists all pending corrections for a tutor", function(){
    var DB = {Solutions:[{lock:"tutor",inProcess:true},{lock:"tutor"},{lock:"tutor",inProcess:false}]};
    db.Set(DB);
    return db.Corrections.getUnfinishedSolutionsForTutor("tutor").then(function(sol){
      sol.should.have.length(1);
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
  it("should not be possibe to lock more than 10 solutions by a single tutor", function() {
    var DB = {
      Solutions:
      [
        {exercise: 1, group: 1, id:1, lock:"Hans", inProcess: false},
        {exercise: 1, group: 2, id:2, lock:"Hans", inProcess: true},
        {exercise: 1, group: 3, id:3, lock:"Hans", inProcess: true},
        {exercise: 1, group: 4, id:4, lock:"Hans", inProcess: true},
        {exercise: 1, group: 5, id:5, lock:"Hans", inProcess: true},
        {exercise: 1, group: 6, id:6, lock:"Hans", inProcess: true},
        {exercise: 1, group: 7, id:7, lock:"Hans", inProcess: true},
        {exercise: 1, group: 8, id:8, lock:"Hans", inProcess: true},
        {exercise: 1, group: 9, id:9, lock:"Hans", inProcess: true},
        {exercise: 1, group: 10, id:10, lock:"Hans", inProcess: false},
        {exercise: 1, group: 11, id:12, lock:"Hans", inProcess: true},
        {exercise: 1, group: 12, id:13, lock:"Hans", inProcess: true},
        {exercise: 1, group: 13, id:14, lock:"Hans", inProcess: true},
        {exercise: 1, group: 14, id:11}, {exercise: 1, id:12}
      ],
      Tutors: [{name: "Hans"}]};

    db.Set(DB);
    return db.Corrections.lockNextSolutionForTutor("Hans", 1).should.be.rejected;
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
  */
  it("should lock a random not corrected solution", function(){
    var DB = {Solutions: [{exercise:1, group:1, results:[]},{exercise:1,group:2}]};
    db.Set(DB);

    return db.Corrections.lockNextSolutionForTutor("tutor",1).then(function(){
      DB.Solutions[1].lock.should.equal("tutor");
    });
  });

  it("should mark a newly locked solution as 'inProcess'", function(){
    var DB = {Solutions: [{exercise:1,group:2}]};
    db.Set(DB);

    return db.Corrections.lockNextSolutionForTutor("tutor",1).then(function(sol){
      sol.inProcess.should.be.true;
    });
  });

  it("should create a time stamp when locking a solution", function () {
    var DB = {Solutions: [{exercise: 1, group: 2}]}
    db.Set(DB);

    return db.Corrections.lockNextSolutionForTutor("tutor", 1).then(function(sol) {
      sol.should.have.property("lockTimeStamp");
    });
  });

  it("should fail if no exercise could be locked", function(){
    var DB = {Solutions: [{exercise:1, group:1, results:[]},{exercise:2,group:2}]};
    db.Set(DB);

    return db.Corrections.lockNextSolutionForTutor("tutor",3).should.be.rejected;
  });

  it("should finalize a solution by setting the 'inProcess' marker to false", function(){
    var DB = {Solutions: [{id:1,results:[],lock:"tutor",inProcess:true}]};
    db.Set(DB);

    return db.Corrections.getUnfinishedSolutionsForTutor("tutor").then(function(sols){
      sols.should.have.length(1);
    });
  });

  it("should finalize a solution by setting the 'inProcess' marker to false", function(){
    var DB = {Solutions: [{id:1,results:[],lock:"tutor",inProcess:true}]};
    db.Set(DB);

    return db.Corrections.finishSolution("tutor",1).then(function(){
      return db.Corrections.getUnfinishedSolutionsForTutor("tutor").then(function(sols){
        sols.should.have.length(0);
      });
    });
  });

  it("should not finalize a solution of another tutor", function(){
    var DB = {Solutions: [{id:1,results:[],lock:"tutor",inProcess:true}]};
    db.Set(DB);

    return db.Corrections.finishSolution("tutor2",1).should.be.rejected;
  });

  it("should not finalize a solution without results", function(){
    var DB = {Solutions: [{id:1,lock:"tutor",inProcess:true}]};
    db.Set(DB);

    return db.Corrections.finishSolution("tutor2",1).should.be.rejected;
  });

  it("should list all unfinished exercises for a tutor", function(){
    var DB = {Solutions: [{id:1,exercise:1,lock:"tutor",inProcess:true},{id:1,lock:"tutor",inProcess:false}]};
    db.Set(DB);

    return db.Corrections.getUnfinishedSolutionsForTutor("tutor",1).then(function(sols){
      sols.should.have.length(1);
    });
  });

  it("has a method that lists all solutions of a user", function(){
    var DB = {Solutions: [{id:1,group:1,exercise:1}],
              Groups: [{id:1,users:[2]}]};
    db.Set(DB);

    return  db.Corrections.getUserSolutions(2).then(function(sols){
      sols.should.have.length(1);
      sols.should.deep.include.members([{id:1,group:1,exercise:1}]);
    });
  });

  it("has a method returning the correction status of all exercises", function(){
    var date = moment().subtract(1, "days");
    var DB = {Solutions:[
      {exercise: 1, group: 1, results:[],lock: "tutor",inProcess:false},
      {exercise: 1, group: 2},
      {exercise: 2, group: 1, lock:"blubb",inProcess:true},
      {exercise: 2, group: 2}
    ],Exercises:[
      {id: 1, activationDate: date},
      {id: 2, activationDate: date}
    ],Tutors: [
      {name:"tutor", contingent:1}
    ]};
    db.Set(DB);

    return db.Corrections.getStatus("tutor").then(function(status){
      status.should.have.length(2);
      status.should.deep.include.members([
        {
          exercise:{id: 1, activationDate: date},
          should: 2,
          is: 1,
          solutions:2,corrected:1,locked:1
        },
        {
          exercise:{id: 2, activationDate: date},
          should: 2,
          is: 0,
          solutions:2,corrected:0,locked:1
        }])
    })
  });

  it("can calculate the contingent for an exercise and tutor", function(){
    var DB = {Tutors:[{name:"a",contingent:20},{name:"b",contingent:10}],
      Solutions:[{exercise:1},{exercise:1,lock:"a",inProcess:false},{exercise:1},{exercise:2}]
    };
    db.Set(DB);

    return db.Corrections.getExerciseContingentForTutor("a",1).then(function(contingent){
      contingent.should.should.equal(2);
      contingent.is.should.equal(1);
    })
  });

  it("can get a specific solution for a user", function(){
    var DB = {Solutions: [{id:1,group:1,exercise:1},{id:2,group:1,exercise:2},{id:3,group:2,exercise:2}],
              Groups: [{id:1,users:[2]}]};
    db.Set(DB);

    return  db.Corrections.getUserExerciseSolution(2,2).then(function(sols){
      sols.id.should.equal(2);
    });
  });
});
