'use strict';

angular.module('tdpharmaClientApp', [
  'templates',
  'ngCookies',
  'ngResource',
  'ngSanitize',
  'btford.socket-io',
  'ui.router',
  'ui.bootstrap',
  'smart-table',
  'ui.select',
  'pascalprecht.translate',
  'ngFileUpload'
]).config(function ($stateProvider, $urlRouterProvider, $locationProvider, $httpProvider) {
      $urlRouterProvider.otherwise('/');
      $httpProvider.interceptors.push('authInterceptor');
    })
    .constant('toastr', toastr)
    .config(toastrConfig)
    .config(RouteConfig)
    .factory('authInterceptor', function ($rootScope, $q, $cookies, $location) {
      return {
        // Add authorization token to headers
        request: function (config) {
          config.headers = config.headers || {};
          if ($cookies.get('token')) {
            config.headers.Authorization = 'Bearer ' + $cookies.get('token');
          }
          return config;
        },

        response: function(response) {
          if (response.data instanceof Object && response.data.authentication_token) {
            $cookies.put('token', response.data.authentication_token);
          }
          return $q.resolve(response);
        },

        // Intercept 401s and redirect you to login
        responseError: function(response) {
          if(response.status === 401) {
            $location.path('/login');
            // remove any stale tokens
            $cookies.remove('token');
            return $q.reject(response);
          }
          else {
            return $q.reject(response);
          }
        }
      };
    });


toastrConfig.$inject = ['toastr'];

function toastrConfig(toastr) {
  toastr.options.timeOut = 4000;
  toastr.options.closeButton = true;
  toastr.options.positionClass = 'toast-custom-top-right';
}


RouteConfig.$inject = ['$stateProvider'];

function RouteConfig($stateProvider){
  $stateProvider
      .state('signup', {
        url: '/signup',
        templateUrl: 'features/account/signup.html',
        controller: 'SignupCtrl'
      })
      .state('settings', {
        url: '/settings',
        templateUrl: 'features/account/settings.html',
        controller: 'SettingsCtrl'
      });
}

