
var chai = require("chai");
var chaiAsPromised = require("chai-as-promised");

chai.use(chaiAsPromised);
chai.should();

var db = require("../lib/db")();

describe("User queries", function(){
  it("should be possible to query a user", function(){
    var DB = {Users:[{pseudonym:1}]};
    db.Set(DB);

    return db.Users.exists(1).then(function(exists){
      exists.should.be.true;
    });
  });
  it("should be possible to query a non existing user", function(){
    var DB = {Users:[{pseudonym:1}]};
    db.Set(DB);

    return db.Users.exists(2).then(function(exists){
      exists.should.be.false;
    });
  });
  it("should detect broken user databases", function(){
    var DB = {Users:[{pseudonym:1},{pseudonym:1}]};
    db.Set(DB);

    return db.Users.exists(1).should.be.rejected;
  });
  it("should be possible to query a users id", function(){
    var DB = {Users:[{id:1,pseudonym:"P"}]};
    db.Set(DB);

    return db.Users.getId("P").then(function(pseudonym){
      pseudonym.should.equal(1);
    });
  });
  it("should be possible to query a users pseudonym", function(){
    var DB = {Users:[{id:1,pseudonym:"P"}]};
    db.Set(DB);

    return db.Users.getPseudonym(1).then(function(pseudonym){
      pseudonym.should.equal("P");
    });
  });
  it("should be possible to change a users pseudonym", function(){
    var DB = {Users:[{pseudonym:"P"}]};
    db.Set(DB);

    return db.Users.setPseudonym("P","Q").then(function(){
      DB.Users[0].pseudonym.should.equal("Q");
    });
  });
  it("should be possible to create a new user", function(){
    var DB = {Users:[]};
    db.Set(DB);

    return db.Users.create(1,"12345678","P").then(function(){
      DB.Users[0].pseudonym.should.equal("P");
      DB.Users[0].id.should.equal(1);
      DB.Users[0].matrikel.should.equal("12345678");
    });
  });

  it("should not be possible to create two users with the same id", function(){
    var DB = {Users:[{id:1,pseudonym:"P"}]};
    db.Set(DB);

    return db.Users.create(1,"12345678","P").should.be.rejected;
  });
});
