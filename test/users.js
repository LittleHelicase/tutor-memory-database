
var chai = require("chai");
chai.should();

var db = require("../lib/db")();

describe("User queries", function(){
  it("should be possible to query a user", function(done){
    DB = {Users:[{id:1}]};
    db.Set(DB);

    db.Student.userExists(1,function(err,exists){
      (err == null).should.be.true;
      exists.should.be.true;
      done();
    });
  });
  it("should be possible to query a non existing user", function(done){
    DB = {Users:[{id:1}]};
    db.Set(DB);

    db.Student.userExists(2,function(err,exists){
      (err == null).should.be.true;
      exists.should.be.false;
      done();
    });
  });
  it("should detect broken user databases", function(done){
    DB = {Users:[{id:1},{id:1}]};
    db.Set(DB);

    db.Student.userExists(1,function(err,exists){
      (err == null).should.be.false;
      done();
    });
  });
  it("should be possible to query a users pseudonym", function(done){
    DB = {Users:[{id:1,pseudonym:"P"}]};
    db.Set(DB);

    db.Student.getUserPseudonym(1,function(err,pseudonym){
      (err == null).should.be.true;
      pseudonym.should.equal("P");
      done();
    });
  });
  it("should complain if the user has no pseudonym", function(done){
    DB = {Users:[{id:1,wrongPseudo:"P"}]};
    db.Set(DB);

    db.Student.getUserPseudonym(1,function(err,pseudonym){
      (err == null).should.be.false;
      (pseudonym == undefined).should.be.true;
      done();
    });
  });
  it("should be possible to change a users pseudonym", function(done){
    DB = {Users:[{id:1,pseudonym:"P"}]};
    db.Set(DB);

    db.Student.setUserPseudonym(1,"Q",function(err){
      (err == null).should.be.true;
      db.Student.getUserPseudonym(1,function(err,pseudonym){
        (err == null).should.be.true;
        pseudonym.should.equal("Q");
        done();
      });
    });
  });
  it("should be possible to create a new user", function(done){
    DB = {Users:[{}]};
    db.Set(DB);

    db.Student.createUser(1,"12345678","P",function(err){
      (err == null).should.be.true;
      db.Student.getUserPseudonym(1,function(err,pseudonym){
        (err == null).should.be.true;
        pseudonym.should.equal("P");
        done();
      });
    });
  });

  it("should not be possible to create two users with the same id", function(done){
    DB = {Users:[{id:1,pseudonym:"P"}]};
    db.Set(DB);

    db.Student.createUser(1,"12345678","P",function(err){
      (err == null).should.be.false;
      db.Get(DB).Users.length.should.equal(1);
      done();
    });
  });
});
