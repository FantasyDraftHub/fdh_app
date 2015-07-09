angular.module('fantasyDraftHub').factory 'snakeJsonToCamelCasing',
  ($q) ->
    request: (request) ->
      request.data = humps.decamelizeKeys(request.data)
      request

    response: (response) ->
      response.data = humps.camelizeKeys(response.data)
      response

    responseError: (rejection) ->
      rejection.data = humps.camelizeKeys(rejection.data)
      $q.reject(rejection)