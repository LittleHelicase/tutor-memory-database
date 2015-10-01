
var chai = require("chai");
var chaiAsPromised = require("chai-as-promised");

chai.use(chaiAsPromised);
chai.should();

var moment = require("moment");

var db = require("../lib/db")({});

describe("User queries", function(){
  it("should be possible to query a user", function(){
    var DB = {Users:[{id:1}]};
    db.Set(DB);

    return db.Users.exists(1).then(function(exists){
      exists.should.be.true;
    });
  });
  it("should be possible to query a non existing user", function(){
    var DB = {Users:[{id:1}]};
    db.Set(DB);

    return db.Users.exists(2).then(function(exists){
      exists.should.be.false;
    });
  });
  it("should detect broken user databases", function(){
    var DB = {Users:[{id:1},{id:1}]};
    db.Set(DB);

    return db.Users.exists(1).should.be.rejected;
  });
  it("should be possible to query a users pseudonym", function(){
    var DB = {Users:[{id:1,pseudonym:"P"}]};
    db.Set(DB);

    return db.Users.getPseudonym(1).then(function(pseudonym){
      pseudonym.should.equal("P");
    });
  });
  it("should be possible to change a users pseudonym", function(){
    var DB = {Users:[{id:1,pseudonym:"P"}]};
    db.Set(DB);

    return db.Users.setPseudonym(1,"Q").then(function(){
      DB.Users[0].pseudonym.should.equal("Q");
    });
  });
  it("should be possible to create a new user", function(){
    var DB = {Users:[]};
    db.Set(DB);

    return db.Users.create({id: 1,matrikel: "12345678",pseudonym: "P", name: "NO!"}).then(function(){
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

  it("can query a tutor", function(){
    var DB = {Tutors: [{name: "a",pw:"hidden!", salt:"ABC"}]};
    db.Set(DB);

    return db.Users.getTutor("a").then(function(tutor){
      (tutor == null).should.be.false;
      tutor.name.should.equal("a");
      tutor.salt.should.equal("ABC");
      tutor.should.not.have.key("pw");
    });
  });

  it("cannot query a non existing", function(){
    var DB = {Tutors: []};
    db.Set(DB);

    return db.Users.getTutor("nonExisting").should.be.rejected;
  });

  it("can authorize a tutor", function(){
    var DB = {Tutors: [{name: "a", pw:"test123"}]};
    db.Set(DB);

    return db.Users.authTutor("a", "test123").then(function(isAuthorized){
      isAuthorized.should.be.true;
    });
  });

  it("can lock a pseudonym", function(){
    var DB = {PseudonymList:[{pseudonym:"abc"}]};
    db.Set(DB);

    return db.Users.lockRandomPseudonymFromList(1,["ccc"]).then(function(pseudo){
      pseudo.should.equal("ccc");
    })
  });

  it("cannot lock already reserved pseudonyms", function(){
    var DB = {PseudonymList:[{pseudonym:"abc"},{pseudonym:"ccc"}]};
    db.Set(DB);

    return db.Users.lockRandomPseudonymFromList(1,["ccc","abc"]).should.be.rejected;
  });

  it("clears pending pseudonyms if they are old enough", function(){
    var DB = {PseudonymList:[{pseudonym:"abc",user:2,locked:moment().subtract(16,"minutes").toJSON()}]};
    db.Set(DB);

    return db.Users.lockRandomPseudonymFromList(1,["abc"]).should.be.fulfilled;
  });

  it("set a pseudonym that is locked for the user", function() {
    var DB = {
      PseudonymList:[{pseudonym:"abc",user:1,locked:moment().subtract(12,"minutes").toJSON()}],
      Users:[{id:1,pseudonym:"P"}]
    };
    db.Set(DB);
    return db.Users.setPseudonym(1, "abc").should.be.fulfilled;
  });
});
