
var chai = require("chai");
var chaiAsPromised = require("chai-as-promised");

chai.use(chaiAsPromised);
chai.should();

var moment = require("moment");
var db = require("../lib/db")({});

describe("Managing methods", function(){
  it("should create a new tutor", function(){
    var DB = {Tutors:[]};
    db.Set(DB);

    return db.Manage.storeTutor("t","ABC").then(function(){
      DB.Tutors.should.have.length(1);
      DB.Tutors[0].name.should.equal("t");
      DB.Tutors[0].pw.should.equal("ABC");
    });
  });
  it("should update an existing tutor", function(){
    var DB = {Tutors:[{name:"t",pw:"BCD"}]};
    db.Set(DB);

    return db.Manage.storeTutor("t","ABC").then(function(){
      DB.Tutors.should.have.length(1);
      DB.Tutors[0].name.should.equal("t");
      DB.Tutors[0].pw.should.equal("ABC");
    });
  });
  it("should create a new exercise for a new ID", function(){
    var DB = {Exercises:[]};
    db.Set(DB);

    return db.Manage.storeExercise({id:1}).then(function(){
      DB.Exercises.should.have.length(1);
      DB.Exercises[0].id.should.equal(1);
    });
  });
  it("should update an existing exercise by ID", function(){
    var DB = {Exercises:[{id:1,number:2}]};
    db.Set(DB);

    return db.Manage.storeExercise({id:1,number:1}).then(function(){
      DB.Exercises.should.have.length(1);
      DB.Exercises[0].id.should.equal(1);
      DB.Exercises[0].number.should.equal(1);
    });
  });
  it("should list all tutors without password", function(){
    var DB = {Tutors:[{name: "a", pw:"no"},{name: "b", pw:"nono"}]};
    db.Set(DB);

    return db.Manage.listTutors().then(function(tutors){
      tutors.should.have.length(2);
      tutors[0].should.be.a("string");
      tutors[1].should.be.a("string");
    });
  });
  it("should lock a not locked solution", function() {
    var DB = {Solutions:[{id:1, solutions:["abc"]}]};
    db.Set(DB);
    
    return db.Manage.lockUnprocessedSolutions().then(function(sol){
      sol.id.should.equal(1);
    });
  });
  it("should not lock a marked solution", function() {
    var DB = {Solutions:[{id:1, processingLock: true},{id:2}]};
    db.Set(DB);
    
    return db.Manage.lockUnprocessedSolutions().then(function(sol){
      sol.id.should.equal(2);
    });
  });
  it("should reject if no solution can be locked", function() {
    var DB = {Solutions:[{id:1, processingLock: true},{id:2, processed: true}]};
    db.Set(DB);
    
    return db.Manage.lockUnprocessedSolutions().should.be.rejected;
  });
});
