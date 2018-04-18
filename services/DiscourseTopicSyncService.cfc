/**
 * @singleton
 * @presideService
 */
component {

// CONSTRUCTOR
	/**
	 * @discourseApiWrapper.inject discourseApiWrapper
	 *
	 */
	public any function init( required any discourseApiWrapper ) {
		_setDiscourseApiWrapper( arguments.discourseApiWrapper );

		return this;
	}

// PUBLIC API METHODS
	public boolean function syncCategories( any logger ) {
		var canLog  = StructKeyExists( arguments, "logger" );
		var canInfo = canLog && logger.canInfo();

		var newCategoryIds     = [];
		var categoriesToDelete = [];
		var newCategories      = _getDiscourseApiWrapper().getAllCategories();
		var categoryDao        = $getPresideObject( "discourse_category" );
		var existingCategories = categoryDao.selectData( selectFields=[ "id" ] );
		    existingCategories = ValueArray( existingCategories.id );

		if ( canInfo ) { logger.info( "[#newCategories.len()#] fetched from Discourse. Syncing now..." ) }

		for( var category in newCategories ) {
			category.parent_category = category.parent_category_id ?: "";

			if ( existingCategories.find( category.id ) ) {
				categoryDao.updateData( id=category.id, data=category );
			} else {
				categoryDao.insertData( data=category );
			}

			newCategoryIds.append( category.id );
		}

		if ( canInfo ) { logger.info( "Done." ) }

		if ( newCategoryIds.len() ) {
			for( var categoryId in existingCategories ) {
				if ( !newCategoryIds.find( categoryId ) ) {
					categoriesToDelete.append( categoryId );
				}
			}

			if ( categoriesToDelete.len() ) {
				if ( canInfo ) { logger.info( "Deleting [#categoriesToDelete.len()#] categories that no longer exist in Discourse..." ) }

				categoryDao.deleteData( filter={ id=categoriesToDelete } );

				if ( canInfo ) { logger.info( "Done." ) }
			}
		}

		return true;
	}

	public boolean function syncTopics( any logger ) {
		var canLog              = StructKeyExists( arguments, "logger" );
		var canInfo             = canLog && logger.canInfo();
		var canError            = canLog && logger.canError();
		var categoryFilter      = ListToArray( $getPresideSetting( "discourse-sync-api-credentials", "categories" ) );
		var baseUrl             = $getPresideSetting( "discourse-sync-api-credentials", "discourse_url" );
		var topicDao            = $getPresideObject( "discourse_topic" );
		var filter              = {};
		var topicsFromDiscourse = [];
		var topicsToDelete      = [];
		var existingTopics      = topicDao.selectData( selectFields=[ "id" ] );
		    existingTopics      = ValueArray( existingTopics.id );

		if ( categoryFilter.len() ) {
			filter.id = categoryFilter;
		}

		var categories = $getPresideObject( "discourse_category" ).selectData( filter=filter, savedFilters=[ "topLevelDiscourseCategories" ] );

		if ( !categories.recordCount ) {
			if ( canError ) { logger.error( "No categories setup to sync topics from!" ); }
			return false;
		}

		if ( canInfo ) { logger.info( "Syncing topics for [#categories.recordCount#] #( categories.recordCount == 1 ? 'category' : 'categories' )#..." ); }
		for( var category in categories ) {
			if ( canInfo ) { logger.info( "Syncing topics for category: [#category.name#]..." ); }

			var topics = _getDiscourseApiWrapper().getTopicsForCategory( category.id );

			if ( canInfo ) { logger.info( "Fetched [#NumberFormat( topics.len() )#] topics from Discourse. Syncing now..." ); }

			for( var topic in topics ) {
				var topicToSave = {
					  id              = topic.id          ?: ""
					, title           = topic.title       ?: ""
					, excerpt         = topic.excerpt     ?: ""
					, liked           = topic.liked       ?: false
					, views           = topic.views       ?: 0
					, posts_count     = topic.posts_count ?: 0
					, reply_count     = topic.reply_count ?: 0
					, like_count      = topic.like_count  ?: 0
					, category        = topic.category_id ?: ""
					, visible         = topic.visible     ?: false
					, topic_url       = baseUrl & "/t/#topic.slug#"
					, image_url       = Len( Trim( topic.image_url ?: "" ) ) ? baseUrl & topic.image_url : ""
					, created_at      = _parseDateTime( topic.created_at     ?: "" )
					, last_posted_at  = _parseDateTime( topic.last_posted_at ?: "" )
					, author          = _getAndSyncAuthorIdFromUserName( topic.author )
				};

				try {
					var fullTopicDetail = _getDiscourseApiWrapper().getTopic( topic.id ?: "" );
				} catch( any e ) {
					if ( canError ) {
						logger.error( "Error fetching full topic details for topic, [#topicToSave.title#]. See following log for error details. The topic has not been saved." );
						logger.error( e );
					}
					continue;
				}

				topicToSave.append( _extractFieldsFromFullTopic( fullTopicDetail ) );

				topicsFromDiscourse.append( topic.id );

				if ( existingTopics.find( topicToSave.id ) ) {
					topicDao.updateData( id=topicToSave.id, data=topicToSave );
				} else {
					topicDao.insertData( data=topicToSave );
				}
				if ( canInfo ) { logger.info( "Synced topic: [#topicToSave.title#]." ); }
			}

			if ( canInfo ) { logger.info( "Finished syncing category: [#category.name#]." ); }
		}

		for( var topic in existingTopics ) {
			if ( !topicsFromDiscourse.find( topic ) ) {
				topicsToDelete.append( topic );
			}
		}

		if ( topicsToDelete.len() ) {
			if ( canInfo ) { logger.info( "Deleting [#topicsToDelete.len()#] topic(s) that are no longer listed in Discourse." ); }
			topicDao.deleteData( filter={ id=topicsToDelete } );
			if ( canInfo ) { logger.info( "Finished deleting topics." ); }
		}

		if ( canInfo ) { logger.info( "All done!" ); }

		return true;
	}

// PRIVATE HELPERS
	private any function _getAndSyncAuthorIdFromUserName( required string username ) {
		request._discourseSyncedUsers = request._discourseSyncedUsers ?: {};

		if ( request._discourseSyncedUsers.keyExists( arguments.userName ) ) {
			return request._discourseSyncedUsers[ arguments.username ];
		}

		var baseUrl = $getPresideSetting( "discourse-sync-api-credentials", "discourse_url" );
		var user    = _getDiscourseApiWrapper().getUser( arguments.userName );

		if ( user.count() ) {
			request._discourseSyncedUsers[ arguments.username ] = user.id;

			if ( $getPresideObject( "discourse_user" ).dataExists( id=user.id ) ) {
				$getPresideObject( "discourse_user" ).updateData( id=user.id, data={
					  name            = user.name            ?: ""
					, username        = user.username        ?: ""
					, avatar_template = baseUrl & ( user.avatar_template ?: "" )
					, post_count      = user.post_count      ?: 0
				} );
			} else {
				$getPresideObject( "discourse_user" ).insertData( data={
					  id              = user.id              ?: ""
					, name            = user.name            ?: ""
					, username        = user.username        ?: ""
					, avatar_template = baseUrl & ( user.avatar_template ?: "" )
					, post_count      = user.post_count      ?: 0
				} );
			}

			return user.id;
		}

		return "";
	}

	private any function _parseDateTime( required string input ) {
		var dateTime = arguments.input.reReplace( "Z$", "" );

		return IsDate( dateTime ) ? dateTime : "";
	}

	private struct function _extractFieldsFromFullTopic( required struct fullTopicDetail ) {
		return {
			  full_content = fullTopicDetail.post_stream.posts[ 1 ].cooked ?: ""
			, score        = Val( fullTopicDetail.post_stream.posts[ 1 ].score ?: "" )
		};

	}

// GETTERS AND SETTERS
	private any function _getDiscourseApiWrapper() {
		return _discourseApiWrapper;
	}
	private void function _setDiscourseApiWrapper( required any discourseApiWrapper ) {
		_discourseApiWrapper = arguments.discourseApiWrapper;
	}
}