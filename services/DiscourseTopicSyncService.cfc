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


// GETTERS AND SETTERS
	private any function _getDiscourseApiWrapper() {
		return _discourseApiWrapper;
	}
	private void function _setDiscourseApiWrapper( required any discourseApiWrapper ) {
		_discourseApiWrapper = arguments.discourseApiWrapper;
	}
}