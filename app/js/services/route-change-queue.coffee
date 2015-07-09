angular.module('fantasyDraftHub').service 'routeChangeQueue', ->
  queue = []

  enq: (lambda) ->
    queue.push(lambda)
  deq: ->
    queue.shift()
  peek: ->
    queue[0]
  flush: ->
    _queue = queue
    queue = []
    return _queue