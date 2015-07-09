angular.module 'fantasyDraftHub'
  .controller 'fantasyLeagueController', ($scope, $state, $stateParams, $http, APP_CONSTANTS, flashService) ->
    $scope.fantasyLeague = {
      fantasyTeams: []
    }
    $scope.newFantasyTeam = {}
    $scope.updateFantasyTeam = {}

    $http.get(APP_CONSTANTS.apiUrl+'/fantasy_leagues/'+$stateParams.fantasyLeagueId)
    .success (data) ->
      $scope.fantasyLeague = data

      $http.get(APP_CONSTANTS.apiUrl+'/fantasy_leagues/'+$stateParams.fantasyLeagueId+'/fantasy_teams')
      .success (data) ->
        $scope.fantasyLeague.fantasyTeams = data

    $scope.createFantasyTeam = () ->
      $http.post(APP_CONSTANTS.apiUrl+'/fantasy_leagues/'+$stateParams.fantasyLeagueId+'/fantasy_teams', $scope.newFantasyTeam)
      .success (data) ->
        flashService.success 'Team has been created!'
        $scope.fantasyLeague.fantasyTeams.push(data)
        $scope.newFantasyTeam = {}
      .error (data) ->
        flashService.error 'Name can\'t be blank'

    $scope.editFantasyTeam = () ->
      $http.put(APP_CONSTANTS.apiUrl+'/fantasy_leagues/'+$stateParams.fantasyLeagueId+'/fantasy_teams/'+$scope.updateFantasyTeam.id, $scope.updateFantasyTeam)
      .success (data) ->
        flashService.success 'Team has been updated!'
      .error (data) ->
        flashService.error 'Name can\'t be blank'

      $scope.updateFantasyTeam = {}



    $scope.setUpdateFantasyTeam = (fantasyTeam) ->
      $scope.updateFantasyTeam = fantasyTeam

