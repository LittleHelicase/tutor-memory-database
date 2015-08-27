
var chai = require("chai");
chai.should();

var db = require("../lib/db")();

describe("Group queries", function(){
  it("should return the group for a user", function(done){
    DB = {Groups:[
      {id:1,users:[1,5]},
      {id:2,users:[2,3]},
      {id:3,users:[4]}
    ]};
    db.Set(DB);

    db.Student.getGroupForUser(1,function(err,group){
      (err == null).should.be.true;
      group.id.should.equal(1);
      done();
    });
  });
  it("should return an error if the user is in multiple groups", function(done){
    DB = {Groups:[
      {id:1,users:[1,5]},
      {id:2,users:[2,1]},
      {id:3,users:[4]}
    ]};
    db.Set(DB);

    db.Student.getGroupForUser(1,function(err,group){
      (err == null).should.be.false;
      done();
    });
  });

  it("should be able to leave a group with more than one member", function(done){
    DB = {Groups:[{id:1,users:[1,2]}],Results:[]};
    db.Set(DB);
    db.Student.leaveGroup(1,function(err){
      (err == null).should.be.true;
      db.Student.getGroupForUser(1,function(err, group){
        (err == null).should.be.true;
        group.users.length.should.equal(1);
        group.users[0].should.equal(1);
        db.Student.getGroupForUser(2,function(err2, group2){
          (err2 == null).should.be.true;
          group2.users.length.should.equal(1);
          group2.users[0].should.equal(2);
          done();
        });
      })
    });
  });

  it("should not be able to leave a one-user group", function(done){
    DB = {Groups:[{id:1,users:[1]}],Results:[]};
    db.Set(DB);
    db.Student.leaveGroup(1,function(err){
      (err == null).should.be.false;
      done();
    });
  });

  it("should be possible to create a group of users who are in no group", function(done){
    DB = {Groups:[]};
    db.Set(DB);
    db.Student.createGroup([1,2,3], function(err){
      (err == null).should.be.true;
      db.Student.getGroupForUser(2, function(err,group){
        (err == null).should.be.true;
        group.users.should.deep.equal([1,2,3]);
        done();
      });
    });
  });
  it("should not be possible to create a group of users who are in another group", function(done){
    DB = {Groups:[{id:1,users:[3,4,5]}]};
    db.Set(DB);
    db.Student.createGroup([1,2,3], function(err){
      (err == null).should.be.false;
      done();
    });
  });
});
