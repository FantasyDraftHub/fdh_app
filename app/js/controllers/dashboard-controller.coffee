angular.module 'fantasyDraftHub'
  .controller 'dashboardController', ($scope, $state, $http, APP_CONSTANTS, flashService) ->
    $scope.fantasyLeagues = []
    $scope.newLeague = {}

    $http.get(APP_CONSTANTS.apiUrl+'/fantasy_leagues')
    .success (data) ->
      $scope.fantasyLeagues = data

    $scope.createLeague = () ->
      $http.post(APP_CONSTANTS.apiUrl+'/fantasy_leagues', $scope.newLeague)
      .success (data) ->
        flashService.success 'Awesome! You league has been created. Click your league in the list below to set it all up!'
        $scope.fantasyLeagues.push(data)
        $scope.newLeague = {}
      .error (data) ->
        flashService.error 'Name can\'t be blank'

