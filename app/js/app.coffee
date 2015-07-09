appModule = angular.module 'fantasyDraftHub',
  ['ngAnimate', 'LocalStorageModule', 'ngSanitize', 'ui.router', 'ui.utils', 'ui.select', 'ui.sortable', 'flash']

appModule.config ($stateProvider, $urlRouterProvider, $httpProvider, localStorageServiceProvider) ->

  $stateProvider
  .state 'login',
    url: '/login'
    templateUrl: '/views/login.html'
    controller: 'loginController'

  .state 'logout',
    url: '/logout'
    controller: 'logoutController'
    templateUrl: '/views/login.html'

  .state 'auth',
    abstract: true
    url: '/hub'
    templateUrl: '/views/auth.html'
    controller: 'authController'
    data:
      requireLogin: true

  .state 'auth.dashboard',
    url: '/dashboard'
    templateUrl: 'views/dashboard.html'
    controller: 'dashboardController'

  .state 'auth.fantasy-league',
    url: '/fantasy-league/:fantasyLeagueId'
    templateUrl: 'views/fantasy-league.html'
    controller: 'fantasyLeagueController'



  $httpProvider.interceptors.push('authRedirector')
  $httpProvider.interceptors.push('authInterceptor')
  $httpProvider.interceptors.push('snakeJsonToCamelCasing')

  localStorageServiceProvider.setPrefix('fantasyDraftHub')

  $urlRouterProvider.otherwise('/hub/dashboard');

appModule.run ($rootScope, $state, authService, sessionService, flashService, routeChangeQueue) ->

  $rootScope.$on '$stateChangeStart', (evt, toState, toParams) ->
    if toState.data and toState.data.requireLogin
      if !authService.isLoggedIn()
        evt.preventDefault()
        $state.go('login')
      else
        if toState.data.requirePermission
          unless sessionService.hasPermission(toState.data.requirePermission)
            evt.preventDefault()
            flashService.error "You don't have permission to access this page"
            $state.go('auth.dashboard')

  $rootScope.$on '$stateChangeSuccess', (evt, to, params) ->
    flashService.clear()
    queue = routeChangeQueue.flush()
    func() for func in queue