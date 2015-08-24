appModule = angular.module 'fantasyDraftHub',
  ['LocalStorageModule', 'ngSanitize', 'ui.router', 'ui.utils', 'ui.select', 'ui.sortable', 'flash', 'angular-repeat-n', 'doowb.angular-pusher', 'ngFitText', 'ui.bootstrap']

appModule.config ($stateProvider, $urlRouterProvider, $httpProvider, localStorageServiceProvider, PusherServiceProvider) ->

  $stateProvider
  .state 'login',
    url: '/login'
    templateUrl: '/views/login.html'
    controller: 'loginController'

  .state 'register',
    url: '/register'
    templateUrl: '/views/register.html'
    controller: 'registerController'

  .state 'logout',
    url: '/logout'
    controller: 'logoutController'
    templateUrl: '/views/login.html'

  .state 'draft',
    url: '/draft/:url'
    templateUrl: 'views/draft.html'
    controller: 'draftController'

  .state 'auth',
    abstract: true
    url: '/hub'
    templateUrl: '/views/auth.html'
    controller: 'authController'
    data:
      requireLogin: true

  .state 'auth.fantasy-drafts',
    url: '/fantasy-drafts'
    templateUrl: 'views/fantasy-drafts.html'
    controller: 'fantasyDraftsController'

  .state 'auth.fantasy-draft',
    url: '/fantasy-drafts/:fantasyDraftId'
    templateUrl: 'views/fantasy-draft.html'
    controller: 'fantasyDraftController'

  .state 'auth.fantasy-teams',
    url: '/fantasy-teams/:fantasyDraftId'
    templateUrl: 'views/fantasy-teams.html'
    controller: 'fantasyTeamsController'

  $httpProvider.interceptors.push('authRedirector')
  $httpProvider.interceptors.push('authInterceptor')
  $httpProvider.interceptors.push('snakeJsonToCamelCasing')

  PusherServiceProvider.setToken('a85a38516f6db88b62ae').setOptions({})

  localStorageServiceProvider.setPrefix('fantasyDraftHub')

  $urlRouterProvider.otherwise('/hub/fantasy-drafts');


appModule.run ($rootScope, $state, authService, sessionService, flashService, routeChangeQueue) ->

  $rootScope.$on '$stateChangeStart', (evt, toState, toParams) ->
    if toState.name == 'draft'
      $rootScope.draftBoard = true
    else
      $rootScope.draftBoard = false

    if toState.data and toState.data.requireLogin
      if !authService.isLoggedIn()
        evt.preventDefault()
        $state.go('login')
      else

        # if toState.data.requirePermission

        if toState.data.requirePermission
          unless sessionService.hasPermission(toState.data.requirePermission)
            evt.preventDefault()
            flashService.error "You don't have permission to access this page"
            $state.go('auth.fantasy-drafts')



  $rootScope.$on '$stateChangeSuccess', (evt, to, params) ->
    flashService.clear()
    queue = routeChangeQueue.flush()
    func() for func in queue