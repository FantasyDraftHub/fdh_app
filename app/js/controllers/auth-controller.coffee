angular.module 'fantasyDraftHub'
  .controller 'authController', ($scope, $state, $http, APP_CONSTANTS, sessionService, authService) ->
    $scope.currentUser = {}

    $http.get(APP_CONSTANTS.apiUrl+'/users/me')
    .success (data) ->
      $scope.currentUser = data

    $scope.logout = () ->
      if sessionService.verifySession()
        authService.logout()
      $state.go 'login'
