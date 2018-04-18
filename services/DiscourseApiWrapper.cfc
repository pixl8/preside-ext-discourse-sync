/**
 * @singleton
 * @presideService
 */
component {

// CONSTRUCTOR
	public any function init() {
		return this;
	}

// PUBLIC API METHODS
	public array function getAllCategories() {
		var result = _apiCall( "site" );

		return result.categories ?: [];
	}

	public array function getTopicsForCategory( required numeric categoryId ) {
		var topics      = [];
		var page        = 0;
		var result      = "";
		var topicsToAdd = [];
		var userMapping = {};
		var users       = [];

		do {
			result      = _apiCall( uri="c/#arguments.categoryId#", params={ page=page++ } );
			topicsToAdd = result.topic_list.topics ?: [];
			users       = result.users ?: [];

			for( var user in users ) {
				userMapping[ user.id ] = user;
			}

			for( var topic in topicsToAdd ) {
				var posters = topic.posters ?: [];

				for( var poster in posters ) {
					if ( ( poster.description ) contains "Original Poster" ) {
						topic.author = userMapping[ poster.user_id ].username;

						break;
					}
				}
			}

			topics.append( topicsToAdd, true );

		} while( topicsToAdd.len() );

		return topics;
	}

	public struct function getTopic( required numeric topicId ) {
		return _apiCall( "t/#arguments.topicId#" );
	}

	public struct function getUser( required string username ) {
		var result = _apiCall( "users/#arguments.userName#" );

		return result.user ?: {};
	}

// PRIVATE HELPERS
	private any function _apiCall( required string uri, string method="GET", struct params={} ) {
		var httpResponse = "";
		var settings     = _getSettings();
		var callUrl      = _buildApiCallUrl( settings.discourse_url, arguments.uri );
		var paramType    = _getParamType( arguments.method );

		http url=callUrl method="#arguments.method#" timeout=30 result="httpResponse" {
			httpparam name="api_username" type=paramType value=settings.username;
			httpparam name="api_key"      type=paramType value=settings.api_key;

			for( var paramName in arguments.params ) {
				httpparam name=paramName type=paramType value=arguments.params[ paramName ];
			}
		}

		return _processResponse( httpResponse );
	}

	private struct function _getSettings() {
		var settings = $getPresideCategorySettings( "discourse-sync-api-credentials" );

		return {
			  discourse_url = settings.discourse_url ?: ""
			, username      = settings.username      ?: ""
			, api_key       = settings.api_key       ?: ""
		};
	}

	private string function _buildApiCallUrl( required string rootUrl, required string uri ) {
		var apiCallUrl = rootUrl.reReplace( "/$", "" ) & "/" & uri.reReplace( "^/", "" );

		return apiCallUrl.findNoCase( "\.json$" ) ? apiCallUrl : apiCallUrl & ".json";
	}

	private string function _getParamType( required string httpMethod ) {
		 return arguments.httpMethod == "GET" ? "url" : "formfield";
	}

	private any function _processResponse( required struct httpResponse ) {
		var parsedResponse = {};

		try {
			parsedResponse = DeserializeJson( httpResponse.filecontent );
		} catch( any e ) {
			throw(
				  type     = "preside.discourse.bad.api.response"
				, messsage = "Unexpected response from Discourse API. Expected valid json response. See detail for actual response"
				, detail   = ( httpResponse.fileContent ?: "" )
			);
		}

		var responseCode = Val( arguments.httpResponse.status_code ?: "" );
		if ( responseCode != 200 ) {
			var errorMessage = ArrayToList( parsedResponse.errors ?: [], " " );

			throw(
				  errorcode = responseCode
				, type      = "preside.discourse.api.call.failure"
				, message   = "#responseCode# error. #errorMessage#"
			);
		}

		return parsedResponse;
	}
}