
var chai = require("chai");
chai.should();

var moment = require("moment");
var db = require("../lib/db")();

describe("Student Exercise Queries", function(){
  it("should filter not activated exercises", function(done){
    var DB = {Exercises:[
      {activationDate: moment().subtract(2, 'days').toJSON()},
      {activationDate: moment().add(2, 'days').toJSON()}
    ]};
    db.Set(DB);

    db.Student.getExercises(function(err,ex){
      (err == null).should.be.true;
      ex.length.should.equal(1);
      done();
    });
  });

  it("should return an exercise by id", function(done){
    var DB = {Exercises:[
      {activationDate: moment().subtract(2, 'days').toJSON(),id:1},
      {activationDate: moment().add(2, 'days').toJSON(),id:2}
    ]};
    db.Set(DB);

    db.Student.getExerciseById(1, function(err,ex){
      (err == null).should.be.true;
      ex.id.should.equal(1);
      done();
    });
  });

  it("should not return an unactive exercise by id", function(done){
    var DB = {Exercises:[
      {activationDate: moment().subtract(2, 'days').toJSON(),id:1},
      {activationDate: moment().add(2, 'days').toJSON(),id:2}
    ]};
    db.Set(DB);

    db.Student.getExerciseById(2, function(err,ex){
      (err == null).should.be.true;
      (ex == null).should.be.true;
      done();
    });
  });

  it("should be able to query all active exercises", function(done){
    var DB = {Exercises:[
      {activationDate: moment().subtract(2, 'days').toJSON(),dueDate: moment().add(2, 'days').toJSON()},
      {activationDate: moment().subtract(2, 'days').toJSON(),dueDate: moment().subtract(1, 'days').toJSON()},
      {activationDate: moment().add(2, 'days').toJSON(),dueDate: moment().subtract(2, 'days').toJSON()}
    ]};
    db.Set(DB);

    db.Student.getAllActiveExercises(function(err,ex){
      (err == null).should.be.true;
      ex.length.should.equal(1);
      done();
    });
  });
});
