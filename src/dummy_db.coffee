
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
        lockTimeStamp: moment().subtract(1, 'days').toJSON()
        results: ["JO, No, JO"]
        tasks: [
          {
            solution: "$$\\mathcal O(n)$$"
            tests: [
              { name: "Sollte O(n) sein", passes: true },
              { name: "Keine Rechtschreibfehler!", passes: false }
            ]
          },
          {
            solution: "```dot digraph....```",
            tests:[
              { name: "Ein Graph sollte da sein!", passes: true }
            ],
          },
          {
            solution: "Bla bla"
            tests: []
          }
        ]
      },
      {
        id: "8c510bb6-61d6-11e5-8a80-685b35b5d746"
        group: "fd8c6b08-572d-11e5-9824-685b35b5d746"
        exercise: "ee256059-9d92-4774-9db2-456378e04586"
        pdf: ""
        tasks: [
          {
            solution: "$$\\mathcal O(n^2)$$",
            tests: [
              { name: "Sollte O(n) sein", passes: true },
              { name: "Keine Rechtschreibfehler!", passes: false }
            ]
          },
          {
            solution: "A->B,C->B ...",
            tests:[
              { name: "Ein Graph sollte da sein!", passes: false }
            ],
          },
          {
            solution: "War viel zu schwer, nicht bearbeitet"
            tests: []
          }
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
        id: "ee256059-9d92-4774-9db2-456378e04586"
        title: "Test exercise"
        number: 1
        activationDate: moment().subtract(10, 'days').toJSON()
        dueDate: moment().subtract(2, 'days').toJSON()
        tasks: [
          {
            title: "Binomialkoeffizienten (40 Punkte)",
            maxPoints: "40",
            text: "beschreibungstext",
            prefilled: "```js\nfunction a(){\n}\n```",
            tests: "```tests\nit('Funktion a existiert', function(){\n  if(!a || typeof(a) != 'function'){\n    throw 'Die Funktion a ist nicht ordentlich definiert';\n  }\n});\n```",
            solution: "lösung"
          },
          {
            title: "Gimmel Gammel Gummel Shake (30 Punkte)",
            maxPoints: "30",
            text: "beschreibungstext",
            prefilled: "prefilled",
            tests: "test",
            solution: "lösung"
          }
        ]
      },
      {
        number: 2
        activationDate: moment().subtract(1, 'days').toJSON()
        dueDate: moment().add(1000, 'years').toJSON()
        id: "f31ad341-9d92-4774-9db2-456378e04586"
        tasks: [
          {
            title: "Binomialkoeffizienten (40 Punkte)",
            maxPoints: "40",
            text: "beschreibungstext",
            prefilled: "prefilled",
            tests: "test",
            solution: "lösung"
          },
          {
            title: "Gimmel Gammel Gummel Shake (30 Punkte)",
            maxPoints: "30",
            text: "beschreibungstext",
            prefilled: "prefilled",
            tests: "test",
            solution: "lösung"
          },
          {
            title: "I am bad at sample texts (20 Punkte)",
            maxPoints: "20",
            text: "beschreibungstext",
            prefilled: "prefilled",
            tests: "test",
            solution: "lösung"
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
        users: [ "ABC-DEF" ]
      },
      {
        name: "pending group"
        id: "fd8c6b08-572d-11e5-9824-685b35b5d746"
        users: ["NO-GROUP-2"]
        pendingUsers: ["ABC-DEF"]
      }
    ]
  Users:
    [
      {
        id: "ABC-DEF"
        matrikel: "1234560"
        pseudonym: "Lazy Dijkstra"
        previousGroups: []
      },
      {
        id: "NO-GROUP-1"
        matrikel: "9234560"
        pseudonym: "Lonely Gates"
        previousGroups: []
      },
      {
        id: "NO-GROUP-2"
        matrikel: "8234560"
        pseudonym: "Tiny Knuth"
        previousGroups: []
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
