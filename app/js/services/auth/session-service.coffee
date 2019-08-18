angular.module 'fantasyDraftHub'
  .service 'sessionService', (localStorageService) ->
    getSession: ->
      id: localStorageService.get 'id'
      token: localStorageService.get 'token'
    create: (data) ->
      console.log('seession')
      localStorageService.set 'id', data.id
      localStorageService.set 'token', data.token
    destroy: ->
      localStorageService.remove 'id'
      localStorageService.remove 'token'
    verifySession: ->
      if localStorageService.get 'token' then true else false