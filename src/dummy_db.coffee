
moment = require 'moment'

module.exports =
  Solutions:
    [
      {
        id: "85ca34c0-61d6-11e5-97cb-685b35b5d746"
        group: "af3fb55a-4b6f-11e5-90ba-685b35b5d746"
        exercise: "ee256059-9d92-4774-9db2-456378e04586"
        pdf: ""
        lock: "tutor"
        inProcess: true
        results: ["JO, No, JO"]
        solution: [
          "$$\\mathcal O(n)$$",
          "```dot digraph....```",
          "Bla bla"
        ]
      },
      {
        id: "8c510bb6-61d6-11e5-8a80-685b35b5d746"
        group: "fd8c6b08-572d-11e5-9824-685b35b5d746"
        exercise: "ee256059-9d92-4774-9db2-456378e04586"
        pdf: ""
        solution: [
          "$$\\mathcal O(n^2)$$",
          "A->B,C->B ...",
          "War viel zu schwer, nicht bearbeitet"
        ]
      }
    ]
  PseudonymList: [
    { pseudonym: "Lazy Dijkstra", user: "ABC-DEF" },
    { pseudonym: "Lonely Gates", user: "NO-GROUP-1" },
    { pseudonym: "Tiny Knuth", user: "NO-GROUP-2" }
  ]
  Exercises:
    [
      {
        number: 1
        activationDate: moment().subtract(10, 'days').toJSON()
        dueDate: moment().subtract(2, 'days').toJSON()
        id: "ee256059-9d92-4774-9db2-456378e04586"
        tasks: [
          {
            id: 'f4ca6e7e-3f6e-11e5-8359-685b35b5d746'
            number: '1.1'
            title: 'Example'
            type: 'code'
            text: 'Do something.'
            maxPoints: 42,
            solution: 'TEST'
          },
          {
            id: 'ff7f08de-3f6e-11e5-9b7e-685b35b5d746'
            number: '1.2'
            title: 'Another example'
            type: 'code'
            text: 'Do something more awesome.'
            maxPoints: 21
          },
          {
            id: '0801fe80-3f6f-11e5-abbc-685b35b5d746'
            number: '1.3'
            title: 'Yet another example'
            type: 'code'
            text: 'Do nothing.'
            maxPoints: 1
          }
        ]
        title: "Test exercise"
      },
      {
        number: 2
        activationDate: moment().subtract(1, 'days').toJSON()
        dueDate: moment().add(1000, 'years').toJSON()
        id: "f31ad341-9d92-4774-9db2-456378e04586"
        tasks: [
          {
            id: '14141e7e-3f6f-11e5-9726-685b35b5d746'
            number: '1.1'
            title: 'Example'
            type: 'code'
            text: 'Do something.'
            maxPoints: 42
            solution: 'TEST'
          },
          {
            id: '1b77a3f2-3f6f-11e5-ab52-685b35b5d746'
            number: '1.2'
            title: 'Another example'
            type: 'code'
            text: 'Do something more awesome.'
            maxPoints: 21
          },
          {
            id: '23be803a-3f6f-11e5-9a08-685b35b5d746'
            number: '2.1'
            title: 'Yet another example'
            type: 'code'
            text: 'Do nothing.'
            maxPoints: 1
          }
        ]
        title: "Test exercise #2"
      }
    ]
  Groups:
    [
      {
        name: "One man group"
        id: "af3fb55a-4b6f-11e5-90ba-685b35b5d746"
        users: [ "Lazy Dijkstra" ]
      },
      {
        name: "pending group"
        id: "fd8c6b08-572d-11e5-9824-685b35b5d746"
        users: ["Tiny Knuth"]
        pendingUsers: ["Lazy Dijkstra"]
      }
    ]
  Users:
    [
      {
        id: "ABC-DEF"
        matrikel: "1234560"
        pseudonym: "Lazy Dijkstra"
      },
      {
        id: "NO-GROUP-1"
        matrikel: "9234560"
        pseudonym: "Lonely Gates"
      },
      {
        id: "NO-GROUP-2"
        matrikel: "8234560"
        pseudonym: "Tiny Knuth"
      }
    ]
  Tutors:
    [
      {
        name: "max"
        pw: "$2a$04$rOZPlMpKBKKNrJ6gF7m92O.O1cbOKl0R30ryfgnVKcMtEyqBO5zT2"
        contingent: 10
      },
      {
        name: "few"
        pw: "$2a$04$EwmqMb9Dycxiy2fJlZsfR.64aClI.g2O/5ooenN9PuCXiJUFpTjIu"
        contingent: 8
      }
    ]
