
moment = require 'moment'

module.exports =
  Results:
    [
      {
        group: "af3fb55a-4b6f-11e5-90ba-685b35b5d746"
        exercise: "ee256059-9d92-4774-9db2-456378e04586"
        task: "f4ca6e7e-3f6e-11e5-8359-685b35b5d746"
        points: 5
        data: [] # contains correction information
      },
      {
        group: "af3fb55a-4b6f-11e5-90ba-685b35b5d746"
        exercise: "ee256059-9d92-4774-9db2-456378e04586"
        task: "ff7f08de-3f6e-11e5-9b7e-685b35b5d746"
        points: 10
        data: [] # contains correction information
      },
      {
        group: "af3fb55a-4b6f-11e5-90ba-685b35b5d746"
        exercise: "ee256059-9d92-4774-9db2-456378e04586"
        task: "0801fe80-3f6f-11e5-abbc-685b35b5d746"
        points: 0.5
        data: [] # contains correction information
      }
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
        dueDate: moment().add(100, 'days').toJSON()
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
        users: [ "6c884c4a-4b6f-11e5-8099-685b35b5d746" ]
      }
    ]
  Users:
    [
      {
        id: "ABC-DEF"
        matrikel: "1234560"
        pseudonym: "Lazy Dijkstra"
      }
    ]
