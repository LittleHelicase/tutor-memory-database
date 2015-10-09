
var chai = require("chai");
var chaiAsPromised = require("chai-as-promised");

chai.use(chaiAsPromised);
chai.should();

var moment = require("moment");
var db = require("../lib/db")({});

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

  it("should hide solution information for a normal exercise query by id", function(){
    var DB = {
      Exercises:[
        {id:1,activationDate: moment().subtract(2, 'days').toJSON(),tasks:[
          {title: 'abc', maxPoints: 10, text: 'You should!', prefilled: {title: 'title 1', content: 'content 1'}, solution: {}, solutionTest: {}},
          {title: 'def', maxPoints: 12, text: 'You should too!', prefilled: {title: 'title 2', content: 'content 2'}, solution: {}},
          {title: 'ghi', maxPoints: 15, text: 'You should also!', prefilled: {title: 'title 3', content: 'content 3'}, solutionTest: {}}
        ]}
      ]
    };
    db.Set(DB);

    return db.Exercises.getById(1).then(function(ex){
      (Array.isArray(ex)).should.be.false;
      ex.id.should.equal(1);
      //ex.tasks.should.all.not.have.key("solutions");
      for (var i = 0; i != ex.tasks.length; ++i) {
        ex.tasks[i].should.not.have.key("solution");
        ex.tasks[i].should.not.have.key("solutionTest");
      }
    });
  });

  it("should not return an unactive exercise by id", function(){
    var DB = {Exercises:[
      {activationDate: moment().subtract(2, 'days').toJSON(),id:1},
      {activationDate: moment().add(2, 'days').toJSON(),id:2}
    ]};
    db.Set(DB);

    return db.Exercises.getById(2).should.be.rejected;
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

  it("should hide solution information for a normal exercise query", function(){
    var DB = {
      Exercises:[
        {id:1,activationDate: moment().subtract(2, 'days').toJSON(),tasks:[
          {title: 'abc', maxPoints: 10, text: 'You should!', prefilled: {title: 'title 1', content: 'content 1'}, solution: {}, solutionTest: {}},
          {title: 'def', maxPoints: 12, text: 'You should too!', prefilled: {title: 'title 2', content: 'content 2'}, solution: {}},
          {title: 'ghi', maxPoints: 15, text: 'You should also!', prefilled: {title: 'title 3', content: 'content 3'}, solutionTest: {}}
        ]},
        {id:2,activationDate: moment().subtract(2, 'days').toJSON(),tasks:[
          {title: 'abc', maxPoints: 10, text: 'You should!', prefilled: {title: 'title 1', content: 'content 1'}},
          {title: 'def', maxPoints: 12, text: 'You should too!', prefilled: {title: 'title 2', content: 'content 2'}, solution: {}},
          {title: 'ghi', maxPoints: 15, text: 'You should also!', prefilled: {title: 'title 3', content: 'content 3'}, solution: {}}
        ]}
      ]
    };
    db.Set(DB);
    return db.Exercises.get().then(function(ex){
      (Array.isArray(ex)).should.be.true;
      ex.should.have.length(2);

      for (var j = 0; j != ex.length; ++j)
        for (var i = 0; i != ex[j].tasks.length; ++i) {
          ex[j].tasks[i].should.not.have.key("solution");
          ex[j].tasks[i].should.not.have.key("solutionTest");
        }
    });
  });

  it("should be able to get the users solution for an exercise", function(){
    var DB = {Solutions:[
      {group:"A",exercise: 1,solution:["text","textA"]},
      {group:2,exercise: 1,solution:["text2","textA2"]},
      {group:1,exercise: 2,solution:["text3","textA3"]},
      {group:"A",exercise: 2,solution:["text3","textA3"]}
    ], Groups: [
      {id: "A", users: [ 1 ]}
    ], Users: [
      {id: 1, pseudonym: 1}
    ], Exercises: [
      {id: 1,
        activationDate: moment().subtract(7,"days").toJSON(),
        dueDate: moment().add(1, "days").toJSON()}
    ]};
    db.Set(DB);
    return db.Exercises.getExerciseSolution(1,1).then(function(sol){
      (Array.isArray(sol)).should.be.false;
      sol.solution.should.deep.include.members(["text","textA"])
    });
  });

  it("should hide unfinished tutor results", function(){
    var DB = {Solutions:[
      {group:"A",exercise: 1,solution:["text","textA"],results:"bla",inProcess:true,lock:"tutor"}
    ], Groups: [
      {id: "A", users: [ 1 ]}
    ], Users: [
      {id: 1, pseudonym: 1}
    ], Exercises: [
      {id: 1,
        activationDate: moment().subtract(7,"days").toJSON(),
        dueDate: moment().add(1, "days").toJSON()}
    ]};
    db.Set(DB);
    return db.Exercises.getExerciseSolution(1,1).then(function(sol){
      (Array.isArray(sol)).should.be.false;
      sol.should.not.have.key("results");
      sol.should.not.have.key("inProcess");
      sol.should.not.have.key("lock");
    });
  });

  it("should show finished tutor results", function(){
    var DB = {Solutions:[
      {group:"A",exercise: 1,solution:["text","textA"],results:"bla",inProcess:false}
    ], Groups: [
      {id: "A", users: [ 1 ]}
    ], Users: [
      {id: 1, pseudonym: 1}
    ], Exercises: [
      {id: 1,
        activationDate: moment().subtract(7,"days").toJSON(),
        dueDate: moment().add(1, "days").toJSON()}
    ]};
    db.Set(DB);
    return db.Exercises.getExerciseSolution(1,1).then(function(sol){
      (Array.isArray(sol)).should.be.false;
      sol.should.have.any.keys("results");
      sol.should.not.have.key("inProcess");
    });
  });

  it("a non existing solution should return null", function(){
    var DB = {Solutions:[
      {group:"B",exercise: 1,solutions:["text","textA"]},
      {group:2,exercise: 1,solutions:["text2","textA2"]},
      {group:1,exercise: 2,solutions:["text3","textA3"]},
      {group:"A",exercise: 2,solutions:["text3","textA3"]}
    ], Groups: [
      {id: "A", users: [ 1 ]}
    ], Users: [
      {id: 1, pseudonym: 1}
    ], Exercises: [
      {id: 1,
        activationDate: moment().subtract(7,"days").toJSON(),
        dueDate: moment().add(1, "days").toJSON()}
    ]};
    db.Set(DB);
    return db.Exercises.getExerciseSolution(1,1).then(function(sol){
      (sol == null).should.be.true;
    });
  });

  it("should add a solution if there is none", function(){
    var DB = {Solutions:[],Groups: [
      {id: "A", users: [ 1 ]}
    ], Users: [
      {id: 1, pseudonym: 1}
    ], Exercises: [
      {id: 1,
        activationDate: moment().subtract(7,"days").toJSON(),
        dueDate: moment().add(1, "days").toJSON()}
    ]};
    db.Set(DB);
    return db.Exercises.setExerciseSolution(1,1,["abc","cde"]).then(function(){
      return db.Exercises.getExerciseSolution(1,1).then(function(sol){
        (Array.isArray(sol)).should.be.false;
        sol.solution.should.deep.include.members(["abc","cde"])
      });
    });
  });
  it("should update a solution if there is one", function(){
    var DB = {Solutions:[
      {group:"A",exercise: 1,solution:["text","textA"]}
    ], Groups: [
      {id: "A", users: [ 1 ]}
    ], Users: [
      {id: 1, pseudonym: 1}
    ], Exercises: [
      {id: 1,
        activationDate: moment().subtract(7,"days").toJSON(),
        dueDate: moment().add(1, "days").toJSON()}
    ]};
    db.Set(DB);
    return db.Exercises.setExerciseSolution(1,1,["abc","cde"]).then(function(){
      return db.Exercises.getExerciseSolution(1,1).then(function(sol){
        (Array.isArray(sol)).should.be.false;
        sol.solution.should.deep.include.members(["abc","cde"])
      });
    });
  });

  it("should not update a solution if the exercise has expired", function(){
    var DB = {Solutions:[
      {group:"A",exercise: 1,solution:["text","textA"]}
    ], Groups: [
      {id: "A", users: [ 1 ]}
    ], Users: [
      {id: 1, pseudonym: 1}
    ], Exercises: [
      {id: 1,
        activationDate: moment().subtract(7,"days").toJSON(),
        dueDate: moment().subtract(1, "days").toJSON()}
    ]};
    db.Set(DB);
    return db.Exercises.setExerciseSolution(1,1,["abc","cde"]).should.be.rejected;
  });

  it("should not update a solution for a not-yet active exercise", function(){
    var DB = {Solutions:[
      {group:"A",exercise: 1,solution:["text","textA"]}
    ], Groups: [
      {id: "A", users: [ 1 ]}
    ], Users: [
      {id: 1, pseudonym: 1}
    ], Exercises: [
      {id: 1,
        activationDate: moment().add(1,"days").toJSON(),
        dueDate: moment().add(7, "days").toJSON()}
    ]};
    db.Set(DB);
    return db.Exercises.setExerciseSolution(1,1,["abc","cde"]).should.be.rejected;
  });
});
