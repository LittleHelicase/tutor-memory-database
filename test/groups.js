
var chai = require("chai");
var chaiAsPromised = require("chai-as-promised");

chai.use(chaiAsPromised);
chai.should();

var db = require("../lib/db")();

describe("Group queries", function(){
  it("should return the group for a user", function(){
    var DB = {Groups:[
      {id:1,users:[1,5]},
      {id:2,users:[2,3]},
      {id:3,users:[4]}
    ]};
    db.Set(DB);

    return db.Group.getGroupForUser(1).then(function(group){
      group.id.should.equal(1);
    });
  });
  it("should return an error if the user is in multiple groups", function(){
    var DB = {Groups:[
      {id:1,users:[1,5]},
      {id:2,users:[2,1]},
      {id:3,users:[4]}
    ]};
    db.Set(DB);

    db.Group.getGroupForUser(1).should.be.rejected;
  });
  it("should be possible to create a group of users", function(){
    var DB = {Groups:[]};
    db.Set(DB);
    return db.Group.createGroup(1,[1,2,3]).then(function(group){
      group.users.should.deep.equal([1]);
    });
  });
  it("creating a group of users should add others as pending", function(){
    var DB = {Groups:[]};
    db.Set(DB);
    return db.Group.createGroup(1,[1,2,3]).then(function(group){
      group.should.have.property("pendingUsers");
      group.pendingUsers.should.include.members([2,3]);
    });
  });
  it("should return all pending group invitations", function(){
    var DB = {Groups:[{id:1,users:[1],pendingUsers:[2,3]},
                      {id:2,users:[4],pendingUsers:[2,3]},
                      {id:3,users:[7],pendingUsers:[1,3]}]};
    db.Set(DB);
    return db.Group.pendingGroups(2).then(function(pending){
      pending.should.have.length(2);
      pending.should.deep.include.members([{id:1,users:[1],pendingUsers:[2,3]},
                                          {id:2,users:[4],pendingUsers:[2,3]}]);
    });
  });
  it("should be able to join a group with an invitation", function(){
    var DB = {Groups:[{id:1,users:[1],pendingUsers:[2,3]},
                      {id:2,users:[4],pendingUsers:[2,3]},
                      {id:3,users:[7],pendingUsers:[1,3]}]};
    db.Set(DB);
    return db.Group.joinGroup(2, 2).then(function(){
      DB.Groups[1].users.should.have.length(2);
    });
  });
  it("should not be possible to join a group without an invitation", function(){
    var DB = {Groups:[{id:1,users:[1],pendingUsers:[2,3]},
                      {id:2,users:[4],pendingUsers:[2,3]},
                      {id:3,users:[7],pendingUsers:[1,3]}]};
    db.Set(DB);
    return db.Group.joinGroup(2, 3).should.be.rejected;
  });
  it("should not be possible to join a non existing group", function(){
    var DB = {Groups:[{id:1,users:[1],pendingUsers:[2,3]},
                      {id:2,users:[4],pendingUsers:[2,3]},
                      {id:3,users:[7],pendingUsers:[1,3]}]};
    db.Set(DB);
    return db.Group.joinGroup(2, 151).should.be.rejected;
  });
  it("should be able to reject a group invitation", function(){
    var DB = {Groups:[{id:1,users:[1],pendingUsers:[2,3]},
                      {id:2,users:[4],pendingUsers:[2,3]},
                      {id:3,users:[7],pendingUsers:[1,3]}]};
    db.Set(DB);
    return db.Group.rejectInvitation(2, 2).then(function(){
      DB.Groups[1].pendingUsers.should.have.length(1);
    });
  });
});
