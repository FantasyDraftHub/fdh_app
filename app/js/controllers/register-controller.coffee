angular.module 'fantasyDraftHub'
  .controller 'registerController', ($scope, $state, authService, flashService, $http, APP_CONSTANTS) ->
    $scope.registerStatus = 'To Register please enter details below'
    $scope.creds =
      email: ''
      password: ''

    $scope.register = (creds) ->
      $scope.registerStatus = "Registering now..."

      $http.post(APP_CONSTANTS.apiUrl+'/users', creds)
      .success (data) ->
        authService.login(creds)
        .success (data) ->
          flashService.success 'Welcome aboard matey!'
          $state.go('auth.fantasy-drafts')
        .error (data) ->
          flashService.error 'Whoops! Invalid credentials.'
