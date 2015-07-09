angular.module 'fantasyDraftHub'
.service 'authRedirector', ($q, $location, flashService) ->
    'responseError': (rejection) ->
      if rejection.status == 401
        flashService.error 'Please log in to continue', false
        $location.path('/#/login')
      $q.reject(rejection)