angular.module 'fantasyDraftHub'
  .factory 'authInterceptor', ($q, sessionService) ->
    request: (config) ->
      session = sessionService.getSession()
      if session.token
        config.headers['X-AUTH-TOKEN'] = session.token
      config
