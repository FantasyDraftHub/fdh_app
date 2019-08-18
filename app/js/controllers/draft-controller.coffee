angular.module 'fantasyDraftHub'
  .controller 'draftController', ($scope, $state, $stateParams, $http, APP_CONSTANTS, Pusher) ->
    $scope.enableFantasyBoard = true
    $scope.loading = true
    $scope.fantasyDraft = {}
    $scope.fantasyTeams = []
    $scope.fantasyDraftPicks = []
    $scope.players = []
    $scope.player = {}
    $scope.fantasyDraftBoardPusherChannel = null
    $scope.teamThatsUp = {}
    $scope.currentRound = 1

    $scope.init = ->
      $scope.loadPlayers().then ->
        $scope.loadDraftBoard().then ->
          $scope.buildFantasyDraftPicks()
          $scope.whosPick()

          $scope.loading = false

          Pusher.subscribe 'fantasy-draft-board-'+$scope.fantasyDraft.id, 'new-draft-pick', (data) ->
            data = humps.camelizeKeys(data)
            $scope.fantasyDraftPicks.push(data)
            $scope.buildFantasyDraftPicks()
            $scope.player = {}


          Pusher.subscribe 'fantasy-draft-board-'+$scope.fantasyDraft.id, 'edit-draft-pick', (data) ->
            data = humps.camelizeKeys(data)
            $scope.fantasyDraftPicks.forEach (fantasyDraftPick, index) ->
              if fantasyDraftPick.id == data.id
                $scope.fantasyDraftPicks[index] = data

            $scope.buildFantasyDraftPicks()

          Pusher.subscribe 'fantasy-draft-board-'+$scope.fantasyDraft.id, 'destroy-draft-pick', (data) ->
            data = humps.camelizeKeys(data)
            $scope.fantasyDraftPicks.forEach (fantasyDraftPick, index) ->
              if fantasyDraftPick.id == data.id
                $scope.fantasyDraftPicks.splice(index,1)

            $scope.buildFantasyDraftPicks()

          Pusher.subscribe 'fantasy-draft-board-'+$scope.fantasyDraft.id, 'draft-update', (data) ->
            data = humps.camelizeKeys(data)

            $scope.fantasyDraft = data
            if data.playerId
              $scope.player = $scope.findPlayerById(data.playerId)
            else
              $scope.player = {}

          Pusher.subscribe 'fantasy-draft-board-'+$scope.fantasyDraft.id, 'set-team-thats-up', (fantasyTeamId) ->
            $scope.teamThatsUp = $scope.findFantasyTeamById(fantasyTeamId)

    $scope.loadPlayers = ->
      $http.get(APP_CONSTANTS.apiUrl+'/leagues/1/players')
      .success (data) ->
        $scope.players = data

    $scope.loadDraftBoard = ->
      $http.get(APP_CONSTANTS.apiUrl+'/fantasy_drafts/'+$stateParams.url+'/'+$scope.password)
      .success (data) ->
        $scope.fantasyDraft = data
        $scope.fantasyTeams = data.fantasyTeams
        $scope.fantasyDraftPicks = data.fantasyDraftPicks

        $scope.player = $scope.findPlayerById(data.playerId)

    $scope.findPlayerById = (playerId) ->
      $scope.players.find (player) ->
        parseInt(player.id) == parseInt(playerId)

    $scope.findFantasyTeamById = (fantasyTeamId) ->
      $scope.fantasyTeams.find (fantasyTeam) ->
        parseInt(fantasyTeam.id) == parseInt(fantasyTeamId)

    $scope.buildFantasyDraftPicks = ->
      $scope.fantasyTeams.forEach (fantasyTeam, fantasyTeamIndex) ->
        $scope.fantasyTeams[fantasyTeamIndex].fantasyDraftPicks = []
        $scope.fantasyDraftPicks.forEach (fantasyDraftPick, index) ->
          if fantasyDraftPick.fantasyTeamId == fantasyTeam.id
            fantasyDraftPick.player = $scope.findPlayerById(parseInt(fantasyDraftPick.playerId))
            $scope.fantasyTeams[fantasyTeamIndex].fantasyDraftPicks.push(fantasyDraftPick)

    $scope.calculateTeamTotalSpent = (fantasyTeam) ->
      total_spent = 0
      fantasyTeam.fantasyDraftPicks.forEach (fantasyDraftPick, index) ->
        total_spent += fantasyDraftPick.price
        return
      total_spent

    $scope.calculateMaxBid = (fantasyTeam) ->
      totalTeamSpent = $scope.calculateTeamTotalSpent(fantasyTeam)
      if totalTeamSpent == $scope.fantasyDraft.max
        0
      else
        ($scope.fantasyDraft.max - $scope.calculateTeamTotalSpent(fantasyTeam) - ($scope.fantasyDraft.rounds - fantasyTeam.fantasyDraftPicks.length)) + 1

    $scope.whosPick = ->
      $scope.teamThatsUp = $scope.findFantasyTeamById($scope.fantasyDraft.fantasyTeamId)

    $scope.calculateColumnWidth = ->
      (100 / $scope.fantasyTeams.length)+'%'

    $scope.isDraftOver = ->
      $scope.fantasyDraftPicks.length == ($scope.fantasyDraft.rounds * $scope.fantasyTeams.length)

    if $scope.enableFantasyBoard
      $scope.init()



