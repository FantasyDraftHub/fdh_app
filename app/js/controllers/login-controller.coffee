angular.module 'fantasyDraftHub'
  .controller 'loginController', ($scope, $state, authService, flashService) ->
    $scope.loginStatus = 'Login with your credentials below.'
    $scope.creds =
      email: ''
      password: ''

    $scope.login = (creds) ->
      $scope.loginStatus = "We're trying those credentials now..."

      authService.login(creds)
      .success (data) ->
        flashService.success 'Welcome aboard matey!'
        $state.go('auth.draft-boards')
      .error (data) ->
        flashService.error 'Whoops! Invalid credentials.'
