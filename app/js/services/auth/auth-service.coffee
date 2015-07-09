angular.module 'fantasyDraftHub'
  .service 'authService', (sessionService, flashService, $http, APP_CONSTANTS) ->
    login: (creds) ->
      $http.post(APP_CONSTANTS.apiUrl+'/sessions', creds)
      .success (data) ->
        sessionService.create data
    logout: ->
      $http.post(APP_CONSTANTS.apiUrl+'/sessions/logout', {})
      .success (data) ->

      flashService.success 'Successfully logged out'
      sessionService.destroy()
    fetchSession: ->
      sessionService.getSession()
    isLoggedIn: ->
      sessionService.verifySession()